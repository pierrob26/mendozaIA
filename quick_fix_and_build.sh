#!/bin/bash

echo "🔧 FIXING COMPILATION ERROR & REBUILDING..."
echo ""

# Build
mvn clean package -DskipTests

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ BUILD SUCCESSFUL!"
    echo ""
    echo "Restarting application..."
    docker-compose restart app
    
    echo ""
    echo "✅ APPLICATION RESTARTED!"
    echo ""
    echo "Wait 10 seconds for startup, then test:"
    echo "  • http://localhost:8080/auction/manage"
    echo "  • http://localhost:8080/auction/view"
    echo ""
    echo "Monitor logs: docker-compose logs -f app"
else
    echo ""
    echo "❌ BUILD STILL FAILED"
    echo "Check the error messages above."
    exit 1
fi
