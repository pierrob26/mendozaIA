#!/bin/bash

# Quick fix for deployment script and run it
echo "🔧 Making deployment script executable and running it..."

# Make the script executable
chmod +x deploy_salary_cap_update.sh

# Run the deployment
echo "🚀 Running salary cap update deployment..."
echo ""

# Execute the fixed deployment script
./deploy_salary_cap_update.sh

echo ""
echo "✅ Deployment completed! Check the output above for any issues."