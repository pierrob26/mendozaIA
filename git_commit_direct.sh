#!/bin/bash
set -e

echo "🔄 Git Commit and Push - Direct Execution"
echo "=========================================="

cd /Users/robbypierson/IdeaProjects/fantasyIA || {
    echo "❌ Failed to navigate to project directory"
    exit 1
}

echo "Current directory: $(pwd)"
echo ""

# Check if this is a git repository
if [ ! -d ".git" ]; then
    echo "❌ Not a git repository"
    exit 1
fi

# Add all changes
echo "Adding all changes..."
git add . || {
    echo "❌ Failed to add changes"
    exit 1
}

# Create commit
echo ""
echo "Creating commit..."
git commit -m "feat: Home page privacy controls and UI improvements

- Implement role-based salary cap visibility in HomeController
- Add dynamic page titles in home.html template
- Remove 'M' suffix from contract amounts in team.html
- Add deployment scripts for privacy changes
- Enhance user experience with personalized data views

Date: March 1, 2026" || {
    echo "❌ Commit failed or no changes to commit"
}

# Push to remote
echo ""
echo "Pushing to remote..."
git push || {
    echo "❌ Push failed - check remote configuration"
    exit 1
}

echo ""
echo "✅ Git commit and push completed successfully!"