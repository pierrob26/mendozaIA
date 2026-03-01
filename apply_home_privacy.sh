#!/bin/bash

echo "🔒 Applying Home Page Privacy Changes - FantasyIA"
echo "=================================================="
echo "Change: Teams can only see their own salary cap information"
echo "Time: $(date)"
echo ""

cd /Users/robbypierson/IdeaProjects/fantasyIA

echo "1️⃣ Changes Applied:"
echo "   ✅ HomeController: Modified to show only current user's salary info"
echo "   ✅ home.html: Updated title to reflect personalized view"
echo ""

echo "2️⃣ Stopping existing containers..."
docker-compose down

echo ""
echo "3️⃣ Rebuilding application with privacy changes..."
mvn clean package -DskipTests -q

echo ""
echo "4️⃣ Starting application with updated home page..."
docker-compose up --build -d

echo ""
echo "5️⃣ Waiting for application startup..."
sleep 25

echo ""
echo "=================================================="
echo "✅ HOME PAGE PRIVACY APPLIED"
echo "=================================================="
echo "🌐 Application URL: http://localhost:8080"
echo ""
echo "📋 Changes Applied:"
echo "   🔒 Regular managers only see their own salary cap"
echo "   👑 Commissioners still see all teams (for oversight)"
echo "   🏠 Home page title adjusts based on user role"
echo ""
echo "🧪 To Test:"
echo "   1. Login as a manager - see only your salary info"
echo "   2. Login as commissioner - see all teams"
echo ""

docker-compose ps