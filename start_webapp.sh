#!/bin/bash

echo "🚀 FANTASYIA WEB APPLICATION - DOCKER STARTUP"
echo "============================================="
echo ""

# Check prerequisites
echo "🔍 Checking prerequisites..."

# Check if Docker is installed and running
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker Desktop."
    exit 1
fi

if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker Desktop."
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose is not installed."
    exit 1
fi

echo "✅ Docker and Docker Compose are ready"

# Check if Maven is available for building
if command -v mvn &> /dev/null; then
    echo "✅ Maven is available"
    HAS_MAVEN=true
else
    echo "⚠️  Maven not found - will try to use existing JAR"
    HAS_MAVEN=false
fi

echo ""

# Stop any existing containers
echo "🛑 Stopping any existing containers..."
docker-compose down --remove-orphans > /dev/null 2>&1

# Clean up old containers and images
echo "🧹 Cleaning up old containers and images..."
docker container prune -f > /dev/null 2>&1
docker image prune -f > /dev/null 2>&1

echo ""

# Build the application if Maven is available
if [ "$HAS_MAVEN" = true ]; then
    echo "🏗️  Building application with Maven..."
    mvn clean package -DskipTests
    
    if [ $? -ne 0 ]; then
        echo "❌ Maven build failed!"
        echo "Trying to continue with existing JAR..."
    else
        echo "✅ Maven build successful"
    fi
else
    echo "⚠️  Skipping Maven build - using existing JAR"
fi

# Check if JAR exists
if [ ! -f "target/fantasyia-0.0.1-SNAPSHOT.jar" ]; then
    echo "❌ Application JAR not found at target/fantasyia-0.0.1-SNAPSHOT.jar"
    echo "Please run: mvn clean package"
    exit 1
fi

echo "✅ Application JAR found"
echo ""

# Build and start containers
echo "🐳 Building and starting Docker containers..."
echo "This may take a few minutes on first run..."
echo ""

docker-compose up -d --build

if [ $? -ne 0 ]; then
    echo "❌ Failed to start containers"
    echo ""
    echo "🔍 Checking logs..."
    docker-compose logs
    exit 1
fi

echo ""
echo "⏳ Waiting for services to initialize..."

# Wait for database to be ready
echo "Waiting for database..."
for i in {1..30}; do
    if docker-compose exec -T db pg_isready -U fantasyia -d fantasyia > /dev/null 2>&1; then
        echo "✅ Database is ready"
        break
    fi
    echo -n "."
    sleep 2
done
echo ""

# Wait for application to be ready
echo "Waiting for application..."
for i in {1..60}; do
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080 2>/dev/null || echo "000")
    if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "302" ] || [ "$HTTP_CODE" = "404" ]; then
        echo "✅ Application is responding (HTTP $HTTP_CODE)"
        break
    fi
    echo -n "."
    sleep 3
done
echo ""

# Final status check
echo "📊 Final Status Check:"
echo "====================="

# Container status
docker-compose ps

echo ""

# Application test
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080 2>/dev/null || echo "000")
if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "302" ] || [ "$HTTP_CODE" = "404" ]; then
    echo "🎉 SUCCESS! FantasyIA Web Application is running!"
    echo ""
    echo "🌐 Access your application:"
    echo "  📱 Main App: http://localhost:8080"
    echo "  ⚖️  Auction Manager: http://localhost:8080/auction/manage"
    echo "  👥 Team Manager: http://localhost:8080/team"
    echo "  🗄️  Database Admin: http://localhost:8081"
    echo ""
    echo "🔑 PgAdmin Credentials:"
    echo "  📧 Email: admin@admin.com"
    echo "  🔐 Password: admin"
    echo ""
    echo "📊 Container Management:"
    echo "  📱 View logs: docker-compose logs -f app"
    echo "  🔄 Restart: docker-compose restart"
    echo "  🛑 Stop all: docker-compose down"
    echo "  🗑️  Full cleanup: docker-compose down -v"
    echo ""
else
    echo "⚠️  Application may still be starting up"
    echo "HTTP Response: $HTTP_CODE"
    echo ""
    echo "🔍 Troubleshooting:"
    echo "  1. Check application logs: docker-compose logs -f app"
    echo "  2. Check database logs: docker-compose logs -f db"
    echo "  3. Wait a bit longer and try: curl http://localhost:8080"
    echo "  4. Restart services: docker-compose restart"
fi

echo ""
echo "📁 Project files:"
echo "  Docker Compose: docker-compose.yml"
echo "  Dockerfile: Dockerfile"
echo "  Database Init: init-db.sql"
echo ""