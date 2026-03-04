#!/bin/bash

# Exit on error
set -e

echo "🚀 Starting setup for Workflow Engine..."

# Check Prerequisites
command -v pnpm >/dev/null 2>&1 || { echo >&2 "❌ pnpm is required but not installed. Aborting."; exit 1; }
command -v docker >/dev/null 2>&1 || { echo >&2 "❌ docker is required but not installed. Aborting."; exit 1; }

echo "📦 Installing connections..."
pnpm install

echo "📄 Configuring environment variables..."
if [ ! -f .env ]; then
  cp .env.example .env
  echo "✅ Created root .env"
fi

for app in apps/*; do
  if [ -d "$app" ] && [ -f "$app/.env.example" ]; then
    if [ ! -f "$app/.env" ]; then
      cp "$app/.env.example" "$app/.env"
      echo "✅ Created $app/.env"
    fi
  fi
done

echo "🐳 Starting Docker services..."
docker compose up -d

echo "⏳ Waiting for Postgres to be ready..."
until docker exec workflow-postgres pg_isready -U user -d workflow_db; do
  sleep 1
done

echo "🗄️  Syncing database schema..."
pnpm --filter @workflow/database db:push

echo "✅ Setup complete! You can now run 'pnpm dev' to start development."
