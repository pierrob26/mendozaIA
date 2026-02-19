#!/bin/bash

echo "╔════════════════════════════════════════════════════════════════════════╗"
echo "║          🧹 EXECUTING COMPREHENSIVE CODE CLEANUP 🧹                    ║"
echo "╚════════════════════════════════════════════════════════════════════════╝"
echo ""

# Count removed files
REMOVED=0

echo "Step 1: Removing unused template files..."
rm -f src/main/resources/templates/auction-manage-new.html && echo "  ✓ Removed auction-manage-new.html" && ((REMOVED++))
rm -f src/main/resources/templates/auction-view-new.html && echo "  ✓ Removed auction-view-new.html" && ((REMOVED++))

echo ""
echo "Step 2: Removing disabled backup controller..."
rm -f src/main/java/com/fantasyia/user/RegistrationController.java && echo "  ✓ Removed RegistrationController.java" && ((REMOVED++))

echo ""
echo "Step 3: Removing redundant documentation (24 files)..."
rm -f AUCTION_CRASH_FIX_V2.md && echo "  ✓" && ((REMOVED++))
rm -f AUCTION_FIX_README.md && echo "  ✓" && ((REMOVED++))
rm -f AUCTION_V2_README.md && echo "  ✓" && ((REMOVED++))
rm -f AUTO_AUCTION_INTEGRATION.md && echo "  ✓" && ((REMOVED++))
rm -f BUILD_FIX_READY.txt && echo "  ✓" && ((REMOVED++))
rm -f CRASH_FIX_COMPLETE.md && echo "  ✓" && ((REMOVED++))
rm -f DATABASE_ACCESS_SUMMARY.txt && echo "  ✓" && ((REMOVED++))
rm -f DATABASE_CONSTRAINT_FIX.md && echo "  ✓" && ((REMOVED++))
rm -f DATABASE_MIGRATION_GUIDE.md && echo "  ✓" && ((REMOVED++))
rm -f DATABASE_MIGRATION_V2.md && echo "  ✓" && ((REMOVED++))
rm -f DEPLOYMENT_CHECKLIST.md && echo "  ✓" && ((REMOVED++))
rm -f FIX_500_ERROR.md && echo "  ✓" && ((REMOVED++))
rm -f FIX_500_ERROR_GUIDE.md && echo "  ✓" && ((REMOVED++))
rm -f FIX_500_NOW.txt && echo "  ✓" && ((REMOVED++))
rm -f FIX_500_VISUAL.txt && echo "  ✓" && ((REMOVED++))
rm -f FIX_COMPLETION_REPORT.md && echo "  ✓" && ((REMOVED++))
rm -f FIX_CRASH_NOW.txt && echo "  ✓" && ((REMOVED++))
rm -f FIX_NOW.md && echo "  ✓" && ((REMOVED++))
rm -f FIX_SUMMARY.md && echo "  ✓" && ((REMOVED++))
rm -f MASTER_FIX_GUIDE.md && echo "  ✓" && ((REMOVED++))
rm -f QUICK_FIX_VISUAL.txt && echo "  ✓" && ((REMOVED++))
rm -f README_FIX_CRASH.md && echo "  ✓" && ((REMOVED++))
rm -f READY_TO_PUSH.txt && echo "  ✓" && ((REMOVED++))
rm -f SIMPLE_FIX.txt && echo "  ✓" && ((REMOVED++))

echo ""
echo "Step 4: Removing temporary shell scripts (30 files)..."
rm -f access_db.sh && echo "  ✓" && ((REMOVED++))
rm -f apply_crash_fix_v2.sh && echo "  ✓" && ((REMOVED++))
rm -f apply_fix.sh && echo "  ✓" && ((REMOVED++))
rm -f auto_fix.sh && echo "  ✓" && ((REMOVED++))
rm -f check_errors.sh && echo "  ✓" && ((REMOVED++))
rm -f check_tables_exist.sh && echo "  ✓" && ((REMOVED++))
rm -f commit_auction_changes.sh && echo "  ✓" && ((REMOVED++))
rm -f commit_auction_rework.sh && echo "  ✓" && ((REMOVED++))
rm -f commit_changes.sh && echo "  ✓" && ((REMOVED++))
rm -f commit_excel_import.sh && echo "  ✓" && ((REMOVED++))
rm -f commit_queue_and_fixes.sh && echo "  ✓" && ((REMOVED++))
rm -f db_tools.sh && echo "  ✓" && ((REMOVED++))
rm -f deploy_auction_v2.sh && echo "  ✓" && ((REMOVED++))
rm -f diagnose_pgadmin_issue.sh && echo "  ✓" && ((REMOVED++))
rm -f do_commit_push.sh && echo "  ✓" && ((REMOVED++))
rm -f execute_commit_push.sh && echo "  ✓" && ((REMOVED++))
rm -f fix-templates.sh && echo "  ✓" && ((REMOVED++))
rm -f fix_500_error.sh && echo "  ✓" && ((REMOVED++))
rm -f fix_500_error_v2.sh && echo "  ✓" && ((REMOVED++))
rm -f fix_complete.sh && echo "  ✓" && ((REMOVED++))
rm -f fix_crash.sh && echo "  ✓" && ((REMOVED++))
rm -f nuclear_fix.sh && echo "  ✓" && ((REMOVED++))
rm -f one_line_fix.sh && echo "  ✓" && ((REMOVED++))
rm -f quick_db_queries.sh && echo "  ✓" && ((REMOVED++))
rm -f quick_fix.sh && echo "  ✓" && ((REMOVED++))
rm -f quick_fix_and_build.sh && echo "  ✓" && ((REMOVED++))
rm -f restart_app.sh && echo "  ✓" && ((REMOVED++))
rm -f run_pgadmin_diagnostic.sh && echo "  ✓" && ((REMOVED++))
rm -f test_auction_fix.sh && echo "  ✓" && ((REMOVED++))
rm -f test_login_fix.sh && echo "  ✓" && ((REMOVED++))

echo ""
echo "╔════════════════════════════════════════════════════════════════════════╗"
echo "║                    ✅ CLEANUP COMPLETE! ✅                              ║"
echo "╚════════════════════════════════════════════════════════════════════════╝"
echo ""
echo "📊 Total files removed: $REMOVED"
echo ""
echo "✨ Your codebase is now clean and maintainable!"
echo ""
echo "📁 Remaining essential files:"
echo "   • Core Java source files"
echo "   • Active templates (auction-manage.html, auction-view.html, etc.)"
echo "   • Essential scripts (rebuild.sh, start_docker.sh, etc.)"
echo "   • Key documentation"
echo ""
echo "📖 See CLEANUP_REPORT.md for detailed list of what was removed"
echo ""
