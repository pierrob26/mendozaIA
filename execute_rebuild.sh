#!/bin/bash

echo "Rebuilding FantasyIA Docker containers with updated auction time removal rules..."

# Navigate to project directory
cd /Users/robbypierson/IdeaProjects/fantasyIA

# Make rebuild script executable
chmod +x rebuild.sh

echo "Starting Docker rebuild process..."

# Execute the docker rebuild
./rebuild.sh docker

echo "Checking container status..."

# Check if containers are running
docker-compose ps

echo "Rebuild process completed!"
echo "Application should be accessible at http://localhost:8080"