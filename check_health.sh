#!/bin/bash

echo "🏥 FANTASYIA HEALTH CHECK"
echo "========================"
echo ""

# Check if containers are running
echo "📊 Container Status:"
docker-compose ps

echo ""

# Check application health
echo "🌐 Application Health:"
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080 2>/dev/null || echo "000")
echo "  • Main App (port 8080): HTTP $HTTP_CODE"

if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "302" ]; then
    echo "    ✅ Healthy"
else
    echo "    ❌ Not responding"
fi

# Check database health
echo "  • Database (port 5432):"
if docker-compose exec -T db pg_isready -U fantasyia -d fantasyia > /dev/null 2>&1; then
    echo "    ✅ Database ready"
else
    echo "    ❌ Database not ready"
fi

# Check PgAdmin
PGADMIN_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8081 2>/dev/null || echo "000")
echo "  • PgAdmin (port 8081): HTTP $PGADMIN_CODE"
if [ "$PGADMIN_CODE" = "200" ] || [ "$PGADMIN_CODE" = "302" ]; then
    echo "    ✅ Healthy"
else
    echo "    ❌ Not responding"
fi

echo ""

# Show recent logs if there are issues
if [ "$HTTP_CODE" != "200" ] && [ "$HTTP_CODE" != "302" ]; then
    echo "🔍 Recent application logs:"
    docker-compose logs --tail=10 app
    echo ""
fi

echo "💡 Useful commands:"
echo "  📱 View live logs: docker-compose logs -f app"
echo "  🔄 Restart all: docker-compose restart"
echo "  🛑 Stop all: docker-compose down"
echo "  🗑️  Full reset: docker-compose down -v && ./start_webapp.sh"