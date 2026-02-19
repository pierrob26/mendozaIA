#!/bin/bash

echo "🚀 EXECUTING COMPILATION FIX AND DEPLOYMENT"
echo "==========================================="
echo ""

# Make scripts executable
chmod +x fix_compilation_and_deploy.sh
chmod +x verify_compilation_fix.sh

# First verify the fix worked
echo "Step 1: Verifying compilation fix..."
./verify_compilation_fix.sh

if [ $? -eq 0 ]; then
    echo ""
    echo "Step 2: Building and deploying application..."
    ./fix_compilation_and_deploy.sh
else
    echo ""
    echo "❌ Compilation verification failed"
    exit 1
fi