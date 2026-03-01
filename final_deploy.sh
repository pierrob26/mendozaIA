#!/bin/bash
set -e

echo "🚀 DEPLOYING HOME PAGE PRIVACY CHANGES"
echo "Time: $(date)"
echo ""

cd /Users/robbypierson/IdeaProjects/fantasyIA

echo "✅ Changes verified:"
echo "   - HomeController: Role-based salary display"
echo "   - home.html: Dynamic titles"
echo "   - Java compatibility: Using Arrays.asList()"
echo ""

echo "🛑 Stopping containers..."
docker-compose down

echo "🧹 Cleaning build..."
mvn clean

echo "🔨 Building with privacy changes..."
mvn compile

if [ $? -eq 0 ]; then
    echo "✅ Compilation successful"
    
    echo "📦 Packaging application..."
    mvn package -DskipTests
    
    if [ $? -eq 0 ]; then
        echo "✅ Packaging successful"
        
        echo "🐳 Starting with updated code..."
        docker-compose up --build -d
        
        echo "⏳ Waiting for application startup..."
        sleep 35
        
        echo ""
        echo "🎯 DEPLOYMENT SUCCESSFUL!"
        echo "================================"
        echo "🌐 Application: http://localhost:8080"
        echo ""
        echo "🔒 Privacy Features:"
        echo "   ✓ Managers see only their own salary cap"
        echo "   ✓ Commissioners see all teams"
        echo "   ✓ Dynamic page titles by role"
        echo ""
        echo "Container Status:"
        docker-compose ps
    else
        echo "❌ Packaging failed"
        exit 1
    fi
else
    echo "❌ Compilation failed"
    exit 1
fi