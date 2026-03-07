#!/bin/bash

# Fantasy Baseball App Container Fix Script
# March 6, 2026

set -e

echo "🔧 FixingFantasyIA App Container..."
echo "================================="

cd /Users/robbypierson/IdeaProjects/fantasyIA

# Step 1: Stop the app container specifically
echo "🛑 Stopping fantasyia-app container..."
docker stop fantasyia_app 2>/dev/null || echo "Container not running"
docker rm fantasyia_app 2>/dev/null || echo "Container already removed"

# Step 2: Remove the old app image to force rebuild
echo "🗑️ Removing old app image..."
docker rmi fantasyia-app 2>/dev/null || echo "No old image to remove"

# Step 3: Build the application with Maven first
echo "🔨 Building application JAR..."
mvn clean package -DskipTests -q

echo "✅ JAR built successfully!"

# Step 4: Build and start only the app container
echo "🚀 Building and starting app container..."
docker-compose up --build --no-deps -d app

# Step 5: Wait for container to start
echo "⏳ Waiting for container to start..."
sleep 20

# Step 6: Check container status
echo "📊 Container Status:"
docker ps --filter "name=fantasyia_app" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# Step 7: Check health
echo ""
echo "🏥 Health Check:"
if docker inspect fantasyia_app --format='{{.State.Health.Status}}' 2>/dev/null; then
    echo "Health status available"
else
    echo "Health check not yet available (container may still be starting)"
fi

# Step 8: Show recent logs
echo ""
echo "📋 Recent App Logs:"
echo "------------------"
docker logs fantasyia_app --tail=20

echo ""
echo "🔍 Testing Application:"
sleep 5
if curl -f http://localhost:8080/actuator/health 2>/dev/null; then
    echo "✅ App health endpoint responding"
elif curl -f http://localhost:8080/ 2>/dev/null; then
    echo "✅ App main page responding"
else
    echo "⚠️ App not yet responding (may still be starting)"
    echo "   Check logs: docker logs fantasyia_app -f"
fi

echo ""
echo "🎉 App container fix complete!"
echo "🌐 Access: http://localhost:8080"
echo "🏥 Health: http://localhost:8080/actuator/health"