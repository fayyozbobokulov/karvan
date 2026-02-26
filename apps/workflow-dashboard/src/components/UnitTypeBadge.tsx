const TYPE_STYLES: Record<
  string,
  { bg: string; color: string; label: string }
> = {
  DOCUMENT: { bg: "#eff6ff", color: "#3b82f6", label: "Document" },
  TASK: { bg: "#fffbeb", color: "#f59e0b", label: "Task" },
  ACTION: { bg: "#fff7ed", color: "#f97316", label: "Action" },
  CONDITION: { bg: "#f5f3ff", color: "#8b5cf6", label: "Condition" },
  NOTIFICATION: { bg: "#ecfeff", color: "#06b6d4", label: "Notification" },
  AUTOMATION: { bg: "#ecfdf5", color: "#10b981", label: "Automation" },
  GATE: { bg: "#f1f5f9", color: "#64748b", label: "Gate" },
  PARALLEL: { bg: "#eef2ff", color: "#6366f1", label: "Parallel" },
};

export function UnitTypeBadge({ type }: { type: string }) {
  const style = TYPE_STYLES[type] || TYPE_STYLES.DOCUMENT;
  return (
    <span
      style={{
        display: "inline-flex",
        alignItems: "center",
        padding: "0.15rem 0.5rem",
        borderRadius: "4px",
        fontSize: "0.7rem",
        fontWeight: 600,
        letterSpacing: "0.03em",
        backgroundColor: style.bg,
        color: style.color,
        textTransform: "uppercase",
      }}
    >
      {style.label}
    </span>
  );
}
