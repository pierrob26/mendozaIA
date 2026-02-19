#!/bin/bash

echo "╔═══════════════════════════════════════════════════════════════════════════╗"
echo "║                                                                           ║"
echo "║              🗄️  ACCESSING POSTGRESQL DATABASE                           ║"
echo "║                                                                           ║"
echo "╚═══════════════════════════════════════════════════════════════════════════╝"
echo ""

# Check if database container is running
echo "Checking database status..."
DB_STATUS=$(docker-compose ps db | grep -c "Up")

if [ "$DB_STATUS" -eq 0 ]; then
    echo "❌ Database container is not running!"
    echo ""
    echo "Starting database..."
    docker-compose up -d db
    sleep 5
    echo "✅ Database started!"
    echo ""
fi

echo "✅ Database is running!"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "🔌 CONNECTING TO DATABASE..."
echo ""
echo "Database: fantasyia"
echo "Username: fantasyia"
echo "Password: fantasyia"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Connect to database
docker exec -it fantasyia-db-1 psql -U fantasyia -d fantasyia
