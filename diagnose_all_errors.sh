#!/bin/bash

echo "🔧 COMPREHENSIVE ERROR DIAGNOSIS AND FIX"
echo "========================================"
echo ""

# Function to run command and capture output
run_check() {
    echo "➤ $1"
    eval "$2" 2>&1
    echo ""
}

# Check Docker status
run_check "Checking Docker status" "docker --version && docker-compose --version"

# Check container status
run_check "Container status" "docker-compose ps"

# Check recent application logs for errors
echo "🔍 RECENT APPLICATION ERRORS:"
echo "============================="
docker-compose logs --tail=100 app 2>&1 | grep -E "(ERROR|WARN|Exception|Failed|refused)" | tail -20

echo ""
echo "🔍 DATABASE CONNECTION ERRORS:"
echo "=============================="
docker-compose logs --tail=50 app 2>&1 | grep -i "database\|connection\|postgres" | tail -10

echo ""
echo "🔍 COMPILATION ERRORS:"
echo "====================="
# Check if there are any Java compilation issues
if mvn compile -q 2>&1 | grep -i "error\|failed"; then
    echo "❌ Compilation errors found"
    mvn compile 2>&1 | tail -20
else
    echo "✅ Code compiles successfully"
fi

echo ""
echo "🔍 TEMPLATE ERRORS:"
echo "=================="
# Check for template parsing errors
docker-compose logs app 2>&1 | grep -i "template\|thymeleaf" | tail -10

echo ""
echo "🔍 RECENT FULL LOG (last 30 lines):"
echo "==================================="
docker-compose logs --tail=30 app

echo ""
echo "🛠️ SUGGESTED FIXES:"
echo "=================="
echo "1. 🔄 Quick restart: docker-compose restart app"
echo "2. 🏗️ Rebuild: mvn clean package && docker-compose up -d --build" 
echo "3. 🧹 Clean slate: docker-compose down && docker-compose up -d --build"
echo "4. 📱 View live logs: docker-compose logs -f app"
echo ""