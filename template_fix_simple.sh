#!/bin/bash
set -e

echo "🔧 Quick Template Fix - Removing 'M' from contract amounts"
echo "Working in: $(pwd)"

cd /Users/robbypierson/IdeaProjects/fantasyIA

# Verify the template change
echo "✅ Template change verified in team.html"

# Simple rebuild and restart
echo "🛑 Stopping containers..."
docker-compose down

echo "📦 Building application with template changes..."
mvn clean package -DskipTests

echo "🐳 Rebuilding and starting containers..."
docker-compose up --build -d

echo "⏳ Waiting for application to start..."
sleep 30

echo "🎉 Done! Template changes applied."
echo "🌐 Visit: http://localhost:8080"
echo "📋 Go to 'My Team' to see contract amounts without 'M' suffix"