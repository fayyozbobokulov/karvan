# Workflow Dashboard

Simple React + Vite UI to manage document workflows.

## Prerequisites

1.  Start the **main-server** (Port 3001).
2.  Start the **temporal worker** (workflow-engine).
3.  Ensure the database is running.

## Running the Dashboard

```bash
cd apps/workflow-dashboard
npm install
npm run dev
```

The dashboard will be available at `http://localhost:5173`.

## Features

- **Document Listing**: View all documents and their current status.
- **Scenario Creation**: Trigger a new government document workflow.
- **Task Management**: Real-time polling for pending tasks.
- **Workflow Actions**: Sign or Reject documents directly from the UI.
