#!/bin/bash

cd "/Users/robbypierson/IdeaProjects/fantasyIA"

echo "=== COMPREHENSIVE CLEANUP SCRIPT ==="
echo "Removing unused files from fantasy baseball project..."
echo ""

# Count files before cleanup
BEFORE=$(find . -maxdepth 1 -type f | wc -l)
echo "Files before cleanup: $BEFORE"

echo ""
echo "Phase 1: Removing unused template files..."
rm -f "src/main/resources/templates/auction-manage-new.html"
rm -f "src/main/resources/templates/auction-view-new.html" 
rm -f "src/main/resources/templates/players.html"
rm -f "src/main/resources/templates/team-simple.html"
echo "✓ Removed 4 unused template files"

echo ""
echo "Phase 2: Removing AUCTION documentation files..."
rm -f AUCTION_500_ERROR_FIX.md
rm -f AUCTION_BIDDING_UPDATE.md
rm -f AUCTION_COLUMN_MAPPING_FIX.md
rm -f AUCTION_CRASH_FINAL_RESOLUTION.md
rm -f AUCTION_CRASH_FIX_INSTRUCTIONS.md
rm -f AUCTION_CRASH_FIX_V2.md
rm -f AUCTION_DATABASE_FIX_SUMMARY.md
rm -f AUCTION_ERROR_FIX.md
rm -f AUCTION_FIX_README.md
rm -f AUCTION_IMPLEMENTATION_SUMMARY.md
rm -f AUCTION_MANAGE_FIX.md
rm -f AUCTION_V2_README.md
rm -f AUTO_AUCTION_INTEGRATION.md
echo "✓ Removed 13 AUCTION documentation files"

echo ""
echo "Phase 3: Removing BUILD/COMMIT documentation files..."
rm -f BUILD_FAILURE_RESOLVED.md
rm -f BUILD_SUCCESS_COMPLETE.md
rm -f BUILD_COMMANDS.txt
rm -f BUILD_FIX_READY.txt
rm -f COMMIT_READY_SUMMARY.md
rm -f COMMIT_SUMMARY.md
rm -f COMMIT_MESSAGE.txt
rm -f COMMIT_MESSAGE_NEW.txt
rm -f COMMIT_MESSAGE_UPDATED.txt
echo "✓ Removed 9 BUILD/COMMIT documentation files"

echo ""
echo "Phase 4: Removing CLEANUP documentation files..."
rm -f CLEANUP_GUIDE.md
rm -f CLEANUP_INDEX.md
rm -f CLEANUP_QUICK_REF.txt
rm -f CLEANUP_REPORT.md
rm -f CLEANUP_SUMMARY.txt
rm -f CLEANUP_VISUAL.md
echo "✓ Removed 6 CLEANUP documentation files"

echo ""
echo "Phase 5: Removing COMPILATION/CRASH documentation files..."
rm -f COMPILATION_ERRORS_FIXED.md
rm -f COMPILATION_ERROR_FIX.md
rm -f COMPILATION_FIXES_COMPLETE.md
rm -f CRASH_FIX_COMPLETE.md
echo "✓ Removed 4 COMPILATION/CRASH documentation files"

echo ""
echo "Phase 6: Removing DATABASE documentation files..."
rm -f DATABASE_ACCESS.md
rm -f DATABASE_ACCESS_GUIDE.md
rm -f DATABASE_ACCESS_SUMMARY.txt
rm -f DATABASE_CONSTRAINT_FIX.md
rm -f DATABASE_MIGRATION_GUIDE.md
rm -f DATABASE_MIGRATION_V2.md
rm -f DATA_PERSISTENCE_ANSWER.md
echo "✓ Removed 7 DATABASE documentation files"

echo ""
echo "Phase 7: Removing DOCKER documentation files..."
rm -f DOCKER_BUILD_FIX.md
rm -f DOCKER_CLEANUP_READY.md
rm -f DOCKER_RECREATION_PLAN.md
rm -f DOCKER_SETUP_README.md
echo "✓ Removed 4 DOCKER documentation files"

