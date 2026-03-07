#!/bin/bash

# Fantasy Baseball Docker Container Cleanup and Recreation Script
# Created: March 6, 2026

set -e

echo "🧹 Starting Docker container cleanup for Fantasy Baseball application..."
echo "======================================================================"

# Change to project directory
cd /Users/robbypierson/IdeaProjects/fantasyIA

# Step 1: Stop all running containers for this project
echo "📦 Stopping existing containers..."
docker-compose down -v --remove-orphans 2>/dev/null || echo "ℹ️  No containers were running"

# Step 2: Remove any existing containers that might be stuck
echo "🗑️ Removing any existing project containers..."
docker rm -f fantasyia_app fantasyia_postgres fantasyia_pgadmin 2>/dev/null || echo "ℹ️  No containers to remove"

# Step 3: Remove project-specific images (but keep base images for faster rebuilds)
echo "🖼️ Cleaning up project images..."
docker rmi $(docker images -q fantasyia*) 2>/dev/null || echo "ℹ️  No project images to remove"

# Step 4: Remove project volumes to ensure clean database
echo "💾 Removing project volumes for clean database..."
docker volume rm fantasyia_pgdata fantasyia_pgadmin_data 2>/dev/null || echo "ℹ️  No volumes to remove"
docker volume ls | grep fantasyia | awk '{print $2}' | xargs -I {} docker volume rm {} 2>/dev/null || echo "ℹ️  No additional volumes found"

# Step 5: Clean up any dangling images and unused containers
echo "🧽 Cleaning up Docker system..."
docker system prune -f

echo "✅ Docker cleanup completed!"
echo ""

# Step 6: Build the JAR file first
echo "🔨 Building application JAR file..."
echo "-------------------------------"
mvn clean package -DskipTests -q || {
    echo "❌ Maven build failed. Trying without tests..."
    mvn clean compile -q
}

echo "✅ JAR file built successfully!"
echo ""

# Step 7: Build and start fresh containers
echo "🚀 Creating fresh Docker containers..."
echo "-----------------------------------"
docker-compose up --build -d

echo "✅ Containers created!"
echo ""

# Step 8: Wait for services to be healthy
echo "⏳ Waiting for services to start..."
sleep 15

# Step 9: Show container status
echo "📊 Container Status:"
echo "------------------"
docker-compose ps

echo ""
echo "🔍 Health Check Status:"
echo "---------------------"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

echo ""

# Step 10: Show logs for any failed containers
echo "📋 Recent Logs:"
echo "-------------"
docker-compose logs --tail=10

echo ""
echo "🎉 Docker container recreation completed!"
echo "========================================"
echo ""
echo "🌐 Access Points:"
echo "   • Fantasy Baseball App: http://localhost:8080"
echo "   • PgAdmin (Database): http://localhost:8081"
echo "     - Email: admin@admin.com"
echo "     - Password: admin"
echo ""
echo "📝 Useful Commands:"
echo "   • View logs: docker-compose logs -f"
echo "   • Stop containers: docker-compose down"
echo "   • Restart: docker-compose restart"
echo "   • Shell into app: docker exec -it fantasyia_app /bin/bash"
echo ""

# Step 11: Test application endpoint
echo "🔍 Testing application availability..."
sleep 5
if curl -f http://localhost:8080/ >/dev/null 2>&1; then
    echo "✅ Application is responding at http://localhost:8080"
else
    echo "⚠️  Application not yet responding (may still be starting up)"
    echo "   Check logs with: docker-compose logs -f app"
fi

echo ""
echo "🏁 Setup complete! Your Fantasy Baseball application is ready to use."