#!/bin/bash

echo "=========================================="
echo "🧪 TESTING AUCTION CRASH FIX"
echo "=========================================="
echo ""

BASE_URL="http://localhost:8080"

echo "Testing auction endpoints..."
echo ""

# Test 1: Auction Management Page
echo "1️⃣  Testing /auction/manage..."
RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" -L ${BASE_URL}/auction/manage)
if [ "$RESPONSE" == "200" ]; then
    echo "   ✅ Auction manage page loads (HTTP 200)"
elif [ "$RESPONSE" == "302" ]; then
    echo "   ⚠️  Redirected (probably to login) - need to be logged in"
else
    echo "   ❌ Failed with HTTP $RESPONSE"
fi

# Test 2: Auction View Page
echo ""
echo "2️⃣  Testing /auction/view..."
RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" -L ${BASE_URL}/auction/view)
if [ "$RESPONSE" == "200" ]; then
    echo "   ✅ Auction view page loads (HTTP 200)"
elif [ "$RESPONSE" == "302" ]; then
    echo "   ⚠️  Redirected (probably to login)"
else
    echo "   ❌ Failed with HTTP $RESPONSE"
fi

# Test 3: Check Application Logs
echo ""
echo "3️⃣  Checking application logs for errors..."
ERROR_COUNT=$(docker-compose logs app --tail=100 | grep -c "ERROR")
if [ "$ERROR_COUNT" -eq 0 ]; then
    echo "   ✅ No errors in recent logs"
else
    echo "   ⚠️  Found $ERROR_COUNT error(s) in logs - check with: docker-compose logs app | grep ERROR"
fi

# Test 4: Check if containers are running
echo ""
echo "4️⃣  Checking Docker containers..."
APP_STATUS=$(docker-compose ps | grep app | grep -c "Up")
DB_STATUS=$(docker-compose ps | grep db | grep -c "Up")

if [ "$APP_STATUS" -eq 1 ]; then
    echo "   ✅ Application container is running"
else
    echo "   ❌ Application container is NOT running"
fi

if [ "$DB_STATUS" -eq 1 ]; then
    echo "   ✅ Database container is running"
else
    echo "   ❌ Database container is NOT running"
fi

# Test 5: Check database connection
echo ""
echo "5️⃣  Testing database connection..."
DB_TEST=$(docker exec fantasyia-db-1 psql -U fantasyia -d fantasyia -c "SELECT 1;" 2>&1)
if [[ $DB_TEST == *"1 row"* ]]; then
    echo "   ✅ Database connection successful"
else
    echo "   ❌ Database connection failed"
fi

# Test 6: Check for orphaned auction items
echo ""
echo "6️⃣  Checking for orphaned auction items..."
ORPHANED=$(docker exec fantasyia-db-1 psql -U fantasyia -d fantasyia -t -c "SELECT COUNT(*) FROM auction_items ai LEFT JOIN players p ON ai.player_id = p.id WHERE ai.status = 'ACTIVE' AND p.id IS NULL;" 2>&1)
ORPHANED=$(echo $ORPHANED | xargs) # trim whitespace
if [ "$ORPHANED" == "0" ]; then
    echo "   ✅ No orphaned auction items found"
else
    echo "   ⚠️  Found $ORPHANED orphaned auction item(s) - will be auto-cleaned on page load"
fi

echo ""
echo "=========================================="
echo "📊 TEST SUMMARY"
echo "=========================================="
echo ""
echo "Next steps:"
echo "1. Login to http://localhost:8080"
echo "2. Go to 'Manage Auction' (if commissioner)"
echo "3. Try adding a released player"
echo "4. Check 'Auction View' page"
echo ""
echo "Monitor logs: docker-compose logs -f app"
echo "Check database: docker exec -it fantasyia-db-1 psql -U fantasyia -d fantasyia"
echo ""
