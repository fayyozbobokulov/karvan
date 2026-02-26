import { useEffect, useState } from "react";
import { Shield, Clock, User, ArrowRight } from "lucide-react";

interface FlowInstance {
  id: string;
  flowName: string;
  flowIcon?: string;
  status: string;
  startedAt: string;
}

interface AuditEntry {
  id: string;
  flowInstanceId: string;
  unitInstanceId?: string;
  actorId?: string;
  action: string;
  fromStatus?: string;
  toStatus?: string;
  comment?: string;
  metadata?: Record<string, any>;
  createdAt: string;
}

interface FlowAuditTrailProps {
  instances: FlowInstance[];
  apiBase: string;
}

const ACTION_COLORS: Record<string, string> = {
  COMPLETE: "var(--status-green)",
  SIGN: "var(--status-green)",
  APPROVE: "var(--status-green)",
  AGREE: "var(--status-green)",
  ACKNOWLEDGE: "var(--status-green)",
  REJECT: "var(--status-red)",
  TIMEOUT: "var(--status-red)",
  REQUEST_CHANGE: "var(--status-amber)",
  NOTIFICATION_SENT: "var(--status-blue)",
  AUTOMATION_EXECUTED: "var(--status-purple)",
  ACTION_ACTIVATED: "var(--status-orange)",
  TASK_ACTIVATED: "var(--status-amber)",
};

