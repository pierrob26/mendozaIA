#!/bin/bash
set -e

echo "🚀 EXECUTING GIT COMMIT AND PUSH"
echo "================================"
echo "Time: $(date)"
echo ""

# Navigate to project directory
cd /Users/robbypierson/IdeaProjects/fantasyIA

# Show current status
echo "📋 Current git status:"
git status

echo ""
echo "📝 Adding all changes to staging..."
git add .

# Show what's been staged
echo ""
echo "📦 Files staged for commit:"
git status --porcelain

echo ""
echo "💾 Creating commit..."
git commit -m "feat: Implement home page salary cap privacy and contract display improvements

🔒 Privacy Features:
- HomeController: Managers now see only their own salary cap information  
- Commissioners retain full team visibility for league management
- Role-based access control for team salary data

🎨 UI Improvements:
- Dynamic page titles: 'My Team Salary Overview' vs 'All Teams Salary Overview'
- Removed 'M' suffix from contract amounts in My Team page for cleaner display
- Enhanced salary cap visualization with proper role-based filtering

🛠️ Technical Changes:
- Updated HomeController.java with Arrays.asList() for Java compatibility
- Modified home.html template with conditional title rendering
- Updated team.html contract amount formatting
- Added comprehensive deployment and build scripts

📁 Files Modified:
- src/main/java/com/fantasyia/controller/HomeController.java
- src/main/resources/templates/home.html  
- src/main/resources/templates/team.html
- Multiple deployment automation scripts

🗓️ Date: March 1, 2026"

if [ $? -eq 0 ]; then
    echo "✅ Commit successful!"
    
    echo ""
    echo "🚀 Pushing to remote repository..."
    git push
    
    if [ $? -eq 0 ]; then
        echo ""
        echo "🎉 SUCCESS! All changes committed and pushed to remote!"
        echo "======================================================"
        echo "✓ Privacy controls implemented"
        echo "✓ UI improvements applied"
        echo "✓ Changes available in remote repository"
    else
        echo "❌ Push failed - check remote repository configuration"
        exit 1
    fi
else
    echo "❌ Commit failed - check for issues above"
    exit 1
fi