echo ""
echo "Phase 8: Removing FIX documentation files..."
rm -f FIX_500_ERROR.md
rm -f FIX_500_ERROR_GUIDE.md
rm -f FIX_500_NOW.txt
rm -f FIX_500_VISUAL.txt
rm -f FIX_COMPLETE_SUMMARY.txt
rm -f FIX_COMPLETION_REPORT.md
rm -f FIX_CRASH_NOW.txt
rm -f FIX_NOW.md
rm -f FIX_SUMMARY.md
rm -f FIX_SUMMARY.txt
echo "✓ Removed 10 FIX documentation files"

echo ""
echo "Phase 9: Removing miscellaneous documentation files..."
rm -f APP_CONTAINER_FIX_SUMMARY.md
rm -f COMMISSIONER_ACCOUNTS_READY.md
rm -f CRITERION_C_APPENDIX.md
rm -f CRITERION_C_DEVELOPMENT.md
rm -f CRITERION_C_EVIDENCE_SUMMARY.md
rm -f DASGOAT_ACCOUNT_SOLUTION.md
rm -f DEPLOYMENT_CHECKLIST.md
rm -f DUPLICATE_PLAYER_PREVENTION.md
rm -f ENTITY_MAPPING_FIX_COMPLETE.md
rm -f EXCEL_TESTING_GUIDE.md
rm -f FEATURE_IMPLEMENTATION_SUMMARY.md
rm -f FILLER_PLAYERS_FEATURE.md
rm -f FREE_AGENCY_IMPLEMENTATION_STATUS.md
rm -f FREE_AGENCY_RULES.md
rm -f FREE_AGENCY_SYSTEM.md
rm -f GIT_COMMIT_SUMMARY.md
rm -f HTML_CHANGES_SOLUTION.md
rm -f IB_CRITERION_C_SUBMISSION_GUIDE.md
rm -f IMPLEMENTATION_SUMMARY.md
rm -f INCREMENT_BUTTONS_REMOVAL.md
rm -f JPA_FIX_INSTRUCTIONS.md
rm -f LOGIN_ISSUE_SOLUTION.md
rm -f MASTER_FIX_GUIDE.md
rm -f PLAYER_ADDITION_FIX.md
rm -f PROJECT_STRUCTURE_GUIDE.md
rm -f QUICK_REFERENCE.md
rm -f README_FIX_CRASH.md
rm -f README_SIMPLE.md
rm -f REBUILD_GUIDE.md
rm -f RELEASED_PLAYERS_QUEUE.md
rm -f RELEASE_PLAYERS_FEATURE.md
rm -f RELEASE_PLAYERS_FIX.md
rm -f REMOVED_FILES.md
rm -f REVERSION_COMPLETE.md
rm -f SALARY_CAP_125M_COMPLETE.md
rm -f SALARY_CAP_UPDATE.md
rm -f SALARY_DISPLAY_ENHANCEMENT.md
rm -f SIMPLIFICATION_COMPLETE.md
rm -f TEAMCONTROLLER_COMPILATION_FIX.md
rm -f TEAMCONTROLLER_FIXES.md
rm -f TERMINAL_ERRORS_DIAGNOSIS.md
rm -f TERMINAL_ERRORS_FIXED.md
rm -f TESTING_CHANGES_README.md
rm -f TEST_COMMISSIONER_LOGINS.md
rm -f USER_CHECK_REPORT.md
rm -f WORKFLOW_DIAGRAM.md
echo "✓ Removed 44 miscellaneous documentation files"

echo ""
echo "Phase 10: Removing temporary text files..."
rm -f CODE_SOURCES.txt
rm -f FINAL_SUMMARY.txt
rm -f PGADMIN_QUICKSTART.txt
rm -f QUICK_FIX_VISUAL.txt
rm -f READY_TO_PUSH.txt
rm -f SIMPLE_FIX.txt
rm -f backend_logic_explanation.txt
rm -f current_error.log
echo "✓ Removed 8 temporary text files"

echo ""
echo "Phase 11: Removing PgAdmin documentation files..."
rm -f PGADMIN_GUIDE.md
rm -f PGADMIN_SETUP_GUIDE.md
rm -f PGLADMIN_CONNECTION_GUIDE.md
rm -f REGISTER_PGADMIN_SERVER.md
echo "✓ Removed 4 PgAdmin documentation files"

