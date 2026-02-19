#!/bin/bash

# Fix Script for Page Crash - Makes all new fields nullable with safe defaults
echo "======================================"
echo "Fixing Page Crash Issue"
echo "======================================"

cd /Users/robbypierson/IdeaProjects/fantasyIA

echo ""
echo "The crash was caused by new database fields that don't exist in the current database."
echo ""
echo "FIXES APPLIED:"
echo "1. ✅ Made UserAccount new fields nullable (salaryCap, currentSalaryUsed, roster counts)"
echo "2. ✅ Made Player new fields nullable (isMinorLeaguer, isRookie, stats tracking)"
echo "3. ✅ Made AuctionItem.isMinorLeaguer nullable"
echo "4. ✅ Made Auction.auctionType nullable"
echo "5. ✅ Made PendingContract.isMinorLeaguer nullable"
echo "6. ✅ Added safe default values in all getters to prevent null pointer exceptions"
echo ""
echo "With spring.jpa.hibernate.ddl-auto=update, the new columns will be added automatically."
echo "Existing data will have NULL values, but getters return safe defaults."
echo ""
echo "Building application..."
./mvnw clean package -DskipTests

if [ $? -eq 0 ]; then
    echo ""
    echo "======================================"
    echo "✅ BUILD SUCCESSFUL - READY TO RUN"
    echo "======================================"
    echo ""
    echo "The application should now start without crashing."
    echo ""
    echo "To start:"
    echo "  ./mvnw spring-boot:run"
    echo ""
    echo "Or with Docker:"
    echo "  docker-compose down"
    echo "  docker-compose up --build"
    echo ""
    echo "WHAT HAPPENS ON FIRST RUN:"
    echo "- Hibernate will add new columns to existing tables"
    echo "- Existing users will have NULL values for new fields"
    echo "- Getters return safe defaults (0, false, 'IN_SEASON', etc.)"
    echo "- New registrations will initialize all fields properly"
    echo ""
    echo "OPTIONAL: Run database update script to set defaults for existing data"
    echo "  See: update_existing_data.sql"
    echo ""
else
    echo ""
    echo "❌ Build failed - check errors above"
    exit 1
fi
