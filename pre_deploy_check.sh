#!/bin/bash

echo "🔍 PRE-DEPLOYMENT CHECK"
echo "======================"
echo ""

# Check Docker availability
echo "Checking Docker status..."
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker Desktop first."
    exit 1
fi
echo "✅ Docker is running"

# Check current containers
echo ""
echo "Current containers:"
docker ps -a --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" 2>/dev/null || echo "No containers found"

# Check if our compose services exist
echo ""
echo "FantasyIA services status:"
if [ -f "docker-compose.yml" ]; then
    docker-compose ps 2>/dev/null || echo "No compose services found"
else
    echo "❌ docker-compose.yml not found"
    exit 1
fi

# Check if JAR exists for building
echo ""
echo "Checking application JAR..."
if [ -f "target/fantasyia-0.0.1-SNAPSHOT.jar" ]; then
    JAR_SIZE=$(ls -lh target/fantasyia-0.0.1-SNAPSHOT.jar | awk '{print $5}')
    echo "✅ JAR found: $JAR_SIZE"
else
    echo "⚠️ JAR not found - will build with Maven"
fi

# Check Maven availability
if command -v mvn &> /dev/null; then
    echo "✅ Maven is available"
else
    echo "❌ Maven not found - install Maven to build the application"
    exit 1
fi

echo ""
echo "🚀 Ready for redeployment!"
echo ""
echo "To proceed with redeployment, run:"
echo "  chmod +x redeploy_containers.sh && ./redeploy_containers.sh"
echo ""
echo "Or use the execute script:"
echo "  chmod +x execute_redeploy.sh && ./execute_redeploy.sh"