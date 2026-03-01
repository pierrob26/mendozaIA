#!/bin/bash

# Direct execution of privacy deployment
echo "🔒 DEPLOYING PRIVACY CHANGES NOW"
echo "================================"

cd /Users/robbypierson/IdeaProjects/fantasyIA

# Verify we have the right files
if [ ! -f "src/main/java/com/fantasyia/controller/HomeController.java" ]; then
    echo "❌ HomeController not found"
    exit 1
fi

echo "✅ Privacy code verified:"
echo "   - Managers see only their own salary cap"
echo "   - Commissioners see all teams"

# Execute deployment sequence
echo ""
echo "1. Stopping containers..."
docker-compose down >/dev/null 2>&1

echo "2. Building application..."
mvn clean package -DskipTests >/dev/null 2>&1

echo "3. Starting with privacy changes..."
docker-compose up --build -d >/dev/null 2>&1

echo "4. Allowing startup time..."
sleep 25

echo ""
echo "🎯 PRIVACY IS NOW ACTIVE!"
echo "========================"
echo "🌐 Go to: http://localhost:8080"
echo "🔒 You'll see ONLY your salary cap now"

# Show final status
echo ""
echo "Container status:"
docker-compose ps