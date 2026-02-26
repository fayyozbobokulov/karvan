import { UnitTypeBadge } from "./UnitTypeBadge";

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

interface UnitInstanceInfo {
  nodeId: string;
  status: string;
  unitType: string;
  unitName: string;
  assigneeId?: string;
}

interface FlowGraphProps {
  graph: FlowNode[];
  unitInstances: UnitInstanceInfo[];
  activeNodes?: string[];
}

const NODE_HEIGHT = 52;
const NODE_WIDTH = 240;
const NODE_GAP_Y = 16;
const NODE_GAP_X = 300;

const STATUS_COLORS: Record<
  string,
  { border: string; bg: string; text: string }
> = {
  completed: { border: "#10b981", bg: "#ecfdf5", text: "#065f46" },
  active: { border: "#3b82f6", bg: "#eff6ff", text: "#1e40af" },
  pending: { border: "#e2e8f0", bg: "#f8fafc", text: "#64748b" },
  failed: { border: "#ef4444", bg: "#fef2f2", text: "#991b1b" },
  skipped: { border: "#cbd5e1", bg: "#f1f5f9", text: "#94a3b8" },
  cancelled: { border: "#cbd5e1", bg: "#f1f5f9", text: "#94a3b8" },
};

// Simple layout: assign columns using topological order
function layoutNodes(graph: FlowNode[]): Map<string, { x: number; y: number }> {
  const positions = new Map<string, { x: number; y: number }>();
  const visited = new Set<string>();
  const columns = new Map<string, number>();

  // Calculate column (depth) for each node using BFS
  function assignColumn(nodeId: string, col: number) {
    const existingCol = columns.get(nodeId);
    if (existingCol !== undefined && existingCol >= col) return;
    columns.set(nodeId, col);

    const node = graph.find((n) => n.id === nodeId);
    if (!node) return;

    const nextIds = Array.isArray(node.next)
      ? node.next
      : Object.values(node.next).flat();

    for (const nextId of nextIds) {
      assignColumn(nextId, col + 1);
    }
  }

  const rootNode = graph.find((n) => n.id === "1");
  if (rootNode) assignColumn("1", 0);

  // Also handle disconnected nodes
  for (const node of graph) {
    if (!columns.has(node.id)) {
      assignColumn(node.id, 0);
    }
  }

  // Group nodes by column
  const columnNodes = new Map<number, string[]>();
  for (const [nodeId, col] of columns) {
    const list = columnNodes.get(col) || [];
    list.push(nodeId);
    columnNodes.set(col, list);
  }

  // Position nodes
  for (const [col, nodeIds] of columnNodes) {
    nodeIds.forEach((nodeId, rowIdx) => {
      positions.set(nodeId, {
        x: col * NODE_GAP_X + 20,
        y: rowIdx * (NODE_HEIGHT + NODE_GAP_Y) + 20,
      });
    });
  }

  return positions;
}

