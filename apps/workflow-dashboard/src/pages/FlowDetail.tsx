import { useEffect, useState } from "react";
import { ArrowLeft, RefreshCw, Clock, User, GitBranch } from "lucide-react";
import { FlowGraph } from "../components/FlowGraph";
import { UnitTypeBadge } from "../components/UnitTypeBadge";

interface FlowDetailData {
  id: string;
  flowDefinitionId: string;
  flowName: string;
  flowIcon?: string;
  flowColor?: string;
  status: string;
  temporalWorkflowId: string;
  startedBy?: string;
  startedAt: string;
  completedAt?: string;
  currentNodeIds: string[];
  context: any;
  graph: any[];
  unitInstances: Array<{
    id: string;
    nodeId: string;
    status: string;
    unitType: string;
    unitName: string;
    assigneeId?: string;
    assigneeName?: string;
    output?: any;
    startedAt?: string;
    completedAt?: string;
  }>;
}

interface FlowDetailProps {
  flowInstanceId: string;
  onBack: () => void;
  apiBase: string;
}

const STATUS_STYLES: Record<string, { bg: string; color: string }> = {
  running: { bg: "var(--status-blue-bg)", color: "var(--status-blue)" },
  waiting: { bg: "var(--status-amber-bg)", color: "var(--status-amber)" },
  completed: { bg: "var(--status-green-bg)", color: "var(--status-green)" },
  failed: { bg: "var(--status-red-bg)", color: "var(--status-red)" },
  cancelled: { bg: "var(--status-gray-bg)", color: "var(--status-gray)" },
  active: { bg: "var(--status-blue-bg)", color: "var(--status-blue)" },
  pending: { bg: "var(--status-gray-bg)", color: "var(--status-gray)" },
};

