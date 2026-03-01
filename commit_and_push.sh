#!/bin/bash

# Commit and push recent changes for FantasyIA
# Date: February 26, 2026

echo "🚀 FantasyIA - Committing and Pushing Changes"
echo "============================================="
echo "Date: $(date)"
echo ""

# Check if we're in a git repository
if [ ! -d ".git" ]; then
    echo "❌ No git repository found"
    echo "Please initialize git first: git init"
    exit 1
fi

# Check git status
echo "📊 Checking git repository status..."
CHANGES=$(git status --porcelain | wc -l | tr -d ' ')
echo "Files with changes: $CHANGES"

if [ "$CHANGES" -eq 0 ]; then
    echo "✅ No changes to commit"
    exit 0
fi

echo ""
echo "📋 Files to be committed:"
git status --short

echo ""
echo "📦 Adding all changes..."
git add .

echo ""
echo "💾 Creating commit..."
if git commit -F COMMIT_MESSAGE_NEW.txt; then
    echo ""
    echo "✅ Commit successful!"
    COMMIT_HASH=$(git rev-parse HEAD)
    echo "📝 Commit hash: $COMMIT_HASH"
    echo "🌿 Branch: $(git branch --show-current)"
    
    echo ""
    echo "🔄 Pushing to remote..."
    
    # Check if remote exists
    if git remote get-url origin >/dev/null 2>&1; then
        REMOTE_URL=$(git remote get-url origin)
        echo "🌐 Remote URL: $REMOTE_URL"
        
        # Try to push
        if git push origin HEAD; then
            echo ""
            echo "🎉 Successfully pushed to remote!"
            echo "✅ All changes have been committed and pushed"
        else
            echo ""
            echo "⚠️  Push failed, trying to set upstream..."
            if git push -u origin HEAD; then
                echo "🎉 Successfully pushed with upstream set!"
            else
                echo "❌ Push failed. You may need to pull first or resolve conflicts."
                echo "Try: git pull origin $(git branch --show-current)"
                exit 1
            fi
        fi
    else
        echo "⚠️  No remote origin configured"
        echo "To add a remote, run: git remote add origin <repository-url>"
        echo "Commit was successful but not pushed to remote"
    fi
    
else
    echo ""
    echo "❌ Commit failed"
    exit 1
fi

echo ""
echo "🏁 Git operations completed successfully!"
echo "📊 Final status:"
git status --short
echo ""
echo "📈 Recent commits:"
git log --oneline -3