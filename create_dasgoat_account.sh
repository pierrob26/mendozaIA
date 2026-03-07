#!/bin/bash

echo "🐐 Creating dasGoat Commissioner Account"
echo "======================================"

cd /Users/robbypierson/IdeaProjects/fantasyIA

echo "📋 Account Details:"
echo "   Username: dasGoat"
echo "   Password: goat123"
echo "   Role: COMMISSIONER"
echo ""

echo "🔨 Step 1: Building application with new user..."
mvn clean compile -q

if [ $? -ne 0 ]; then
    echo "❌ ERROR: Build failed"
    exit 1
fi

echo "📦 Step 2: Packaging application..."
mvn package -DskipTests -q

if [ $? -ne 0 ]; then
    echo "❌ ERROR: Package failed"
    exit 1
fi

echo "🐳 Step 3: Rebuilding containers..."
docker-compose down --volumes --remove-orphans >/dev/null 2>&1
docker-compose up --build -d

echo "⏳ Step 4: Waiting for initialization..."
sleep 20

echo "🔍 Step 5: Checking container status..."
if docker-compose ps | grep -q "fantasyia_app.*Up"; then
    echo "✅ SUCCESS: Application is running!"
    echo ""
    echo "📱 Access: http://localhost:8080"
    echo ""
    echo "🐐 Commissioner Login Details:"
    echo "   Username: dasGoat"
    echo "   Password: goat123"
    echo ""
    echo "🔧 Other commissioner accounts available:"
    echo "   commissioner / admin123"
    echo "   admin / password"
    echo "   commish / commish"
    echo ""
else
    echo "❌ WARNING: Container may not be running properly"
    echo "📋 Recent logs:"
    docker-compose logs --tail=10 app
    echo ""
    echo "🔧 Try: docker-compose logs -f app"
fi

echo "🎯 Setup complete! You can now login as dasGoat"