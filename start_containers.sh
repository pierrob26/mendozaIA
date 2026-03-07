#!/bin/bash
set -e

echo "🐳 Starting FantasyIA Docker Containers"
echo "======================================"

cd /Users/robbypierson/IdeaProjects/fantasyIA

# Clean up any existing containers
echo "🧹 Stopping existing containers..."
docker-compose down --remove-orphans || true

# Remove volumes if you want fresh database (comment out if you want to keep data)
# docker-compose down -v --remove-orphans

echo ""
echo "🏗️ Building and starting containers..."
docker-compose up --build -d

echo ""
echo "⏳ Waiting for containers to initialize..."
sleep 15

echo ""
echo "📊 Container Status:"
docker-compose ps

echo ""
echo "🔍 Application Health Check:"
echo "Checking if application is responding..."

# Wait a bit more for the app to fully start
sleep 10

# Check if containers are healthy
if docker-compose ps | grep -q "unhealthy"; then
    echo "⚠️ Some containers are unhealthy. Checking logs:"
    docker-compose logs --tail=30
else
    echo "✅ All containers appear to be running!"
fi

echo ""
echo "🌐 Access Information:"
echo "   • Application: http://localhost:8080"
echo "   • PgAdmin: http://localhost:8081"
echo "     Login: admin@admin.com / admin"
echo ""
echo "📝 Useful commands:"
echo "   • View logs: docker-compose logs -f app"
echo "   • Stop all: docker-compose down"
echo "   • Restart app: docker-compose restart app"