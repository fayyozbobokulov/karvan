import {
  proxyActivities,
  defineSignal,
  defineQuery,
  setHandler,
  condition,
} from '@temporalio/workflow';

// ── Types ────────────────────────────────────────────────────────────────────

interface FlowNode {
  id: string;
  unit: string;
  label: string;
  config?: Record<string, any>;
  next: string[] | Record<string, string[]>;
  isTerminal?: boolean;
  isError?: boolean;
  isLoop?: boolean;
}

interface FlowContext {
  roleAssignments: Record<string, string>;
  variables: Record<string, any>;
  completedNodes: string[];
  nodeOutputs: Record<string, any>;
  activeNodes: string[];
}

interface FlowInput {
  flowInstanceId: string;
  flowDefinitionId: string;
  graph: FlowNode[];
  context: FlowContext;
}

interface FlowStatus {
  flowInstanceId: string;
  status: string;
  activeNodes: string[];
  completedNodes: string[];
  history: Array<{
    nodeId: string;
    label: string;
    unitType: string;
    status: string;
    timestamp: string;
  }>;
}

interface HumanDecision {
  nodeId: string;
  action: string;
  comment?: string;
  data?: Record<string, any>;
}

// ── Signals ──────────────────────────────────────────────────────────────────

export const humanDecisionSignal =
  defineSignal<[HumanDecision]>('humanDecision');

// ── Queries ──────────────────────────────────────────────────────────────────

export const getFlowStatusQuery = defineQuery<FlowStatus>('getFlowStatus');

// ── Activities ───────────────────────────────────────────────────────────────

// Import activity types for type-safe proxying
import type * as unitActivities from '../activities/unit.activities';

const act = proxyActivities<typeof unitActivities>({
  startToCloseTimeout: '10 minutes',
  retry: { maximumAttempts: 3 },
});

// ═══════════════════════════════════════════════════════════════════════════════
// MAIN WORKFLOW — The Generic Graph Executor
// ═══════════════════════════════════════════════════════════════════════════════

