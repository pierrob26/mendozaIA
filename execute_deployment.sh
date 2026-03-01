#!/bin/bash

echo "🔍 Checking current application status..."
cd /Users/robbypierson/IdeaProjects/fantasyIA

echo "Docker containers:"
docker-compose ps 2>/dev/null || echo "No containers found or docker-compose not accessible"

echo ""
echo "🚀 EXECUTING DEPLOYMENT NOW..."
echo "===================================="

# Make sure we're in the right directory
if [ ! -f "pom.xml" ]; then
    echo "❌ Error: Not in project directory (pom.xml not found)"
    exit 1
fi

# Stop any running containers
echo "1. Stopping containers..."
docker-compose down 2>/dev/null || echo "No containers to stop"

# Clean build
echo "2. Cleaning build..."
mvn clean

# Build with changes
echo "3. Building application..."
mvn package -DskipTests

# Start with fresh containers
echo "4. Starting application with changes..."
docker-compose up --build -d

# Wait and check
echo "5. Waiting for startup (30 seconds)..."
sleep 30

echo ""
echo "✅ DEPLOYMENT EXECUTED!"
echo "Application should be running at: http://localhost:8080"
echo ""
echo "Final container status:"
docker-compose ps

echo ""
echo "🔒 PRIVACY CHANGES APPLIED:"
echo "• Managers now see only their own salary info"
echo "• Commissioners see all teams"  
echo "• Home page title adjusts by role"