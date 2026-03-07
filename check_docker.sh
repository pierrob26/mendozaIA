#!/bin/bash

echo "🐳 Checking Docker Status"
echo "========================"

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker daemon is not running. Please start Docker Desktop."
    echo "   You can start it from Applications or run 'open -a Docker' from terminal"
    exit 1
fi

echo "✅ Docker is running"
docker --version
docker-compose --version

echo ""
echo "📊 Current Docker containers:"
docker ps -a

echo ""
echo "🖼️ Current Docker images:"
docker images | head -10