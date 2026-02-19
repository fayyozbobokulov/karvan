import { useState, useEffect } from "react";
import "./App.css";

interface Task {
  id: string;
  documentId: string;
  assigneeId: string;
  type: string;
  status: "pending" | "completed" | "rejected";
  comment?: string;
}

interface Document {
  id: string;
  title: string;
  status:
    | "pending"
    | "processing"
    | "completed"
    | "failed"
    | "signed"
    | "rejected";
  authorId: string;
}

const API_BASE = "http://localhost:3001/documents";

function App() {
  const [documents, setDocuments] = useState<Document[]>([]);
  const [tasks, setTasks] = useState<Task[]>([]);
  const [loading, setLoading] = useState(true);

  // Scenario inputs
  const [title, setTitle] = useState("Gov Document");
  const [authorId, setAuthorId] = useState("user-author");
  const [assigneeId, setAssigneeId] = useState("user-assignee");

  const fetchData = async () => {
    try {
      const [docsRes, tasksRes] = await Promise.all([
        fetch(`${API_BASE}/list`, { method: "POST" }),
        fetch(`${API_BASE}/tasks`, { method: "POST" }),
      ]);

      const docsData = await docsRes.json();
      const tasksData = await tasksRes.json();

      setDocuments(docsData);
      setTasks(tasksData);
    } catch (error) {
      console.error("Error fetching data:", error);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchData();
    const interval = setInterval(fetchData, 3000); // Poll every 3s
    return () => clearInterval(interval);
  }, []);

  const createScenario = async () => {
    try {
      await fetch(`${API_BASE}/scenario`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ title, authorId, assigneeId }),
      });
      fetchData();
    } catch (error) {
      console.error("Error creating scenario:", error);
    }
  };

  const handleAction = async (
    taskId: string,
    documentId: string,
    action: "sign" | "reject",
  ) => {
    try {
      await fetch(`${API_BASE}/action`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          taskId,
          documentId,
          action,
          comment: action === "reject" ? "Rejected via UI" : undefined,
        }),
      });
      fetchData();
    } catch (error) {
      console.error("Error handling action:", error);
    }
  };

  if (loading) return <div className="loading">Loading dashboard...</div>;

  return (
    <div className="dashboard-container">
      <h1>Workflow Dashboard</h1>

      <section className="section">
        <h2>Create Test Scenario</h2>
        <div className="scenario-controls">
          <input
            placeholder="Document Title"
            value={title}
            onChange={(e) => setTitle(e.target.value)}
          />
          <input
            placeholder="Author ID"
            value={authorId}
            onChange={(e) => setAuthorId(e.target.value)}
          />
          <input
            placeholder="Assignee ID"
            value={assigneeId}
            onChange={(e) => setAssigneeId(e.target.value)}
          />
          <button className="button button-primary" onClick={createScenario}>
            Start Government Scenario
          </button>
        </div>
      </section>

      <section className="section">
        <h2>Documents & Tasks</h2>
        <div className="card-grid">
          {documents.map((doc) => {
            const docTasks = tasks.filter((t) => t.documentId === doc.id);
            return (
              <div key={doc.id} className="card">
                <div
                  style={{ display: "flex", justifyContent: "space-between" }}
                >
                  <h3>{doc.title}</h3>
                  <span className={`status-badge status-${doc.status}`}>
                    {doc.status.toUpperCase()}
                  </span>
                </div>
                <p style={{ color: "#94a3b8", fontSize: "0.875rem" }}>
                  ID: {doc.id}
                </p>

                <div className="task-list">
                  <strong>Workflow Tasks:</strong>
                  {docTasks.length === 0 && (
                    <span style={{ color: "#64748b" }}>No tasks yet...</span>
                  )}
                  {docTasks.map((task) => (
                    <div key={task.id} className="task-item">
                      <div>
                        <span>{task.type}</span>
                        <span style={{ marginLeft: "0.5rem", opacity: 0.7 }}>
                          ({task.status})
                        </span>
                      </div>
                      {task.status === "pending" && (
                        <div style={{ display: "flex", gap: "0.5rem" }}>
                          <button
                            className="button button-success"
                            onClick={() =>
                              handleAction(task.id, doc.id, "sign")
                            }
                          >
                            Sign
                          </button>
                          <button
                            className="button button-danger"
                            onClick={() =>
                              handleAction(task.id, doc.id, "reject")
                            }
                          >
                            Reject
                          </button>
                        </div>
                      )}
                    </div>
                  ))}
                </div>
              </div>
            );
          })}
        </div>
      </section>
    </div>
  );
}

export default App;
