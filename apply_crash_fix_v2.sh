#!/bin/bash

echo "=========================================="
echo "🔧 APPLYING AUCTION CRASH FIX v2"
echo "=========================================="
echo ""
echo "This fixes null pointer exceptions when"
echo "player data is missing from the database."
echo ""

# Clean and build
echo "Building application..."
mvn clean package -DskipTests

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Build successful!"
    echo ""
    echo "Restarting application..."
    docker-compose restart app
    
    echo ""
    echo "Waiting for application to start..."
    sleep 10
    
    echo ""
    echo "=========================================="
    echo "✅ FIX APPLIED SUCCESSFULLY!"
    echo "=========================================="
    echo ""
    echo "🔧 What was fixed:"
    echo "  • Null-safe player map handling"
    echo "  • Safe navigation in templates"
    echo "  • Better error handling in controllers"
    echo "  • Automatic cleanup of orphaned auction items"
    echo ""
    echo "📋 Test the fix:"
    echo "  1. Go to http://localhost:8080/auction/manage"
    echo "  2. Try adding a released player"
    echo "  3. Go to http://localhost:8080/auction/view"
    echo "  4. Verify no crashes occur"
    echo ""
    echo "📊 Monitor logs: docker-compose logs -f app"
    echo ""
else
    echo ""
    echo "❌ Build failed!"
    echo "Check errors above and try again."
    exit 1
fi
