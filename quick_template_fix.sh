#!/bin/bash

# Quick template update script
echo "🔄 Updating FantasyIA templates (removing 'M' from contracts)..."

cd /Users/robbypierson/IdeaProjects/fantasyIA

# Show current status
echo "Current Docker containers:"
docker-compose ps

echo ""
echo "Stopping and rebuilding application with template changes..."

# Quick restart approach
docker-compose down
docker-compose up --build -d

echo ""
echo "Waiting for startup (30 seconds)..."
sleep 30

echo ""
echo "✅ Done! Template changes should now be live."
echo "🌐 Check at: http://localhost:8080"
echo "📝 My Team page contract amounts will no longer show 'M' suffix"

docker-compose ps