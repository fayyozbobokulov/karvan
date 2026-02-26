import { useState, useEffect } from "react";
import { History, FileText, Activity } from "lucide-react";
import { StatusBadge } from "../components/StatusBadge";

interface AuditLog {
  id: string;
  documentId: string;
  action: string;
  fromStatus: string;
  toStatus: string;
  createdAt: string;
}

interface Document {
  id: string;
  title: string;
  status: string;
}

export function AuditTrail({
  documents,
  baseUrl,
}: {
  documents: Document[];
  baseUrl: string;
}) {
  const [selectedDocId, setSelectedDocId] = useState<string>("");
  const [logs, setLogs] = useState<AuditLog[]>([]);
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    if (!selectedDocId) {
      setLogs([]);
      return;
    }

    const fetchLogs = async () => {
      setLoading(true);
      try {
        const res = await fetch(`${baseUrl}/${selectedDocId}/audit`);
        const data = await res.json();
        setLogs(data);
      } catch (e) {
        console.error("Failed to fetch logs", e);
      } finally {
        setLoading(false);
      }
    };

    fetchLogs();
  }, [selectedDocId, baseUrl]);

  return (
    <div
      style={{
        display: "flex",
        gap: "2rem",
        height: "calc(100vh - 4rem)",
        paddingBottom: "2rem",
      }}
    >
      {/* Left panel: Document list */}
      <div
        className="card"
        style={{
          width: "350px",
          overflowY: "auto",
          display: "flex",
          flexDirection: "column",
        }}
      >
        <h3
          style={{
            display: "flex",
            alignItems: "center",
            gap: "0.5rem",
            marginBottom: "1.5rem",
          }}
        >
          <FileText size={20} /> Select Document
        </h3>

        <div
          style={{ display: "flex", flexDirection: "column", gap: "0.5rem" }}
        >
          {documents.map((doc) => (
            <div
              key={doc.id}
              onClick={() => setSelectedDocId(doc.id)}
              style={{
                padding: "1rem",
                borderRadius: "8px",
                border: `1px solid ${selectedDocId === doc.id ? "var(--primary)" : "var(--border-color)"}`,
                backgroundColor:
                  selectedDocId === doc.id
                    ? "var(--status-blue-bg)"
                    : "transparent",
                cursor: "pointer",
                transition: "all 0.2s",
              }}
            >
              <div style={{ fontWeight: 500, marginBottom: "0.25rem" }}>
                {doc.title}
              </div>
              <div
                style={{
                  display: "flex",
                  justifyContent: "space-between",
                  alignItems: "center",
                }}
              >
                <span
                  className="text-muted"
                  style={{ fontSize: "0.75rem", fontFamily: "monospace" }}
                >
                  ...{doc.id.slice(-8)}
                </span>
                <StatusBadge status={doc.status} />
              </div>
            </div>
          ))}
          {documents.length === 0 && (
            <p className="text-muted">No documents found in system.</p>
          )}
        </div>
      </div>

      {/* Right panel: Timeline */}
      <div className="card" style={{ flex: 1, overflowY: "auto" }}>
        <h3
          style={{
            display: "flex",
            alignItems: "center",
            gap: "0.5rem",
            marginBottom: "2rem",
            paddingBottom: "1rem",
            borderBottom: "1px solid var(--border-color)",
          }}
        >
          <Activity size={20} /> Immutable Audit History
        </h3>

        {!selectedDocId ? (
          <div
            style={{
              textAlign: "center",
              color: "var(--text-secondary)",
              marginTop: "4rem",
            }}
          >
            <History
              size={48}
              style={{ opacity: 0.2, margin: "0 auto 1rem" }}
            />
            <p>
              Select a document from the left panel to securely view its
              transition history.
            </p>
          </div>
        ) : loading ? (
          <p>Loading secure logs...</p>
        ) : logs.length === 0 ? (
          <p className="text-muted">
            No audit logs found for this document yet.
          </p>
        ) : (
          <div className="timeline">
            {logs.map((log) => (
              <div key={log.id} className="timeline-event">
                <div
                  style={{
                    fontWeight: 600,
                    color: "var(--text-primary)",
                    marginBottom: "0.25rem",
                    textTransform: "capitalize",
                  }}
                >
                  System Action: {log.action.replace(/_/g, " ")}
                </div>
                <div
                  style={{
                    display: "flex",
                    alignItems: "center",
                    gap: "0.5rem",
                    marginBottom: "0.5rem",
                  }}
                >
                  <StatusBadge status={log.fromStatus} />
                  <span style={{ color: "var(--text-secondary)" }}>→</span>
                  <StatusBadge status={log.toStatus} />
                </div>
                <div className="text-muted" style={{ fontSize: "0.75rem" }}>
                  {new Date(log.createdAt).toLocaleString()} | Record ID:{" "}
                  <span style={{ fontFamily: "monospace" }}>{log.id}</span>
                </div>
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  );
}
