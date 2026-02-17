#!/bin/bash

echo "=========================================="
echo "Rebuilding FantasyIA Application"
echo "=========================================="

# Clean and build the application
echo "Building with Maven..."
mvn clean package -DskipTests

if [ $? -eq 0 ]; then
    echo "✅ Build successful!"
    
    echo ""
    echo "=========================================="
    echo "Restarting Docker Containers"
    echo "=========================================="
    
    # Stop existing containers
    docker-compose down
    
    # Start containers
    docker-compose up -d
    
    echo ""
    echo "✅ Application restarted!"
    echo ""
    echo "📊 Check status with: docker-compose ps"
    echo "📋 View logs with: docker-compose logs -f app"
    echo "🌐 Access at: http://localhost:8080"
    echo "🗄️  pgAdmin at: http://localhost:8081 (admin@admin.com / admin)"
    echo ""
else
    echo "❌ Build failed! Please check the errors above."
    exit 1
fi
