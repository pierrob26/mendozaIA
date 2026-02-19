# 500 Error Fix - Auction System v2.0

## Problem

After implementing the new Free Agency auction system, you're seeing a **Whitelabel Error Page** with a **500 Internal Server Error**.

## Root Cause

The 500 error is occurring because:

1. **Duplicate Controller Mapping**: The `RegistrationController` was disabled (commented out `@Controller` annotation) but the old compiled version was still loaded
2. **Missing Database Columns**: New fields added to entities (`AuctionItem`, `Player`, `UserAccount`) may not exist in the database yet
3. **Stale Docker Build**: The Docker container is running old compiled code

## The Fix

### Quick Fix (Recommended)

Run the emergency fix script:

```bash
chmod +x fix_500_error_v2.sh
./fix_500_error_v2.sh
```

This script will:
1. ✅ Stop all containers
2. ✅ Clean Maven build cache
3. ✅ Remove old Docker images
4. ✅ Rebuild application
5. ✅ Start fresh containers
6. ✅ Show you the logs

### Manual Fix

If the script doesn't work, follow these steps:

```bash
# 1. Stop everything
docker compose down

# 2. Clean build
mvn clean
rm -rf target/

# 3. Rebuild
mvn package

# 4. Start database
docker compose up -d db
sleep 10

# 5. Start app with fresh build
docker compose up --build -d app

# 6. Monitor logs
docker compose logs -f app
```

## What Changed

### Files Modified
- ✅ `RegistrationController.java` - Disabled duplicate controller
- ✅ `AuctionItem.java` - Added new fields for rule tracking
- ✅ `AuctionService.java` - NEW: Business logic service
- ✅ `AuctionScheduledTasks.java` - NEW: Automated tasks
- ✅ `AuctionController.java` - Updated to use service
- ✅ `FantasyIaApplication.java` - Added `@EnableScheduling`
- ✅ `CustomErrorController.java` - NEW: Better error handling
- ✅ `error.html` - NEW: Error page template

### Database Changes Needed

The application will auto-create new columns if `spring.jpa.hibernate.ddl-auto=update` is set (it is).

However, if you encounter database issues, manually run these:

```sql
-- Connect to database
./access_db.sh

-- Add new columns to auction_items
ALTER TABLE auction_items ADD COLUMN IF NOT EXISTS can_delete_bid BOOLEAN DEFAULT true;
ALTER TABLE auction_items ADD COLUMN IF NOT EXISTS current_minimum_increment DOUBLE PRECISION DEFAULT 0.0;
ALTER TABLE auction_items ADD COLUMN IF NOT EXISTS roster_compliance_deadline TIMESTAMP;
ALTER TABLE auction_items ADD COLUMN IF NOT EXISTS is_buyout_deadline_passed BOOLEAN DEFAULT false;

-- Verify columns exist
\d auction_items
```

See `DATABASE_MIGRATION_V2.md` for complete migration guide.

## Verification

After running the fix:

### 1. Check Application is Running
```bash
curl http://localhost:8080/login
```

Should return HTML (not an error).

### 2. Check Logs for Errors
```bash
docker compose logs --tail=50 app | grep -i error
```

Should show no errors (or only old errors before restart).

### 3. Test Login
1. Go to http://localhost:8080/login
2. Login with existing credentials
3. Should see home page

### 4. Test Auction Page
1. Go to http://localhost:8080/auction/view
2. Should load without errors

### 5. Check Scheduled Tasks Started
```bash
docker compose logs app | grep -i "scheduled"
```

Should see messages about scheduled task initialization.

## Common Issues After Fix

### Issue: Still getting 500 errors

**Check**: Are there any errors in the logs?
```bash
docker compose logs --tail=100 app
```

**Look for**:
- Database connection errors
- Missing column errors
- Bean creation errors

### Issue: "Column does not exist" error

**Fix**: Manually add the columns (see Database Changes section above)

Or enable auto-update:
```properties
# In application.properties
spring.jpa.hibernate.ddl-auto=update
```

### Issue: "Ambiguous mapping" error

**Symptom**: Error about duplicate `/register` mapping

**Fix**: Make sure `RegistrationController.java` has the `@Controller` annotation commented out:
```java
// @Controller - DISABLED: Duplicate of RegisterController
public class RegistrationController {
```

### Issue: Application won't start

**Check build logs**:
```bash
mvn clean package
```

Look for compilation errors.

### Issue: Database connection refused

**Check database is running**:
```bash
docker compose ps
```

**Restart database**:
```bash
docker compose up -d db
```

## Understanding the New System

### What's Different?

The auction system now:
- ✅ Enforces all Free Agency rules automatically
- ✅ Validates salary cap before accepting bids
- ✅ Checks roster limits
- ✅ Calculates dynamic bid increments based on time
- ✅ Auto-awards players when time expires
- ✅ Auto-applies buyout fees for missed contract deadlines
- ✅ Supports both IN_SEASON and OFF_SEASON auction types

### Key Components

1. **AuctionService** - All business logic
2. **AuctionScheduledTasks** - Runs every 30 min / 1 hour
3. **Enhanced Models** - Track additional rule requirements

### Testing the System

After fix is complete:

1. **Login as Commissioner**
2. **Go to** `/auction/manage`
3. **Add a player** to auction
4. **Login as Manager** (different browser/incognito)
5. **Go to** `/auction/view`
6. **Place a bid**
7. **Wait or change time** to test increments
8. **Award player** (as Commissioner)
9. **Post contract** (as Manager)

## Need More Help?

### Documentation
- `FREE_AGENCY_SYSTEM.md` - Complete user guide
- `DATABASE_MIGRATION_V2.md` - Database updates
- `AUCTION_IMPLEMENTATION_SUMMARY.md` - Technical details

### Commands
```bash
# View live logs
docker compose logs -f app

# Access database
./access_db.sh

# Restart everything
docker compose restart

# Full rebuild
./fix_500_error_v2.sh
```

### Debug Mode

Enable detailed logging:

1. Edit `application.properties`:
```properties
logging.level.com.fantasyia=DEBUG
logging.level.org.hibernate.SQL=DEBUG
```

2. Rebuild and restart

3. Check logs for detailed information

## Success Criteria

✅ Application starts without errors
✅ Login page loads
✅ Home page loads after login  
✅ Auction pages load
✅ No duplicate controller errors
✅ Scheduled tasks are running
✅ Can place bids successfully

---

**Last Updated**: February 18, 2026
**Fix Version**: 2.0.1
**Status**: Ready to Deploy
