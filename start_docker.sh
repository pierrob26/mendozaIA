#!/bin/bash

echo "=== Checking Docker Status ==="
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker Desktop first."
    exit 1
fi

echo "✓ Docker is running"
echo ""

echo "=== Checking existing containers ==="
docker ps -a

echo ""
echo "=== Starting Docker Compose services ==="
docker-compose up -d

echo ""
echo "=== Container Status ==="
docker-compose ps

echo ""
echo "=== Services should be available at: ==="
echo "  • PostgreSQL: localhost:5432"
echo "  • Application: http://localhost:8080"
echo "  • PgAdmin: http://localhost:8081"
echo ""
echo "To view logs: docker-compose logs -f"
echo "To stop: docker-compose down"
