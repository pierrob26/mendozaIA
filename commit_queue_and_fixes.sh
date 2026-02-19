#!/bin/bash

echo "=========================================="
echo "📦 COMMITTING RELEASED PLAYERS QUEUE & FIXES"
echo "=========================================="
echo ""

# Check git status
echo "Checking git status..."
git status

echo ""
echo "Adding all changes..."

# Add all modified Java files
git add src/main/java/com/fantasyia/team/ReleasedPlayer.java
git add src/main/java/com/fantasyia/team/ReleasedPlayerRepository.java
git add src/main/java/com/fantasyia/team/TeamController.java
git add src/main/java/com/fantasyia/auction/AuctionController.java
git add src/main/java/com/fantasyia/controller/HomeController.java

# Add all modified templates
git add src/main/resources/templates/home.html
git add src/main/resources/templates/auction-manage.html
git add src/main/resources/templates/auction-view.html

# Add all documentation files
git add RELEASED_PLAYERS_QUEUE.md
git add IMPLEMENTATION_SUMMARY.md
git add WORKFLOW_DIAGRAM.md
git add QUICK_REFERENCE.md
git add DEPLOYMENT_CHECKLIST.md
git add CRASH_FIX.md
git add AUCTION_CRASH_FIX_V2.md
git add CRASH_FIX_V2_SUMMARY.md
git add MASTER_FIX_GUIDE.md
git add AUCTION_FIX_README.md
git add FIX_COMPLETION_REPORT.md
git add QUICK_FIX_VISUAL.txt
git add COMPILATION_ERROR_FIX.md
git add BUILD_FIX_READY.txt
git add FIX_500_ERROR.md
git add FIX_500_VISUAL.txt
git add COMPLETE_500_FIX.md

# Add all scripts
git add restart_app.sh
git add apply_fix.sh
git add apply_crash_fix_v2.sh
git add test_auction_fix.sh
git add quick_fix_and_build.sh
git add check_errors.sh
git add fix_500_error.sh

echo ""
echo "Committing changes..."

git commit -m "Implement released players queue system and fix auction crashes

FEATURES:
- Released Players Queue: Players released by owners go to commissioner queue for approval
- Commissioner Control: Only commissioners can approve/reject released players before auction
- Notification System: Badge on home page shows pending player count
- Auto-cleanup: Orphaned auction items automatically removed
- Robust Error Handling: Pages work even with missing data

BUG FIXES:
- Fixed null pointer exceptions in auction pages (500 errors)
- Fixed concurrent modification exceptions
- Fixed compilation errors from orphaned code
- Replaced Map.of() with HashMap for compatibility
- Changed removeIf() to filter() for safety

FILES ADDED:
- ReleasedPlayer.java - Queue entity
- ReleasedPlayerRepository.java - Repository for queue

FILES MODIFIED:
- TeamController.java - Updated release logic to use queue
- AuctionController.java - Added queue endpoints, fixed crashes
- HomeController.java - Added notification count
- home.html - Added notification badge
- auction-manage.html - Added queue section, safe navigation
- auction-view.html - Added safe navigation

DOCUMENTATION:
- Comprehensive docs for features and fixes
- Deployment scripts for easy updates
- Testing guides and troubleshooting

DATABASE:
- New table: released_players_queue (auto-created by Hibernate)
- Tracks: player name, position, team, previous contract, release date, status

TESTING:
- All auction pages load without errors
- Released players properly queued
- Commissioner approval/reject works
- No more 500 errors or crashes"

echo ""
echo "Pushing to remote..."
git push mendozaIA main

if [ $? -eq 0 ]; then
    echo ""
    echo "=========================================="
    echo "✅ SUCCESSFULLY COMMITTED AND PUSHED!"
    echo "=========================================="
    echo ""
    echo "Changes pushed to remote: mendozaIA/main"
    echo ""
else
    echo ""
    echo "❌ Push failed!"
    echo "You may need to pull first if there are remote changes."
    echo ""
    echo "Run: git pull mendozaIA main --rebase"
    echo "Then: git push mendozaIA main"
    exit 1
fi
