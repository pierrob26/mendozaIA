#!/bin/bash

echo "🚨 Fixing FantasyIA 500 Internal Server Error"
echo "Time: $(date)"
echo ""

cd /Users/robbypierson/IdeaProjects/fantasyIA

# Make scripts executable
chmod +x verify_and_rebuild.sh
chmod +x fix_500_error.sh

echo "Running existing rebuild script designed for this issue..."
./verify_and_rebuild.sh

echo ""
echo "🎉 Fix attempt completed!"
echo "If successful, login at: http://localhost:8080"
echo "Test credentials: testuser / password"