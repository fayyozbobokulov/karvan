import { useState } from "react";
import { StatusBadge } from "../components/StatusBadge";
import { FileText, Plus, Search } from "lucide-react";
import { USERS } from "../components/Sidebar";

const STAGES = [
  "submitted",
  "validating",
  "in_review",
  "in_approval",
  "awaiting_signature",
  "registering",
  "distributing",
  "completed",
];

interface Document {
  id: string;
  title: string;
  status: string;
  authorId: string;
}

export function DocumentTracker({
  documents,
  onSubmit,
}: {
  documents: Document[];
  onSubmit: (title: string, authorId: string) => void;
}) {
  const [newTitle, setNewTitle] = useState("");
  const [search, setSearch] = useState("");

  const filteredDocs = documents.filter(
    (d) =>
      d.title.toLowerCase().includes(search.toLowerCase()) ||
      d.id.includes(search),
  );

  const getStageIndex = (status: string) => {
    const idx = STAGES.indexOf(status);
    return idx === -1 ? 0 : idx;
  };

  return (
    <div>
      <div
        style={{
          display: "flex",
          justifyContent: "space-between",
          alignItems: "center",
          marginBottom: "2rem",
        }}
      >
        <h2>Document Tracker</h2>

        <div style={{ display: "flex", gap: "1rem" }}>
          <div style={{ position: "relative" }}>
            <Search
              size={16}
              style={{
                position: "absolute",
                left: "0.5rem",
                top: "0.6rem",
                color: "var(--text-secondary)",
              }}
            />
            <input
              type="text"
              className="input-field"
              placeholder="Search documents..."
              value={search}
              onChange={(e) => setSearch(e.target.value)}
              style={{ paddingLeft: "2rem", marginBottom: 0, width: "250px" }}
            />
          </div>
        </div>
      </div>

      <div
        className="card"
        style={{ marginBottom: "2rem", backgroundColor: "var(--bg-color)" }}
      >
        <h3 style={{ fontSize: "1rem", marginBottom: "1rem" }}>
          Launch New Document
        </h3>
        <div style={{ display: "flex", gap: "1rem", alignItems: "center" }}>
          <input
            type="text"
            className="input-field"
            placeholder="e.g. Procurement Order #2026-X"
            value={newTitle}
            onChange={(e) => setNewTitle(e.target.value)}
            style={{ marginBottom: 0, flex: 2 }}
          />
          <button
            className="btn btn-primary"
            onClick={() => {
              if (newTitle) {
                onSubmit(newTitle, USERS[0].id); // Default to clerk
                setNewTitle("");
              }
            }}
          >
            <Plus size={16} /> Submit to Workflow
          </button>
        </div>
      </div>

      <div className="pipeline-container">
        <div className="pipeline">
          {STAGES.map((stage, idx) => {
            const stageDocs = filteredDocs.filter(
              (d) => getStageIndex(d.status) === idx,
            );

            return (
              <div key={stage} className="pipeline-stage">
                <div
                  style={{
                    display: "flex",
                    justifyContent: "space-between",
                    alignItems: "center",
                    marginBottom: "1rem",
                    borderBottom: "2px solid var(--border-color)",
                    paddingBottom: "0.5rem",
                  }}
                >
                  <h3
                    style={{
                      margin: 0,
                      borderBottom: "none",
                      paddingBottom: 0,
                    }}
                  >
                    {stage.replace("_", " ")}
                  </h3>
                  <span
                    style={{
                      backgroundColor: "var(--border-color)",
                      padding: "0.1rem 0.5rem",
                      borderRadius: "99px",
                      fontSize: "0.75rem",
                      fontWeight: "bold",
                    }}
                  >
                    {stageDocs.length}
                  </span>
                </div>

                <div
                  style={{
                    display: "flex",
                    flexDirection: "column",
                    gap: "0.5rem",
                  }}
                >
                  {stageDocs.map((doc) => (
                    <div
                      key={doc.id}
                      className="card"
                      style={{ padding: "1rem", marginBottom: 0 }}
                    >
                      <div
                        style={{
                          display: "flex",
                          gap: "0.5rem",
                          alignItems: "flex-start",
                          marginBottom: "0.5rem",
                        }}
                      >
                        <FileText
                          size={16}
                          style={{
                            color: "var(--primary)",
                            marginTop: "0.1rem",
                          }}
                        />
                        <span
                          style={{
                            fontWeight: 500,
                            fontSize: "0.875rem",
                            lineHeight: 1.2,
                          }}
                        >
                          {doc.title}
                        </span>
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
                          style={{
                            fontSize: "0.75rem",
                            fontFamily: "monospace",
                          }}
                        >
                          ...{doc.id.slice(-6)}
                        </span>
                        <StatusBadge status={doc.status} />
                      </div>
                    </div>
                  ))}
                  {stageDocs.length === 0 && (
                    <div
                      className="text-muted"
                      style={{
                        textAlign: "center",
                        padding: "1rem 0",
                        fontStyle: "italic",
                        fontSize: "0.875rem",
                      }}
                    >
                      Empty
                    </div>
                  )}
                </div>
              </div>
            );
          })}
        </div>
      </div>
    </div>
  );
}
