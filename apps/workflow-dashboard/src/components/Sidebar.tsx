import {
  Box,
  CheckSquare,
  FileText,
  History,
  Settings,
  LayoutGrid,
  ClipboardCheck,
  GitBranch,
  Shield,
  Eye,
} from "lucide-react";

export const USERS = [
  { id: "clerk-uuid", name: "John Smith (Clerk)", role: "clerk" },
  { id: "reviewer-uuid", name: "Jane Doe (Reviewer)", role: "reviewer" },
  { id: "head-uuid", name: "Dr. Adams (Dept Head)", role: "department_head" },
  { id: "director-uuid", name: "Dir. Bates (Director)", role: "director" },
  { id: "minister-uuid", name: "Min. Clark (Signatory)", role: "signatory" },
  { id: "accountant-uuid", name: "Ms. Davis (Accountant)", role: "accountant" },
  { id: "hr-uuid", name: "Mr. Evans (HR)", role: "hr_officer" },
  { id: "secretary-uuid", name: "Ms. Fisher (Secretary)", role: "secretary" },
];

interface SidebarProps {
  currentView: string;
  setCurrentView: (v: string) => void;
  activeUserId: string;
  setActiveUserId: (id: string) => void;
  flowTaskCount?: number;
}

export function Sidebar({
  currentView,
  setCurrentView,
  activeUserId,
  setActiveUserId,
  flowTaskCount = 0,
}: SidebarProps) {
  const activeUser = USERS.find((u) => u.id === activeUserId);

  return (
    <aside className="sidebar">
      <div className="sidebar-header">
        <h1>
          <Box size={24} />
          Flow Engine
        </h1>
      </div>

      <nav className="sidebar-nav">
        {/* Flow Engine section */}
        <div className="nav-section-label">Flow Engine</div>

        <div
          className={`nav-item ${currentView === "flow-catalog" ? "active" : ""}`}
          onClick={() => setCurrentView("flow-catalog")}
        >
          <LayoutGrid size={20} />
          <span>Flow Catalog</span>
        </div>

        <div
          className={`nav-item ${currentView === "flow-tasks" ? "active" : ""}`}
          onClick={() => setCurrentView("flow-tasks")}
        >
          <ClipboardCheck size={20} />
          <span>My Tasks</span>
          {flowTaskCount > 0 && (
            <span
              style={{
                marginLeft: "auto",
                background: "var(--status-red)",
                color: "white",
                borderRadius: "9999px",
                padding: "0.1rem 0.5rem",
                fontSize: "0.7rem",
                fontWeight: 700,
              }}
            >
              {flowTaskCount}
            </span>
          )}
        </div>

        <div
          className={`nav-item ${currentView === "flow-instances" || currentView === "flow-detail" ? "active" : ""}`}
          onClick={() => setCurrentView("flow-instances")}
        >
          <GitBranch size={20} />
          <span>Flow Instances</span>
        </div>

        <div
          className={`nav-item ${currentView === "flow-audit" ? "active" : ""}`}
          onClick={() => setCurrentView("flow-audit")}
        >
          <Shield size={20} />
          <span>Audit Trail</span>
        </div>

        {/* Legacy section */}
        <div className="nav-section-label" style={{ marginTop: "0.5rem" }}>
          Legacy System
        </div>

        <div
          className={`nav-item ${currentView === "tasks" ? "active" : ""}`}
          onClick={() => setCurrentView("tasks")}
        >
          <CheckSquare size={20} />
          <span>Doc Tasks</span>
        </div>

        <div
          className={`nav-item ${currentView === "tracker" ? "active" : ""}`}
          onClick={() => setCurrentView("tracker")}
        >
          <FileText size={20} />
          <span>Doc Tracker</span>
        </div>

        <div
          className={`nav-item ${currentView === "audit" ? "active" : ""}`}
          onClick={() => setCurrentView("audit")}
        >
          <History size={20} />
          <span>Doc Audit</span>
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
            Role:{" "}
            <code
              style={{
                background: "var(--status-gray-bg)",
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
