# Player Auction Page 500 Error - DIAGNOSIS & FIX

## Problem
Player auction page shows Internal Server Error 500

## Root Cause
The application is **crashing on startup** and never successfully starts. The error log shows:

```
Unable to locate Attribute with the given name [status] on this ManagedType [com.fantasyia.auction.AuctionItem]
```

## Why This Happens
- The **source code** has the `status` field with getters/setters in `AuctionItem.java`
- The **compiled code** in the Docker container is from an old build that doesn't match
- When Spring Boot tries to create JPA repositories, it can't find the `status` attribute
- Application fails to start
- Any web request returns 500 error because the application isn't running

## Source Code Status
✅ `AuctionItem.java` line 38: `private String status = "ACTIVE";`
✅ `AuctionItem.java` line 119-120: `getStatus()` and `setStatus()` methods exist
✅ `Auction.java` line 13: Column mapping fixed `@Column(name = "auction_name")`

## The Issue
**The Docker container has OLD compiled code that doesn't match the source.**

## Solution
**Rebuild the application to sync compiled code with source code.**

This will:
1. Stop the old containers with outdated code
2. Clean all compiled artifacts
3. Compile fresh code from source (with all fixes)
4. Package into new JAR file
5. Build new Docker image with updated code
6. Start containers with working application

## Data Safety
✅ **Your user data IS SAFE** - stored in Docker volume `pgdata`
✅ All users, players, auctions, and bids will be preserved
✅ Only the application code is rebuilt, not the database

## How to Fix

### Automated Fix (Recommended)
```bash
cd /Users/robbypierson/IdeaProjects/fantasyIA
chmod +x fix_500_error.sh
./fix_500_error.sh
```

This script will:
- Stop containers
- Clean and rebuild with Maven
- Start fresh containers
- Test the endpoints
- Report success/failure

### Manual Fix
```bash
cd /Users/robbypierson/IdeaProjects/fantasyIA
docker-compose down
mvn clean package -DskipTests
docker-compose up -d --build
```

## After the Fix
Once the rebuild completes (~2-3 minutes):

1. ✅ Application will start successfully
2. ✅ Player auction page will load without errors
3. ✅ All your users and data will be intact
4. ✅ Both column mapping issues will be resolved:
   - `Auction.name` → `auction_name` column
   - `AuctionItem.status` field properly compiled

## Access the Fixed Application
- Login: http://localhost:8080/login
- Auction View: http://localhost:8080/auction/view
- Auction Manage: http://localhost:8080/auction/manage

## What Was Wrong
The application has TWO related issues:
1. **Compilation mismatch**: Docker container had old compiled code
2. **Column name mismatch**: `Auction.name` field mapping (now fixed in source)

Both are resolved by rebuilding, which:
- Compiles the updated source code (with column fix)
- Deploys fresh compiled classes to Docker
- Ensures all entity mappings are correct

## Verification
After rebuild, check:
```bash
# Application logs should show successful startup
docker-compose logs app | grep "Started FantasyIaApplication"

# Should return HTTP 200 or 302 (redirect to login)
curl -I http://localhost:8080/auction/view

# Check container is running
docker-compose ps
```

## Timeline
- **Before**: Application crashes on startup, 500 error on all pages
- **During**: ~2-3 minutes rebuild time
- **After**: Application works normally, auction pages load correctly

---

## Execute the Fix Now
```bash
chmod +x fix_500_error.sh && ./fix_500_error.sh
```

Your data is safe - let's fix this! 🚀
