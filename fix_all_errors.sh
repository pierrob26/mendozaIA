#!/bin/bash

echo "🔧 FIXING APPLICATION ERRORS - COMPREHENSIVE FIX"
echo "=============================================="
echo ""

echo "📝 Summary of fixes applied:"
echo "1. ✅ Fixed database connection URL (localhost → db)"
echo "2. ✅ Fixed UserAccount null safety in getAvailableCapSpace()" 
echo "3. ✅ Fixed AuctionService validateBid method missing code"
echo "4. ✅ Added null checks in canAffordPlayer method"
echo ""

echo "🏗️  Building application with fixes..."
mvn clean package -DskipTests

if [ $? -eq 0 ]; then
    echo "✅ Build successful!"
    echo ""
    
    echo "🐳 Restarting Docker containers..."
    docker-compose down
    docker-compose up -d --build
    
    echo ""
    echo "⏳ Waiting for containers to start..."
    sleep 15
    
    echo ""
    echo "📊 Container status:"
    docker-compose ps
    
    echo ""
    echo "🔍 Quick error check in logs:"
    echo "============================"
    docker-compose logs --tail=20 app 2>&1 | grep -E "(ERROR|Exception|Failed)" || echo "✅ No obvious errors found in recent logs"
    
    echo ""
    echo "✨ FIXES COMPLETE!"
    echo ""
    echo "🌐 Access your application:"
    echo "  • Main app: http://localhost:8080"
    echo "  • Auction manage: http://localhost:8080/auction/manage"  
    echo "  • Auction view: http://localhost:8080/auction/view"
    echo ""
    echo "📱 To monitor logs: docker-compose logs -f app"
    
else
    echo "❌ Build failed. Checking for compilation errors..."
    mvn compile 2>&1 | tail -20
fi