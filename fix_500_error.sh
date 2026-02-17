#!/bin/bash

echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║        🔧 FIXING 500 ERROR & REBUILDING                       ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""
echo "What was fixed:"
echo "  ✓ Replaced Map.of() with HashMap"
echo "  ✓ Fixed concurrent modification issues"
echo "  ✓ Better null handling"
echo ""
echo "Building application..."
echo ""

mvn clean package -DskipTests

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ BUILD SUCCESSFUL!"
    echo ""
    echo "Restarting application..."
    docker-compose restart app
    
    echo ""
    echo "Waiting for application to start (15 seconds)..."
    sleep 15
    
    echo ""
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║                    ✅ DEPLOYMENT COMPLETE                     ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo ""
    echo "🧪 TEST NOW:"
    echo "   1. Go to http://localhost:8080/auction/manage"
    echo "   2. Go to http://localhost:8080/auction/view"
    echo ""
    echo "📊 Check logs:"
    echo "   docker-compose logs -f app"
    echo ""
    echo "If still seeing errors, run:"
    echo "   chmod +x check_errors.sh && ./check_errors.sh"
    echo ""
else
    echo ""
    echo "❌ BUILD FAILED"
    echo "Check error messages above"
    exit 1
fi
