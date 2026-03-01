#!/bin/bash

echo "🔄 Committing and Pushing FantasyIA Changes to Remote"
echo "===================================================="
echo "Date: $(date)"
echo ""

# Navigate to project directory
cd /Users/robbypierson/IdeaProjects/fantasyIA

# Check git status
echo "1️⃣ Checking repository status..."
git status

echo ""
echo "2️⃣ Adding all changes to staging..."
git add .

echo ""
echo "3️⃣ Committing changes..."
git commit -m "Implement home page privacy and contract display improvements

- Modified HomeController to show only current user's salary cap (managers see own, commissioners see all)
- Updated home.html with dynamic titles based on user role
- Removed 'M' suffix from contract amounts in My Team page (team.html)
- Added Java compatibility fixes using Arrays.asList()
- Enhanced privacy controls for salary cap visibility

Changes include:
- HomeController.java: Role-based salary information display
- home.html: Dynamic page titles ('My Team' vs 'All Teams')
- team.html: Contract amounts without 'M' suffix
- Multiple deployment scripts for applying changes"

echo ""
echo "4️⃣ Pushing to remote repository..."
git push origin main

echo ""
echo "✅ COMMIT AND PUSH COMPLETE!"
echo "=============================="
echo "All privacy and UI improvements have been committed and pushed to remote."