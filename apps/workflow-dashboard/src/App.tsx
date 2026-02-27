import { useState, useEffect } from "react";
import "./App.css";

// Components
import { Sidebar, USERS } from "./components/Sidebar";

// Legacy pages
import { MyTasks } from "./pages/MyTasks";
import { DocumentTracker } from "./pages/DocumentTracker";
import { AuditTrail } from "./pages/AuditTrail";

// Flow engine pages
import { FlowCatalog } from "./pages/FlowCatalog";
import { StartFlow } from "./pages/StartFlow";
import { FlowMyTasks } from "./pages/FlowMyTasks";
import { FlowInstances } from "./pages/FlowInstances";
import { FlowDetail } from "./pages/FlowDetail";
import { FlowAuditTrail } from "./pages/FlowAuditTrail";

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

interface FlowInstance {
  id: string;
  flowDefinitionId: string;
  flowName: string;
  flowIcon?: string;
  flowColor?: string;
  status: string;
  temporalWorkflowId: string;
  startedBy: string;
  startedAt: string;
  completedAt?: string;
  currentNodeIds: string[];
}

interface FlowTask {
  id: string;
  nodeId: string;
  status: string;
  unitType: string;
  unitName: string;
  unitConfig: Record<string, any>;
  flowInstanceId: string;
  flowName: string;
  flowDefinitionId: string;
  assigneeId: string;
  input: Record<string, any>;
  createdAt: string;
}

const API_BASE = "http://localhost:4000/documents";
const FLOW_API_BASE = "http://localhost:4000/api";

type ViewType =
  | "flow-catalog"
  | "flow-start"
  | "flow-tasks"
  | "flow-instances"
  | "flow-detail"
  | "flow-audit"
  | "tasks"
  | "tracker"
  | "audit";

