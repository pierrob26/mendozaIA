#!/bin/bash

# Make all Docker scripts executable
echo "Making Docker scripts executable..."

cd /Users/robbypierson/IdeaProjects/fantasyIA

chmod +x recreate_containers.sh
chmod +x quick_docker_start.sh  
chmod +x build_and_deploy.sh
chmod +x rebuild.sh 2>/dev/null || echo "rebuild.sh not found"

echo "✅ All scripts are now executable!"
echo ""
echo "📋 Available Docker Commands:"
echo "============================="
echo ""
echo "🚀 For complete setup (recommended):"
echo "   ./build_and_deploy.sh"
echo ""
echo "🔄 For just recreating containers:"
echo "   ./recreate_containers.sh"
echo ""
echo "⚡ For quick start (if already built):"
echo "   ./quick_docker_start.sh"
echo ""
echo "🔧 Manual commands:"
echo "   docker-compose up -d              # Start containers"
echo "   docker-compose down               # Stop containers"
echo "   docker-compose logs -f app        # View app logs"
echo "   docker-compose ps                 # Check status"