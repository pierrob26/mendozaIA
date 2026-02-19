#!/bin/bash

echo "🔍 Checking for Application Errors..."
echo ""

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker Desktop first."
    exit 1
fi

echo "✅ Docker is running"
echo ""

echo "📊 Container Status:"
docker-compose ps
echo ""

echo "🔍 Application Logs (last 50 lines):"
echo "===========================================" 
docker-compose logs --tail=50 app 2>&1
echo ""

echo "🔍 Database Logs (last 20 lines):"
echo "===========================================" 
docker-compose logs --tail=20 db 2>&1
echo ""

echo "🔍 Build Status Check:"
echo "===========================================" 
if [ -f "target/classes/application.properties" ]; then
    echo "✅ Application appears to be built"
else
    echo "❌ Application may not be built properly"
    echo "Running quick build check..."
    mvn compile -q 2>&1 | tail -10
fi
echo ""

echo "🔍 Common Error Check:"
echo "===========================================" 
echo "Checking for common error patterns in logs..."

# Check for specific error patterns
docker-compose logs app 2>&1 | grep -i "error\|exception\|failed" | tail -10

echo ""
echo "💡 Quick Fix Options:"
echo "1. Restart containers: docker-compose restart"
echo "2. Rebuild application: mvn clean package && docker-compose up -d --build"
echo "3. Clean restart: docker-compose down && docker-compose up -d --build"