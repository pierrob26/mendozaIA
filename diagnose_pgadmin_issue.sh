#!/bin/bash

echo "╔═══════════════════════════════════════════════════════════════════════════╗"
echo "║                                                                           ║"
echo "║          🔍  PGADMIN DATABASE VISIBILITY DIAGNOSTIC TOOL                 ║"
echo "║                                                                           ║"
echo "╚═══════════════════════════════════════════════════════════════════════════╝"
echo ""

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check prerequisites
echo "📋 CHECKING PREREQUISITES..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if command_exists docker; then
    echo "✅ Docker is installed"
else
    echo "❌ Docker is not installed or not in PATH"
    exit 1
fi

if command_exists docker-compose; then
    echo "✅ Docker Compose is installed"
else
    echo "❌ Docker Compose is not installed or not in PATH"
    exit 1
fi

echo ""

# Check Docker containers status
echo "🐳 CHECKING DOCKER CONTAINERS..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Check if containers exist and their status
DB_STATUS=$(docker-compose ps | grep db || echo "not found")
APP_STATUS=$(docker-compose ps | grep app || echo "not found")
PGADMIN_STATUS=$(docker-compose ps | grep pgadmin || echo "not found")

echo "Database container: $DB_STATUS"
echo "Application container: $APP_STATUS" 
echo "pgAdmin container: $PGADMIN_STATUS"
echo ""

# Check if database container is running
if docker-compose ps | grep -q "db.*Up"; then
    echo "✅ Database container is running"
    DB_RUNNING=true
else
    echo "❌ Database container is not running"
    DB_RUNNING=false
fi

# Check if pgAdmin container is running
if docker-compose ps | grep -q "pgadmin.*Up"; then
    echo "✅ pgAdmin container is running"
    PGADMIN_RUNNING=true
else
    echo "❌ pgAdmin container is not running"
    PGADMIN_RUNNING=false
fi

echo ""

# If containers aren't running, offer to start them
if [ "$DB_RUNNING" = false ] || [ "$PGADMIN_RUNNING" = false ]; then
    echo "🚀 STARTING CONTAINERS..."
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Starting database and pgAdmin containers..."
    docker-compose up -d db pgadmin
    sleep 10
    echo "✅ Containers started"
    echo ""
fi

# Check database connectivity
echo "🔌 TESTING DATABASE CONNECTIVITY..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Test connection to database
if docker exec -i fantasyia-db-1 psql -U fantasyia -d fantasyia -c "SELECT 1;" > /dev/null 2>&1; then
    echo "✅ Can connect to PostgreSQL database"
else
    echo "❌ Cannot connect to PostgreSQL database"
    echo "   This might be why you can't see tables in pgAdmin"
    echo ""
    echo "Try running: docker-compose restart db"
    exit 1
fi

# Check if database contains tables
echo ""
echo "📊 CHECKING DATABASE TABLES..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

TABLES=$(docker exec -i fantasyia-db-1 psql -U fantasyia -d fantasyia -t -c "\dt" 2>/dev/null | wc -l)

if [ "$TABLES" -gt 0 ]; then
    echo "✅ Database contains $TABLES table(s):"
    docker exec -i fantasyia-db-1 psql -U fantasyia -d fantasyia -c "\dt"
    echo ""
    
    # Check for data in key tables
    echo "📈 CHECKING TABLE DATA..."
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    USERS_COUNT=$(docker exec -i fantasyia-db-1 psql -U fantasyia -d fantasyia -t -c "SELECT COUNT(*) FROM users;" 2>/dev/null || echo "0")
    PLAYERS_COUNT=$(docker exec -i fantasyia-db-1 psql -U fantasyia -d fantasyia -t -c "SELECT COUNT(*) FROM players;" 2>/dev/null || echo "0")
    
    echo "Users: $USERS_COUNT"
    echo "Players: $PLAYERS_COUNT"
    echo ""
    
    if [ "$USERS_COUNT" -eq 0 ] && [ "$PLAYERS_COUNT" -eq 0 ]; then
        echo "⚠️  Tables exist but contain no data"
        echo "   The DataInitializer may not have run successfully"
    else
        echo "✅ Database contains data"
    fi
    
else
    echo "❌ No tables found in database"
    echo "   JPA entities haven't created tables yet"
    echo ""
    
    # Check if application is running
    echo "🏃 CHECKING APPLICATION STATUS..."
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    if docker-compose ps | grep -q "app.*Up"; then
        echo "✅ Application container is running but tables aren't created"
        echo "   Check application logs for errors:"
        echo "   docker-compose logs app"
    else
        echo "❌ Application container is not running"
        echo "   Tables won't be created until the app starts"
        echo "   Try: docker-compose up -d app"
    fi
fi

echo ""
echo "🌐 PGADMIN CONNECTION INFO..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ "$PGADMIN_RUNNING" = true ]; then
    echo "✅ pgAdmin is accessible at: http://localhost:8081"
    echo ""
    echo "Login credentials:"
    echo "  Email: admin@admin.com"
    echo "  Password: admin"
    echo ""
    echo "Database server connection details:"
    echo "  Hostname: db (internal Docker network) OR localhost (external)"
    echo "  Port: 5432"
    echo "  Database: fantasyia"
    echo "  Username: fantasyia"
    echo "  Password: fantasyia"
    echo ""
    echo "📌 IMPORTANT: When adding a server in pgAdmin:"
    echo "   1. Use hostname 'db' if pgAdmin is in Docker (recommended)"
    echo "   2. Use 'localhost' if connecting from outside Docker"
    echo ""
else
    echo "❌ pgAdmin container is not running"
    echo "   Start it with: docker-compose up -d pgadmin"
fi

echo ""
echo "🔧 TROUBLESHOOTING RECOMMENDATIONS..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ "$TABLES" -eq 0 ]; then
    echo "1. Start the application to create tables:"
    echo "   docker-compose up -d app"
    echo ""
    echo "2. Wait a few seconds, then check again:"
    echo "   ./diagnose_pgadmin_issue.sh"
    echo ""
fi

echo "3. If you still can't see tables in pgAdmin:"
echo "   a) Make sure you're connecting to the 'fantasyia' database"
echo "   b) Try refreshing the database tree in pgAdmin"
echo "   c) Check that the server hostname is correct ('db' not 'localhost')"
echo ""

echo "4. View database directly from command line:"
echo "   ./access_db.sh"
echo ""

echo "5. Check application logs for JPA/Hibernate errors:"
echo "   docker-compose logs app | grep -i error"
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Diagnostic complete! Follow the recommendations above."
echo ""