import { useState } from "react";
import { Play, X, UserPlus } from "lucide-react";
import { USERS } from "../components/Sidebar";

interface FlowDefinition {
  id: string;
  name: string;
  description: string;
  icon?: string;
  roles: string[];
  graph: any[];
}

interface StartFlowProps {
  flowDefinition: FlowDefinition;
  onStart: (data: {
    flowDefinitionId: string;
    roleAssignments: Record<string, string>;
    variables: Record<string, any>;
    startedBy: string;
  }) => void;
  onCancel: () => void;
  activeUserId: string;
}

export function StartFlow({
  flowDefinition,
  onStart,
  onCancel,
  activeUserId,
}: StartFlowProps) {
  const [roleAssignments, setRoleAssignments] = useState<
    Record<string, string>
  >(() => {
    // Pre-fill initiator with active user
    const init: Record<string, string> = {};
    for (const role of flowDefinition.roles) {
      if (role === "initiator") {
        init[role] = activeUserId;
      } else {
        // Auto-assign based on matching user roles
        const matchingUser = USERS.find((u) => u.role === role);
        if (matchingUser) init[role] = matchingUser.id;
        else init[role] = "";
      }
    }
    return init;
  });

  const [variables, setVariables] = useState<Record<string, string>>({});
  const [newVarKey, setNewVarKey] = useState("");
  const [newVarValue, setNewVarValue] = useState("");

  const handleAddVariable = () => {
    if (newVarKey && newVarValue) {
      setVariables((prev) => ({ ...prev, [newVarKey]: newVarValue }));
      setNewVarKey("");
      setNewVarValue("");
    }
  };

  const handleRemoveVariable = (key: string) => {
    setVariables((prev) => {
      const next = { ...prev };
      delete next[key];
      return next;
    });
  };

  const handleSubmit = () => {
    onStart({
      flowDefinitionId: flowDefinition.id,
      roleAssignments,
      variables,
      startedBy: activeUserId,
    });
  };

  const allRolesAssigned = flowDefinition.roles.every(
    (role) => roleAssignments[role] && roleAssignments[role] !== "",
  );

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
        <div style={{ display: "flex", alignItems: "center", gap: "0.75rem" }}>
          <span style={{ fontSize: "1.75rem" }}>
            {flowDefinition.icon || "📄"}
          </span>
          <div>
            <h2 style={{ margin: 0 }}>Start: {flowDefinition.name}</h2>
            <p
              className="text-muted"
              style={{ margin: 0, fontSize: "0.875rem" }}
            >
              {flowDefinition.description}
            </p>
          </div>
        </div>
        <button
          className="btn"
          style={{
            background: "var(--status-gray-bg)",
            color: "var(--text-secondary)",
          }}
          onClick={onCancel}
        >
          <X size={16} /> Cancel
        </button>
      </div>

      {/* Role Assignments */}
      <div className="card" style={{ marginBottom: "1.5rem" }}>
        <h3
          style={{
            display: "flex",
            alignItems: "center",
            gap: "0.5rem",
            margin: "0 0 1rem",
          }}
        >
          <UserPlus size={20} /> Role Assignments
        </h3>
        <p
          className="text-muted"
          style={{ fontSize: "0.875rem", marginBottom: "1rem" }}
        >
          Assign a user to each role required by this flow.
        </p>

        <div
          style={{
            display: "grid",
            gridTemplateColumns: "1fr 1fr",
            gap: "0.75rem",
          }}
        >
          {flowDefinition.roles.map((role) => (
            <div key={role}>
              <label
                style={{
                  display: "block",
                  fontSize: "0.8rem",
                  fontWeight: 600,
                  marginBottom: "0.25rem",
                  textTransform: "capitalize",
                }}
              >
                {role.replace(/_/g, " ")}
              </label>
              <select
                className="input-field"
                style={{ marginBottom: 0 }}
                value={roleAssignments[role] || ""}
                onChange={(e) =>
                  setRoleAssignments((prev) => ({
                    ...prev,
                    [role]: e.target.value,
                  }))
                }
              >
                <option value="">Select user...</option>
                {USERS.map((u) => (
                  <option key={u.id} value={u.id}>
                    {u.name} ({u.role})
                  </option>
                ))}
              </select>
            </div>
          ))}
        </div>
      </div>

      {/* Variables */}
      <div className="card" style={{ marginBottom: "1.5rem" }}>
        <h3 style={{ margin: "0 0 1rem" }}>Variables (Optional)</h3>
        <p
          className="text-muted"
          style={{ fontSize: "0.875rem", marginBottom: "1rem" }}
        >
          Add initial variables for the flow context.
        </p>

        {Object.entries(variables).length > 0 && (
          <div style={{ marginBottom: "1rem" }}>
            {Object.entries(variables).map(([key, value]) => (
              <div
                key={key}
                style={{
                  display: "flex",
                  justifyContent: "space-between",
                  alignItems: "center",
                  padding: "0.5rem 0.75rem",
                  background: "var(--status-gray-bg)",
                  borderRadius: "6px",
                  marginBottom: "0.5rem",
                  fontSize: "0.875rem",
                }}
              >
                <span>
                  <strong>{key}</strong>: {value}
                </span>
                <button
                  onClick={() => handleRemoveVariable(key)}
                  style={{
                    background: "none",
                    border: "none",
                    cursor: "pointer",
                    color: "var(--status-red)",
                    padding: "0.25rem",
                  }}
                >
                  <X size={14} />
                </button>
              </div>
            ))}
          </div>
        )}

        <div style={{ display: "flex", gap: "0.5rem" }}>
          <input
            type="text"
            className="input-field"
            placeholder="Key"
            value={newVarKey}
            onChange={(e) => setNewVarKey(e.target.value)}
            style={{ marginBottom: 0, flex: 1 }}
          />
          <input
            type="text"
            className="input-field"
            placeholder="Value"
            value={newVarValue}
            onChange={(e) => setNewVarValue(e.target.value)}
            style={{ marginBottom: 0, flex: 1 }}
          />
          <button
            className="btn btn-primary"
            onClick={handleAddVariable}
            disabled={!newVarKey || !newVarValue}
          >
            Add
          </button>
        </div>
      </div>

      {/* Submit */}
      <button
        className="btn btn-success"
        style={{ width: "100%", padding: "0.75rem", fontSize: "1rem" }}
        onClick={handleSubmit}
        disabled={!allRolesAssigned}
      >
        <Play size={18} /> Launch Flow
      </button>
      {!allRolesAssigned && (
        <p
          className="text-muted"
          style={{
            textAlign: "center",
            marginTop: "0.5rem",
            fontSize: "0.8rem",
          }}
        >
          All roles must be assigned before starting the flow.
        </p>
      )}
    </div>
  );
}
