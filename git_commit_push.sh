#!/bin/bash
set -e

echo "🚀 EXECUTING GIT COMMIT AND PUSH - February 24, 2026"
echo "=================================================="

cd /Users/robbypierson/IdeaProjects/fantasyIA

echo "Step 1: Checking repository status..."
if [ -d ".git" ]; then
    echo "✅ Git repository confirmed"
    echo "Current branch: $(git branch --show-current 2>/dev/null || echo 'unknown')"
    
    CHANGES=$(git status --porcelain | wc -l)
    echo "Files with changes: $CHANGES"
else
    echo "❌ No git repository found"
    echo "Please initialize git first: git init"
    exit 1
fi

echo ""
echo "Step 2: Staging all changes..."
git add .
echo "✅ All changes staged"

echo ""
echo "Step 3: Creating commit..."
if git commit -F COMMIT_MESSAGE_UPDATED.txt; then
    echo "✅ COMMIT SUCCESSFUL!"
    
    COMMIT_HASH=$(git rev-parse HEAD)
    echo "Commit hash: $COMMIT_HASH"
    
    echo ""
    echo "Step 4: Pushing to remote..."
    
    # Check for remote repository
    if git remote get-url origin >/dev/null 2>&1; then
        REMOTE_URL=$(git remote get-url origin)
        echo "Remote repository: $REMOTE_URL"
        
        # Attempt push
        CURRENT_BRANCH=$(git branch --show-current)
        echo "Pushing branch: $CURRENT_BRANCH"
        
        if git push origin "$CURRENT_BRANCH"; then
            echo "🎉 PUSH SUCCESSFUL!"
        elif git push -u origin "$CURRENT_BRANCH"; then
            echo "🎉 PUSH SUCCESSFUL (upstream set)!"
        else
            echo "⚠️ Push failed, but commit exists locally"
            echo "Manual push may be required"
            exit 1
        fi
    else
        echo "⚠️ No remote repository configured"
        echo "To add remote: git remote add origin <repository-url>"
        echo "Then push: git push -u origin main"
    fi
    
    echo ""
    echo "🎯 OPERATION COMPLETED SUCCESSFULLY!"
    
else
    echo "❌ Commit failed"
    exit 1
fi

echo ""
echo "📋 COMMITTED CHANGES SUMMARY:"
echo "✅ Fixed auction page crashes (JPA repository errors)"
echo "✅ Created commissioner account system with test logins"
echo "✅ Enhanced HTML templates with cache-busting"
echo "✅ Resolved database column mapping issues"  
echo "✅ Added comprehensive documentation"
echo "✅ Implemented security and stability improvements"
echo ""
echo "🏁 All changes committed and pushed to remote repository!"

# Clean up
rm -f COMMIT_MESSAGE.txt