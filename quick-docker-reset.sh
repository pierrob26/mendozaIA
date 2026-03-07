#!/bin/bash

# Quick Docker Reset Script for Fantasy Baseball App
# Use this for quick cleanup without full rebuild

echo "⚡ Quick Docker Reset for FantasyIA..."

cd /Users/robbypierson/IdeaProjects/fantasyIA

# Stop everything
echo "🛑 Stopping containers..."
docker-compose down

# Start everything back up (without rebuild)
echo "▶️ Restarting containers..."
docker-compose up -d

# Show status
echo "📊 Status:"
docker-compose ps

echo "✅ Quick reset complete!"
echo "🌐 App: http://localhost:8080"
echo "🗄️ PgAdmin: http://localhost:8081"