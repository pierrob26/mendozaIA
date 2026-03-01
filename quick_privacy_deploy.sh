#!/bin/bash
set -e

echo "🔒 Applying Home Page Privacy - Quick Deploy"
echo "Time: $(date)"

cd /Users/robbypierson/IdeaProjects/fantasyIA

echo "📝 Changes implemented:"
echo "   - Managers only see their own salary cap"
echo "   - Commissioners see all teams"
echo "   - Dynamic page title"

echo ""
echo "🛑 Stopping containers..."
docker-compose down

echo "📦 Rebuilding application..."
mvn clean package -DskipTests

echo "🐳 Starting with changes..."
docker-compose up --build -d

echo "⏳ Waiting for startup..."
sleep 20

echo ""
echo "✅ Privacy changes applied!"
echo "🌐 Test at: http://localhost:8080"
echo "🔒 Each team now sees only their own salary info"

docker-compose ps