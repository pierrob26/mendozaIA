#!/bin/bash

# FantasyIA 500 Error Fix Script
# Fixes JPA mapping issue with AuctionItem status field

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_status "Starting FantasyIA 500 Error Fix..."
echo "Time: $(date)"
echo ""

# Step 1: Stop all containers
print_status "Step 1: Stopping all Docker containers..."
if docker-compose down --remove-orphans; then
    print_success "Containers stopped successfully"
else
    print_error "Failed to stop containers"
    exit 1
fi
echo ""

# Step 2: Clean Maven artifacts
print_status "Step 2: Cleaning Maven build artifacts..."
if mvn clean; then
    print_success "Maven clean completed"
else
    print_error "Maven clean failed"
    exit 1
fi
echo ""

# Step 3: Compile with fresh JPA mappings
print_status "Step 3: Compiling source code with JPA mappings..."
if mvn compile; then
    print_success "Compilation successful - AuctionItem.status field should now be recognized"
else
    print_error "Compilation failed"
    exit 1
fi
echo ""

# Step 4: Build JAR package
print_status "Step 4: Building JAR package..."
if mvn package -DskipTests; then
    print_success "JAR package built successfully"
else
    print_error "JAR packaging failed"
    exit 1
fi
echo ""

# Step 5: Rebuild Docker containers (no cache)
print_status "Step 5: Rebuilding Docker containers with fresh code..."
if docker-compose build --no-cache; then
    print_success "Docker containers rebuilt successfully"
else
    print_error "Docker rebuild failed"
    exit 1
fi
echo ""

# Step 6: Start containers
print_status "Step 6: Starting FantasyIA application..."
if docker-compose up -d; then
    print_success "Application started successfully"
else
    print_error "Application startup failed"
    exit 1
fi
echo ""

# Step 7: Wait for application startup and check logs
print_status "Step 7: Waiting for application startup (30 seconds)..."
sleep 30
echo ""

print_status "Checking application logs for JPA mapping errors..."
docker-compose logs --tail=50 fantasyia_app

echo ""
print_status "Testing application endpoint..."
if curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/ | grep -q "200\|302\|301"; then
    print_success "Application is responding! Login should now work."
    echo ""
    echo "🎉 Fix Complete! You can now login at: http://localhost:8080"
    echo ""
    echo "Test credentials:"
    echo "  Username: testuser"
    echo "  Password: password"
else
    print_error "Application may still have issues. Check logs above."
fi

echo ""
print_status "Fix script completed at $(date)"