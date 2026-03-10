# Workflow Engine Developer Guide

This guide explains how the unit-based flow engine works and how to extend it.

## Architecture Overview

```
Dashboard (React)
    |  HTTP
    v
Main Server (NestJS, port 3001)  --Temporal Client-->  Temporal Server (localhost:7233)
    |                                                         |
    |  Drizzle ORM                                            | dispatches tasks
    v                                                         v
PostgreSQL (port 5433)  <---- Drizzle ORM ---- Workflow Engine (Temporal Worker, port 3002)
```

1. **Main Server** receives HTTP requests, writes to DB, and starts/signals Temporal workflows
2. **Temporal Server** orchestrates workflow execution, manages state, retries, and timeouts
3. **Workflow Engine** runs as a Temporal worker, picks up tasks from queues, executes workflow logic + activities that read/write the DB

---

## Core Concepts

### Unit Definitions (the building blocks)

A unit definition is a reusable, typed building block stored in the `unitDefinitions` table. Each one has:

- **An ID** using a `type:name` convention: `"doc:leave_request"`, `"action:sign"`, `"cond:amount_threshold"`
- **A type** (one of 8): determines how the executor runs it
- **A config** (JSON): type-specific defaults

The 8 unit types fall into 3 behavioral categories:

```
HUMAN-BLOCKING (pause workflow, wait for signal):
  +-- DOCUMENT     -- creates a doc record, waits for user to fill it in
  +-- ACTION       -- assigned to a person, waits for SIGN/APPROVE/REJECT
  +-- TASK         -- assigned to a person, waits for completion

INSTANT (execute and continue immediately):
  +-- CONDITION    -- evaluates an expression, returns a branch key
  +-- NOTIFICATION -- sends a notification
  +-- AUTOMATION   -- runs a named handler function

STRUCTURAL (control flow shape, no real logic):
  +-- PARALLEL     -- marks a fork point (branches run concurrently)
  +-- GATE         -- marks a join point (waits for all branches)
```

### Flow Definitions (the graph wiring blocks together)

A flow definition is a directed graph stored as a JSON array of nodes. Each node wires a unit into a specific position:

```typescript
{
  id: "6",                              // unique within this graph
  unit: "action:sign",                  // which unit definition to use
  label: "Main Signer Reviews",         // human-readable name
  config: { assignee: "head_signer" },  // OVERRIDES unit defaults
  next: ["7"]                           // edges: where to go after
}
```

**Key insight**: `unit` references a unit definition, but `config` on the node **merges over** the unit's default config. So `"action:sign"` has `allowedActions: ["SIGN", "REJECT", "REQUEST_CHANGE"]` by default, but a specific node can override `assignee` to point to different roles in different flows.

### How `next` Works: 3 Patterns

```typescript
// 1. SEQUENTIAL -- array of IDs, run one after another
next: ["7"]           // go to node 7
next: ["8", "9"]      // after a PARALLEL node: fork to 8 and 9

// 2. BRANCHING -- object keyed by result, for CONDITION/ACTION nodes
next: { "SIGN": ["8"], "REJECT": ["R1"], "REQUEST_CHANGE": ["RC1"] }
next: { "true": ["5"], "false": ["6"] }

// 3. TERMINAL -- empty array, this branch ends
next: []
```

### Definition vs Instance

```
unitDefinitions (catalog)          unitInstances (runtime)
+----------------------+          +----------------------------+
| id: "action:sign"    | <------- | unitDefinitionId           |
| type: ACTION         |  1:many  | nodeId: "6"                |
| config: {            |          | flowInstanceId: "abc-123"  |
|   allowedActions:    |          | status: active -> completed|
|     [SIGN,REJECT]    |          | assigneeId: "director-uuid"|
|   timeout: "168h"    |          | output: { action: "SIGN" } |
| }                    |          +----------------------------+
+----------------------+

flowDefinitions (template)         flowInstances (runtime)
+----------------------+          +----------------------------+
| id: "leave_request"  | <------- | flowDefinitionId           |
| graph: [             |  1:many  | temporalWorkflowId         |
|   { id:"1", ... },   |          | status: running -> completed|
|   { id:"2", ... },   |          | context: {                 |
|   ...                |          |   roleAssignments: {...}   |
| ]                    |          |   completedNodes: [1,2,3]  |
| roles: [initiator,   |          |   nodeOutputs: {...}       |
|   department_head]   |          | }                          |
+----------------------+          +----------------------------+
```

