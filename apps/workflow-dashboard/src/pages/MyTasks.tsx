import { useState } from "react";
import { Check, X, FileEdit } from "lucide-react";

interface Task {
  id: string;
  documentId: string;
  assigneeId: string;
  type: string;
  status: string;
}

interface Document {
  id: string;
  title: string;
  status: string;
  authorId: string;
}

export function MyTasks({
  tasks,
  documents,
  activeUserId,
  onAction,
}: {
  tasks: Task[];
  documents: Document[];
  activeUserId: string;
  onAction: (
    taskId: string,
    docId: string,
    action: string,
    comment?: string,
  ) => void;
}) {
  const [comment, setComment] = useState("");

  const activeTasks = tasks.filter(
    (t) => t.assigneeId === activeUserId && t.status === "pending",
  );

  if (activeTasks.length === 0) {
    return (
      <div
        style={{
          textAlign: "center",
          padding: "4rem",
          color: "var(--text-secondary)",
        }}
      >
        <Check size={48} style={{ opacity: 0.2, margin: "0 auto 1rem" }} />
        <h3>All caught up!</h3>
        <p>You have no pending tasks in your queue.</p>
      </div>
    );
  }

  return (
    <div>
      <h2>My Pending Tasks ({activeTasks.length})</h2>
      <div className="card-grid" style={{ marginTop: "1.5rem" }}>
        {activeTasks.map((task) => {
          const doc = documents.find((d) => d.id === task.documentId);
          if (!doc) return null;

          const isSignatory = task.type === "sign";
          const isReview = task.type === "review";

          return (
            <div key={task.id} className="card">
              <div className="card-header">
                <h3 style={{ margin: 0, fontSize: "1.1rem" }}>{doc.title}</h3>
                <span className="badge badge-in_review">Action Required</span>
              </div>

              <div style={{ marginBottom: "1.5rem" }}>
                <div
                  style={{
                    display: "flex",
                    justifyContent: "space-between",
                    marginBottom: "0.5rem",
                  }}
                >
                  <span className="text-muted">Document ID:</span>
                  <span
                    style={{ fontFamily: "monospace", fontSize: "0.875rem" }}
                  >
                    ...{doc.id.slice(-8)}
                  </span>
                </div>
                <div
                  style={{ display: "flex", justifyContent: "space-between" }}
                >
                  <span className="text-muted">Task Type:</span>
                  <span
                    style={{ textTransform: "capitalize", fontWeight: 500 }}
                  >
                    {task.type}
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
                  value={comment}
                  onChange={(e) => setComment(e.target.value)}
                />

                <div
                  style={{ display: "flex", gap: "0.5rem", flexWrap: "wrap" }}
                >
                  <button
                    className="btn btn-success"
                    style={{ flex: 1 }}
                    onClick={() => {
                      onAction(
                        task.id,
                        doc.id,
                        isSignatory ? "sign" : "approve",
                        comment,
                      );
                      setComment("");
                    }}
                  >
                    <Check size={16} />
                    {isSignatory ? "Sign Document" : "Approve"}
                  </button>

                  <button
                    className="btn btn-danger"
                    onClick={() => {
                      onAction(
                        task.id,
                        doc.id,
                        "reject",
                        comment || "Rejected without comment",
                      );
                      setComment("");
                    }}
                  >
                    <X size={16} />
                    Reject
                  </button>

                  {isReview && (
                    <button
                      className="btn btn-warning"
                      style={{ width: "100%" }}
                      onClick={() => {
                        onAction(
                          task.id,
                          doc.id,
                          "request_changes",
                          comment || "Changes requested",
                        );
                        setComment("");
                      }}
                    >
                      <FileEdit size={16} />
                      Request Changes
                    </button>
                  )}
                </div>
              </div>
            </div>
          );
        })}
      </div>
    </div>
  );
}
