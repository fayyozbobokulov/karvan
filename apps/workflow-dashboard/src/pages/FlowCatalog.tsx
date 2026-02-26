import { useState } from "react";
import { Play, GitBranch, Clock, Users } from "lucide-react";
import { UnitTypeBadge } from "../components/UnitTypeBadge";

interface FlowDefinition {
  id: string;
  name: string;
  description: string;
  icon?: string;
  color?: string;
  category?: string;
  roles: string[];
  graph: any[];
  estimatedDuration?: string;
}

interface FlowCatalogProps {
  flowDefinitions: FlowDefinition[];
  onStartFlow: (flowDefId: string) => void;
}

export function FlowCatalog({
  flowDefinitions,
  onStartFlow,
}: FlowCatalogProps) {
  const [search, setSearch] = useState("");
  const [filterCategory, setFilterCategory] = useState("");

  const categories = [
    ...new Set(flowDefinitions.map((f) => f.category).filter(Boolean)),
  ];

  const filtered = flowDefinitions.filter((f) => {
    const matchSearch =
      !search ||
      f.name.toLowerCase().includes(search.toLowerCase()) ||
      f.description?.toLowerCase().includes(search.toLowerCase());
    const matchCategory = !filterCategory || f.category === filterCategory;
    return matchSearch && matchCategory;
  });

  // Count unit types in a graph
  const getUnitTypeCounts = (graph: any[]): Record<string, number> => {
    const counts: Record<string, number> = {};
    for (const node of graph) {
      const prefix = node.unit.split(":")[0].toUpperCase();
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
      const type = typeMap[prefix] || prefix;
      counts[type] = (counts[type] || 0) + 1;
    }
    return counts;
  };

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
        <h2>Flow Catalog</h2>
        <div style={{ display: "flex", gap: "0.75rem" }}>
          <input
            type="text"
            className="input-field"
            placeholder="Search flows..."
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            style={{ marginBottom: 0, width: "200px" }}
          />
          <select
            className="input-field"
            value={filterCategory}
            onChange={(e) => setFilterCategory(e.target.value)}
            style={{ marginBottom: 0, width: "140px" }}
          >
            <option value="">All Categories</option>
            {categories.map((c) => (
              <option key={c} value={c!}>
                {c}
              </option>
            ))}
          </select>
        </div>
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
          <h3>No flow definitions found</h3>
          <p>Run the seed script to populate flow definitions.</p>
        </div>
      ) : (
        <div className="card-grid">
          {filtered.map((flow) => {
            const typeCounts = getUnitTypeCounts(flow.graph || []);
            return (
              <div
                key={flow.id}
                className="card"
                style={{ position: "relative" }}
              >
                {/* Color accent */}
                <div
                  style={{
                    position: "absolute",
                    top: 0,
                    left: 0,
                    right: 0,
                    height: "4px",
                    borderRadius: "8px 8px 0 0",
                    background: flow.color || "var(--primary)",
                  }}
                />

                <div className="card-header" style={{ marginTop: "0.25rem" }}>
                  <div
                    style={{
                      display: "flex",
                      alignItems: "center",
                      gap: "0.5rem",
                    }}
                  >
                    <span style={{ fontSize: "1.5rem" }}>
                      {flow.icon || "📄"}
                    </span>
                    <div>
                      <h3 style={{ margin: 0, fontSize: "1.1rem" }}>
                        {flow.name}
                      </h3>
                      {flow.category && (
                        <span
                          className="text-muted"
                          style={{
                            fontSize: "0.75rem",
                            textTransform: "uppercase",
                          }}
                        >
                          {flow.category}
                        </span>
                      )}
                    </div>
                  </div>
                </div>

                <p
                  className="text-muted"
                  style={{
                    margin: "0 0 1rem",
                    fontSize: "0.875rem",
                    lineHeight: 1.5,
                  }}
                >
                  {flow.description}
                </p>

                {/* Stats */}
                <div
                  style={{
                    display: "flex",
                    gap: "1rem",
                    marginBottom: "0.75rem",
                    fontSize: "0.8rem",
                    color: "var(--text-secondary)",
                  }}
                >
                  <span
                    style={{
                      display: "flex",
                      alignItems: "center",
                      gap: "0.25rem",
                    }}
                  >
                    <GitBranch size={14} /> {flow.graph?.length || 0} nodes
                  </span>
                  <span
                    style={{
                      display: "flex",
                      alignItems: "center",
                      gap: "0.25rem",
                    }}
                  >
                    <Users size={14} /> {flow.roles?.length || 0} roles
                  </span>
                  {flow.estimatedDuration && (
                    <span
                      style={{
                        display: "flex",
                        alignItems: "center",
                        gap: "0.25rem",
                      }}
                    >
                      <Clock size={14} /> {flow.estimatedDuration}
                    </span>
                  )}
                </div>

                {/* Unit type breakdown */}
                <div
                  style={{
                    display: "flex",
                    flexWrap: "wrap",
                    gap: "0.35rem",
                    marginBottom: "1rem",
                  }}
                >
                  {Object.entries(typeCounts).map(([type, count]) => (
                    <span
                      key={type}
                      style={{
                        display: "flex",
                        alignItems: "center",
                        gap: "0.2rem",
                      }}
                    >
                      <UnitTypeBadge type={type} />
                      <span
                        style={{
                          fontSize: "0.7rem",
                          color: "var(--text-secondary)",
                        }}
                      >
                        ×{count}
                      </span>
                    </span>
                  ))}
                </div>

                {/* Roles */}
                <div
                  style={{
                    borderTop: "1px solid var(--border-color)",
                    paddingTop: "0.75rem",
                  }}
                >
                  <div
                    className="text-muted"
                    style={{
                      fontSize: "0.7rem",
                      marginBottom: "0.35rem",
                      textTransform: "uppercase",
                      letterSpacing: "0.05em",
                    }}
                  >
                    Required Roles
                  </div>
                  <div
                    style={{
                      display: "flex",
                      flexWrap: "wrap",
                      gap: "0.25rem",
                    }}
                  >
                    {flow.roles?.map((role) => (
                      <span
                        key={role}
                        style={{
                          padding: "0.1rem 0.4rem",
                          borderRadius: "4px",
                          fontSize: "0.7rem",
                          background: "var(--status-gray-bg)",
                          color: "var(--text-secondary)",
                        }}
                      >
                        {role.replace(/_/g, " ")}
                      </span>
                    ))}
                  </div>
                </div>

                <button
                  className="btn btn-primary"
                  style={{ marginTop: "1rem", width: "100%" }}
                  onClick={() => onStartFlow(flow.id)}
                >
                  <Play size={16} /> Start Flow
                </button>
              </div>
            );
          })}
        </div>
      )}
    </div>
  );
}