export function FlowAuditTrail({ instances, apiBase }: FlowAuditTrailProps) {
  const [selectedId, setSelectedId] = useState<string | null>(null);
  const [auditEntries, setAuditEntries] = useState<AuditEntry[]>([]);
  const [loadingAudit, setLoadingAudit] = useState(false);

  const fetchAudit = async (flowInstanceId: string) => {
    setLoadingAudit(true);
    try {
      const res = await fetch(`${apiBase}/flows/${flowInstanceId}/audit`);
      if (res.ok) {
        const data = await res.json();
        setAuditEntries(data);
      }
    } catch (err) {
      console.error("Error fetching audit:", err);
    } finally {
      setLoadingAudit(false);
    }
  };

  useEffect(() => {
    if (selectedId) {
      fetchAudit(selectedId);
    }
  }, [selectedId]);

  return (
    <div>
      <h2 style={{ marginBottom: "1.5rem" }}>
        <Shield
          size={24}
          style={{ verticalAlign: "middle", marginRight: "0.5rem" }}
        />
        Flow Audit Trail
      </h2>

      <div
        style={{
          display: "grid",
          gridTemplateColumns: "300px 1fr",
          gap: "1.5rem",
          minHeight: "500px",
        }}
      >
        {/* Left panel — flow instance list */}
        <div className="card" style={{ overflow: "auto", maxHeight: "70vh" }}>
          <h3
            style={{
              margin: "0 0 1rem",
              fontSize: "0.9rem",
              color: "var(--text-secondary)",
            }}
          >
            Select Flow Instance
          </h3>
          {instances.length === 0 ? (
            <p className="text-muted" style={{ fontSize: "0.875rem" }}>
              No flow instances.
            </p>
          ) : (
            <div
              style={{
                display: "flex",
                flexDirection: "column",
                gap: "0.5rem",
              }}
            >
              {instances.map((inst) => (
                <div
                  key={inst.id}
                  onClick={() => setSelectedId(inst.id)}
                  style={{
                    padding: "0.75rem",
                    borderRadius: "6px",
                    cursor: "pointer",
                    transition: "all 0.2s",
                    background:
                      selectedId === inst.id
                        ? "var(--status-blue-bg)"
                        : "transparent",
                    borderLeft:
                      selectedId === inst.id
                        ? "3px solid var(--primary)"
                        : "3px solid transparent",
                  }}
                >
                  <div
                    style={{
                      display: "flex",
                      alignItems: "center",
                      gap: "0.5rem",
                    }}
                  >
                    <span>{inst.flowIcon || "📄"}</span>
                    <div>
                      <div style={{ fontWeight: 500, fontSize: "0.875rem" }}>
                        {inst.flowName}
                      </div>
                      <div
                        className="text-muted"
                        style={{ fontSize: "0.7rem", fontFamily: "monospace" }}
                      >
                        ...{inst.id.slice(-8)}
                      </div>
                    </div>
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>

        {/* Right panel — audit timeline */}
        <div className="card" style={{ overflow: "auto", maxHeight: "70vh" }}>
          {!selectedId ? (
            <div
              style={{
                textAlign: "center",
                padding: "3rem",
                color: "var(--text-secondary)",
              }}
            >
              <Shield
                size={40}
                style={{
                  opacity: 0.2,
                  margin: "0 auto 1rem",
                  display: "block",
                }}
              />
              <p>Select a flow instance to view its audit trail.</p>
            </div>
          ) : loadingAudit ? (
            <p
              className="text-muted"
              style={{ padding: "2rem", textAlign: "center" }}
            >
              Loading audit trail...
            </p>
          ) : auditEntries.length === 0 ? (
            <p
              className="text-muted"
              style={{ padding: "2rem", textAlign: "center" }}
            >
              No audit entries yet.
            </p>
          ) : (
            <div className="timeline">
              {auditEntries.map((entry) => {
                const color =
                  ACTION_COLORS[entry.action] || "var(--status-gray)";
                return (
                  <div
                    key={entry.id}
                    className="timeline-event"
                    style={{ "--dot-color": color } as any}
                  >
                    <style>{`
                      .timeline-event[style*="--dot-color"]::before {
                        background-color: var(--dot-color) !important;
                      }
                    `}</style>
                    <div
                      style={{
                        display: "flex",
                        justifyContent: "space-between",
                        alignItems: "flex-start",
                        marginBottom: "0.25rem",
                      }}
                    >
                      <span
                        style={{ fontWeight: 600, color, fontSize: "0.9rem" }}
                      >
                        {entry.action}
                      </span>
                      <span
                        className="text-muted"
                        style={{
                          fontSize: "0.75rem",
                          display: "flex",
                          alignItems: "center",
                          gap: "0.25rem",
                        }}
                      >
                        <Clock size={11} />
                        {new Date(entry.createdAt).toLocaleString()}
                      </span>
                    </div>

                    {(entry.fromStatus || entry.toStatus) && (
                      <div
                        style={{
                          fontSize: "0.8rem",
                          color: "var(--text-secondary)",
                          marginBottom: "0.25rem",
                          display: "flex",
                          alignItems: "center",
                          gap: "0.35rem",
                        }}
                      >
                        <span
                          className="badge"
                          style={{
                            fontSize: "0.65rem",
                            padding: "0.1rem 0.4rem",
                          }}
                        >
                          {entry.fromStatus || "—"}
                        </span>
                        <ArrowRight size={12} />
                        <span
                          className="badge"
                          style={{
                            fontSize: "0.65rem",
                            padding: "0.1rem 0.4rem",
                          }}
                        >
                          {entry.toStatus || "—"}
                        </span>
                      </div>
                    )}

                    {entry.comment && (
                      <p
                        style={{
                          margin: "0.25rem 0 0",
                          fontSize: "0.85rem",
                          color: "var(--text-secondary)",
                          fontStyle: "italic",
                        }}
                      >
                        "{entry.comment}"
                      </p>
                    )}

                    {entry.metadata &&
                      Object.keys(entry.metadata).length > 0 && (
                        <div
                          style={{
                            marginTop: "0.25rem",
                            fontSize: "0.7rem",
                            fontFamily: "monospace",
                            color: "var(--text-secondary)",
                            maxWidth: "100%",
                            overflow: "hidden",
                            textOverflow: "ellipsis",
                          }}
                        >
                          {JSON.stringify(entry.metadata).slice(0, 100)}
                        </div>
                      )}
                  </div>
                );
              })}
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
