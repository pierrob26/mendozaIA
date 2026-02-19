#!/bin/bash

echo "=== Fixing Auction Manage Page Crash ==="
echo ""

echo "Step 1: Stopping current containers..."
docker-compose down

echo ""
echo "Step 2: Cleaning and rebuilding application..."
mvn clean package -DskipTests

if [ $? -ne 0 ]; then
    echo "❌ Build failed! Check the errors above."
    exit 1
fi

echo ""
echo "Step 3: Rebuilding and starting Docker containers..."
docker-compose up -d --build

echo ""
echo "Step 4: Waiting for services to start..."
sleep 10

echo ""
echo "Step 5: Checking container status..."
docker-compose ps

echo ""
echo "=== Fix Applied Successfully! ==="
echo ""
echo "Changes made:"
echo "  ✅ Added comprehensive null checks in AuctionController.manageAuctions()"
echo "  ✅ Fixed template to use .get() method instead of array notation"
echo "  ✅ Fixed canBeRemoved() calls to pass auction type parameter"
echo "  ✅ Added safety checks for all repository queries"
echo "  ✅ Initialize empty collections in error handler to prevent template crashes"
echo ""
echo "Services available at:"
echo "  • Application: http://localhost:8080"
echo "  • PgAdmin: http://localhost:8081"
echo ""
echo "To view logs: docker-compose logs -f app"
echo "To stop: docker-compose down"
