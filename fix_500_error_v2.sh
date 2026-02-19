#!/usr/bin/env zsh
# This script fixes the 500 error by rebuilding everything fresh
set -euo pipefail

echo "=========================================="
echo "  EMERGENCY FIX - 500 Error Resolution"
echo "=========================================="
echo ""

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$PROJECT_DIR"

echo "[1/6] Stopping all containers..."
docker compose down
echo "✅ Containers stopped"
echo ""

echo "[2/6] Cleaning Maven build..."
mvn clean
rm -rf target/
echo "✅ Build cleaned"
echo ""

echo "[3/6] Removing old Docker images..."
docker rmi fantasyia-app || true
echo "✅ Old images removed"
echo ""

echo "[4/6] Building application..."
mvn package -DskipTests
if [ $? -eq 0 ]; then
    echo "✅ Build successful"
else
    echo "❌ Build failed!"
    echo ""
    echo "Please check the errors above and fix compilation issues."
    exit 1
fi
echo ""

echo "[5/6] Starting database..."
docker compose up -d db
echo "⏳ Waiting 10 seconds for database..."
sleep 10
echo "✅ Database ready"
echo ""

echo "[6/6] Starting application with fresh build..."
docker compose up --build -d app
echo "⏳ Waiting for application to start..."
sleep 15

# Check if app is running
if curl -s http://localhost:8080/login > /dev/null 2>&1; then
    echo "✅ Application is UP and responding!"
else
    echo "⚠️  Application may still be starting..."
    echo "   Check logs with: docker compose logs -f app"
fi
echo ""

echo "=========================================="
echo "  Status Check"
echo "=========================================="
docker compose ps
echo ""

echo "=========================================="
echo "  Recent Logs"
echo "=========================================="
docker compose logs --tail=30 app
echo ""

echo "=========================================="
echo "  ✅ FIX COMPLETE"
echo "=========================================="
echo ""
echo "🌐 Application: http://localhost:8080"
echo "🔍 Monitor logs: docker compose logs -f app"
echo ""
echo "If you still see 500 errors:"
echo "1. Check logs above for specific error messages"
echo "2. Verify database connection"
echo "3. Check if all new columns exist in database"
echo ""
