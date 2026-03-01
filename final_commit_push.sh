#!/bin/bash

cd /Users/robbypierson/IdeaProjects/fantasyIA

echo "📋 Current git status:"
git status --porcelain

echo ""
echo "📝 Adding all changes..."
git add .

echo ""
echo "💾 Committing with comprehensive message..."
git commit -m "feat: Implement home page privacy controls and UI improvements

Privacy Features:
- HomeController: Managers now see only their own salary cap information
- Commissioners retain full visibility for league oversight  
- Dynamic page titles based on user role

UI Improvements:
- Removed 'M' suffix from contract amounts in My Team page
- Enhanced salary cap display with role-based access

Technical Changes:
- Updated HomeController.java with role-based team filtering
- Modified home.html template for dynamic titles
- Updated team.html to remove 'M' from contract display
- Added Java compatibility using Arrays.asList()

Files Modified:
- src/main/java/com/fantasyia/controller/HomeController.java
- src/main/resources/templates/home.html
- src/main/resources/templates/team.html
- Multiple deployment and build scripts added

Date: $(date)"

echo ""
echo "🚀 Pushing to remote repository..."
git push

echo ""
echo "✅ COMMIT AND PUSH SUCCESSFUL!"
echo "All privacy and UI changes are now in the remote repository."