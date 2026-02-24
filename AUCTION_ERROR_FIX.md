# Auction Management Page Error - FIXED

## Problem
Error on auction management page:
```
Error loading auction management page: could not execute statement 
[ERROR: null value in column "auction_name" of relation "auctions" violates not-null constraint
```

## Root Cause
The database table `auctions` has a column named `auction_name`, but the JPA entity `Auction.java` was mapping the Java field `name` to a column also called `name` (by default). This caused a mismatch:

- **Java entity field**: `name`
- **Database column**: `auction_name`
- **Result**: JPA tried to insert into column `name`, but it doesn't exist. The actual column `auction_name` received NULL.

## Solution Applied
Added explicit column name mapping in `Auction.java`:

```java
@Column(name = "auction_name", nullable = false)
private String name;
```

This tells JPA/Hibernate to map the Java field `name` to the database column `auction_name`.

## Changes Made

### File: `src/main/java/com/fantasyia/auction/Auction.java`

**Before:**
```java
@Column(nullable = false)
private String name;
```

**After:**
```java
@Column(name = "auction_name", nullable = false)
private String name;
```

## How to Apply the Fix

### Method 1: Run the fix script (RECOMMENDED)
```bash
cd /Users/robbypierson/IdeaProjects/fantasyIA
chmod +x fix_auction_column.sh
./fix_auction_column.sh
```

This will:
1. Stop containers
2. Clean and rebuild the application
3. Restart containers
4. Test the auction management page
5. Verify the fix works

### Method 2: Manual rebuild
```bash
cd /Users/robbypierson/IdeaProjects/fantasyIA
docker-compose down
mvn clean package -DskipTests
docker-compose up -d --build
```

## Verification

After rebuilding, test the auction management page:
1. Login as commissioner at http://localhost:8080/login
   - Username: `commissioner`
   - Password: `password`
2. Navigate to http://localhost:8080/auction/manage
3. The page should load without errors
4. Creating/viewing auctions should work properly

## Technical Details

The error occurred because:
1. When `getOrCreateMainAuction()` tried to create a new auction
2. It set the `name` field to "Main Player Auction"
3. JPA generated SQL: `INSERT INTO auctions (..., name, ...) VALUES (..., 'Main Player Auction', ...)`
4. Database rejected it because there's no column called `name`, only `auction_name`
5. The `auction_name` column received NULL, violating the NOT NULL constraint

The fix ensures JPA uses the correct column name in the SQL.

## Status
✅ **FIXED** - The column mapping has been corrected in the source code.

Run the rebuild script to apply the fix to your running application.
