#!/bin/bash

# Make scripts executable and run Docker cleanup
echo "🔧 Making scripts executable..."
chmod +x /Users/robbypierson/IdeaProjects/fantasyIA/recreate-docker-containers.sh
chmod +x /Users/robbypierson/IdeaProjects/fantasyIA/quick-docker-reset.sh
chmod +x /Users/robbypierson/IdeaProjects/fantasyIA/cleanup-docker.sh

echo "✅ Scripts are now executable"

# Run the main recreation script
echo "🚀 Running Docker container recreation..."
/Users/robbypierson/IdeaProjects/fantasyIA/recreate-docker-containers.sh