#!/bin/bash

# Direct PostgreSQL Database Connection Script
# Connects directly to the FantasyIA database

echo "🗄️  Connecting to FantasyIA Database..."

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker first."
    exit 1
fi

# Start database if not running
if ! docker compose ps | grep fantasyia_postgres | grep "Up" > /dev/null; then
    echo "📦 Starting database container..."
    docker compose up -d db
    echo "⏳ Waiting for database to be ready..."
    
    # Wait for database to be healthy
    for i in {1..30}; do
        if docker compose exec db pg_isready -U fantasyia -d fantasyia > /dev/null 2>&1; then
            echo "✅ Database is ready!"
            break
        fi
        sleep 1
        echo -n "."
    done
    echo ""
fi

echo ""
echo "📝 Useful PostgreSQL commands:"
echo "   \\dt                    - List all tables"
echo "   \\d table_name         - Describe a table (e.g., \\d users)"
echo "   \\l                     - List all databases"
echo "   \\du                    - List all users"
echo "   \\q                     - Quit"
echo ""
echo "💡 Example queries:"
echo "   SELECT * FROM users;"
echo "   SELECT name, position, mlb_team FROM players LIMIT 10;"
echo "   SELECT * FROM auctions WHERE auction_status = 'ACTIVE';"
echo ""
echo "🔗 Connecting to database..."
echo "   Database: fantasyia"
echo "   User: fantasyia"
echo ""

# Connect to the database
docker compose exec db psql -U fantasyia -d fantasyia