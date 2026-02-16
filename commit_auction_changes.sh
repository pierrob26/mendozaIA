#!/usr/bin/env zsh
set -euo pipefail

# Project root
PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$PROJECT_DIR"

echo "[commit] Checking git status..."
git status

echo "[commit] Adding all auction functionality files..."
git add .

echo "[commit] Committing auction functionality..."
git commit -m "Implement comprehensive auction system for commissioners

Features added:
- Commissioner-only auction management system
- Auction entity with configurable duration (1 hour - 1 week)
- Free agent detection (players without contracts)
- Auction creation, management, and manual ending
- Role-based access control (MEMBER/COMMISSIONER roles)
- Updated user registration with role selection
- Enhanced home page with commissioner-specific features
- Auction management UI with real-time countdown
- Free agent listing and auction details view
- Updated Player model to support free agents
- Added test data with sample free agents and commissioner account
- Fixed compilation errors in DataInitializer

Technical changes:
- Created Auction entity and repository
- Added AuctionController with full CRUD operations
- Updated SecurityConfig for role-based auction access
- Modified Player model to allow null contracts for free agents
- Enhanced PlayerRepository with free agent queries
- Updated HomeController to show user-specific features
- Added auction-manage.html and auction-view.html templates
- Updated registration system with role selection dropdown
- Enhanced team.html to display free agent status properly"

echo "[commit] Pushing to remote..."
git push mendozaIA main

echo "[commit] Changes successfully committed and pushed!"