export async function executeFlowGraph(input: FlowInput) {
  const { flowInstanceId, graph } = input;
  const ctx: FlowContext = {
    roleAssignments: { ...input.context.roleAssignments },
    variables: { ...input.context.variables },
    completedNodes: [...(input.context.completedNodes || [])],
    nodeOutputs: { ...(input.context.nodeOutputs || {}) },
    activeNodes: [...(input.context.activeNodes || [])],
  };

  const history: FlowStatus['history'] = [];
  let overallStatus = 'running';

  // Lookup helper
  const getNode = (id: string): FlowNode | undefined =>
    graph.find((n) => n.id === id);

  // Signal storage — human decisions arrive here
  const pendingDecisions: Map<string, HumanDecision> = new Map();

  setHandler(humanDecisionSignal, (decision: HumanDecision) => {
    pendingDecisions.set(decision.nodeId, decision);
  });

  // Query handler — UI can ask for current state anytime
  setHandler(
    getFlowStatusQuery,
    (): FlowStatus => ({
      flowInstanceId,
      status: overallStatus,
      activeNodes: [...ctx.activeNodes],
      completedNodes: [...ctx.completedNodes],
      history: [...history],
    }),
  );

  // ── Core: Execute a single node ──────────────────────────────────────────

  async function executeNode(nodeId: string): Promise<void> {
    const node = getNode(nodeId);
    if (!node) throw new Error(`Node ${nodeId} not found in graph`);

    // Load unit definition
    const unitDef = await act.loadUnitDefinition({ unitId: node.unit });

    // Merge configs: unit default config + node-level overrides
    const mergedConfig = {
      ...((unitDef.config as Record<string, any>) || {}),
      ...(node.config || {}),
    };

    // Create unit instance record
    const unitInstanceId = await act.createUnitInstance({
      flowInstanceId,
      unitDefinitionId: node.unit,
      nodeId: node.id,
      config: mergedConfig,
    });

    // Track as active
    ctx.activeNodes = [...ctx.activeNodes.filter((n) => n !== nodeId), nodeId];
    await act.updateFlowInstance({
      flowInstanceId,
      currentNodeIds: ctx.activeNodes,
    });

    history.push({
      nodeId,
      label: node.label,
      unitType: unitDef.type,
      status: 'started',
      timestamp: new Date().toISOString(),
    });

    let result: any;

    // ── TYPE-SPECIFIC EXECUTION ──────────────────────────────────────────

    switch (unitDef.type) {
      case 'DOCUMENT': {
        result = await act.executeDocumentUnit({
          unitInstanceId,
          flowInstanceId,
          config: mergedConfig,
          context: ctx,
        });
        break;
      }

      case 'ACTION': {
        // Determine assignee from config + role assignments
        const assigneeRole = mergedConfig.assignee;
        const assigneeId = assigneeRole
          ? ctx.roleAssignments[assigneeRole] || ''
          : '';

        await act.activateActionUnit({
          unitInstanceId,
          assigneeId,
          flowInstanceId,
          allowedActions: mergedConfig.allowedActions || [],
        });

        // Update flow status to waiting
        overallStatus = 'waiting';

        // PAUSE — wait for human signal
        const timeoutMs = parseTimeout(mergedConfig.timeout || '168h');

        const signalReceived = await condition(
          () => pendingDecisions.has(nodeId),
          timeoutMs,
        );

        overallStatus = 'running';

        if (!signalReceived) {
          result = { action: 'TIMEOUT' };
          await act.handleTimeout({
            unitInstanceId,
            flowInstanceId,
            nodeId,
          });
        } else {
          result = pendingDecisions.get(nodeId)!;
          pendingDecisions.delete(nodeId);
        }

        await act.completeActionUnit({
          unitInstanceId,
          action: result.action,
          comment: result.comment,
        });
        break;
      }

      case 'TASK': {
        const assigneeRole = mergedConfig.assignee;
        const assigneeId = assigneeRole
          ? ctx.roleAssignments[assigneeRole] || ''
          : '';

        await act.activateTaskUnit({
          unitInstanceId,
          assigneeId,
          flowInstanceId,
          instructions: node.label,
        });

        overallStatus = 'waiting';

        const timeoutMs = parseTimeout(mergedConfig.deadline || '72h');

        const signalReceived = await condition(
          () => pendingDecisions.has(nodeId),
          timeoutMs,
        );

        overallStatus = 'running';

        if (!signalReceived) {
          result = { action: 'TIMEOUT' };
          await act.handleTimeout({
            unitInstanceId,
            flowInstanceId,
            nodeId,
          });
        } else {
          result = pendingDecisions.get(nodeId)!;
          pendingDecisions.delete(nodeId);
        }

        await act.completeTaskUnit({
          unitInstanceId,
          result: result,
        });
        break;
      }

      case 'CONDITION': {
        result = await act.evaluateCondition({
          unitInstanceId,
          flowInstanceId,
          expression: (mergedConfig.expression as string) || '',
          context: ctx,
        });
        // result = { branch: "true" } or { branch: "SIGN" } etc.
        break;
      }

      case 'NOTIFICATION': {
        const recipientRole = mergedConfig.recipients;
        const recipientId = recipientRole
          ? ctx.roleAssignments[recipientRole] || ''
          : '';

        result = await act.sendNotification({
          unitInstanceId,
          recipientId,
          flowInstanceId,
          channel: mergedConfig.channel || ['portal'],
          message: mergedConfig.message || node.label,
        });
        break;
      }

      case 'AUTOMATION': {
        result = await act.executeAutomation({
          unitInstanceId,
          flowInstanceId,
          handler: mergedConfig.handler as string,
          config: mergedConfig,
          context: ctx,
        });
        break;
      }

      case 'PARALLEL': {
        // Parallel just marks the fork point.
        // The next resolution handles the actual forking.
        await act.updateUnitInstance({
          unitInstanceId,
          status: 'completed',
          output: { forked: true },
        });
        result = { forked: true };
        break;
      }

      case 'GATE': {
        // Gate just marks convergence. The parallel handler waits for all
        // branches before advancing past the gate.
        await act.updateUnitInstance({
          unitInstanceId,
          status: 'completed',
          output: { gateReached: true },
        });
        result = { gateReached: true };
        break;
      }
    }

    // ── Record completion ────────────────────────────────────────────────

    ctx.completedNodes.push(nodeId);
    ctx.nodeOutputs[nodeId] = result;
    ctx.activeNodes = ctx.activeNodes.filter((n) => n !== nodeId);

    history.push({
      nodeId,
      label: node.label,
      unitType: unitDef.type,
      status: 'completed',
      timestamp: new Date().toISOString(),
    });

    await act.recordAuditEntry({
      flowInstanceId,
      unitInstanceId,
      actorId: null,
      action: result?.action || 'COMPLETE',
      details: result,
    });

    // ── Resolve next nodes ───────────────────────────────────────────────

    let nextNodeIds: string[] = [];

    if (Array.isArray(node.next)) {
      nextNodeIds = node.next;
    } else if (typeof node.next === 'object' && node.next !== null) {
      // Branch resolution — match by branch key or action
      const branchKey = result?.branch || result?.action || 'default';
      nextNodeIds =
        (node.next as Record<string, string[]>)[branchKey] ||
        (node.next as Record<string, string[]>)['default'] ||
        [];
    }

    if (nextNodeIds.length === 0) {
      // Terminal node — this branch is done
      return;
    }

    // ── Handle PARALLEL forking ──────────────────────────────────────────

    if (unitDef.type === 'PARALLEL' && nextNodeIds.length > 1) {
      // Find the GATE node that these branches converge on
      const gateNodeId = findConvergenceGate(graph, nextNodeIds);

      // Execute all branches in parallel
      const branchPromises = nextNodeIds.map((nid) => executeNode(nid));
      await Promise.all(branchPromises);

      // After all branches complete, continue from gate
      if (gateNodeId) {
        await executeNode(gateNodeId);
      }
      return;
    }

    // ── Sequential next ──────────────────────────────────────────────────

    for (const nextId of nextNodeIds) {
      const nextNode = getNode(nextId);

      // Handle loop-back
      if (nextNode?.isLoop || ctx.completedNodes.includes(nextId)) {
        // Reset the loop target and all downstream nodes
        ctx.completedNodes = ctx.completedNodes.filter(
          (n) => !isDownstream(graph, nextId, n) && n !== nextId,
        );
        // Clear outputs for reset nodes
        for (const resetNode of [...ctx.completedNodes]) {
          if (isDownstream(graph, nextId, resetNode)) {
            delete ctx.nodeOutputs[resetNode];
          }
        }
      }

      await executeNode(nextId);
    }
  }

  // ── Start execution from root node ─────────────────────────────────────

  try {
    const rootNode = graph.find((n) => n.id === '1');
    if (!rootNode) throw new Error('Flow graph must have a node with id "1"');

    await executeNode('1');
    overallStatus = 'completed';
  } catch (error) {
    overallStatus = 'failed';
    throw error;
  } finally {
    await act.updateFlowInstance({
      flowInstanceId,
      status: overallStatus as any,
    });
  }

  return {
    status: overallStatus,
    completedNodes: ctx.completedNodes,
    outputs: ctx.nodeOutputs,
  };
}

