import { useState, useEffect } from "react";
import { Bell, X } from "lucide-react";

interface ToastNotification {
  id: string;
  title: string;
  message: string;
}

interface NotificationToastContainerProps {
  toasts: ToastNotification[];
  onDismiss: (id: string) => void;
}

function SingleToast({
  toast,
  onDismiss,
}: {
  toast: ToastNotification;
  onDismiss: () => void;
}) {
  const [exiting, setExiting] = useState(false);

  useEffect(() => {
    const timer = setTimeout(() => {
      setExiting(true);
      setTimeout(onDismiss, 300);
    }, 5000);
    return () => clearTimeout(timer);
  }, [onDismiss]);

  return (
    <div
      style={{
        display: "flex",
        alignItems: "flex-start",
        gap: "0.75rem",
        background: "var(--surface-color)",
        border: "1px solid var(--border-color)",
        borderRadius: "8px",
        padding: "0.85rem 1rem",
        boxShadow: "0 4px 16px rgba(0,0,0,0.12)",
        minWidth: "320px",
        maxWidth: "400px",
        opacity: exiting ? 0 : 1,
        transform: exiting ? "translateX(100%)" : "translateX(0)",
        transition: "opacity 0.3s ease, transform 0.3s ease",
        animation: "slideInRight 0.3s ease",
      }}
    >
      <div
        style={{
          background: "var(--status-blue-bg)",
          borderRadius: "50%",
          width: "32px",
          height: "32px",
          display: "flex",
          alignItems: "center",
          justifyContent: "center",
          flexShrink: 0,
        }}
      >
        <Bell size={16} style={{ color: "var(--status-blue)" }} />
      </div>
      <div style={{ flex: 1, minWidth: 0 }}>
        <div
          style={{
            fontWeight: 600,
            fontSize: "0.85rem",
            color: "var(--text-primary)",
            marginBottom: "0.15rem",
          }}
        >
          {toast.title}
        </div>
        <div
          style={{
            fontSize: "0.8rem",
            color: "var(--text-secondary)",
            lineHeight: 1.4,
          }}
        >
          {toast.message}
        </div>
      </div>
      <button
        onClick={(e) => {
          e.stopPropagation();
          setExiting(true);
          setTimeout(onDismiss, 300);
        }}
        style={{
          background: "none",
          border: "none",
          cursor: "pointer",
          color: "var(--text-secondary)",
          padding: "2px",
          flexShrink: 0,
        }}
      >
        <X size={14} />
      </button>
    </div>
  );
}

export function NotificationToastContainer({
  toasts,
  onDismiss,
}: NotificationToastContainerProps) {
  if (toasts.length === 0) return null;

  return (
    <>
      <style>{`
        @keyframes slideInRight {
          from { opacity: 0; transform: translateX(100%); }
          to   { opacity: 1; transform: translateX(0); }
        }
      `}</style>
      <div
        style={{
          position: "fixed",
          top: "1rem",
          right: "1rem",
          zIndex: 9999,
          display: "flex",
          flexDirection: "column",
          gap: "0.5rem",
          pointerEvents: "auto",
        }}
      >
        {toasts.map((t) => (
          <SingleToast key={t.id} toast={t} onDismiss={() => onDismiss(t.id)} />
        ))}
      </div>
    </>
  );
}
