#!/bin/bash

# FantasyIA Docker Container Recreation Script
# This script will rebuild and start all necessary containers

set -e

echo "🚀 Starting FantasyIA Docker Container Recreation"
echo "============================================="

# Navigate to project directory
cd /Users/robbypierson/IdeaProjects/fantasyIA

# Check if docker-compose.yml exists
if [ ! -f "docker-compose.yml" ]; then
    echo "❌ ERROR: docker-compose.yml not found!"
    exit 1
fi

echo "📋 Found docker-compose.yml - proceeding with container setup..."

# Stop and remove any existing containers
echo "🛑 Stopping and removing any existing containers..."
docker-compose down --volumes --remove-orphans 2>/dev/null || echo "No existing containers to remove"

# Remove any old images to ensure clean build
echo "🧹 Cleaning up old Docker images..."
docker system prune -f 2>/dev/null || echo "No cleanup needed"

# Build and start containers with fresh build
echo "🔨 Building and starting containers..."
docker-compose up --build -d

# Wait a moment for containers to initialize
echo "⏳ Waiting for containers to initialize..."
sleep 15

# Check container status
echo "📊 Container Status:"
echo "==================="
docker-compose ps

# Check if app container is running
if docker-compose ps | grep -q "fantasyia_app.*Up"; then
    echo ""
    echo "✅ SUCCESS: FantasyIA containers are running!"
    echo ""
    echo "📱 Application URLs:"
    echo "   - Main App: http://localhost:8080"
    echo "   - PgAdmin: http://localhost:8081 (admin@admin.com / admin)"
    echo ""
    echo "🔧 Useful commands:"
    echo "   - View app logs: docker-compose logs -f app"
    echo "   - View all logs: docker-compose logs -f"
    echo "   - Stop containers: docker-compose down"
    echo ""
else
    echo "❌ WARNING: Application container may not be running properly"
    echo "📋 Container logs:"
    docker-compose logs app
    echo ""
    echo "🔧 Try these troubleshooting commands:"
    echo "   - docker-compose logs -f app"
    echo "   - docker-compose restart app"
fi

echo "🎯 Container recreation completed!"