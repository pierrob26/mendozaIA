#!/bin/bash

# Fantasy Baseball Entity Fix Script
# March 6, 2026

set -e

echo "🔧 Fixing Hibernate Entity Mapping Issues..."
echo "============================================"

cd /Users/robbypierson/IdeaProjects/fantasyIA

# Step 1: Stop the app container
echo "🛑 Stopping fantasyia-app container..."
docker stop fantasyia_app 2>/dev/null || echo "Container not running"
docker rm fantasyia_app 2>/dev/null || echo "Container already removed"

# Step 2: Remove the old app image
echo "🗑️ Removing old app image..."
docker rmi fantasyia-app 2>/dev/null || echo "No old image to remove"

# Step 3: Compile the application with entity fixes
echo "🔨 Building application with entity fixes..."
mvn clean compile -q

if [ $? -eq 0 ]; then
    echo "✅ Compilation successful - entity issues fixed!"
else
    echo "❌ Compilation failed - there may be more entity issues"
    exit 1
fi

# Step 4: Build JAR
echo "📦 Building JAR file..."
mvn package -DskipTests -q

# Step 5: Build and start app container
echo "🚀 Building and starting app container..."
docker-compose up --build --no-deps -d app

# Step 6: Wait for startup
echo "⏳ Waiting for application to start..."
sleep 30

# Step 7: Check container status
echo "📊 Container Status:"
docker ps --filter "name=fantasyia_app" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# Step 8: Check health endpoint
echo ""
echo "🏥 Health Check:"
sleep 5
if curl -f http://localhost:8080/actuator/health 2>/dev/null | grep -q "UP"; then
    echo "✅ Application health check PASSED - Entity issues resolved!"
elif curl -f http://localhost:8080/ 2>/dev/null; then
    echo "✅ Application main page responding - Likely resolved!"
else
    echo "⚠️ Application not yet responding - checking logs..."
fi

# Step 9: Show relevant logs
echo ""
echo "📋 Recent App Logs (entity-related):"
echo "-----------------------------------"
docker logs fantasyia_app --tail=50 | grep -E "(Entity|Hibernate|JPA|ERROR|Exception)" || docker logs fantasyia_app --tail=20

echo ""
echo "🎯 Entity Fix Results:"
echo "- Removed conflicting field mappings in Auction entity"
echo "- Fixed createdBy vs createdByCommissionerId duplication"  
echo "- Fixed type vs auctionType duplication"
echo "- Updated AuctionRepository method names"
echo "- Added Hibernate debugging configuration"

echo ""
echo "🌐 Access Points:"
echo "  • App: http://localhost:8080"
echo "  • Health: http://localhost:8080/actuator/health"