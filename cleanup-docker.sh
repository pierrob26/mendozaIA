#!/bin/bash

# Quick Docker cleanup script
echo "🧹 Cleaning up Docker containers for FantasyIA..."

# Stop and remove all project containers
echo "Stopping containers..."
docker-compose -f /Users/robbypierson/IdeaProjects/fantasyIA/docker-compose.yml down -v --remove-orphans

# Remove specific containers if they exist
echo "Removing specific containers..."
docker rm -f fantasyia_app fantasyia_postgres fantasyia_pgadmin 2>/dev/null || echo "Containers already removed"

# Remove project images
echo "Removing project images..."
docker rmi fantasyia-app 2>/dev/null || echo "No project images to remove"

# Remove volumes
echo "Removing volumes..."
docker volume rm fantasyia_pgdata fantasyia_pgadmin_data 2>/dev/null || echo "No volumes to remove"

echo "✅ Cleanup complete!"