export function FlowDetail({
  flowInstanceId,
  onBack,
  apiBase,
}: FlowDetailProps) {
  const [data, setData] = useState<FlowDetailData | null>(null);
  const [loading, setLoading] = useState(true);

  const fetchDetail = async () => {
    try {
      const res = await fetch(`${apiBase}/flows/${flowInstanceId}`);
      if (res.ok) {
        setData(await res.json());
      }
    } catch (err) {
      console.error("Error fetching flow detail:", err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchDetail();
    const interval = setInterval(fetchDetail, 3000);
    return () => clearInterval(interval);
  }, [flowInstanceId]);

  if (loading) {
    return (
      <div
        style={{
          textAlign: "center",
          padding: "4rem",
          color: "var(--text-secondary)",
        }}
      >
        <RefreshCw
          size={32}
          style={{
            animation: "spin 1s linear infinite",
            margin: "0 auto 1rem",
            display: "block",
          }}
        />
        <p>Loading flow detail...</p>
      </div>
    );
  }

  if (!data) {
    return (
      <div
        style={{
          textAlign: "center",
          padding: "4rem",
          color: "var(--text-secondary)",
        }}
      >
        <p>Flow instance not found.</p>
        <button className="btn btn-primary" onClick={onBack}>
          Go Back
        </button>
      </div>
    );
  }

  const statusStyle = STATUS_STYLES[data.status] || STATUS_STYLES.running;

  return (
    <div>
      {/* Header */}
      <div
        style={{
          display: "flex",
          justifyContent: "space-between",
          alignItems: "center",
          marginBottom: "1.5rem",
        }}
      >
        <div style={{ display: "flex", alignItems: "center", gap: "0.75rem" }}>
          <button
            className="btn"
            style={{
              background: "var(--status-gray-bg)",
              color: "var(--text-secondary)",
              padding: "0.4rem 0.6rem",
            }}
            onClick={onBack}
          >
            <ArrowLeft size={18} />
          </button>
          <span style={{ fontSize: "1.75rem" }}>{data.flowIcon || "📄"}</span>
          <div>
            <h2 style={{ margin: 0 }}>{data.flowName}</h2>
            <span
              className="text-muted"
              style={{ fontSize: "0.8rem", fontFamily: "monospace" }}
            >
              {data.id}
            </span>
          </div>
        </div>
        <span
          className="badge"
          style={{
            backgroundColor: statusStyle.bg,
            color: statusStyle.color,
            fontSize: "0.85rem",
            padding: "0.3rem 0.8rem",
          }}
        >
          {data.status}
        </span>
      </div>

      {/* Info bar */}
      <div
        style={{
          display: "flex",
          gap: "2rem",
          marginBottom: "1.5rem",
          fontSize: "0.875rem",
          color: "var(--text-secondary)",
        }}
      >
        <span style={{ display: "flex", alignItems: "center", gap: "0.35rem" }}>
          <Clock size={14} /> Started:{" "}
          {new Date(data.startedAt).toLocaleString()}
        </span>
        {data.completedAt && (
          <span
            style={{ display: "flex", alignItems: "center", gap: "0.35rem" }}
          >
            <Clock size={14} /> Completed:{" "}
            {new Date(data.completedAt).toLocaleString()}
          </span>
        )}
        <span style={{ display: "flex", alignItems: "center", gap: "0.35rem" }}>
          <GitBranch size={14} /> {data.graph?.length || 0} nodes
        </span>
      </div>

      {/* Graph visualization */}
      <div className="card" style={{ marginBottom: "1.5rem", padding: "1rem" }}>
        <h3 style={{ margin: "0 0 1rem", fontSize: "1rem" }}>Flow Graph</h3>
        <FlowGraph
          graph={data.graph || []}
          unitInstances={data.unitInstances || []}
          activeNodes={data.currentNodeIds || []}
        />
      </div>

      {/* Unit Instances table */}
      <div className="card">
        <h3 style={{ margin: "0 0 1rem", fontSize: "1rem" }}>
          Unit Instances ({data.unitInstances?.length || 0})
        </h3>

        {!data.unitInstances || data.unitInstances.length === 0 ? (
          <p className="text-muted">
            No unit instances yet. The flow may still be initializing.
          </p>
        ) : (
          <div style={{ overflowX: "auto" }}>
            <table
              style={{
                width: "100%",
                borderCollapse: "collapse",
                fontSize: "0.875rem",
              }}
            >
              <thead>
                <tr
                  style={{
                    borderBottom: "2px solid var(--border-color)",
                    textAlign: "left",
                  }}
                >
                  <th
                    style={{
                      padding: "0.5rem",
                      color: "var(--text-secondary)",
                      fontWeight: 600,
                    }}
                  >
                    Node
                  </th>
                  <th
                    style={{
                      padding: "0.5rem",
                      color: "var(--text-secondary)",
                      fontWeight: 600,
                    }}
                  >
                    Type
                  </th>
                  <th
                    style={{
                      padding: "0.5rem",
                      color: "var(--text-secondary)",
                      fontWeight: 600,
                    }}
                  >
                    Name
                  </th>
                  <th
                    style={{
                      padding: "0.5rem",
                      color: "var(--text-secondary)",
                      fontWeight: 600,
                    }}
                  >
                    Assignee
                  </th>
                  <th
                    style={{
                      padding: "0.5rem",
                      color: "var(--text-secondary)",
                      fontWeight: 600,
                    }}
                  >
                    Status
                  </th>
                  <th
                    style={{
                      padding: "0.5rem",
                      color: "var(--text-secondary)",
                      fontWeight: 600,
                    }}
                  >
                    Output
                  </th>
                </tr>
              </thead>
              <tbody>
                {data.unitInstances.map((ui) => {
                  const uiStatus =
                    STATUS_STYLES[ui.status] || STATUS_STYLES.pending;
                  return (
                    <tr
                      key={ui.id}
                      style={{ borderBottom: "1px solid var(--border-color)" }}
                    >
                      <td
                        style={{ padding: "0.5rem", fontFamily: "monospace" }}
                      >
                        #{ui.nodeId}
                      </td>
                      <td style={{ padding: "0.5rem" }}>
                        <UnitTypeBadge type={ui.unitType} />
                      </td>
                      <td style={{ padding: "0.5rem", fontWeight: 500 }}>
                        {ui.unitName}
                      </td>
                      <td
                        style={{
                          padding: "0.5rem",
                          display: "flex",
                          alignItems: "center",
                          gap: "0.35rem",
                        }}
                      >
                        {ui.assigneeName ? (
                          <>
                            <User size={14} style={{ opacity: 0.5 }} />
                            {ui.assigneeName}
                          </>
                        ) : (
                          <span className="text-muted">—</span>
                        )}
                      </td>
                      <td style={{ padding: "0.5rem" }}>
                        <span
                          className="badge"
                          style={{
                            backgroundColor: uiStatus.bg,
                            color: uiStatus.color,
                          }}
                        >
                          {ui.status}
                        </span>
                      </td>
                      <td
                        style={{
                          padding: "0.5rem",
                          fontFamily: "monospace",
                          fontSize: "0.75rem",
                          maxWidth: "200px",
                          overflow: "hidden",
                          textOverflow: "ellipsis",
                          whiteSpace: "nowrap",
                        }}
                      >
                        {ui.output ? JSON.stringify(ui.output) : "—"}
                      </td>
                    </tr>
                  );
                })}
              </tbody>
            </table>
          </div>
        )}
      </div>
    </div>
  );
}
