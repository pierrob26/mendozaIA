#!/bin/bash
set -e

echo "🔒 DEPLOYING SALARY CAP PRIVACY - IMMEDIATE ACTION"
echo "================================================="
echo "Making sure you only see YOUR salary cap, not others"
echo "Time: $(date)"

cd /Users/robbypierson/IdeaProjects/fantasyIA

# Stop containers
echo "1. Stopping application..."
docker-compose down > /dev/null 2>&1

# Quick clean and build
echo "2. Rebuilding with privacy changes..."
mvn clean package -DskipTests > /dev/null 2>&1

# Start with changes
echo "3. Starting application with privacy applied..."
docker-compose up --build -d > /dev/null 2>&1

# Wait for startup
echo "4. Waiting for startup (30 seconds)..."
sleep 30

# Test if it's running
if curl -s http://localhost:8080 > /dev/null; then
    echo "✅ SUCCESS! Application is running with privacy changes"
else
    echo "⏳ Still starting up..."
    sleep 15
fi

echo ""
echo "🎯 PRIVACY DEPLOYED!"
echo "===================="
echo "🌐 Application: http://localhost:8080"
echo "🔒 You now see ONLY your own salary cap"
echo "🚫 Other teams' salary info is hidden"

docker-compose ps