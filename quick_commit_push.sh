#!/bin/bash
set -e

echo "🚀 COMMITTING AND PUSHING RECENT CHANGES - February 26, 2026"
echo "=========================================================="

cd /Users/robbypierson/IdeaProjects/fantasyIA

echo "📊 Checking git status..."
git status --short

echo ""
echo "📦 Adding all changes..."
git add .

echo ""
echo "💾 Committing with updated message..."
git commit -F COMMIT_MESSAGE_UPDATED.txt

echo ""
echo "🔄 Pushing to remote..."
git push

echo ""
echo "🎉 Successfully committed and pushed all changes!"
echo "✅ Team salary display and rebuild script features are now live"