**Definitions** are templates (created once, reused forever). **Instances** are runtime records (created each time a flow runs).

---

## How the Graph Executor Works

File: `apps/workflow-engine/src/workflows/graph-executor.workflow.ts`

### Startup

```
Input: { flowInstanceId, graph, context: { roleAssignments, variables, ... } }
```

Sets up signal handlers (`humanDecision`, `cancelFlow`, `pauseFlow`, `resumeFlow`), query handler (`getFlowStatus`), starts at node `"1"`.

### For Each Node -- `executeNode(nodeId)`

```
Check cancelled? -> cancel all active units, return
Check paused?    -> block on condition(() => !paused)
                          |
Load unit definition from DB (e.g. "action:sign" -> type=ACTION, config={...})
                          |
Merge config: unitDef.config + node.config (node overrides win)
                          |
Create unitInstance record in DB (status=pending)
                          |
Execute based on type (switch block)
                          |
Record completion -> update context -> resolve next nodes
```

### Type-Specific Execution

**DOCUMENT**:

```
executeDocumentUnit() -> creates row in `documents` table
  +-- autoGenerate=true?  -> status='completed', done instantly
  +-- manual?             -> status='draft', notify creator
                             -> workflow BLOCKS on condition()
                             -> waits for humanDecision signal
                             -> on signal: completeDocumentUnit()
                             -> on timeout: handleTimeout()
```

**ACTION**:

```
activateActionUnit() -> sets unitInstance status='active', assigneeId
  -> notify assignee
  -> workflow BLOCKS on condition()
  -> waits for humanDecision signal with timeout
  -> on signal: completeActionUnit() with action="SIGN"/"REJECT"/etc.
  -> on timeout: handleTimeout() marks as failed
```

**TASK**: Same pattern as ACTION but for general work items.

**CONDITION**:

```
evaluateCondition() -> whitelist lookup:
  "has_agreement_parties" -> checks roleAssignments['agreement_party']
  "action_result"         -> walks completedNodes backwards, finds last action
  "amount_threshold"      -> variables.estimatedCost > 100000?
-> returns { branch: "true" } or { branch: "SIGN" } etc.
```

**PARALLEL + GATE**:

```
PARALLEL node executes -> result = { forked: true }
  -> next: ["11", "12", "13"] (3 branches)
  -> findConvergenceGate() finds the GATE node as common target
  -> Promise.all([ executeNode("11"), executeNode("12"), executeNode("13") ])
  -> after all complete -> executeNode(gateNode)
  -> continues to whatever is after the GATE
```

**Loop-back**: When `next` points to an already-completed node (or `isLoop: true`), the executor resets that node and all downstream nodes, clears their outputs, and re-executes from the loop target.

---

## How Documents Work (Signal Flow)

When a DOCUMENT unit is reached in the graph:

```
1. Start flow     -> Temporal starts executeFlowGraph()
2. Hit DOCUMENT   -> creates a "draft" row in documents table
                     creates "active" unitInstance
                     sends notification to the creator
3. WORKFLOW BLOCKS -> await condition() -- just sits there waiting
4. User acts      -> POST /api/flows/:id/signal -> Temporal delivers humanDecision signal
5. Signal arrives -> pendingDecisions map gets populated
                     condition() unblocks
6. Complete       -> document status: draft -> pending
                     unitInstance: active -> completed
7. Move on        -> executeNode(next node)
```

The document creation itself is automatic (inserts a draft row), but the workflow pauses and waits for the user to signal that they've finished filling it in. The same `humanDecision` signal mechanism is used for DOCUMENT, ACTION, and TASK units.

---

## Extension Point Map

