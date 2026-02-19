#!/usr/bin/env zsh
# Auto-fix script - stops containers, rebuilds, restarts
set -e

echo "═══════════════════════════════════════════════════════════════"
echo "  AUTO-FIX: Rebuilding Application to Fix 500 Error"
echo "═══════════════════════════════════════════════════════════════"
echo ""

cd "$(dirname "$0")"

echo "Step 1/7: Stopping all containers..."
docker compose down
echo "✅ Containers stopped"
echo ""

echo "Step 2/7: Removing old JAR file..."
rm -f target/fantasyia-0.0.1-SNAPSHOT.jar
echo "✅ Old JAR removed"
echo ""

echo "Step 3/7: Cleaning Maven cache..."
mvn clean -q
echo "✅ Maven cleaned"
echo ""

echo "Step 4/7: Compiling with new code (this takes ~1 minute)..."
mvn package -DskipTests
if [ $? -ne 0 ]; then
    echo "❌ Build failed! Check errors above."
    exit 1
fi
echo "✅ Build successful"
echo ""

echo "Step 5/7: Starting database..."
docker compose up -d db
echo "⏳ Waiting 10 seconds for database..."
sleep 10
echo "✅ Database ready"
echo ""

echo "Step 6/7: Building and starting application..."
docker compose up --build -d app
echo "✅ Application container started"
echo ""

echo "Step 7/7: Waiting for application to initialize..."
for i in {1..30}; do
    if curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/login | grep -q "200"; then
        echo ""
        echo "✅ Application is UP!"
        break
    fi
    echo -n "."
    sleep 2
done
echo ""
echo ""

echo "═══════════════════════════════════════════════════════════════"
echo "  Status Check"
echo "═══════════════════════════════════════════════════════════════"
docker compose ps
echo ""

echo "═══════════════════════════════════════════════════════════════"
echo "  Recent Application Logs"
echo "═══════════════════════════════════════════════════════════════"
docker compose logs --tail=30 app
echo ""

echo "═══════════════════════════════════════════════════════════════"
echo "  ✅ AUTO-FIX COMPLETE"
echo "═══════════════════════════════════════════════════════════════"
echo ""
echo "🌐 Application URL: http://localhost:8080"
echo ""
echo "Check for errors in logs above. Look for:"
echo "  ✅ 'Started FantasyIaApplication' = SUCCESS"
echo "  ❌ 'Ambiguous mapping' = Still has conflict"
echo ""
echo "If still broken, check full logs:"
echo "  docker compose logs -f app"
echo ""
