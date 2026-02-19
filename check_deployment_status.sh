#!/bin/bash

echo "📊 DOCKER CONTAINER DEPLOYMENT STATUS"
echo "===================================="
echo ""

echo "🐳 Container Status:"
echo "-------------------"
docker-compose ps

echo ""
echo "🌐 Service Health Check:"
echo "------------------------"

# Check Application
echo -n "Application (localhost:8080): "
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080 2>/dev/null || echo "000")
case $HTTP_CODE in
    200|302|404)
        echo "✅ HEALTHY (HTTP $HTTP_CODE)"
        APP_HEALTHY=true
        ;;
    000)
        echo "❌ NOT RESPONDING"
        APP_HEALTHY=false
        ;;
    *)
        echo "⚠️ ISSUES (HTTP $HTTP_CODE)"
        APP_HEALTHY=false
        ;;
esac

# Check Database
echo -n "Database (PostgreSQL): "
if docker-compose exec -T db pg_isready -U fantasyia -d fantasyia > /dev/null 2>&1; then
    echo "✅ READY"
    DB_HEALTHY=true
else
    echo "❌ NOT READY"
    DB_HEALTHY=false
fi

# Check PgAdmin
echo -n "PgAdmin (localhost:8081): "
PGADMIN_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8081 2>/dev/null || echo "000")
case $PGADMIN_CODE in
    200|302)
        echo "✅ HEALTHY (HTTP $PGADMIN_CODE)"
        ;;
    000)
        echo "❌ NOT RESPONDING"
        ;;
    *)
        echo "⚠️ ISSUES (HTTP $PGADMIN_CODE)"
        ;;
esac

echo ""
echo "📱 Access URLs:"
echo "--------------"
echo "Main Application: http://localhost:8080"
echo "Auction Manager:  http://localhost:8080/auction/manage"
echo "Team Manager:     http://localhost:8080/team"
echo "Database Admin:   http://localhost:8081"

echo ""
echo "🔧 Management Commands:"
echo "----------------------"
echo "View app logs:    docker-compose logs -f app"
echo "View all logs:    docker-compose logs -f"
echo "Restart services: docker-compose restart"
echo "Stop services:    docker-compose down"
echo "Rebuild all:      docker-compose up -d --build"

echo ""

# Show recent logs if there are issues
if [ "$APP_HEALTHY" != true ] || [ "$DB_HEALTHY" != true ]; then
    echo "🔍 Recent Logs (Last 10 lines):"
    echo "--------------------------------"
    if [ "$APP_HEALTHY" != true ]; then
        echo "Application logs:"
        docker-compose logs --tail=10 app 2>/dev/null || echo "No app logs available"
        echo ""
    fi
    if [ "$DB_HEALTHY" != true ]; then
        echo "Database logs:"
        docker-compose logs --tail=5 db 2>/dev/null || echo "No database logs available"
        echo ""
    fi
    
    echo "💡 Troubleshooting tips:"
    echo "- Wait a few more minutes for services to fully start"
    echo "- Check full logs: docker-compose logs -f"
    echo "- Restart: docker-compose restart"
    echo "- Full redeploy: ./redeploy_containers.sh"
fi

if [ "$APP_HEALTHY" = true ] && [ "$DB_HEALTHY" = true ]; then
    echo "🎉 ALL SERVICES ARE HEALTHY!"
    echo ""
    echo "Your FantasyIA application is ready to use at http://localhost:8080"
fi