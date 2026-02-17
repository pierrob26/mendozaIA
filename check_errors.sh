#!/bin/bash

echo "🔍 CHECKING APPLICATION LOGS FOR ERROR..."
echo ""

# Get last 100 lines and look for errors
docker-compose logs app --tail=100 | grep -A 20 "ERROR\|Exception\|at com.fantasyia"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Full recent logs:"
docker-compose logs app --tail=50
