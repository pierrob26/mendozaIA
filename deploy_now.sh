#!/bin/bash
set -e

echo "🚀 DEPLOYING HOME PAGE PRIVACY CHANGES NOW"
echo "=========================================="
echo "Time: $(date)"
echo ""

# Navigate to project directory
cd /Users/robbypierson/IdeaProjects/fantasyIA || exit 1

# Check current status
echo "Current container status:"
docker-compose ps
echo ""

# Stop containers
echo "1. Stopping containers..."
docker-compose down

# Clean and rebuild
echo "2. Cleaning previous build..."
mvn clean -q

echo "3. Building with privacy changes..."
mvn package -DskipTests -q

if [ $? -ne 0 ]; then
    echo "❌ Build failed!"
    exit 1
fi

echo "4. Rebuilding Docker containers..."
docker-compose build --no-cache

echo "5. Starting application..."
docker-compose up -d

echo "6. Waiting for startup..."
sleep 30

echo "7. Checking status..."
docker-compose ps

echo ""
echo "✅ DEPLOYMENT COMPLETE!"
echo "🌐 Application: http://localhost:8080"
echo "🔒 Privacy changes applied:"
echo "   - Managers see only their own salary cap"
echo "   - Commissioners see all teams"
echo "   - Dynamic page titles"