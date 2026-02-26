import { useState } from "react";
import { Check, X, FileEdit, Clock, AlertCircle } from "lucide-react";
import { UnitTypeBadge } from "../components/UnitTypeBadge";

interface FlowTask {
  id: string;
  nodeId: string;
  status: string;
  unitType: string;
  unitName: string;
  unitConfig: Record<string, any>;
  flowInstanceId: string;
  flowName: string;
  flowDefinitionId: string;
  assigneeId: string;
  input: Record<string, any>;
  createdAt: string;
}

interface FlowMyTasksProps {
  tasks: FlowTask[];
  activeUserId: string;
  onSignal: (
    flowInstanceId: string,
    nodeId: string,
    action: string,
    comment?: string,
  ) => void;
}

export function FlowMyTasks({
  tasks,
  activeUserId,
  onSignal,
}: FlowMyTasksProps) {
  const [comments, setComments] = useState<Record<string, string>>({});

  const myTasks = tasks.filter((t) => t.assigneeId === activeUserId);

  const getComment = (taskId: string) => comments[taskId] || "";
  const setComment = (taskId: string, value: string) =>
    setComments((prev) => ({ ...prev, [taskId]: value }));

  const getActionButtons = (task: FlowTask) => {
    const config = task.unitConfig || {};
    const allowedActions: string[] = config.allowedActions || [];

    if (task.unitType === "ACTION") {
      return (
        <div style={{ display: "flex", gap: "0.5rem", flexWrap: "wrap" }}>
          {(allowedActions.includes("SIGN") ||
            allowedActions.includes("AGREE") ||
            allowedActions.includes("APPROVE") ||
            allowedActions.includes("ACKNOWLEDGE")) && (
            <button
              className="btn btn-success"
              style={{ flex: 1 }}
              onClick={() => {
                const action =
                  allowedActions.find((a) =>
                    ["SIGN", "AGREE", "APPROVE", "ACKNOWLEDGE"].includes(a),
                  ) || "APPROVE";
                onSignal(
                  task.flowInstanceId,
                  task.nodeId,
                  action,
                  getComment(task.id),
                );
                setComment(task.id, "");
              }}
            >
              <Check size={16} />
              {allowedActions.includes("SIGN")
                ? "Sign"
                : allowedActions.includes("AGREE")
                  ? "Agree"
                  : allowedActions.includes("ACKNOWLEDGE")
                    ? "Acknowledge"
                    : "Approve"}
            </button>
          )}
          {allowedActions.includes("REJECT") && (
            <button
              className="btn btn-danger"
              onClick={() => {
                onSignal(
                  task.flowInstanceId,
                  task.nodeId,
                  "REJECT",
                  getComment(task.id) || "Rejected",
                );
                setComment(task.id, "");
              }}
            >
              <X size={16} /> Reject
            </button>
          )}
          {allowedActions.includes("REQUEST_CHANGE") && (
            <button
              className="btn btn-warning"
              style={{ width: "100%" }}
              onClick={() => {
                onSignal(
                  task.flowInstanceId,
                  task.nodeId,
                  "REQUEST_CHANGE",
                  getComment(task.id) || "Changes requested",
                );
                setComment(task.id, "");
              }}
            >
              <FileEdit size={16} /> Request Changes
            </button>
          )}
        </div>
      );
    }

    // TASK type — generic complete button
    return (
      <button
        className="btn btn-success"
        style={{ width: "100%" }}
        onClick={() => {
          onSignal(
            task.flowInstanceId,
            task.nodeId,
            "COMPLETE",
            getComment(task.id),
          );
          setComment(task.id, "");
        }}
      >
        <Check size={16} /> Complete Task
      </button>
    );
  };

  if (myTasks.length === 0) {
    return (
      <div
        style={{
          textAlign: "center",
          padding: "4rem",
          color: "var(--text-secondary)",
        }}
      >
        <Check
          size={48}
          style={{ opacity: 0.2, margin: "0 auto 1rem", display: "block" }}
        />
        <h3>All caught up!</h3>
        <p>You have no pending flow tasks in your queue.</p>
      </div>
    );
  }

  return (
    <div>
      <h2>My Flow Tasks ({myTasks.length})</h2>

      <div className="card-grid" style={{ marginTop: "1.5rem" }}>
        {myTasks.map((task) => (
          <div key={task.id} className="card">
            <div className="card-header">
              <div>
                <h3 style={{ margin: 0, fontSize: "1.1rem" }}>
                  {task.unitName}
                </h3>
                <span className="text-muted" style={{ fontSize: "0.8rem" }}>
                  {task.flowName}
                </span>
              </div>
              <UnitTypeBadge type={task.unitType} />
            </div>

            <div style={{ marginBottom: "1rem" }}>
              <div
                style={{
                  display: "flex",
                  justifyContent: "space-between",
                  marginBottom: "0.4rem",
                }}
              >
                <span className="text-muted">Flow:</span>
                <span style={{ fontWeight: 500, fontSize: "0.875rem" }}>
                  {task.flowDefinitionId}
                </span>
              </div>
              <div
                style={{
                  display: "flex",
                  justifyContent: "space-between",
                  marginBottom: "0.4rem",
                }}
              >
                <span className="text-muted">Node:</span>
                <span style={{ fontFamily: "monospace", fontSize: "0.875rem" }}>
                  #{task.nodeId}
                </span>
              </div>
              <div style={{ display: "flex", justifyContent: "space-between" }}>
                <span className="text-muted">Created:</span>
                <span
                  style={{
                    fontSize: "0.8rem",
                    display: "flex",
                    alignItems: "center",
                    gap: "0.25rem",
                  }}
                >
                  <Clock size={12} />
                  {new Date(task.createdAt).toLocaleString()}
                </span>
              </div>
            </div>

            <div
              style={{
                borderTop: "1px solid var(--border-color)",
                paddingTop: "1rem",
              }}
            >
              <input
                type="text"
                className="input-field"
                placeholder="Optional comment..."
                value={getComment(task.id)}
                onChange={(e) => setComment(task.id, e.target.value)}
              />
              {getActionButtons(task)}
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}
