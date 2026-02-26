import { useState, useEffect } from "react";
import "./App.css";

// Components
import { Sidebar, USERS } from "./components/Sidebar";
import { MyTasks } from "./pages/MyTasks";
import { DocumentTracker } from "./pages/DocumentTracker";
import { AuditTrail } from "./pages/AuditTrail";

// Types
interface Task {
  id: string;
  documentId: string;
  assigneeId: string;
  type: string;
  status: string;
}

interface Document {
  id: string;
  title: string;
  status: string;
  authorId: string;
}

const API_BASE = "http://localhost:4000/documents";

function App() {
  const [documents, setDocuments] = useState<Document[]>([]);
  const [tasks, setTasks] = useState<Task[]>([]);
  const [loading, setLoading] = useState(true);

  // App State
  const [currentView, setCurrentView] = useState("tasks"); // "tasks" | "tracker" | "audit"
  const [activeUserId, setActiveUserId] = useState(USERS[0].id);

  const fetchData = async () => {
    try {
      const [docsRes, tasksRes] = await Promise.all([
        fetch(`${API_BASE}/list`, { method: "POST" }),
        fetch(`${API_BASE}/tasks`, { method: "POST" }),
      ]);

      if (docsRes.ok && tasksRes.ok) {
        const docsData = await docsRes.json();
        const tasksData = await tasksRes.json();

        setDocuments(docsData);
        setTasks(tasksData);
      }
    } catch (error) {
      console.error("Error fetching data from API:", error);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchData();
    const interval = setInterval(fetchData, 3000); // Poll every 3s
    return () => clearInterval(interval);
  }, []);

  const handleSubmit = async (title: string, authorId: string) => {
    try {
      await fetch(`${API_BASE}/submit`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          title,
          authorId,
          fileUrl: "/placeholder-doc.pdf",
          metadata: { systemVersion: "1.0", internalApproval: true },
          approvalLevels: ["department_head", "director"],
        }),
      });
      fetchData(); // Force immediate refresh
    } catch (error) {
      console.error("Error submitting document:", error);
    }
  };

  const handleAction = async (
    taskId: string,
    documentId: string,
    action: string,
    comment?: string,
  ) => {
    try {
      await fetch(`${API_BASE}/${documentId}/action`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          taskId,
          action,
          comment,
        }),
      });
      fetchData(); // Force immediate refresh
    } catch (error) {
      console.error("Error handling action:", error);
    }
  };

  if (loading) {
    return (
      <div
        className="app-layout"
        style={{ justifyContent: "center", alignItems: "center" }}
      >
        <p>Loading Dashboard...</p>
      </div>
    );
  }

  return (
    <div className="app-layout">
      <Sidebar
        currentView={currentView}
        setCurrentView={setCurrentView}
        activeUserId={activeUserId}
        setActiveUserId={setActiveUserId}
      />

      <main className="main-content">
        {currentView === "tasks" && (
          <MyTasks
            tasks={tasks}
            documents={documents}
            activeUserId={activeUserId}
            onAction={handleAction}
          />
        )}

        {currentView === "tracker" && (
          <DocumentTracker documents={documents} onSubmit={handleSubmit} />
        )}

        {currentView === "audit" && (
          <AuditTrail documents={documents} baseUrl={API_BASE} />
        )}
      </main>
    </div>
  );
}

export default App;
