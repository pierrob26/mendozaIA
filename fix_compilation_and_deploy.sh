#!/bin/bash

echo "🔧 FIXING TEAMCONTROLLER COMPILATION ERRORS"
echo "==========================================="
echo ""

echo "🧪 Testing compilation..."
mvn compile -q

if [ $? -eq 0 ]; then
    echo "✅ Compilation successful!"
    echo ""
    
    echo "📦 Building full application..."
    mvn clean package -DskipTests
    
    if [ $? -eq 0 ]; then
        echo "✅ Build successful!"
        echo ""
        
        echo "🐳 Rebuilding and starting Docker containers..."
        docker-compose down --remove-orphans 2>/dev/null
        docker-compose up -d --build
        
        echo ""
        echo "⏳ Waiting for services to initialize..."
        sleep 30
        
        echo "🏥 Checking application health..."
        HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080 2>/dev/null || echo "000")
        
        case $HTTP_CODE in
            200|302|404)
                echo "🎉 SUCCESS! Application is running (HTTP $HTTP_CODE)"
                echo ""
                echo "🌐 Your FantasyIA app is ready:"
                echo "  • Main App: http://localhost:8080"
                echo "  • Auction Manager: http://localhost:8080/auction/manage"
                echo "  • Team Manager: http://localhost:8080/team"
                echo "  • Database Admin: http://localhost:8081"
                echo ""
                echo "📊 Container Status:"
                docker-compose ps
                ;;
            000)
                echo "⚠️ Application not responding yet"
                echo "   May still be starting up - try http://localhost:8080 in a moment"
                ;;
            *)
                echo "⚠️ Application responding with HTTP $HTTP_CODE"
                echo "   Check logs: docker-compose logs -f app"
                ;;
        esac
        
    else
        echo "❌ Build failed after compilation fix"
        echo ""
        echo "🔍 Checking for remaining errors..."
        mvn compile
    fi
else
    echo "❌ Compilation still has errors"
    echo ""
    echo "🔍 Detailed error information:"
    mvn compile
fi