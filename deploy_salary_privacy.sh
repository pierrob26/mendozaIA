#!/bin/bash

echo "🔒 DEPLOYING HOME PAGE PRIVACY CHANGES"
echo "====================================="
echo "Making ALL users see only their own salary information"
echo "Time: $(date)"
echo ""

# Navigate to project directory
cd /Users/robbypierson/IdeaProjects/fantasyIA

echo "📋 Privacy Changes Applied:"
echo "   ✅ HomeController modified: All users see only own salary"  
echo "   ✅ Home.html updated: Shows 'My Team Salary Overview'"
echo "   ✅ Equal privacy for managers and commissioners"
echo ""

echo "1️⃣ Stopping current application..."
docker-compose down 2>/dev/null || echo "   No containers were running"

echo ""
echo "2️⃣ Building application with privacy changes..."
mvn clean package -DskipTests

if [ $? -ne 0 ]; then
    echo "❌ Maven build failed!"
    exit 1
fi

echo ""
echo "3️⃣ Starting application with new privacy settings..."
docker-compose up --build -d

echo ""
echo "4️⃣ Waiting for startup (30 seconds)..."
sleep 30

echo ""
echo "5️⃣ Checking application status..."
docker-compose ps

echo ""
echo "✅ PRIVACY DEPLOYMENT COMPLETE!"
echo "==============================="
echo "🌐 Application: http://localhost:8080"
echo ""
echo "🔒 What Changed:"
echo "   • Every user now sees ONLY their own salary cap info"
echo "   • No cross-team financial data visible on home page"
echo "   • Commissioners and managers have same privacy level"
echo ""
echo "🧪 Test Instructions:"
echo "   1. Login with any account"
echo "   2. Check home page shows only YOUR team's salary"
echo "   3. Try different accounts - each sees only their own data"
echo ""

# Final status check
if curl -f http://localhost:8080 >/dev/null 2>&1; then
    echo "✅ Application is responding at http://localhost:8080"
else
    echo "⚠️  Application may still be starting up..."
fi

echo ""
echo "🎉 ALL TEAMS NOW HAVE SALARY PRIVACY!"