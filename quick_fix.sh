#!/usr/bin/env zsh
# Quick fix for 500 error - rebuild and restart
set -e

cd "$(dirname "$0")"

echo "🔄 Stopping containers..."
docker compose down

echo "🧹 Cleaning build..."
mvn clean -q

echo "🔨 Building fresh..."
mvn package -DskipTests -q

echo "🚀 Starting with new build..."
docker compose up --build -d

echo "⏳ Waiting for app to start..."
sleep 20

echo ""
echo "✅ Done! Check status:"
docker compose ps

echo ""
echo "View logs: docker compose logs -f app"
echo "Access app: http://localhost:8080"
