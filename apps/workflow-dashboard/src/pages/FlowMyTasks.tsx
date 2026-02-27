import { useState } from "react";
import { Check, X, FileEdit, Clock, AlertCircle, Loader } from "lucide-react";
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
  ) => Promise<{ success: boolean; error?: string }>;
}

export function FlowMyTasks({
  tasks,
  activeUserId,
  onSignal,
}: FlowMyTasksProps) {
  const [comments, setComments] = useState<Record<string, string>>({});
  const [loadingTaskIds, setLoadingTaskIds] = useState<Set<string>>(new Set());
  const [taskErrors, setTaskErrors] = useState<Record<string, string>>({});

  const myTasks = tasks.filter((t) => t.assigneeId === activeUserId);

  const getComment = (taskId: string) => comments[taskId] || "";
  const setComment = (taskId: string, value: string) =>
    setComments((prev) => ({ ...prev, [taskId]: value }));

  const handleAction = async (
    task: FlowTask,
    action: string,
    comment: string,
  ) => {
    if (loadingTaskIds.has(task.id)) return;

    setLoadingTaskIds((prev) => new Set(prev).add(task.id));
    setTaskErrors((prev) => {
      const next = { ...prev };
      delete next[task.id];
      return next;
    });

    const result = await onSignal(
      task.flowInstanceId,
      task.nodeId,
      action,
      comment,
    );

    if (!result.success) {
      setLoadingTaskIds((prev) => {
        const next = new Set(prev);
        next.delete(task.id);
        return next;
      });
      setTaskErrors((prev) => ({
        ...prev,
        [task.id]: result.error || "Action failed",
      }));
    }
  };

  const getActionButtons = (task: FlowTask) => {
    const config = task.unitConfig || {};
    const allowedActions: string[] = config.allowedActions || [];
    const isLoading = loadingTaskIds.has(task.id);

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
              disabled={isLoading}
              onClick={() => {
                const action =
                  allowedActions.find((a) =>
                    ["SIGN", "AGREE", "APPROVE", "ACKNOWLEDGE"].includes(a),
                  ) || "APPROVE";
                handleAction(task, action, getComment(task.id));
                setComment(task.id, "");
              }}
            >
              {isLoading ? (
                <Loader
                  size={16}
                  style={{ animation: "spin 1s linear infinite" }}
                />
              ) : (
                <Check size={16} />
              )}
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
              disabled={isLoading}
              onClick={() => {
                handleAction(task, "REJECT", getComment(task.id) || "Rejected");
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
              disabled={isLoading}
              onClick={() => {
                handleAction(
                  task,
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
        disabled={isLoading}
        onClick={() => {
          handleAction(task, "COMPLETE", getComment(task.id));
          setComment(task.id, "");
        }}
      >
        {isLoading ? (
          <Loader size={16} style={{ animation: "spin 1s linear infinite" }} />
        ) : (
          <Check size={16} />
        )}{" "}
        Complete Task
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
        {myTasks.map((task) => {
          const isLoading = loadingTaskIds.has(task.id);
          return (
            <div
              key={task.id}
              className="card"
              style={{
                opacity: isLoading ? 0.6 : 1,
                pointerEvents: isLoading ? "none" : "auto",
                transition: "opacity 0.2s",
              }}
            >
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
                  <span
                    style={{
                      fontFamily: "monospace",
                      fontSize: "0.875rem",
                    }}
                  >
                    #{task.nodeId}
                  </span>
                </div>
                <div
                  style={{
                    display: "flex",
                    justifyContent: "space-between",
                  }}
                >
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
                  disabled={isLoading}
                />
                {getActionButtons(task)}
                {taskErrors[task.id] && (
                  <div
                    style={{
                      marginTop: "0.5rem",
                      padding: "0.5rem",
                      backgroundColor: "#fef2f2",
                      color: "#dc2626",
                      borderRadius: "6px",
                      fontSize: "0.8rem",
                      display: "flex",
                      alignItems: "center",
                      gap: "0.4rem",
                    }}
                  >
                    <AlertCircle size={14} />
                    {taskErrors[task.id]}
                  </div>
                )}
              </div>
            </div>
          );
        })}
      </div>
    </div>
  );
}