function App() {
  // Legacy state
  const [documents, setDocuments] = useState<Document[]>([]);
  const [tasks, setTasks] = useState<Task[]>([]);
  const [loading, setLoading] = useState(true);

  // Flow engine state
  const [flowDefinitions, setFlowDefinitions] = useState<FlowDefinition[]>([]);
  const [flowInstances, setFlowInstances] = useState<FlowInstance[]>([]);
  const [flowTasks, setFlowTasks] = useState<FlowTask[]>([]);
  const [selectedFlowDef, setSelectedFlowDef] = useState<FlowDefinition | null>(
    null,
  );
  const [selectedFlowInstanceId, setSelectedFlowInstanceId] = useState<
    string | null
  >(null);
  const [instanceStatusFilter, setInstanceStatusFilter] = useState("");

  // App state
  const [currentView, setCurrentView] = useState<ViewType>("flow-catalog");
  const [activeUserId, setActiveUserId] = useState(USERS[0].id);

  // ── Legacy data fetching ────────────────────────────────────────────

  const fetchLegacyData = async () => {
    try {
      const [docsRes, tasksRes] = await Promise.all([
        fetch(`${API_BASE}/list`, { method: "POST" }),
        fetch(`${API_BASE}/tasks`, { method: "POST" }),
      ]);

      if (docsRes.ok && tasksRes.ok) {
        setDocuments(await docsRes.json());
        setTasks(await tasksRes.json());
      }
    } catch (error) {
      console.error("Error fetching legacy data:", error);
    }
  };

  // ── Flow engine data fetching ───────────────────────────────────────

  const fetchFlowData = async () => {
    try {
      const [defsRes, instancesRes, tasksRes] = await Promise.all([
        fetch(`${FLOW_API_BASE}/flow-definitions`),
        fetch(`${FLOW_API_BASE}/flow-instances`),
        fetch(`${FLOW_API_BASE}/my-tasks?userId=${activeUserId}`),
      ]);

      if (defsRes.ok) setFlowDefinitions(await defsRes.json());
      if (instancesRes.ok) setFlowInstances(await instancesRes.json());
      if (tasksRes.ok) setFlowTasks(await tasksRes.json());
    } catch (error) {
      console.error("Error fetching flow data:", error);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchFlowData();
    const interval = setInterval(() => {
      fetchFlowData();
    }, 10000);
    return () => clearInterval(interval);
  }, [activeUserId]);

  // ── Legacy handlers ─────────────────────────────────────────────────

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
      fetchLegacyData();
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
        body: JSON.stringify({ taskId, action, comment }),
      });
      fetchLegacyData();
    } catch (error) {
      console.error("Error handling action:", error);
    }
  };

  // ── Flow engine handlers ────────────────────────────────────────────

  const handleStartFlow = (flowDefId: string) => {
    const def = flowDefinitions.find((f) => f.id === flowDefId);
    if (def) {
      setSelectedFlowDef(def);
      setCurrentView("flow-start");
    }
  };

  const handleLaunchFlow = async (data: {
    flowDefinitionId: string;
    roleAssignments: Record<string, string>;
    variables: Record<string, any>;
    startedBy: string;
  }) => {
    try {
      const res = await fetch(`${FLOW_API_BASE}/flows/start`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(data),
      });
      if (res.ok) {
        const result = await res.json();
        setSelectedFlowInstanceId(result.flowInstanceId);
        setCurrentView("flow-detail");
        fetchFlowData();
      }
    } catch (error) {
      console.error("Error starting flow:", error);
    }
  };

  const handleSignal = async (
    flowInstanceId: string,
    nodeId: string,
    action: string,
    comment?: string,
  ): Promise<{ success: boolean; error?: string }> => {
    try {
      const res = await fetch(
        `${FLOW_API_BASE}/flows/${flowInstanceId}/signal`,
        {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({
            nodeId,
            action,
            comment,
            data: { actorId: activeUserId },
          }),
        },
      );

      if (!res.ok) {
        const errorData = await res.json().catch(() => ({}));
        return {
          success: false,
          error: errorData.message || `Server error (${res.status})`,
        };
      }

      // Optimistically remove the task so the card disappears immediately
      setFlowTasks((prev) =>
        prev.filter(
          (t) => !(t.flowInstanceId === flowInstanceId && t.nodeId === nodeId),
        ),
      );
      fetchFlowData();
      return { success: true };
    } catch (error) {
      console.error("Error sending signal:", error);
      return { success: false, error: "Network error. Please try again." };
    }
  };

  const handleViewFlowDetail = (flowInstanceId: string) => {
    setSelectedFlowInstanceId(flowInstanceId);
    setCurrentView("flow-detail");
  };

  // ── Render ──────────────────────────────────────────────────────────

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
        setCurrentView={(v) => {
          setCurrentView(v as ViewType);
          setSelectedFlowDef(null);
          setSelectedFlowInstanceId(null);
        }}
        activeUserId={activeUserId}
        setActiveUserId={setActiveUserId}
        flowTaskCount={flowTasks.length}
      />

      <main className="main-content">
        {/* Flow Engine Views */}
        {currentView === "flow-catalog" && (
          <FlowCatalog
            flowDefinitions={flowDefinitions}
            onStartFlow={handleStartFlow}
          />
        )}

        {currentView === "flow-start" && selectedFlowDef && (
          <StartFlow
            flowDefinition={selectedFlowDef}
            onStart={handleLaunchFlow}
            onCancel={() => setCurrentView("flow-catalog")}
            activeUserId={activeUserId}
          />
        )}

        {currentView === "flow-tasks" && (
          <FlowMyTasks
            tasks={flowTasks}
            activeUserId={activeUserId}
            onSignal={handleSignal}
          />
        )}

        {currentView === "flow-instances" && (
          <FlowInstances
            instances={flowInstances}
            onViewDetail={handleViewFlowDetail}
            statusFilter={instanceStatusFilter}
            onStatusFilterChange={setInstanceStatusFilter}
          />
        )}

        {currentView === "flow-detail" && selectedFlowInstanceId && (
          <FlowDetail
            flowInstanceId={selectedFlowInstanceId}
            onBack={() => setCurrentView("flow-instances")}
            apiBase={FLOW_API_BASE}
          />
        )}

        {currentView === "flow-audit" && (
          <FlowAuditTrail instances={flowInstances} apiBase={FLOW_API_BASE} />
        )}

        {/* Legacy Views */}
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
