#!/bin/bash

echo "=== Verifying Reversion and Rebuilding Application ==="
echo "Current time: $(date)"
echo ""

# Check current state of key files
echo "1. Checking AuctionService salary cap message..."
grep -n "100M salary cap" src/main/java/com/fantasyia/auction/AuctionService.java && echo "✅ Salary cap reverted to $100M" || echo "❌ Salary cap issue"

echo ""
echo "2. Checking UserAccount salary cap default..."
grep -n "100.0" src/main/java/com/fantasyia/user/UserAccount.java && echo "✅ UserAccount salary cap reverted" || echo "❌ UserAccount salary cap issue"

echo ""
echo "3. Checking AuctionItemRepository method parsing..."
grep -A2 -B2 "findByAuctionIdAndStatus" src/main/java/com/fantasyia/auction/AuctionItemRepository.java

echo ""
echo "4. Stopping existing containers..."
docker-compose down

echo ""
echo "5. Cleaning Maven build artifacts..."
mvn clean

echo ""
echo "6. Compiling with reverted changes..."
mvn compile

if [ $? -eq 0 ]; then
    echo "✅ Compilation successful with reverted changes"
    
    echo ""
    echo "7. Building JAR package..."
    mvn package -DskipTests
    
    if [ $? -eq 0 ]; then
        echo "✅ JAR built successfully"
        
        echo ""
        echo "8. Rebuilding Docker containers (no cache)..."
        docker-compose build --no-cache
        
        echo ""
        echo "9. Starting containers with reverted code..."
        docker-compose up -d
        
        echo ""
        echo "10. Checking container status..."
        sleep 10
        docker-compose ps
        
        echo ""
        echo "=== Reversion Rebuild Complete ==="
        echo "Check application logs: docker-compose logs -f fantasyia_app"
        echo "Application should be available at: http://localhost:8080"
    else
        echo "❌ JAR build failed"
    fi
else
    echo "❌ Compilation failed - check errors above"
fi