```
What do you want to do?
|
+-- A. Add a new document type         -> seed.ts only (no code changes)
+-- B. Add a new flow                  -> seed.ts only (no code changes)
+-- C. Add a new condition expression  -> unit.activities.ts (code change)
+-- D. Add a new automation handler    -> unit.activities.ts (code change)
+-- E. Add a new unit TYPE             -> schema + executor + activities (big change)
+-- F. Add a new notification type     -> schema.ts enum (migration)
+-- G. Add a new API endpoint          -> flows.controller.ts + flows.service.ts
+-- H. Change how a unit type behaves  -> graph-executor.workflow.ts switch block
```

---

## A. Add a New Document Type

**File:** `packages/database/src/seed.ts` -- add to `units` array

```typescript
{
  id: "doc:travel_expense_report",       // convention: "doc:<snake_name>"
  type: "DOCUMENT",
  name: "Travel Expense Report",
  description: "Post-trip expense report with receipts",
  config: {
    template: "travel_expense_report",   // template identifier for the frontend
    fields: ["tripRef", "totalExpense", "receipts", "currency"],
    creator: "initiator",                // which role fills this in
    // autoGenerate: true,               // skip human input, complete instantly
    // timeout: "72h",                   // override default 168h wait time
  },
},
```

**Config fields and their effect:**

| Field          | Effect in executor                                                     |
| -------------- | ---------------------------------------------------------------------- |
| `template`     | Stored in document record, frontend uses to pick form template         |
| `fields`       | Stored in unitInstance output, frontend uses to render form fields     |
| `creator`      | Role key -> looked up in `ctx.roleAssignments[creator]` to find userId |
| `autoGenerate` | `true` = no human wait, creates doc as "completed" instantly           |
| `timeout`      | How long to wait for signal before TIMEOUT (default "168h")            |

**No code changes needed.** The executor already handles all DOCUMENT units generically.

**Run:** `pnpm --filter @workflow/database db:seed`

---

## B. Add a New Flow

**File:** `packages/database/src/seed.ts` -- add graph + flow definition

### Step 1: Define the graph

```typescript
const travelExpenseGraph: FlowNode[] = [
  {
    id: "1",
    unit: "doc:travel_expense_report",
    label: "Submit Expense Report",
    next: ["2"],
  },
  {
    id: "2",
    unit: "action:approve",
    label: "Manager Approves",
    config: { assignee: "manager" },
    next: ["3"],
  },
  {
    id: "3",
    unit: "cond:action_result",
    label: "Decision?",
    next: { APPROVE: ["4"], REJECT: ["R1"] },
  },
  {
    id: "4",
    unit: "task:disburse_funds",
    label: "Finance: Reimburse",
    config: { assignee: "accountant" },
    next: ["5"],
  },
  {
    id: "5",
    unit: "notify:flow_complete",
    label: "Done",
    config: { recipients: "initiator" },
    next: [],
  },
  {
    id: "R1",
    unit: "notify:rejection",
    label: "Rejected",
    config: { recipients: "initiator" },
    next: [],
    isTerminal: true,
    isError: true,
  },
];
```

### Step 2: Register the flow definition

```typescript
{
  id: "travel_expense",
  name: "Travel Expense Reimbursement",
  description: "Submit expense report -> manager approval -> reimbursement",
  icon: "money",
  color: "#f59e0b",
  category: "finance",
  roles: ["initiator", "manager", "accountant"],
  graph: travelExpenseGraph,
  estimatedDuration: "2-5 days",
},
```

### Graph Rules

- Must have a node with `id: "1"` (the root -- executor starts here)
- `unit` must reference an existing `unitDefinitions.id`
- `next: []` = terminal node (branch ends)
- `next: { "KEY": ["nodeId"] }` = branching (used after CONDITION or ACTION)
- `isLoop: true` + `next: ["already-done-node"]` = loop back
- `isTerminal: true, isError: true` = error end (rejection/failure)
- For parallel: use a PARALLEL node with `next: ["a","b","c"]`, all branches must point to the same GATE node

**No code changes needed.** Run: `pnpm --filter @workflow/database db:seed`

---

## C. Add a New Condition Expression

