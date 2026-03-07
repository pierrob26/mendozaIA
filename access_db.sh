#!/bin/bash

# Quick Database Access Script for FantasyIA
# This script provides easy database access options

echo "🗄️  FantasyIA Database Access"
echo "================================"
echo ""

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker first."
    exit 1
fi

# Function to start database if not running
start_db() {
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
}

# Check if database container exists and is running
if ! docker compose ps | grep fantasyia_postgres | grep "Up" > /dev/null; then
    start_db
fi

echo ""
echo "Choose an access method:"
echo "1) 🌐 Open PgAdmin (Web GUI)"
echo "2) 💻 PostgreSQL Command Line"
echo "3) 📊 View Database Tables"
echo "4) 👥 Show All Users"
echo "5) 🏃 Show All Players"
echo "6) 🔨 Show Active Auctions"
echo "7) 💰 Show Recent Bids"
echo "8) 📋 Custom SQL Query"
echo "9) 🔄 Database Status"
echo "0) ❌ Exit"
echo ""

read -p "Enter your choice (0-9): " choice

case $choice in
    1)
        echo ""
        echo "🌐 Starting PgAdmin..."
        docker compose up -d pgadmin
        sleep 3
        echo "✅ PgAdmin is starting up!"
        echo ""
        echo "📝 Access details:"
        echo "   URL: http://localhost:8081"
        echo "   Email: admin@admin.com"
        echo "   Password: admin"
        echo ""
        echo "🔧 To connect to the database in PgAdmin:"
        echo "   Host: db"
        echo "   Port: 5432"
        echo "   Database: fantasyia"
        echo "   Username: fantasyia"
        echo "   Password: fantasyia"
        echo ""
        if command -v open > /dev/null; then
            read -p "Open in browser? (y/n): " open_browser
            if [ "$open_browser" = "y" ]; then
                open http://localhost:8081
            fi
        fi
        ;;
    2)
        echo ""
        echo "💻 Opening PostgreSQL command line..."
        echo "📝 Useful commands:"
        echo "   \\dt          - List all tables"
        echo "   \\d users     - Describe users table"
        echo "   \\q           - Quit"
        echo ""
        docker compose exec db psql -U fantasyia -d fantasyia
        ;;
    3)
        echo ""
        echo "📊 Database Tables:"
        docker compose exec db psql -U fantasyia -d fantasyia -c "\\dt"
        ;;
    4)
        echo ""
        echo "👥 All Users:"
        docker compose exec db psql -U fantasyia -d fantasyia -c "SELECT id, username, role, salary_cap, current_salary_used FROM users ORDER BY id;"
        ;;
    5)
        echo ""
        echo "🏃 All Players:"
        docker compose exec db psql -U fantasyia -d fantasyia -c "SELECT id, name, position, mlb_team, contract_amount, owner_id FROM players ORDER BY name LIMIT 20;"
        ;;
    6)
        echo ""
        echo "🔨 Active Auctions:"
        docker compose exec db psql -U fantasyia -d fantasyia -c "SELECT id, auction_name, start_time, end_time, auction_status FROM auctions WHERE auction_status = 'ACTIVE' ORDER BY start_time;"
        ;;
    7)
        echo ""
        echo "💰 Recent Bids (Last 10):"
        docker compose exec db psql -U fantasyia -d fantasyia -c "SELECT * FROM bids ORDER BY id DESC LIMIT 10;" 2>/dev/null || echo "No bids table found or no bids yet."
        ;;
    8)
        echo ""
        read -p "Enter your SQL query: " sql_query
        if [ ! -z "$sql_query" ]; then
            docker compose exec db psql -U fantasyia -d fantasyia -c "$sql_query"
        fi
        ;;
    9)
        echo ""
        echo "🔄 Database Status:"
        echo "Containers:"
        docker compose ps
        echo ""
        echo "Database connection test:"
        if docker compose exec db pg_isready -U fantasyia -d fantasyia; then
            echo "✅ Database is accessible"
        else
            echo "❌ Database connection failed"
        fi
        ;;
    0)
        echo "👋 Goodbye!"
        exit 0
        ;;
    *)
        echo "❌ Invalid choice. Please try again."
        exit 1
        ;;
esac

echo ""
echo "✅ Operation completed!"