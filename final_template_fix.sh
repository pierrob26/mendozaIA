#!/bin/bash

echo "=================================================="
echo "🔄 APPLYING TEMPLATE CHANGES - FantasyIA"
echo "=================================================="
echo "Change: Removing 'M' suffix from contract amounts"
echo "File: /src/main/resources/templates/team.html"
echo "Time: $(date)"
echo ""

cd /Users/robbypierson/IdeaProjects/fantasyIA

echo "1️⃣ Verifying template change is in place..."
if grep -q "formatDecimal(player.contractAmount, 0, 2) : 'None'" src/main/resources/templates/team.html; then
    echo "✅ Template change confirmed - 'M' suffix has been removed"
else
    echo "❌ Template change not found - applying fix..."
    sed -i '' 's/formatDecimal(player.contractAmount, 0, 2) + '\''M'\'' :/formatDecimal(player.contractAmount, 0, 2) :/g' src/main/resources/templates/team.html
fi

echo ""
echo "2️⃣ Stopping existing containers..."
docker-compose down

echo ""
echo "3️⃣ Cleaning previous build..."
mvn clean -q

echo ""
echo "4️⃣ Building JAR with updated templates..."
mvn package -DskipTests -q

echo ""
echo "5️⃣ Rebuilding Docker image with new JAR..."
docker-compose build --no-cache app

echo ""
echo "6️⃣ Starting application with updated templates..."
docker-compose up -d

echo ""
echo "7️⃣ Monitoring startup..."
sleep 25

# Check if app is responding
echo ""
echo "8️⃣ Testing application response..."
if curl -s http://localhost:8080 > /dev/null; then
    echo "✅ Application is responding!"
else
    echo "⚠️  Application may still be starting up..."
fi

echo ""
echo "=================================================="
echo "✅ TEMPLATE UPDATE COMPLETE"
echo "=================================================="
echo "🌐 Application URL: http://localhost:8080"
echo "📝 Changes Applied:"
echo "   - Contract amounts on My Team page no longer show 'M'"
echo "   - Example: '$5.50' instead of '$5.50M'"
echo ""
echo "🧪 To Test:"
echo "   1. Login to the application"
echo "   2. Navigate to 'My Team'"
echo "   3. Check contract amounts in the table"
echo ""
echo "Container Status:"
docker-compose ps
echo ""