**File:** `apps/workflow-engine/src/activities/unit.activities.ts` -- `evaluateCondition()` function, `evaluators` map (line ~388)

### Step 1: Add the evaluator function

```typescript
const evaluators: Record<string, (ctx: FlowContext) => string> = {
  // ... existing evaluators ...

  // NEW: Check if employee has remaining leave days
  has_remaining_leave: (ctx) => {
    const remaining = ctx.variables["remainingLeaveDays"] as number | undefined;
    return remaining !== undefined && remaining > 0 ? "true" : "false";
  },

  // NEW: Multi-value branch (returns the value itself, not true/false)
  document_type: (ctx) => {
    const docType = ctx.variables["documentType"] as string | undefined;
    return docType || "default"; // returns "invoice", "contract", etc.
  },
};
```

**Rules:**

- Function receives the full `FlowContext` (roleAssignments, variables, completedNodes, nodeOutputs)
- Must return a string that matches a key in the node's `next` object
- For boolean conditions, return `"true"` or `"false"`
- For multi-branch, return the branch key directly (e.g. `"invoice"`, `"contract"`)
- Unknown expressions default to `"false"` with a console warning

### Step 2: Create unit definition in seed.ts

```typescript
{
  id: "cond:has_remaining_leave",
  type: "CONDITION",
  name: "Has Remaining Leave?",
  description: "Check if employee has leave days remaining",
  config: { expression: "has_remaining_leave" },  // must match evaluator key
},
```

### Step 3: Use in a flow graph

```typescript
{
  id: "3",
  unit: "cond:has_remaining_leave",
  label: "Leave Days Available?",
  next: { "true": ["4"], "false": ["R1"] },  // branch keys match evaluator return values
},
```

**How it connects:** The executor calls `evaluateCondition({ expression: "has_remaining_leave", context })` -> looks up `evaluators["has_remaining_leave"]` -> runs the function -> returns `{ branch: "true" }` -> picks `next["true"]`.

**Rebuild:** `pnpm --filter workflow-engine build`

---

## D. Add a New Automation Handler

**File:** `apps/workflow-engine/src/activities/unit.activities.ts` -- `executeAutomation()` function, `handlers` map (line ~540)

### Step 1: Add the handler function

```typescript
const handlers: Record<
  string,
  (cfg: AutomationConfig, ctx: FlowContext) => AutomationResult
> = {
  // ... existing handlers ...

  // NEW: Calculate reimbursement with tax
  calculateReimbursement: (cfg, ctx) => {
    const amount = Number(ctx.variables["totalExpense"] || 0);
    const taxRate = Number(cfg.taxRate || 0.12);
    const reimbursement = amount * (1 + taxRate);
    console.log(`[AUTOMATION] Reimbursement: ${reimbursement}`);
    return { reimbursement, taxRate, originalAmount: amount };
  },

  // NEW: External API call placeholder
  sendExternalEmail: (cfg, ctx) => {
    const to = ctx.roleAssignments[cfg.recipient as string] || "";
    const template = (cfg.emailTemplate as string) || "default";
    console.log(`[AUTOMATION] Sending email to ${to}, template: ${template}`);
    return { sent: true, to, template };
  },
};
```

**Rules:**

- Receives `(config, context)` -- config is the merged unit+node config, context is the flow context
- Must return a plain object (stored as unitInstance output)
- Throws if handler name not found
- Result is recorded in audit log automatically

### Step 2: Create unit definition in seed.ts

```typescript
{
  id: "auto:calculate_reimbursement",
  type: "AUTOMATION",
  name: "Calculate Reimbursement",
  description: "Calculate expense reimbursement with tax",
  config: { handler: "calculateReimbursement", taxRate: 0.12 },  // handler must match key
},
```

### Step 3: Use in a flow graph

```typescript
{
  id: "5",
  unit: "auto:calculate_reimbursement",
  label: "Calculate Amount",
  config: { taxRate: 0.15 },  // node config overrides unit default
  next: ["6"],
},
```

**How it connects:** Executor calls `executeAutomation({ handler: "calculateReimbursement", config, context })` -> looks up `handlers["calculateReimbursement"]` -> runs it -> stores result in unitInstance output -> continues.

