#!/bin/bash
set -e

echo "🚨 EXECUTING PRIVACY DEPLOYMENT - IMMEDIATE ACTION"
echo "=================================================="
echo "Time: $(date)"
echo ""

# Navigate to project
cd /Users/robbypierson/IdeaProjects/fantasyIA

# Stop containers
echo "1. Stopping Docker containers..."
docker-compose down

# Clean and rebuild
echo "2. Cleaning build..."
mvn clean -q

echo "3. Building with privacy changes..."
mvn package -DskipTests -q

# Start with fresh build
echo "4. Starting application with privacy enabled..."
docker-compose up --build -d

# Wait for startup
echo "5. Waiting for application startup..."
sleep 30

echo ""
echo "✅ DEPLOYMENT EXECUTED!"
echo "Application should now show only your salary cap."
echo ""
echo "🌐 Check: http://localhost:8080"

# Show container status
docker-compose ps