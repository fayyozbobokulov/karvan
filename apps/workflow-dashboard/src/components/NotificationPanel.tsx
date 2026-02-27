import { Bell, CheckCheck, X, ExternalLink } from "lucide-react";

interface Notification {
  id: string;
  recipientId: string;
  type: string;
  title: string;
  message: string;
  flowInstanceId: string | null;
  flowDefinitionId: string | null;
  isRead: boolean;
  createdAt: string;
}

interface NotificationPanelProps {
  notifications: Notification[];
  unreadCount: number;
  isOpen: boolean;
  onToggle: () => void;
  onMarkAsRead: (id: string) => void;
  onMarkAllAsRead: () => void;
  onViewFlow: (flowInstanceId: string) => void;
}

const TYPE_COLORS: Record<string, string> = {
  task_assigned: "var(--status-blue)",
  action_completed: "var(--status-green)",
  flow_completed: "var(--status-green)",
  flow_failed: "var(--status-red)",
  rejection: "var(--status-red)",
  request_change: "var(--status-amber)",
  timeout: "var(--status-orange)",
  info: "var(--status-gray)",
};

function timeAgo(dateStr: string) {
  const diff = Date.now() - new Date(dateStr).getTime();
  const mins = Math.floor(diff / 60000);
  if (mins < 1) return "just now";
  if (mins < 60) return `${mins}m ago`;
  const hours = Math.floor(mins / 60);
  if (hours < 24) return `${hours}h ago`;
  const days = Math.floor(hours / 24);
  return `${days}d ago`;
}

export function NotificationPanel({
  notifications,
  unreadCount,
  isOpen,
  onToggle,
  onMarkAsRead,
  onMarkAllAsRead,
  onViewFlow,
}: NotificationPanelProps) {
  return (
    <div>
      {/* Bell nav item */}
      <div onClick={onToggle} className={`nav-item ${isOpen ? "active" : ""}`}>
        <Bell size={20} />
        <span>Notifications</span>
        {unreadCount > 0 && (
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
            {unreadCount}
          </span>
        )}
      </div>

      {/* Slide-out panel */}
      {isOpen && (
        <div
          style={{
            position: "fixed",
            left: "260px",
            top: 0,
            bottom: 0,
            width: "380px",
            backgroundColor: "var(--surface-color)",
            borderRight: "1px solid var(--border-color)",
            boxShadow: "4px 0 12px rgba(0,0,0,0.08)",
            zIndex: 100,
            display: "flex",
            flexDirection: "column",
            overflow: "hidden",
          }}
        >
          {/* Header */}
          <div
            style={{
              padding: "1rem 1.25rem",
              borderBottom: "1px solid var(--border-color)",
              display: "flex",
              justifyContent: "space-between",
              alignItems: "center",
            }}
          >
            <h3 style={{ margin: 0, fontSize: "1rem" }}>Notifications</h3>
            <div
              style={{ display: "flex", gap: "0.5rem", alignItems: "center" }}
            >
              {unreadCount > 0 && (
                <button
                  className="btn"
                  style={{
                    padding: "0.25rem 0.5rem",
                    fontSize: "0.75rem",
                    background: "var(--bg-color)",
                    border: "1px solid var(--border-color)",
                  }}
                  onClick={onMarkAllAsRead}
                >
                  <CheckCheck size={14} /> Mark all read
                </button>
              )}
              <button
                onClick={onToggle}
                style={{
                  background: "none",
                  border: "none",
                  cursor: "pointer",
                  color: "var(--text-secondary)",
                  padding: "0.25rem",
                }}
              >
                <X size={18} />
              </button>
            </div>
          </div>

          {/* Notification list */}
          <div style={{ flex: 1, overflowY: "auto" }}>
            {notifications.length === 0 ? (
              <div
                style={{
                  textAlign: "center",
                  padding: "3rem 1rem",
                  color: "var(--text-secondary)",
                }}
              >
                <Bell
                  size={36}
                  style={{
                    opacity: 0.2,
                    marginBottom: "0.75rem",
                    display: "block",
                    margin: "0 auto 0.75rem",
                  }}
                />
                <p>No notifications yet</p>
              </div>
            ) : (
              notifications.map((n) => (
                <div
                  key={n.id}
                  style={{
                    padding: "0.75rem 1.25rem",
                    borderBottom: "1px solid var(--border-color)",
                    backgroundColor: n.isRead
                      ? "transparent"
                      : "var(--status-blue-bg)",
                    cursor: "pointer",
                    transition: "background-color 0.15s",
                  }}
                  onClick={() => {
                    if (!n.isRead) onMarkAsRead(n.id);
                    if (n.flowInstanceId) onViewFlow(n.flowInstanceId);
                  }}
                >
                  <div
                    style={{
                      display: "flex",
                      alignItems: "flex-start",
                      gap: "0.75rem",
                    }}
                  >
                    <div
                      style={{
                        width: "8px",
                        height: "8px",
                        borderRadius: "50%",
                        backgroundColor: n.isRead
                          ? "transparent"
                          : TYPE_COLORS[n.type] || "var(--status-gray)",
                        marginTop: "0.4rem",
                        flexShrink: 0,
                      }}
                    />
                    <div style={{ flex: 1, minWidth: 0 }}>
                      <div
                        style={{
                          fontWeight: n.isRead ? 400 : 600,
                          fontSize: "0.85rem",
                          marginBottom: "0.2rem",
                        }}
                      >
                        {n.title}
                      </div>
                      <div
                        style={{
                          fontSize: "0.8rem",
                          color: "var(--text-secondary)",
                          marginBottom: "0.3rem",
                        }}
                      >
                        {n.message}
                      </div>
                      <div
                        style={{
                          display: "flex",
                          justifyContent: "space-between",
                          alignItems: "center",
                        }}
                      >
                        <span
                          style={{
                            fontSize: "0.7rem",
                            color: "var(--text-secondary)",
                          }}
                        >
                          {timeAgo(n.createdAt)}
                        </span>
                        {n.flowInstanceId && (
                          <ExternalLink
                            size={12}
                            style={{ color: "var(--primary)" }}
                          />
                        )}
                      </div>
                    </div>
                  </div>
                </div>
              ))
            )}
          </div>
        </div>
      )}
    </div>
  );
}