// ═══════════════════════════════════════════════════════════════════════════════
// Helper Functions
// ═══════════════════════════════════════════════════════════════════════════════

/**
 * Find the GATE node that parallel branches converge on.
 * Walks each branch forward to find the first common target.
 */
function findConvergenceGate(
  graph: FlowNode[],
  branchStartIds: string[],
): string | null {
  const branchTargets = branchStartIds.map((id) => {
    const node = graph.find((n) => n.id === id);
    if (!node) return [];
    return Array.isArray(node.next)
      ? node.next
      : Object.values(node.next).flat();
  });

  if (branchTargets.length === 0) return null;

  // Find intersection of all branch targets
  const common = branchTargets.reduce((acc, targets) =>
    acc.filter((t) => targets.includes(t)),
  );

  return common[0] || null;
}

/**
 * Check if targetId is reachable from startId by walking the graph.
 */
function isDownstream(
  graph: FlowNode[],
  startId: string,
  targetId: string,
): boolean {
  const visited = new Set<string>();
  const queue = [startId];

  while (queue.length > 0) {
    const current = queue.shift()!;
    if (current === targetId) return true;
    if (visited.has(current)) continue;
    visited.add(current);

    const node = graph.find((n) => n.id === current);
    if (!node) continue;

    const nexts = Array.isArray(node.next)
      ? node.next
      : Object.values(node.next).flat();
    queue.push(...nexts);
  }

  return false;
}

/**
 * Parse a timeout string like "72h", "168h", "24h" into milliseconds.
 */
function parseTimeout(timeout: string): string {
  // Temporal condition() accepts duration strings directly
  // Return as-is since Temporal supports "72h", "48h", etc.
  return timeout;
}
