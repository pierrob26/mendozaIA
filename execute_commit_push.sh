#!/bin/bash
set -e

echo "🚀 EXECUTING COMMIT AND PUSH NOW"
echo "================================"

cd /Users/robbypierson/IdeaProjects/fantasyIA

# Make commit script executable and run it
chmod +x commit_and_push_changes.sh
./commit_and_push_changes.sh

echo ""
echo "🎉 ALL CHANGES COMMITTED AND PUSHED TO REMOTE!"