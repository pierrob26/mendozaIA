#!/usr/bin/env zsh
set -euo pipefail

# Project root
PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$PROJECT_DIR"

echo "[commit] Checking git status..."
git status

echo "[commit] Adding team.html changes..."
git add src/main/resources/templates/team.html

echo "[commit] Committing changes..."
git commit -m "Replace text inputs with dropdowns in team.html - MLB team selector with all 30 teams and contract amount selector with predefined salary tiers"

echo "[commit] Pushing to remote..."
git push mendozaIA main

echo "[commit] Changes successfully committed and pushed!"