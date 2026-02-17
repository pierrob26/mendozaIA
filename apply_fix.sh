#!/bin/bash

echo "=========================================="
echo "🔧 APPLYING CRASH FIX"
echo "=========================================="
echo ""
echo "This will fix the auction page crash issue"
echo "and rebuild the application."
echo ""

# Clean and build
echo "Building application..."
mvn clean package -DskipTests

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Build successful!"
    echo ""
    echo "Restarting application container..."
    docker-compose restart app
    
    echo ""
    echo "✅ Application restarted!"
    echo ""
    echo "Waiting 10 seconds for application to start..."
    sleep 10
    
    echo ""
    echo "=========================================="
    echo "✅ FIX APPLIED SUCCESSFULLY!"
    echo "=========================================="
    echo ""
    echo "📋 Next Steps:"
    echo "1. Go to http://localhost:8080"
    echo "2. Login as commissioner"
    echo "3. Click 'Manage Auction'"
    echo "4. Try adding a released player to auction"
    echo ""
    echo "📊 Check logs with: docker-compose logs -f app"
    echo "🔍 Look for debug output like:"
    echo "    === ADD RELEASED PLAYER TO AUCTION ==="
    echo ""
    echo "📖 See CRASH_FIX.md for detailed troubleshooting"
    echo ""
else
    echo ""
    echo "❌ Build failed!"
    echo "Please check the error messages above."
    exit 1
fi
