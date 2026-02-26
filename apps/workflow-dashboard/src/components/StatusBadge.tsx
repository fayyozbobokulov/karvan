export const StatusBadge = ({ status }: { status?: string }) => {
  if (!status) return null;

  // The CSS classes match the government scenario statuses
  return (
    <span className={`badge badge-${status.toLowerCase()}`}>
      {status.replace("_", " ")}
    </span>
  );
};
