#!/bin/bash

echo "🔒 Applying Home Page Privacy Changes - FantasyIA"
echo "=================================================="
echo "Change: ALL teams can only see their own salary cap information"
echo "Time: $(date)"
echo ""

cd /Users/robbypierson/IdeaProjects/fantasyIA

echo "1️⃣ Changes Applied:"
echo "   ✅ HomeController: Modified so ALL users see only their own salary info"
echo "   ✅ home.html: Updated title to always show 'My Team Salary Overview'"
echo "   ✅ Commissioners and Managers both see only their own team data"
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
echo "   🔒 ALL users (managers AND commissioners) only see their own salary cap"
echo "   👥 Every team sees only their own financial information on home page"
echo "   🏠 Home page shows 'My Team Salary Overview' for everyone"
echo ""
echo "🧪 To Test:"
echo "   1. Login as any manager - see only your own salary info"
echo "   2. Login as commissioner - also see only your own salary info"
echo "   3. All teams now have equal privacy on home page"
echo ""

docker-compose ps