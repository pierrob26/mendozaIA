#!/bin/bash

# Quick Docker Start Script for FantasyIA

echo "🚀 Quick starting FantasyIA containers..."

cd /Users/robbypierson/IdeaProjects/fantasyIA

# Start containers
docker-compose up -d

echo "⏳ Waiting 10 seconds for startup..."
sleep 10

# Show status
echo "📊 Container Status:"
docker-compose ps

echo "✅ Containers started! App should be at http://localhost:8080"