import { GitBranch, Eye, Clock, User } from "lucide-react";

interface FlowInstance {
  id: string;
  flowDefinitionId: string;
  flowName: string;
  flowIcon?: string;
  flowColor?: string;
  status: string;
  temporalWorkflowId: string;
  startedBy: string;
  startedAt: string;
  completedAt?: string;
  currentNodeIds: string[];
}

interface FlowInstancesProps {
  instances: FlowInstance[];
  onViewDetail: (flowInstanceId: string) => void;
  statusFilter: string;
  onStatusFilterChange: (status: string) => void;
}

const STATUS_STYLES: Record<string, { bg: string; color: string }> = {
  running: { bg: "var(--status-blue-bg)", color: "var(--status-blue)" },
  waiting: { bg: "var(--status-amber-bg)", color: "var(--status-amber)" },
  completed: { bg: "var(--status-green-bg)", color: "var(--status-green)" },
  failed: { bg: "var(--status-red-bg)", color: "var(--status-red)" },
  cancelled: { bg: "var(--status-gray-bg)", color: "var(--status-gray)" },
};

export function FlowInstances({
  instances,
  onViewDetail,
  statusFilter,
  onStatusFilterChange,
}: FlowInstancesProps) {
  const filtered = statusFilter
    ? instances.filter((i) => i.status === statusFilter)
    : instances;

  const statusCounts = instances.reduce<Record<string, number>>((acc, i) => {
    acc[i.status] = (acc[i.status] || 0) + 1;
    return acc;
  }, {});

  return (
    <div>
      <div
        style={{
          display: "flex",
          justifyContent: "space-between",
          alignItems: "center",
          marginBottom: "1.5rem",
        }}
      >
        <h2>Flow Instances ({instances.length})</h2>
      </div>

      {/* Status filter pills */}
      <div
        style={{
          display: "flex",
          gap: "0.5rem",
          marginBottom: "1.5rem",
          flexWrap: "wrap",
        }}
      >
        <button
          className={`btn ${!statusFilter ? "btn-primary" : ""}`}
          style={
            statusFilter
              ? {
                  background: "var(--status-gray-bg)",
                  color: "var(--text-secondary)",
                }
              : {}
          }
          onClick={() => onStatusFilterChange("")}
        >
          All ({instances.length})
        </button>
        {Object.entries(statusCounts).map(([status, count]) => {
          const style = STATUS_STYLES[status] || STATUS_STYLES.running;
          return (
            <button
              key={status}
              className="btn"
              style={{
                background: statusFilter === status ? style.color : style.bg,
                color: statusFilter === status ? "white" : style.color,
                fontWeight: 600,
              }}
              onClick={() =>
                onStatusFilterChange(statusFilter === status ? "" : status)
              }
            >
              {status} ({count})
            </button>
          );
        })}
      </div>

      {filtered.length === 0 ? (
        <div
          style={{
            textAlign: "center",
            padding: "4rem",
            color: "var(--text-secondary)",
          }}
        >
          <GitBranch
            size={48}
            style={{ opacity: 0.2, margin: "0 auto 1rem", display: "block" }}
          />
          <h3>No flow instances</h3>
          <p>Start a flow from the catalog to see it here.</p>
        </div>
      ) : (
        <div
          style={{ display: "flex", flexDirection: "column", gap: "0.75rem" }}
        >
          {filtered.map((instance) => {
            const statusStyle =
              STATUS_STYLES[instance.status] || STATUS_STYLES.running;
            const duration = instance.completedAt
              ? timeSince(
                  new Date(instance.startedAt),
                  new Date(instance.completedAt),
                )
              : timeSince(new Date(instance.startedAt), new Date());

            return (
              <div
                key={instance.id}
                className="card"
                style={{
                  cursor: "pointer",
                  transition: "border-color 0.2s",
                  borderLeft: `4px solid ${instance.flowColor || statusStyle.color}`,
                }}
                onClick={() => onViewDetail(instance.id)}
              >
                <div
                  style={{
                    display: "flex",
                    justifyContent: "space-between",
                    alignItems: "center",
                  }}
                >
                  <div
                    style={{
                      display: "flex",
                      alignItems: "center",
                      gap: "0.75rem",
                    }}
                  >
                    <span style={{ fontSize: "1.5rem" }}>
                      {instance.flowIcon || "📄"}
                    </span>
                    <div>
                      <div style={{ fontWeight: 600, fontSize: "1rem" }}>
                        {instance.flowName}
                      </div>
                      <div
                        className="text-muted"
                        style={{ fontSize: "0.8rem", fontFamily: "monospace" }}
                      >
                        ...{instance.id.slice(-8)}
                      </div>
                    </div>
                  </div>

                  <div
                    style={{
                      display: "flex",
                      alignItems: "center",
                      gap: "1rem",
                    }}
                  >
                    <div style={{ textAlign: "right" }}>
                      <div
                        style={{
                          display: "flex",
                          alignItems: "center",
                          gap: "0.35rem",
                          color: "var(--text-secondary)",
                          fontSize: "0.8rem",
                        }}
                      >
                        <User size={12} /> {instance.startedBy}
                      </div>
                      <div
                        style={{
                          display: "flex",
                          alignItems: "center",
                          gap: "0.35rem",
                          color: "var(--text-secondary)",
                          fontSize: "0.8rem",
                        }}
                      >
                        <Clock size={12} /> {duration}
                      </div>
                    </div>

                    <span
                      className="badge"
                      style={{
                        backgroundColor: statusStyle.bg,
                        color: statusStyle.color,
                      }}
                    >
                      {instance.status}
                    </span>

                    <Eye size={18} style={{ color: "var(--text-secondary)" }} />
                  </div>
                </div>
              </div>
            );
          })}
        </div>
      )}
    </div>
  );
}

function timeSince(start: Date, end: Date): string {
  const diffMs = end.getTime() - start.getTime();
  const diffMins = Math.floor(diffMs / 60000);
  if (diffMins < 1) return "just now";
  if (diffMins < 60) return `${diffMins}m ago`;
  const diffHrs = Math.floor(diffMins / 60);
  if (diffHrs < 24) return `${diffHrs}h ago`;
  const diffDays = Math.floor(diffHrs / 24);
  return `${diffDays}d ago`;
}
