#!/usr/bin/env zsh
set -euo pipefail

# Project root
PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$PROJECT_DIR"

echo "[commit] Excel bulk import feature - Checking git status..."
git status

echo "[commit] Adding pom.xml with Apache POI dependencies..."
git add pom.xml

echo "[commit] Adding TeamController.java with bulk import functionality..."
git add src/main/java/com/fantasyia/team/TeamController.java

echo "[commit] Adding team.html with bulk import UI..."
git add src/main/resources/templates/team.html

echo "[commit] Adding documentation and test files..."
git add EXCEL_TESTING_GUIDE.md
git add sample_players.csv

echo "[commit] Committing Excel bulk import feature..."
git commit -m "Add Excel bulk import feature for players

- Add Apache POI dependencies (poi and poi-ooxml 5.2.5) to pom.xml
- Implement bulk import functionality in TeamController:
  - parseExcelFile() method for .xlsx/.xls file processing
  - parsePlayerFromRow() with position validation and error handling
  - File size (10MB) and format validation
  - Excel template download endpoint
- Enhanced team.html with bulk import UI:
  - File upload form with client-side validation
  - Success/error message display
  - Sample Excel format table and instructions
  - Download template link
- Added comprehensive testing guide and sample data
- Support for both contracted players and free agents
- Validates baseball positions (C, 1B, 2B, 3B, SS, OF, DH, SP, RP)
- Handles contract amounts with flexible formatting"

echo "[commit] Pushing to remote..."
git push mendozaIA main

echo "[commit] Excel bulk import feature successfully committed and pushed!"