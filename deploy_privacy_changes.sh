#!/bin/bash

echo "🚀 DEPLOYING HOME PAGE PRIVACY CHANGES"
echo "======================================"
echo "Deploying changes so ALL users see only their own salary info"
echo "Time: $(date)"
echo ""

# Navigate to project directory
cd /Users/robbypierson/IdeaProjects/fantasyIA || exit 1

echo "📋 Changes being deployed:"
echo "   ✅ HomeController: ALL users see only own salary"
echo "   ✅ home.html: Title shows 'My Team Salary Overview'"
echo "   ✅ Commissioners and Managers both get privacy"
echo ""

echo "1️⃣ Stopping existing containers..."
docker-compose down

echo ""
echo "2️⃣ Cleaning and rebuilding application..."
mvn clean package -DskipTests -q

if [ $? -ne 0 ]; then
    echo "❌ Build failed!"
    exit 1
fi

echo ""
echo "3️⃣ Starting application with privacy changes..."
docker-compose up --build -d

echo ""
echo "4️⃣ Waiting for application startup..."
sleep 30

echo ""
echo "5️⃣ Checking application status..."
docker-compose ps

echo ""
echo "✅ PRIVACY DEPLOYMENT COMPLETE!"
echo "================================"
echo "🌐 Application: http://localhost:8080"
echo ""
echo "🔒 Privacy Changes Applied:"
echo "   • Every user sees only their own salary cap"
echo "   • No more cross-team financial visibility"
echo "   • Equal privacy for all roles"
echo ""
echo "🧪 Test by logging in with different accounts"
echo "   Each should see only their own team's data"
echo ""