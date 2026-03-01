#!/bin/bash

echo "🚀 EXECUTING PRIVACY DEPLOYMENT NOW"
echo "==================================="

# Change to project directory
cd /Users/robbypierson/IdeaProjects/fantasyIA || {
    echo "❌ Cannot find project directory"
    exit 1
}

# Make deployment script executable
chmod +x deploy_privacy_now.sh

# Execute the deployment
echo "Deploying privacy changes..."
./deploy_privacy_now.sh

echo ""
echo "✅ PRIVACY DEPLOYMENT COMPLETE!"
echo "You should now see only YOUR salary cap on the home page."