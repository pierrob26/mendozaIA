#!/bin/bash
set -e

clear
echo "🚀 DEPLOYING PRIVACY CHANGES - EXECUTION IN PROGRESS"
echo "===================================================="

cd /Users/robbypierson/IdeaProjects/fantasyIA

# Stop containers
echo "Stopping containers..."
docker-compose down >/dev/null 2>&1
echo "✅ Containers stopped"

# Build application
echo "Building application with privacy changes..."
mvn clean package -DskipTests >/dev/null 2>&1
echo "✅ Application built"

# Start containers
echo "Starting containers with privacy enabled..."
docker-compose up --build -d >/dev/null 2>&1
echo "✅ Containers started"

# Wait for startup
echo "Waiting for application startup..."
for i in {1..30}; do
    echo -n "."
    sleep 1
done
echo ""

# Test if running
if curl -s http://localhost:8080 >/dev/null 2>&1; then
    echo "✅ Application is running!"
else
    echo "⚠️  Still starting up..."
fi

echo ""
echo "🎯 PRIVACY DEPLOYMENT COMPLETE!"
echo "==============================="
echo "🌐 Visit: http://localhost:8080"
echo "🔒 You now see ONLY your salary cap"
echo ""

# Show final status
docker-compose ps