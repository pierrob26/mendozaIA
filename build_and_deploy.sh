#!/bin/bash

# Complete FantasyIA Build and Container Setup
# This script builds the app and creates Docker containers

set -e

echo "🏗️  Complete FantasyIA Build and Container Setup"
echo "==============================================="

# Navigate to project directory
cd /Users/robbypierson/IdeaProjects/fantasyIA

# Check prerequisites
if ! command -v mvn &> /dev/null; then
    echo "❌ ERROR: Maven is not installed or not in PATH"
    exit 1
fi

if ! command -v docker &> /dev/null; then
    echo "❌ ERROR: Docker is not installed or not in PATH"
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo "❌ ERROR: docker-compose is not installed or not in PATH"
    exit 1
fi

echo "✅ Prerequisites check passed"

# Step 1: Clean and build the application
echo ""
echo "🧹 Step 1: Cleaning previous build artifacts..."
mvn clean

echo "🔨 Step 2: Compiling and packaging application..."
mvn package -DskipTests

# Check if JAR was created
if [ ! -f "target/fantasyia-0.0.1-SNAPSHOT.jar" ]; then
    echo "❌ ERROR: JAR file was not created. Build may have failed."
    exit 1
fi

echo "✅ JAR file created successfully: target/fantasyia-0.0.1-SNAPSHOT.jar"

# Step 3: Stop any existing containers
echo ""
echo "🛑 Step 3: Stopping existing containers..."
docker-compose down --volumes --remove-orphans 2>/dev/null || echo "No existing containers to remove"

# Step 4: Build and start containers
echo ""
echo "🐳 Step 4: Building and starting Docker containers..."
docker-compose up --build -d

# Step 5: Wait for initialization
echo ""
echo "⏳ Step 5: Waiting for containers to initialize..."
sleep 20

# Step 6: Check status
echo ""
echo "📊 Step 6: Checking container status..."
echo "======================================="
docker-compose ps

# Check if services are healthy
echo ""
echo "🔍 Health Check Results:"
echo "========================"

# Check database
if docker-compose exec db pg_isready -U fantasyia -d fantasyia >/dev/null 2>&1; then
    echo "✅ Database (PostgreSQL): Healthy"
else
    echo "❌ Database (PostgreSQL): Not responding"
fi

# Check app container
if docker-compose ps | grep -q "fantasyia_app.*Up"; then
    echo "✅ Application Container: Running"
    
    # Try to check if app is responding (with timeout)
    sleep 5
    if timeout 10 curl -s http://localhost:8080 >/dev/null 2>&1; then
        echo "✅ Application Web Server: Responding"
    else
        echo "⚠️  Application Web Server: Not responding yet (may still be starting)"
    fi
else
    echo "❌ Application Container: Not running"
fi

echo ""
echo "🎯 Setup Complete!"
echo "=================="
echo "📱 Access your application:"
echo "   - Main App: http://localhost:8080"
echo "   - PgAdmin: http://localhost:8081 (admin@admin.com / admin)"
echo ""
echo "🔧 Useful commands:"
echo "   - View app logs: docker-compose logs -f app"
echo "   - View all logs: docker-compose logs -f"
echo "   - Stop all: docker-compose down"
echo "   - Restart app: docker-compose restart app"
echo ""

# Show recent app logs if container is running
if docker-compose ps | grep -q "fantasyia_app.*Up"; then
    echo "📋 Recent application logs:"
    echo "==========================="
    docker-compose logs --tail=20 app
fi