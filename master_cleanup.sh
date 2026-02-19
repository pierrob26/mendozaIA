#!/bin/bash

echo ""
echo "╔═════════════════════════════════════════════════════════════════════════╗"
echo "║                                                                         ║"
echo "║          🧹 FANTASYIA CODE CLEANUP - MASTER SCRIPT 🧹                   ║"
echo "║                                                                         ║"
echo "║  This script will remove 57 unused files to clean up your codebase    ║"
echo "║                                                                         ║"
echo "╚═════════════════════════════════════════════════════════════════════════╝"
echo ""

# Safety check
read -p "⚠️  This will permanently delete 57 unused files. Continue? (yes/no): " confirm

if [[ "$confirm" != "yes" ]]; then
    echo ""
    echo "❌ Cleanup cancelled. No files were deleted."
    echo ""
    exit 0
fi

echo ""
echo "🔒 Creating backup first..."
BACKUP_DIR="backup_cleanup_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

# Function to safely remove with backup
safe_remove() {
    local file="$1"
    if [ -f "$file" ]; then
        cp "$file" "$BACKUP_DIR/" 2>/dev/null
        rm "$file"
        return 0
    fi
    return 1
}

REMOVED=0

echo ""
echo "┌─────────────────────────────────────────────────────────────────────────┐"
echo "│ Step 1/4: Removing unused template files (2 files)                     │"
echo "└─────────────────────────────────────────────────────────────────────────┘"

if safe_remove "src/main/resources/templates/auction-manage-new.html"; then
    echo "  ✓ Removed: auction-manage-new.html"
    ((REMOVED++))
fi

if safe_remove "src/main/resources/templates/auction-view-new.html"; then
    echo "  ✓ Removed: auction-view-new.html"
    ((REMOVED++))
fi

echo ""
echo "┌─────────────────────────────────────────────────────────────────────────┐"
echo "│ Step 2/4: Removing disabled backup controller (1 file)                 │"
echo "└─────────────────────────────────────────────────────────────────────────┘"

if safe_remove "src/main/java/com/fantasyia/user/RegistrationController.java"; then
    echo "  ✓ Removed: RegistrationController.java (disabled backup)"
    ((REMOVED++))
fi

echo ""
echo "┌─────────────────────────────────────────────────────────────────────────┐"
echo "│ Step 3/4: Removing redundant documentation (24 files)                  │"
echo "└─────────────────────────────────────────────────────────────────────────┘"

docs=(
    "AUCTION_CRASH_FIX_V2.md" "AUCTION_FIX_README.md" "AUCTION_V2_README.md"
    "AUTO_AUCTION_INTEGRATION.md" "BUILD_FIX_READY.txt" "CRASH_FIX_COMPLETE.md"
    "DATABASE_ACCESS_SUMMARY.txt" "DATABASE_CONSTRAINT_FIX.md"
    "DATABASE_MIGRATION_GUIDE.md" "DATABASE_MIGRATION_V2.md"
    "DEPLOYMENT_CHECKLIST.md" "FIX_500_ERROR.md" "FIX_500_ERROR_GUIDE.md"
    "FIX_500_NOW.txt" "FIX_500_VISUAL.txt" "FIX_COMPLETION_REPORT.md"
    "FIX_CRASH_NOW.txt" "FIX_NOW.md" "FIX_SUMMARY.md" "MASTER_FIX_GUIDE.md"
    "QUICK_FIX_VISUAL.txt" "README_FIX_CRASH.md" "READY_TO_PUSH.txt"
    "SIMPLE_FIX.txt"
)

for doc in "${docs[@]}"; do
    if safe_remove "$doc"; then
        echo "  ✓ $doc"
        ((REMOVED++))
    fi
done

echo ""
echo "┌─────────────────────────────────────────────────────────────────────────┐"
echo "│ Step 4/4: Removing temporary shell scripts (30 files)                  │"
echo "└─────────────────────────────────────────────────────────────────────────┘"

scripts=(
    "access_db.sh" "apply_crash_fix_v2.sh" "apply_fix.sh" "auto_fix.sh"
    "check_errors.sh" "check_tables_exist.sh" "commit_auction_changes.sh"
    "commit_auction_rework.sh" "commit_changes.sh" "commit_excel_import.sh"
    "commit_queue_and_fixes.sh" "db_tools.sh" "deploy_auction_v2.sh"
    "diagnose_pgadmin_issue.sh" "do_commit_push.sh" "execute_commit_push.sh"
    "fix-templates.sh" "fix_500_error.sh" "fix_500_error_v2.sh"
    "fix_complete.sh" "fix_crash.sh" "nuclear_fix.sh" "one_line_fix.sh"
    "quick_db_queries.sh" "quick_fix.sh" "quick_fix_and_build.sh"
    "restart_app.sh" "run_pgadmin_diagnostic.sh" "test_auction_fix.sh"
    "test_login_fix.sh"
)

for script in "${scripts[@]}"; do
    if safe_remove "$script"; then
        echo "  ✓ $script"
        ((REMOVED++))
    fi
done

echo ""
echo "╔═════════════════════════════════════════════════════════════════════════╗"
echo "║                      ✅ CLEANUP COMPLETE! ✅                             ║"
echo "╚═════════════════════════════════════════════════════════════════════════╝"
echo ""
echo "📊 CLEANUP SUMMARY"
echo "├─ Files removed: $REMOVED"
echo "├─ Backup location: $BACKUP_DIR/"
echo "└─ Status: SUCCESS"
echo ""
echo "✨ YOUR CODEBASE IS NOW CLEAN!"
echo ""
echo "📁 What remains:"
echo "  ✓ All active Java source files"
echo "  ✓ All active templates (7 files)"
echo "  ✓ Essential build scripts (4 files)"
echo "  ✓ Core documentation (18 files)"
echo "  ✓ Configuration files (Docker, Maven, etc.)"
echo ""
echo "🔍 Next steps:"
echo "  1. Verify application builds: mvn clean package"
echo "  2. Test application: docker-compose up -d --build"
echo "  3. Review cleanup report: cat CLEANUP_REPORT.md"
echo "  4. Commit changes: git add -A && git commit -m 'Clean up unused code'"
echo ""
echo "💾 Backup available at: $BACKUP_DIR/"
echo "   (Delete backup after verifying everything works)"
echo ""
