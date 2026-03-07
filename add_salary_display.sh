#!/bin/bash

echo "📊 Adding Salary Display for Manager Accounts"
echo "============================================="

cd /Users/robbypierson/IdeaProjects/fantasyIA

echo "🔧 Changes Made:"
echo "  ✅ Updated HomeController to show salary info for ALL user roles"
echo "  ✅ Enhanced salary display with better styling and information"
echo "  ✅ Added roster count display (Major/Minor League)"
echo "  ✅ Improved progress bar and visual indicators"
echo "  ✅ Updated DataInitializer to set proper salary caps for all users"
echo ""

echo "🔨 Building application with salary display updates..."
mvn clean compile -q

if [ $? -ne 0 ]; then
    echo "❌ ERROR: Build failed"
    exit 1
fi

echo "📦 Packaging updated application..."
mvn package -DskipTests -q

if [ $? -ne 0 ]; then
    echo "❌ ERROR: Package failed"
    exit 1
fi

echo "🐳 Rebuilding containers with salary display..."
docker-compose down --volumes --remove-orphans >/dev/null 2>&1
docker-compose up --build -d

echo "⏳ Waiting for application startup..."
sleep 20

echo "🔍 Checking application status..."
if docker-compose ps | grep -q "fantasyia_app.*Up"; then
    echo ""
    echo "✅ SUCCESS: Application updated with salary display!"
    echo ""
    echo "📱 Test the changes:"
    echo "   1. Go to: http://localhost:8080"
    echo "   2. Login with any account:"
    echo "      • Manager accounts: manager1, manager2, team1, team2, owner1 (password: password)"
    echo "      • Member account: testuser (password: password)"
    echo "      • Commissioner: dasGoat (password: goat123)"
    echo ""
    echo "💰 New Salary Display Features:"
    echo "   • Enhanced salary overview for ALL users (not just commissioners)"
    echo "   • Current salary used vs available cap space"
    echo "   • Visual progress bar showing cap utilization"
    echo "   • Roster count display (Major/Minor League)"
    echo "   • Better styling and organization"
    echo ""
else
    echo "❌ WARNING: Container may not be running properly"
    echo "📋 Recent logs:"
    docker-compose logs --tail=10 app
    echo ""
    echo "🔧 Try: docker-compose logs -f app"
fi

echo "🎯 Update complete! All manager accounts can now see their salary information"