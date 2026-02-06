# Workflow Engine Monorepo

This project is a resilient workflow orchestration system built with **NestJS**, **Temporal**, and **Drizzle ORM**. It uses a Turborepo monorepo structure for efficient development and scaling.

## 🚀 Quick Start

To get your local development environment up and running with a single command:

```sh
pnpm setup
```

This script will:

1. Install all dependencies.
2. Create `.env` files from templates.
3. Start required Docker services (Postgres, Temporal).
4. Sync the database schema.

Once setup is complete, start the development servers:

```sh
pnpm dev
```

## 🏗️ Project Structure

- `apps/main-server`: The primary API server (NestJS).
- `apps/workflow-engine`: The Temporal worker and workflow definitions (NestJS).
- `apps/integrations`: Service for external system integrations.
- `packages/database`: Shared Drizzle ORM schema and database utilities.
- `packages/typescript-config`: Shared TypeScript configurations.
- `packages/eslint-config`: Shared ESLint configurations.

## 🛠️ Common Commands

- `pnpm dev`: Start all applications in development mode.
- `pnpm build`: Build all applications.
- `pnpm db:push`: (Development only) Sync local schema changes directly to the database.
- `pnpm db:generate`: Generate a new migration file after changing the schema.
- `pnpm db:migrate`: Apply pending migrations to the database.
- `pnpm docker:up`: Start infrastructure containers.
- `pnpm docker:down`: Stop infrastructure containers.

## 📋 Prerequisites

- [Node.js](https://nodejs.org/) (>= 18)
- [pnpm](https://pnpm.io/) (>= 10)
- [Docker](https://www.docker.com/) & Docker Compose

## 🌐 Infrastructure

The project uses the following services via Docker:

- **Postgres**: Database (port 5432)
- **Temporal**: Workflow Orchestration (port 7233)
- **Temporal UI**: Dashboard for workflows (port 8080)
