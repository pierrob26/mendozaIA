#!/usr/bin/env zsh
# Nuclear option - complete clean and rebuild
set -e

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║                  🔥 NUCLEAR FIX 🔥                             ║"
echo "║  Complete cleanup and rebuild - Use if normal fix didn't work ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

cd "$(dirname "$0")"

read -p "This will remove ALL Docker containers and images. Continue? (y/n) " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Cancelled."
    exit 1
fi

echo ""
echo "1️⃣  Stopping all containers..."
docker compose down
echo "✅ Done"
echo ""

echo "2️⃣  Removing Docker images and volumes..."
docker system prune -a -f --volumes
echo "✅ Done"
echo ""

echo "3️⃣  Cleaning Maven completely..."
mvn clean
rm -rf target/
rm -rf ~/.m2/repository/com/fantasyia 2>/dev/null || true
echo "✅ Done"
echo ""

echo "4️⃣  Removing node_modules and caches (if any)..."
rm -rf node_modules/ 2>/dev/null || true
rm -rf .mvn/ 2>/dev/null || true
echo "✅ Done"
echo ""

echo "5️⃣  Building fresh Maven package..."
mvn clean package -DskipTests
if [ $? -ne 0 ]; then
    echo "❌ Maven build failed!"
    exit 1
fi
echo "✅ Done"
echo ""

echo "6️⃣  Starting database fresh..."
docker compose up -d db
echo "⏳ Waiting 15 seconds for database..."
sleep 15
echo "✅ Done"
echo ""

echo "7️⃣  Building application image from scratch..."
docker compose build --no-cache app
echo "✅ Done"
echo ""

echo "8️⃣  Starting application..."
docker compose up -d app
echo "⏳ Waiting 20 seconds for app to start..."
sleep 20
echo "✅ Done"
echo ""

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║                    ✅ NUCLEAR FIX COMPLETE                     ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""
echo "Status:"
docker compose ps
echo ""
echo "Checking application..."
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/login)
if [ "$HTTP_CODE" = "200" ]; then
    echo "✅ APPLICATION IS UP! (HTTP $HTTP_CODE)"
else
    echo "⚠️  Application returned HTTP $HTTP_CODE"
fi
echo ""
echo "View logs: docker compose logs -f app"
echo "Visit app: http://localhost:8080"
echo ""
