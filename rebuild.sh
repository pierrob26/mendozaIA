#!/usr/bin/env zsh
set -euo pipefail

# Project root
PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$PROJECT_DIR"

echo "[rebuild] Cleaning previous build outputs..."
# Optional: remove build outputs; Maven clean handles most
rm -rf target || true

echo "[rebuild] Running Maven clean package..."
mvn clean package

echo "[rebuild] Restarting Docker stack..."
docker compose down

echo "[rebuild] Building and starting containers..."
docker compose up --build -d

echo "[rebuild] Stack is up. Containers:"
docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}"

APP_URL="http://localhost:8080/"

echo "[rebuild] Open the app at: $APP_URL"
