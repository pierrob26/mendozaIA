#!/bin/bash

echo "🔍 Checking if database tables exist..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Check if database container is running
if ! docker-compose ps | grep -q "db.*Up"; then
    echo "❌ Database container is not running!"
    echo "Starting database..."
    docker-compose up -d db
    sleep 5
fi

# Check if app container is running (needed to create tables)
if ! docker-compose ps | grep -q "app.*Up"; then
    echo "❌ Application container is not running!"
    echo "Starting application to create database tables..."
    docker-compose up -d app
    echo "⏳ Waiting 15 seconds for application to initialize..."
    sleep 15
fi

echo ""
echo "📊 DATABASE STATUS:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# List all tables
echo "Tables in database:"
docker exec fantasyia-db-1 psql -U fantasyia -d fantasyia -c "\dt" 2>/dev/null

echo ""
echo "📈 TABLE COUNTS:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Count records in key tables
echo "Counting records in each table..."
docker exec fantasyia-db-1 psql -U fantasyia -d fantasyia -c "
SELECT 
    'users' as table_name, 
    COUNT(*) as record_count 
FROM users
UNION ALL
SELECT 
    'players' as table_name, 
    COUNT(*) as record_count 
FROM players
UNION ALL
SELECT 
    'auctions' as table_name, 
    COUNT(*) as record_count 
FROM auctions
UNION ALL
SELECT 
    'auction_items' as table_name, 
    COUNT(*) as record_count 
FROM auction_items
UNION ALL
SELECT 
    'bids' as table_name, 
    COUNT(*) as record_count 
FROM bids
UNION ALL
SELECT 
    'released_players_queue' as table_name, 
    COUNT(*) as record_count 
FROM released_players_queue
ORDER BY table_name;" 2>/dev/null

echo ""
echo "✅ Database check complete!"
echo ""
echo "If you see tables above, proceed to register the server in pgAdmin."
echo "If no tables, try: docker-compose restart app"