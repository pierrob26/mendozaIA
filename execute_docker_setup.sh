#!/bin/bash

echo "Making scripts executable..."
chmod +x /Users/robbypierson/IdeaProjects/fantasyIA/check_docker.sh
chmod +x /Users/robbypierson/IdeaProjects/fantasyIA/start_containers.sh
chmod +x /Users/robbypierson/IdeaProjects/fantasyIA/recreate_containers.sh

echo "Executing container startup..."
cd /Users/robbypierson/IdeaProjects/fantasyIA

# First check Docker status
./check_docker.sh

echo ""
echo "Proceeding with container startup..."

# Then start containers
./start_containers.sh