#!/bin/bash

echo "🔧 FIXING COMPILATION ERRORS AND REBUILDING"
echo "=========================================="
echo ""

echo "🏗️ Testing compilation..."
mvn compile -q

if [ $? -eq 0 ]; then
    echo "✅ Compilation successful!"
    echo ""
    
    echo "📦 Building full application..."
    mvn clean package -DskipTests
    
    if [ $? -eq 0 ]; then
        echo "✅ Build successful!"
        echo ""
        
        echo "🐳 Redeploying Docker containers..."
        docker-compose down --remove-orphans
        docker-compose up -d --build
        
        echo ""
        echo "⏳ Waiting for services..."
        sleep 30
        
        echo "🏥 Health check..."
        HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080 2>/dev/null || echo "000")
        
        if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "302" ] || [ "$HTTP_CODE" = "404" ]; then
            echo "🎉 SUCCESS! Application is running"
            echo ""
            echo "🌐 Access your app at:"
            echo "  http://localhost:8080"
            echo "  http://localhost:8080/auction/manage"
            echo "  http://localhost:8080/team"
        else
            echo "⚠️ Application may still be starting (HTTP $HTTP_CODE)"
            echo "Try accessing http://localhost:8080 in a few moments"
        fi
        
    else
        echo "❌ Build failed"
        exit 1
    fi
else
    echo "❌ Compilation still has errors"
    mvn compile
    exit 1
fi