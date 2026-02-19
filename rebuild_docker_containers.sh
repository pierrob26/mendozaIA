#!/bin/bash

echo "🐳 REBUILDING DOCKER CONTAINERS FOR FANTASYIA WEB APPLICATION"
echo "============================================================="
echo ""

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker Desktop first."
    exit 1
fi

echo "✅ Docker is running"
echo ""

# Stop and remove existing containers
echo "🛑 Stopping existing containers..."
docker-compose down -v 2>/dev/null || true

# Remove any orphaned containers
echo "🧹 Cleaning up old containers..."
docker container prune -f
docker image prune -f

echo ""
echo "🏗️ Building application..."
mvn clean package -DskipTests

if [ $? -ne 0 ]; then
    echo "❌ Maven build failed!"
    exit 1
fi

echo ""
echo "🐳 Building and starting Docker containers..."
docker-compose up -d --build

echo ""
echo "⏳ Waiting for services to start..."
sleep 20

echo ""
echo "📊 Container Status:"
docker-compose ps

echo ""
echo "🔍 Checking application health..."
sleep 5

# Check if containers are running
APP_STATUS=$(docker-compose ps app --format "table {{.State}}" | tail -n +2)
DB_STATUS=$(docker-compose ps db --format "table {{.State}}" | tail -n +2)
PGADMIN_STATUS=$(docker-compose ps pgadmin --format "table {{.State}}" | tail -n +2)

echo "Application: $APP_STATUS"
echo "Database: $DB_STATUS" 
echo "PgAdmin: $PGADMIN_STATUS"

echo ""
if [[ "$APP_STATUS" == *"Up"* ]] && [[ "$DB_STATUS" == *"Up"* ]]; then
    echo "✅ ALL CONTAINERS RUNNING SUCCESSFULLY!"
    echo ""
    echo "🌐 Your web application is available at:"
    echo "  • Main Application: http://localhost:8080"
    echo "  • Auction Management: http://localhost:8080/auction/manage"
    echo "  • Team Management: http://localhost:8080/team" 
    echo "  • PgAdmin (Database): http://localhost:8081"
    echo ""
    echo "🔑 PgAdmin Login:"
    echo "  • Email: admin@admin.com"
    echo "  • Password: admin"
    echo ""
    echo "📱 To view logs: docker-compose logs -f app"
    echo "📱 To stop: docker-compose down"
    
    # Test the application
    echo "🧪 Testing application response..."
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080 2>/dev/null || echo "000")
    if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "302" ]; then
        echo "✅ Application responding correctly (HTTP $HTTP_CODE)"
    else
        echo "⚠️  Application may still be starting (HTTP $HTTP_CODE)"
        echo "   Try accessing http://localhost:8080 in a few more seconds"
    fi
    
else
    echo "❌ SOME CONTAINERS FAILED TO START"
    echo ""
    echo "🔍 Application logs:"
    docker-compose logs --tail=20 app
    echo ""
    echo "🔍 Database logs:"
    docker-compose logs --tail=10 db
    
    echo ""
    echo "💡 Troubleshooting tips:"
    echo "  1. Check logs: docker-compose logs -f app"
    echo "  2. Restart containers: docker-compose restart"
    echo "  3. Full rebuild: docker-compose down && docker-compose up -d --build"
fi