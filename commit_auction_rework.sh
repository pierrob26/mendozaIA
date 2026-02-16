#!/usr/bin/env zsh
set -euo pipefail

# Project root
PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$PROJECT_DIR"

echo "[commit] Committing auction rework and release players enhancement..."
git status

echo "[commit] Adding all modified files..."
git add .

echo "[commit] Committing changes..."
git commit -m "Complete auction system rework and enhanced player release functionality

Major Changes:
- Reworked auction system to always-running model with individual player bidding
- Added new entities: AuctionItem and Bid for granular auction management
- Implemented 24-hour minimum bidding period with commissioner removal control
- Enhanced player release to automatically add players to auction

New Features:
- Always-running auction with real-time bidding
- Individual player auction items with time tracking
- Automatic auction integration when releasing players
- Selective player release with checkboxes and bulk operations
- Commissioner auction management with player removal controls
- Enhanced UI with bidding forms, quick bid buttons, and time remaining

Technical Implementation:
- New AuctionItem entity with bidding timeline management
- New Bid entity for tracking all bid history
- Enhanced AuctionController with complex auction logic
- Auto-auction integration in TeamController release methods
- Improved templates with interactive bidding interface
- JavaScript validation and user experience enhancements

Removed:
- Old simple auction system with fixed durations  
- Clear All Contracts button (replaced with selective release)
- Manual player-to-auction workflow

Files Changed:
- Created: AuctionItem.java, Bid.java, AuctionItemRepository.java, BidRepository.java
- Modified: AuctionController.java, TeamController.java, PlayerRepository.java
- Enhanced: auction-manage.html, auction-view.html, team.html, home.html
- Updated: Documentation files and feature guides"

echo "[commit] Pushing to remote..."
git push mendozaIA main

echo "[commit] Auction rework and player release enhancements successfully committed and pushed!"