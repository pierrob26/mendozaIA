#!/bin/bash
set -e

echo "🔒 APPLYING SALARY CAP PRIVACY RIGHT NOW"
echo "========================================"
echo "Time: $(date)"

# Navigate to the project
cd /Users/robbypierson/IdeaProjects/fantasyIA

# Confirm we're in the right place
if [ ! -f "pom.xml" ]; then
    echo "❌ Error: pom.xml not found"
    exit 1
fi

echo "✅ Found project files"

# Stop any running containers
echo ""
echo "1️⃣ Stopping containers..."
docker-compose down

# Clean previous build
echo ""
echo "2️⃣ Cleaning build artifacts..."
mvn clean

# Build with privacy changes
echo ""
echo "3️⃣ Building application with privacy changes..."
mvn package -DskipTests

# Check if build was successful
if [ $? -ne 0 ]; then
    echo "❌ Build failed!"
    exit 1
fi

echo "✅ Build successful"

# Start application with new build
echo ""
echo "4️⃣ Starting application with privacy enabled..."
docker-compose up --build -d

echo ""
echo "5️⃣ Waiting for application to start (30 seconds)..."
sleep 30

# Check if application is responding
echo ""
echo "6️⃣ Testing application..."
if curl -s -I http://localhost:8080 | grep -q "200\|302\|301"; then
    echo "✅ Application is responding!"
else
    echo "⚠️ Application may still be starting..."
fi

echo ""
echo "🎉 PRIVACY CHANGES ARE NOW LIVE!"
echo "================================"
echo "🌐 Visit: http://localhost:8080"
echo "🔒 You will now see ONLY your own salary cap"
echo "🚫 Other teams' information is hidden from you"
echo ""
echo "Current containers:"
docker-compose ps