echo ""
echo "Phase 12: Removing redundant shell scripts..."
rm -f access_db.sh
rm -f add_salary_display.sh
rm -f apply_home_privacy.sh
rm -f apply_template_changes.sh
rm -f build_and_deploy.sh
rm -f build_docker.sh
rm -f build_jar.sh
rm -f check_docker.sh
rm -f check_postgres_container.sh
rm -f cleanup-docker.sh
rm -f commit_and_push.sh
rm -f commit_and_push_changes.sh
rm -f create_dasgoat_account.sh
rm -f db_connect.sh
rm -f deploy_duplicate_prevention.sh
rm -f deploy_master.sh
rm -f deploy_now.sh
rm -f deploy_privacy_changes.sh
rm -f deploy_privacy_immediate.sh
rm -f deploy_privacy_live.sh
rm -f deploy_privacy_now.sh
rm -f deploy_salary_cap_update.sh
rm -f deploy_salary_privacy.sh
rm -f direct_deploy.sh
rm -f execute_commit_push.sh
rm -f execute_deploy.sh
rm -f execute_deployment.sh
rm -f execute_deployment_now.sh
rm -f execute_docker_setup.sh
rm -f execute_git_workflow.sh
rm -f execute_home_privacy.sh
rm -f execute_now.sh
rm -f execute_privacy_deployment.sh
rm -f execute_privacy_now.sh
rm -f execute_rebuild.sh
rm -f execute_template_fix.sh
rm -f final_commit_push.sh
rm -f final_deploy.sh
rm -f final_template_fix.sh
rm -f fix-app-container.sh
rm -f fix-entity-mappings.sh
rm -f fix_500_error.sh
rm -f fix_compilation_and_test.sh
rm -f git_commit_direct.sh
rm -f git_commit_push.sh
rm -f make_executable.sh
rm -f privacy_deploy_final.sh
rm -f quick-docker-reset.sh
rm -f quick_commit_push.sh
rm -f quick_docker_fix.sh
rm -f quick_docker_start.sh
rm -f quick_fix.sh
rm -f quick_privacy_deploy.sh
rm -f quick_template_fix.sh
rm -f rebuild.sh
rm -f recreate-docker-containers.sh
rm -f recreate_containers.sh
rm -f revert_testing_changes.sh
rm -f run-app-fix.sh
rm -f run-docker-setup.sh
rm -f run-entity-fix.sh
rm -f run_deploy.sh
rm -f run_deploy_now.sh
rm -f run_deployment.sh
rm -f run_docker.sh
rm -f run_final_fix.sh
rm -f run_fix.sh
rm -f run_git_commit.sh
rm -f run_pgladmin_now.sh
rm -f run_privacy_deployment.sh
rm -f run_recreation.sh
rm -f run_salary_cap_deployment.sh
rm -f setup_db_access.sh
rm -f start_containers.sh
rm -f start_pgladmin.sh
rm -f template_fix_simple.sh
rm -f test_compilation.sh
rm -f verify_and_rebuild.sh
echo "✓ Removed 73 redundant shell scripts"

echo ""
echo "Phase 13: Removing temporary SQL files (keeping init-db.sql)..."
rm -f create_dasgoat_user.sql
rm -f query_users.sql
rm -f update_existing_data.sql
rm -f update_salary_cap_to_125M.sql
echo "✓ Removed 4 temporary SQL files"

echo ""
echo "Phase 14: Removing cleanup scripts created during this process..."
rm -f cleanup_phase1.sh
rm -f cleanup_unused_files.sh
rm -f CLEANUP_LOG.md
echo "✓ Removed temporary cleanup files"

# Count files after cleanup
AFTER=$(find . -maxdepth 1 -type f | wc -l)
REMOVED=$((BEFORE - AFTER))

echo ""
echo "=== CLEANUP COMPLETE ==="
echo "Files before: $BEFORE"
echo "Files after: $AFTER"  
echo "Files removed: $REMOVED"
echo ""
echo "Essential files preserved:"
echo "✓ src/ (source code)"
echo "✓ pom.xml (Maven build file)"
echo "✓ Dockerfile & docker-compose.yml (containerization)"
echo "✓ README.md (main documentation)"
echo "✓ init-db.sql (database initialization)"
echo "✓ build_app.sh (main build script)"
echo "✓ sample_players.csv (test data)"