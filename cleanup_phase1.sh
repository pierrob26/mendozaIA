#!/bin/bash

# Phase 1: Remove all auction/build/cleanup documentation files
echo "Removing AUCTION_* documentation files..."
rm -f "AUCTION_500_ERROR_FIX.md" "AUCTION_BIDDING_UPDATE.md" "AUCTION_COLUMN_MAPPING_FIX.md" "AUCTION_CRASH_FINAL_RESOLUTION.md" "AUCTION_CRASH_FIX_INSTRUCTIONS.md" "AUCTION_CRASH_FIX_V2.md" "AUCTION_DATABASE_FIX_SUMMARY.md" "AUCTION_ERROR_FIX.md" "AUCTION_FIX_README.md" "AUCTION_IMPLEMENTATION_SUMMARY.md" "AUCTION_MANAGE_FIX.md" "AUCTION_V2_README.md" "AUTO_AUCTION_INTEGRATION.md"

echo "Removing BUILD_* documentation files..."
rm -f "BUILD_FAILURE_RESOLVED.md" "BUILD_SUCCESS_COMPLETE.md"

echo "Removing CLEANUP_* documentation files..."
rm -f "CLEANUP_GUIDE.md" "CLEANUP_INDEX.md" "CLEANUP_REPORT.md" "CLEANUP_VISUAL.md"

echo "Removed batch 1 - auction/build/cleanup docs"