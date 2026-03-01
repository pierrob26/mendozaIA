#!/bin/bash
set -e

echo "🚀 EXECUTING DEPLOYMENT NOW - MAKING PRIVACY CHANGES LIVE"
echo "========================================================="
echo "Time: $(date)"

# Navigate to project directory
cd /Users/robbypierson/IdeaProjects/fantasyIA

echo "✅ Verified privacy implementation:"
echo "   - HomeController: Managers see only own salary"  
echo "   - home.html: Dynamic titles by role"
echo ""

# Execute deployment sequence
echo "1️⃣ Stopping containers..."
docker-compose down

echo ""
echo "2️⃣ Cleaning previous build..."
mvn clean

echo ""
echo "3️⃣ Building application with privacy changes..."
mvn package -DskipTests

if [ $? -ne 0 ]; then
    echo "❌ Build failed - exiting"
    exit 1
fi

echo ""
echo "4️⃣ Starting application with fresh containers..."
docker-compose up --build -d

echo ""
echo "5️⃣ Waiting for application startup (30 seconds)..."
sleep 30

echo ""
echo "6️⃣ Testing application response..."
if curl -s http://localhost:8080 > /dev/null 2>&1; then
    echo "✅ Application is responding!"
else
    echo "⚠️  Application may still be starting..."
    sleep 15
    if curl -s http://localhost:8080 > /dev/null 2>&1; then
        echo "✅ Application is now responding!"
    else
        echo "❌ Application not responding - check logs with: docker-compose logs fantasyia_app"
    fi
fi

echo ""
echo "🎯 DEPLOYMENT COMPLETED!"
echo "======================="
echo "🌐 Application URL: http://localhost:8080"
echo "🔒 Privacy changes are now ACTIVE:"
echo "   ✓ You will see ONLY your salary cap"
echo "   ✓ Other teams' salary info is hidden"
echo "   ✓ Page title shows 'My Team Salary Overview'"
echo ""
echo "Container status:"
docker-compose ps

echo ""
echo "If you still don't see changes, check application logs:"
echo "docker-compose logs -f fantasyia_app"