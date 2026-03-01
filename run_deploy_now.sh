#!/bin/bash

cd /Users/robbypierson/IdeaProjects/fantasyIA || exit 1

echo "🔒 DEPLOYING PRIVACY CHANGES NOW..."

# Execute deployment
docker-compose down
mvn clean package -DskipTests 
docker-compose up --build -d

echo ""
echo "✅ Privacy changes deployed!"
echo "You should now see only YOUR salary cap at http://localhost:8080"

# Wait a moment then show status
sleep 15
docker-compose ps