**Rebuild:** `pnpm --filter workflow-engine build`

---

## E. Add a New Unit TYPE

This is the biggest change. Only needed if the 8 existing types don't cover your use case.

### E1. Schema -- add to enum

**File:** `packages/database/src/schema.ts` (line ~49)

```typescript
export const unitTypeEnum = pgEnum("unit_type", [
  "DOCUMENT",
  "TASK",
  "ACTION",
  "CONDITION",
  "NOTIFICATION",
  "AUTOMATION",
  "GATE",
  "PARALLEL",
  "APPROVAL_CHAIN", // new
]);
```

Generate and apply migration:

```bash
pnpm --filter @workflow/database db:generate
pnpm --filter @workflow/database db:push
```

### E2. Activity -- add execution logic

**File:** `apps/workflow-engine/src/activities/unit.activities.ts`

```typescript
export async function executeApprovalChain(input: {
  unitInstanceId: string;
  flowInstanceId: string;
  approvers: string[];
  config: Record<string, unknown>;
}): Promise<{
  approved: boolean;
  approvals: Array<{ userId: string; action: string }>;
}> {
  // ... your logic: create records, return result ...
}
```

### E3. Workflow -- register proxy + add switch case

**File:** `apps/workflow-engine/src/workflows/graph-executor.workflow.ts`

Add to `proxyActivities` destructuring (line ~84):

```typescript
const {
  // ... existing ...
  executeApprovalChain,
} = proxyActivities<typeof unitActivities>({ ... });
```

Add new case to the switch block (line ~222):

```typescript
case 'APPROVAL_CHAIN': {
  const approverRoles = (mergedConfig.approvers as string[]) || [];
  const approverIds = approverRoles.map(role => ctx.roleAssignments[role] || '');
  result = await executeApprovalChain({
    unitInstanceId,
    flowInstanceId,
    approvers: approverIds,
    config: mergedConfig,
  });
  break;
}
```

### E4. Rebuild everything

```bash
pnpm --filter @workflow/database exec tsc   # rebuild shared package first
pnpm --filter workflow-engine build          # rebuild worker
pnpm --filter main-server build              # rebuild server (if needed)
```

---

## F. Add a New Notification Type

**File:** `packages/database/src/schema.ts` (line ~474)

```typescript
export const notificationTypeEnum = pgEnum("notification_type", [
  "task_assigned",
  "action_completed",
  "flow_completed",
  "flow_failed",
  "rejection",
  "request_change",
  "timeout",
  "info",
  "approval_reminder", // new
]);
```

Generate and apply migration:

```bash
pnpm --filter @workflow/database db:generate
pnpm --filter @workflow/database db:push
```

Then use in activities:

```typescript
await createNotification({
  recipientId: "...",
  type: "approval_reminder",
  title: "Reminder: Approval Pending",
  // ...
});
```

---

## G. Add a New API Endpoint

### Controller

**File:** `apps/main-server/src/flows/flows.controller.ts`

```typescript
@Get('/api/flow-statistics')
async getFlowStatistics() {
  return this.flowsService.getFlowStatistics();
}
```

### Service

**File:** `apps/main-server/src/flows/flows.service.ts`

```typescript
async getFlowStatistics() {
  // query DB, aggregate, return
}
```

---

## H. Change How a Unit Type Behaves

**File:** `apps/workflow-engine/src/workflows/graph-executor.workflow.ts` -- the `switch (unitDef.type)` block (line ~222)

Each case in the switch handles one unit type. Modify the relevant case to change behavior. For example, to add a second approval step to ACTION units, modify `case 'ACTION'`.

**Important:** Changes here affect ALL flows that use that unit type. Test thoroughly.

---

## Quick Reference: What to Change for What

