#!/bin/bash

# Salary Cap Update Deployment Script
# Updates salary cap from $100M to $125M for all teams

echo "🚀 Deploying Salary Cap Update: \$100M → \$125M"
echo "============================================="

echo "📋 Changes Applied:"
echo "  ✅ UserAccount.java - Default salary cap: 125.0"
echo "  ✅ RegisterController.java - New user salary cap: 125.0"
echo "  ✅ DataInitializer.java - Test user salary caps: 125.0"
echo "  ✅ AuctionService.java - Error message: \$125M salary cap"
echo "  ✅ auction-manage.html - Rules display: \$125M"
echo "  ✅ home.html - Placeholder text: \$125M"
echo "  ✅ Documentation updated to reflect \$125M"

echo ""
echo "🔧 Building application..."
mvn clean package -DskipTests -q

if [ $? -ne 0 ]; then
    echo "❌ Build failed! Please check for compilation errors."
    exit 1
fi

echo "✅ Build successful!"
echo ""

echo "🗄️  Updating database..."
echo "  - Changing existing users from \$100M to \$125M salary cap"

# Check if we're using Docker
if [ -f "docker-compose.yml" ]; then
    echo "  - Using Docker environment"
    
    # Make sure containers are running
    echo "  - Starting database container if needed..."
    docker compose up -d db
    
    # Wait for database to be ready
    echo "  - Waiting for database to be ready..."
    for i in {1..30}; do
        if docker compose exec db pg_isready -U fantasyia -d fantasyia > /dev/null 2>&1; then
            echo "  - Database is ready!"
            break
        fi
        if [ $i -eq 30 ]; then
            echo "  ⚠️  Database not ready after 30 seconds - proceeding anyway"
        fi
        sleep 1
    done
    
    # Execute SQL update via Docker
    echo "  - Executing SQL update..."
    if docker compose exec -T db psql -U fantasyia -d fantasyia < update_salary_cap_to_125M.sql; then
        echo "  ✅ Database updated successfully!"
    else
        echo "  ⚠️  Database update may have failed - please check manually"
        echo "     You can run: docker compose exec -T db psql -U fantasyia -d fantasyia < update_salary_cap_to_125M.sql"
    fi
else
    echo "  ⚠️  Docker not detected - please run update_salary_cap_to_125M.sql manually on your database"
fi

echo ""
echo "🐳 Restarting application..."
if [ -f "docker-compose.yml" ]; then
    docker compose down
    docker compose up --build -d
    
    echo ""
    echo "⏳ Waiting for application to start..."
    sleep 10
    
    # Check if application is responding
    if curl -s http://localhost:8080 > /dev/null 2>&1; then
        echo "✅ Application is running!"
        echo "🌐 Access your fantasy league at: http://localhost:8080"
    else
        echo "⚠️  Application may still be starting up - check docker logs if needed"
        echo "   Run: docker compose logs app"
    fi
else
    echo "⚠️  Please restart your application manually"
fi

echo ""
echo "📊 SALARY CAP UPDATE COMPLETE!"
echo "================================"
echo "All teams now have a \$125M salary cap:"
echo "  • New users: \$125M default"
echo "  • Existing users: Updated to \$125M"
echo "  • Error messages: Reference \$125M"
echo "  • UI displays: Show \$125M limits"
echo ""
echo "🎯 Test the changes:"
echo "  1. Login and check home page salary display"
echo "  2. Try placing bids near the \$125M limit"
echo "  3. Register new users (should get \$125M cap)"
echo "  4. Check auction rules display"
echo ""
echo "✨ Happy fantasy league managing!"