export function FlowGraph({
  graph,
  unitInstances,
  activeNodes = [],
}: FlowGraphProps) {
  if (!graph || graph.length === 0) {
    return (
      <div
        className="text-muted"
        style={{ padding: "2rem", textAlign: "center" }}
      >
        No graph data
      </div>
    );
  }

  const positions = layoutNodes(graph);
  const instanceMap = new Map(unitInstances.map((u) => [u.nodeId, u]));

  // Calculate SVG dimensions
  let maxX = 0;
  let maxY = 0;
  for (const pos of positions.values()) {
    maxX = Math.max(maxX, pos.x + NODE_WIDTH + 40);
    maxY = Math.max(maxY, pos.y + NODE_HEIGHT + 40);
  }

  // Build edges
  const edges: Array<{ from: string; to: string; label?: string }> = [];
  for (const node of graph) {
    if (Array.isArray(node.next)) {
      for (const nextId of node.next) {
        edges.push({ from: node.id, to: nextId });
      }
    } else if (typeof node.next === "object") {
      for (const [label, targets] of Object.entries(node.next)) {
        for (const target of targets) {
          edges.push({ from: node.id, to: target, label });
        }
      }
    }
  }

  function getNodeStatus(nodeId: string): string {
    if (activeNodes.includes(nodeId)) return "active";
    const instance = instanceMap.get(nodeId);
    return instance?.status || "pending";
  }

  return (
    <div
      style={{
        overflow: "auto",
        border: "1px solid var(--border-color)",
        borderRadius: "8px",
        background: "var(--surface-color)",
      }}
    >
      <svg width={maxX} height={maxY} style={{ minWidth: "100%" }}>
        <defs>
          <marker
            id="arrowhead"
            markerWidth="8"
            markerHeight="6"
            refX="8"
            refY="3"
            orient="auto"
          >
            <polygon points="0 0, 8 3, 0 6" fill="#94a3b8" />
          </marker>
        </defs>

        {/* Edges */}
        {edges.map((edge, idx) => {
          const fromPos = positions.get(edge.from);
          const toPos = positions.get(edge.to);
          if (!fromPos || !toPos) return null;

          const x1 = fromPos.x + NODE_WIDTH;
          const y1 = fromPos.y + NODE_HEIGHT / 2;
          const x2 = toPos.x;
          const y2 = toPos.y + NODE_HEIGHT / 2;

          // Simple curved path
          const midX = (x1 + x2) / 2;

          return (
            <g key={`edge-${idx}`}>
              <path
                d={`M ${x1} ${y1} C ${midX} ${y1}, ${midX} ${y2}, ${x2} ${y2}`}
                fill="none"
                stroke="#94a3b8"
                strokeWidth="1.5"
                markerEnd="url(#arrowhead)"
              />
              {edge.label && (
                <text
                  x={midX}
                  y={Math.min(y1, y2) - 4}
                  textAnchor="middle"
                  fontSize="10"
                  fill="#64748b"
                  fontWeight="500"
                >
                  {edge.label}
                </text>
              )}
            </g>
          );
        })}

        {/* Nodes */}
        {graph.map((node) => {
          const pos = positions.get(node.id);
          if (!pos) return null;

          const status = getNodeStatus(node.id);
          const colors = STATUS_COLORS[status] || STATUS_COLORS.pending;
          const instance = instanceMap.get(node.id);
          const unitType = node.unit.split(":")[0].toUpperCase();

          // Map short prefix to full type
          const typeMap: Record<string, string> = {
            DOC: "DOCUMENT",
            ACTION: "ACTION",
            TASK: "TASK",
            COND: "CONDITION",
            NOTIFY: "NOTIFICATION",
            AUTO: "AUTOMATION",
            GATE: "GATE",
            PARALLEL: "PARALLEL",
          };
          const fullType = typeMap[unitType] || instance?.unitType || unitType;

          return (
            <g key={node.id}>
              {/* Node background */}
              <rect
                x={pos.x}
                y={pos.y}
                width={NODE_WIDTH}
                height={NODE_HEIGHT}
                rx="8"
                fill={colors.bg}
                stroke={colors.border}
                strokeWidth={status === "active" ? 2.5 : 1.5}
              />
              {/* Left type accent bar */}
              <rect
                x={pos.x}
                y={pos.y}
                width="4"
                height={NODE_HEIGHT}
                rx="2"
                fill={colors.border}
              />
              {/* Node ID */}
              <text
                x={pos.x + 12}
                y={pos.y + 16}
                fontSize="10"
                fill={colors.text}
                fontWeight="600"
                opacity={0.6}
              >
                #{node.id}
              </text>
              {/* Node label */}
              <text
                x={pos.x + 12}
                y={pos.y + 34}
                fontSize="12"
                fill={colors.text}
                fontWeight="500"
              >
                {node.label.length > 28
                  ? node.label.slice(0, 26) + "..."
                  : node.label}
              </text>
              {/* Status indicator */}
              {status === "active" && (
                <circle
                  cx={pos.x + NODE_WIDTH - 14}
                  cy={pos.y + NODE_HEIGHT / 2}
                  r="5"
                  fill="#3b82f6"
                >
                  <animate
                    attributeName="opacity"
                    values="1;0.3;1"
                    dur="1.5s"
                    repeatCount="indefinite"
                  />
                </circle>
              )}
              {status === "completed" && (
                <text
                  x={pos.x + NODE_WIDTH - 18}
                  y={pos.y + NODE_HEIGHT / 2 + 4}
                  fontSize="12"
                  fill="#10b981"
                >
                  ✓
                </text>
              )}
              {status === "failed" && (
                <text
                  x={pos.x + NODE_WIDTH - 18}
                  y={pos.y + NODE_HEIGHT / 2 + 4}
                  fontSize="12"
                  fill="#ef4444"
                >
                  ✗
                </text>
              )}
              {/* Terminal/error indicator */}
              {node.isError && (
                <rect
                  x={pos.x + NODE_WIDTH - 4}
                  y={pos.y}
                  width="4"
                  height={NODE_HEIGHT}
                  rx="2"
                  fill="#ef4444"
                />
              )}
            </g>
          );
        })}
      </svg>
    </div>
  );
}
