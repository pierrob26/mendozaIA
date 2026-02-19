#!/bin/bash

echo "🔧 SETTING UP DOCKER CONTAINERS - EXECUTING STARTUP"
echo "=================================================="
echo ""

# Make scripts executable
chmod +x start_webapp.sh
chmod +x check_health.sh
chmod +x rebuild_docker_containers.sh

echo "✅ Made scripts executable"
echo ""

# Run the main startup script
echo "🚀 Starting FantasyIA Web Application..."
./start_webapp.sh