import { Box, CheckSquare, FileText, History, Settings } from "lucide-react";

export const USERS = [
  { id: "clerk-uuid", name: "John Smith (Clerk)", role: "clerk" },
  { id: "reviewer-uuid", name: "Jane Doe (Reviewer)", role: "reviewer" },
  { id: "head-uuid", name: "Dr. Adams (Dept Head)", role: "department_head" },
  { id: "director-uuid", name: "Dir. Bates (Director)", role: "director" },
  { id: "minister-uuid", name: "Min. Clark (Signatory)", role: "signatory" },
];

interface SidebarProps {
  currentView: string;
  setCurrentView: (v: string) => void;
  activeUserId: string;
  setActiveUserId: (id: string) => void;
}

export function Sidebar({
  currentView,
  setCurrentView,
  activeUserId,
  setActiveUserId,
}: SidebarProps) {
  const activeUser = USERS.find((u) => u.id === activeUserId);

  return (
    <aside className="sidebar">
      <div className="sidebar-header">
        <h1>
          <Box size={24} />
          Gov Docs
        </h1>
      </div>

      <nav className="sidebar-nav">
        <div
          className={`nav-item ${currentView === "tasks" ? "active" : ""}`}
          onClick={() => setCurrentView("tasks")}
        >
          <CheckSquare size={20} />
          <span>My Tasks</span>
        </div>
        <div
          className={`nav-item ${currentView === "tracker" ? "active" : ""}`}
          onClick={() => setCurrentView("tracker")}
        >
          <FileText size={20} />
          <span>Document Tracker</span>
        </div>
        <div
          className={`nav-item ${currentView === "audit" ? "active" : ""}`}
          onClick={() => setCurrentView("audit")}
        >
          <History size={20} />
          <span>Audit Audit</span>
        </div>
        <div className="nav-item">
          <Settings size={20} />
          <span>Admin</span>
        </div>
      </nav>

      <div className="user-selector">
        <label
          className="text-muted"
          style={{ display: "block", marginBottom: "0.25rem" }}
        >
          Simulating as:
        </label>
        <div className="select-wrapper">
          <select
            value={activeUserId}
            onChange={(e) => setActiveUserId(e.target.value)}
          >
            {USERS.map((u) => (
              <option key={u.id} value={u.id}>
                {u.name}
              </option>
            ))}
          </select>
        </div>
        {activeUser && (
          <div
            style={{
              marginTop: "0.5rem",
              fontSize: "0.75rem",
              color: "var(--text-secondary)",
            }}
          >
            Role ID:{" "}
            <code
              style={{
                background: "#f1f5f9",
                padding: "2px 4px",
                borderRadius: "4px",
              }}
            >
              {activeUser.role}
            </code>
          </div>
        )}
      </div>
    </aside>
  );
}