| Want to...               | Files to touch                                                    | Migration? | Rebuild?          |
| ------------------------ | ----------------------------------------------------------------- | ---------- | ----------------- |
| New document template    | `seed.ts` only                                                    | No         | No (just re-seed) |
| New flow                 | `seed.ts` only                                                    | No         | No (just re-seed) |
| New condition expression | `seed.ts` + `unit.activities.ts`                                  | No         | Worker            |
| New automation handler   | `seed.ts` + `unit.activities.ts`                                  | No         | Worker            |
| New unit TYPE            | `schema.ts` + `unit.activities.ts` + `graph-executor.workflow.ts` | Yes        | All               |
| New notification type    | `schema.ts`                                                       | Yes        | DB package        |
| New API endpoint         | `flows.controller.ts` + `flows.service.ts`                        | No         | Server            |
| Change unit behavior     | `graph-executor.workflow.ts`                                      | No         | Worker            |

---

## Key File Locations

| File                                                            | Purpose                                                      |
| --------------------------------------------------------------- | ------------------------------------------------------------ |
| `packages/database/src/schema.ts`                               | All DB table + enum definitions                              |
| `packages/database/src/seed.ts`                                 | Unit definitions + flow definitions seed data                |
| `packages/database/src/constants.ts`                            | Task queue names, workflow type names                        |
| `apps/workflow-engine/src/workflows/graph-executor.workflow.ts` | The generic graph executor (core engine)                     |
| `apps/workflow-engine/src/activities/unit.activities.ts`        | All activities (DB ops, condition eval, automation handlers) |
| `apps/workflow-engine/src/worker/worker.service.ts`             | Temporal worker setup (task queues)                          |
| `apps/main-server/src/flows/flows.controller.ts`                | REST API endpoints                                           |
| `apps/main-server/src/flows/flows.service.ts`                   | Flow orchestration + DB queries                              |
| `apps/main-server/src/temporal/temporal.service.ts`             | Temporal client (start workflows, send signals)              |

---

## Existing Unit Definitions (Reusable)

Before creating new units, check if one of these already fits your need:

**DOCUMENT:** `doc:business_trip_plan`, `doc:business_trip_notice`, `doc:business_trip_order`, `doc:business_trip_certificate`, `doc:leave_request`, `doc:incoming_letter`, `doc:procurement_request`, `doc:procurement_order`, `doc:vacation_plan`

**ACTION:** `action:sign_self`, `action:sign`, `action:agree`, `action:approve`, `action:acknowledge`

**TASK:** `task:prepare_document`, `task:disburse_funds`, `task:hr_process`, `task:register_incoming`, `task:review_and_assign`, `task:execute_resolution`, `task:procurement_evaluation`, `task:submit_vacation_schedule`

**CONDITION:** `cond:has_agreement_parties`, `cond:action_result`, `cond:amount_threshold`, `cond:urgency_check`

**NOTIFICATION:** `notify:inform`, `notify:flow_complete`, `notify:rejection`, `notify:changes_requested`

**AUTOMATION:** `auto:generate_document`, `auto:archive`, `auto:register_number`, `auto:validate_fields`

**GATE:** `gate:wait_all`, `gate:wait_any`

**PARALLEL:** `parallel:post_sign_tasks`, `parallel:multi_approval`

---

## Existing Condition Expressions

| Expression              | What it checks                                                 | Returns                          |
| ----------------------- | -------------------------------------------------------------- | -------------------------------- |
| `has_agreement_parties` | `roleAssignments['agreement_party']` exists                    | `"true"` / `"false"`             |
| `action_result`         | Most recent completed node's `action` output                   | The action string or `"default"` |
| `amount_threshold`      | `variables.estimatedCost` or `variables.totalAmount` > 100,000 | `"true"` / `"false"`             |
| `urgency_check`         | `variables.urgency` is `"high"` or `"urgent"`                  | `"true"` / `"false"`             |

## Existing Automation Handlers

| Handler                        | What it does                                  | Returns                      |
| ------------------------------ | --------------------------------------------- | ---------------------------- |
| `generateDocumentFromTemplate` | Logs template generation                      | `{ generated, template }`    |
| `archiveDocuments`             | Logs archive action                           | `{ archived, timestamp }`    |
| `generateRegistryNumber`       | Generates `REG-YYYY-NNNNN` format             | `{ registryNumber }`         |
| `validateDocumentFields`       | Checks required fields in `context.variables` | `{ isValid, missingFields }` |
