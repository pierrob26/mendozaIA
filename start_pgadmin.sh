#!/bin/bash

# PgAdmin Quick Setup and Access Script
echo "🌐 Setting up PgAdmin for FantasyIA Database"
echo "============================================"

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker first."
    exit 1
fi

echo "📦 Starting database and PgAdmin containers..."
docker compose up -d db pgadmin

echo "⏳ Waiting for services to be ready..."
sleep 5

# Wait for database to be healthy
echo "🔍 Checking database status..."
for i in {1..30}; do
    if docker compose exec db pg_isready -U fantasyia -d fantasyia > /dev/null 2>&1; then
        echo "✅ Database is ready!"
        break
    fi
    sleep 1
    echo -n "."
done

echo ""
echo "🌐 PgAdmin is now starting up..."
sleep 3

echo ""
echo "🎉 PgAdmin Setup Complete!"
echo ""
echo "📝 Access Information:"
echo "   URL: http://localhost:8081"
echo "   Email: admin@admin.com"
echo "   Password: admin"
echo ""
echo "🔧 Database Connection Settings for PgAdmin:"
echo "   Host name/address: db"
echo "   Port: 5432"
echo "   Maintenance database: fantasyia"
echo "   Username: fantasyia"
echo "   Password: fantasyia"
echo ""
echo "📊 Available Tables:"
docker compose exec db psql -U fantasyia -d fantasyia -c "\dt" 2>/dev/null | grep -E "users|players|auctions|bids" || echo "   Tables will be visible once you connect in PgAdmin"
echo ""
echo "🚀 Opening PgAdmin in browser..."

# Try to open in browser (macOS)
if command -v open > /dev/null; then
    open http://localhost:8081
    echo "✅ Browser opened - you should see PgAdmin loading"
else
    echo "💻 Please open http://localhost:8081 in your browser"
fi

echo ""
echo "📚 Next steps:"
echo "1. Login to PgAdmin with the credentials above"
echo "2. Right-click 'Servers' → 'Create' → 'Server...'"
echo "3. Enter the database connection settings shown above"
echo "4. Browse your data under Servers → FantasyIA → Databases → fantasyia → Schemas → public → Tables"