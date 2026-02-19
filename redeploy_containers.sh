#!/bin/bash

echo "🚀 REDEPLOYING FANTASYIA DOCKER CONTAINERS"
echo "=========================================="
echo ""

# Step 1: Stop existing containers
echo "🛑 Stopping existing containers..."
docker-compose down --remove-orphans 2>/dev/null || true

# Step 2: Clean up old resources
echo "🧹 Cleaning up old containers and images..."
docker container prune -f > /dev/null 2>&1
docker image prune -f > /dev/null 2>&1

# Step 3: Build the application
echo "🏗️ Building application..."
mvn clean package -DskipTests

if [ $? -ne 0 ]; then
    echo "❌ Build failed!"
    exit 1
fi

echo "✅ Build successful"

# Step 4: Build and start containers
echo "🐳 Building and starting Docker containers..."
docker-compose up -d --build

# Step 5: Wait for services to be ready
echo "⏳ Waiting for services to start..."
sleep 30

# Step 6: Health check
echo "🏥 Checking service health..."

# Check database
echo "Checking database..."
for i in {1..20}; do
    if docker-compose exec -T db pg_isready -U fantasyia -d fantasyia > /dev/null 2>&1; then
        echo "✅ Database is ready"
        break
    fi
    echo -n "."
    sleep 2
done

echo ""

# Check application
echo "Checking application..."
for i in {1..30}; do
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080 2>/dev/null || echo "000")
    if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "302" ] || [ "$HTTP_CODE" = "404" ]; then
        echo "✅ Application is ready (HTTP $HTTP_CODE)"
        break
    fi
    echo -n "."
    sleep 3
done

echo ""
echo ""

# Final status
echo "📊 DEPLOYMENT STATUS"
echo "==================="
docker-compose ps

echo ""

# Test application endpoint
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080 2>/dev/null || echo "000")
if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "302" ] || [ "$HTTP_CODE" = "404" ]; then
    echo "🎉 DEPLOYMENT SUCCESSFUL!"
    echo ""
    echo "🌐 Your FantasyIA application is ready:"
    echo "  📱 Main App: http://localhost:8080"
    echo "  ⚖️  Auction Manager: http://localhost:8080/auction/manage"
    echo "  👥 Team Manager: http://localhost:8080/team"
    echo "  🗄️  Database Admin: http://localhost:8081"
    echo ""
    echo "🔑 PgAdmin Login:"
    echo "  📧 Email: admin@admin.com"
    echo "  🔐 Password: admin"
    echo ""
else
    echo "⚠️ DEPLOYMENT MAY HAVE ISSUES"
    echo "Application response: HTTP $HTTP_CODE"
    echo ""
    echo "🔍 Recent application logs:"
    docker-compose logs --tail=10 app
    echo ""
    echo "Try waiting a bit longer and check http://localhost:8080"
fi

echo "📊 Management commands:"
echo "  📱 View logs: docker-compose logs -f app"
echo "  🔄 Restart: docker-compose restart"
echo "  🛑 Stop: docker-compose down"