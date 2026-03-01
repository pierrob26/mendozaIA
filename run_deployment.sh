#!/bin/bash

# IMMEDIATE DEPLOYMENT EXECUTION
echo "🚨 EXECUTING PRIVACY DEPLOYMENT - RIGHT NOW"
echo "============================================"

# Navigate to project
cd /Users/robbypierson/IdeaProjects/fantasyIA

# Make deployment script executable and run it
chmod +x execute_deployment_now.sh
./execute_deployment_now.sh

echo ""
echo "🎉 DEPLOYMENT EXECUTION COMPLETE!"
echo "Check http://localhost:8080 - you should now see only YOUR salary cap!"