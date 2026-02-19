#!/bin/bash

echo "🚀 EXECUTING COMMIT AND PUSH PROCESS"
echo "===================================="

# Make the script executable and run it
chmod +x commit_and_push.sh

# Check if we're in a git repository
if [ ! -d ".git" ]; then
    echo "❌ Not a git repository. Initializing..."
    git init
    echo "✅ Git repository initialized"
fi

# Execute the commit and push
./commit_and_push.sh