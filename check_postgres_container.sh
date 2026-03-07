#!/bin/bash

# Check PostgreSQL Docker Container Status
echo "🐳 PostgreSQL Container Status"
echo "================================"

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running"
    exit 1
fi

echo "📦 Container Status:"
docker compose ps | grep postgres || echo "❌ PostgreSQL container not found"

echo ""
echo "🏥 Container Health:"
docker compose ps | grep fantasyia_postgres | grep -q "healthy" && echo "✅ Container is healthy" || echo "⚠️  Container may not be healthy"

echo ""
echo "📊 Container Details:"
docker inspect fantasyia_postgres --format="Container ID: {{.Id}}" 2>/dev/null || echo "Container not running"
docker inspect fantasyia_postgres --format="Status: {{.State.Status}}" 2>/dev/null || echo "Container not running"
docker inspect fantasyia_postgres --format="Image: {{.Config.Image}}" 2>/dev/null || echo "Container not running"

echo ""
echo "💾 Volume Information:"
docker volume ls | grep pgdata || echo "Volume not found"

echo ""
echo "🌐 Network Information:"
docker network ls | grep fantasyia-network || echo "Network not found"

echo ""
echo "🔧 Quick Actions:"
echo "   Start containers:  docker compose up -d"
echo "   Stop containers:   docker compose down"
echo "   View logs:         docker compose logs db"
echo "   Connect to DB:     ./db_connect.sh"