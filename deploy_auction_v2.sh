#!/usr/bin/env zsh
set -euo pipefail

echo "=========================================="
echo "  Free Agency Auction System v2.0"
echo "  Deployment Script"
echo "=========================================="
echo ""

# Project root
PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$PROJECT_DIR"

# Check if database is up
echo "[1/6] Checking database status..."
if ! docker ps | grep -q fantasyia-postgres; then
    echo "⚠️  PostgreSQL container not running. Starting database..."
    docker compose up -d postgres
    echo "⏳ Waiting 10 seconds for database to initialize..."
    sleep 10
fi
echo "✅ Database is running"
echo ""

# Build application
echo "[2/6] Building application..."
mvn clean package -DskipTests
if [ $? -eq 0 ]; then
    echo "✅ Build successful"
else
    echo "❌ Build failed. Please fix compilation errors."
    exit 1
fi
echo ""

# Stop existing application
echo "[3/6] Stopping existing application..."
docker compose down app || true
echo "✅ Application stopped"
echo ""

# Start application with new code
echo "[4/6] Starting application with new auction system..."
docker compose up --build -d app
echo "✅ Application container started"
echo ""

# Wait for application to be ready
echo "[5/6] Waiting for application to start..."
echo "⏳ This may take 30-60 seconds..."
for i in {1..30}; do
    if curl -s http://localhost:8080/login > /dev/null 2>&1; then
        echo "✅ Application is ready!"
        break
    fi
    echo -n "."
    sleep 2
done
echo ""

# Show status
echo "[6/6] Deployment status:"
docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}" | grep fantasyia
echo ""

# Show recent logs
echo "=========================================="
echo "Recent application logs:"
echo "=========================================="
docker compose logs --tail=20 app
echo ""

echo "=========================================="
echo "  ✅ DEPLOYMENT COMPLETE"
echo "=========================================="
echo ""
echo "📍 Application URL: http://localhost:8080"
echo "📍 Database: localhost:5433"
echo ""
echo "📚 Documentation:"
echo "   - FREE_AGENCY_SYSTEM.md - User guide and rules"
echo "   - DATABASE_MIGRATION_V2.md - Database updates"
echo "   - AUCTION_IMPLEMENTATION_SUMMARY.md - Technical details"
echo ""
echo "🔍 Monitor logs with: docker compose logs -f app"
echo "🔍 Access database with: ./access_db.sh"
echo ""
echo "⚠️  IMPORTANT: Review DATABASE_MIGRATION_V2.md for required"
echo "    database schema updates if not using Hibernate auto-update"
echo ""
