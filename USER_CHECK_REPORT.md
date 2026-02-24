# Database User Check - Summary Report

## What I'm Checking

Looking for any previously registered user accounts in the FantasyIA PostgreSQL database.

## Scripts Created for You

I've created several scripts to help you check for users:

### 🎯 **Main Script (Run This):**
```bash
chmod +x check_for_users.sh
./check_for_users.sh
```

This comprehensive script will:
- Check if database container is running
- Check if application container is running  
- Query the users table
- Display all registered accounts
- Show password encryption status
- List all database tables
- Provide diagnosis and recommendations

### 📊 **Alternative Quick Check:**
```bash
chmod +x quick_user_check.sh
./quick_user_check.sh
```

### 🔍 **Direct SQL Query:**
```bash
docker exec -i fantasyia_postgres psql -U fantasyia -d fantasyia -c "SELECT * FROM users;"
```

## Expected Users (from DataInitializer.java)

The application should automatically create these users on first startup:

1. **testuser**
   - Password: `password` (BCrypt encrypted)
   - Role: `MEMBER`
   - Salary Cap: $100M
   - Gets 14 sample players

2. **commissioner**
   - Password: `password` (BCrypt encrypted)
   - Role: `COMMISSIONER`
   - Salary Cap: $100M

## Current Situation

Based on your `current_error.log`, the application **crashed on startup** with this error:

```
Unable to locate Attribute with the given name [status] on this ManagedType [com.fantasyia.auction.AuctionItem]
```

### What This Means:
- ❌ Application never started successfully
- ❌ DataInitializer never ran
- ❌ No users were created in the database
- ❌ Users table might be empty or not exist

## Solution

### Option 1: Run Full Rebuild (RECOMMENDED)
```bash
chmod +x full_rebuild.sh
./full_rebuild.sh
```

This will:
1. Stop containers
2. Clean compiled code
3. Rebuild from source
4. Start application
5. DataInitializer will create users automatically

### Option 2: Check Current State First
```bash
chmod +x check_for_users.sh
./check_for_users.sh
```

This will tell you exactly what's in the database right now.

## How to View Database Users

### Method 1: Command Line
```bash
docker exec -i fantasyia_postgres psql -U fantasyia -d fantasyia -c "SELECT id, username, role, salary_cap FROM users;"
```

### Method 2: pgAdmin (Web GUI)
1. Open http://localhost:8081
2. Login: `admin@admin.com` / `admin`
3. Add server connection:
   - Host: `db`
   - Port: `5432`
   - Database: `fantasyia`
   - Username: `fantasyia`
   - Password: `fantasyia`
4. Navigate to: FantasyIA Database → Databases → fantasyia → Schemas → public → Tables → users

### Method 3: Run Check Script
```bash
./check_for_users.sh
```

## What to Expect

### If Users Exist:
```
✅ Found 2 user(s) in database

User Details:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 id | username    | role         | salary_cap
----+-------------+--------------+------------
  1 | testuser    | MEMBER       | 100.0
  2 | commissioner| COMMISSIONER | 100.0
```

### If No Users:
```
❌ No users found in database

The users table is empty. This means:
  • No one has registered yet
  • DataInitializer hasn't run (app didn't start)
  • Database may have been cleared
```

## Next Steps

1. **First**: Run `./check_for_users.sh` to see current state
2. **If no users found**: Run `./full_rebuild.sh` to fix the application
3. **After rebuild**: Users will be created automatically
4. **Then**: Login at http://localhost:8080/login with `testuser` / `password`

## Additional Information

- **Database**: PostgreSQL (not MySQL)
- **Container**: `fantasyia_postgres`
- **Database Name**: `fantasyia`
- **Database User**: `fantasyia`
- **Database Password**: `fantasyia`
- **Port**: 5432 (internal), exposed on localhost:5432

## Files Created

- `check_for_users.sh` - Main comprehensive check
- `find_registered_users.sh` - Detailed user search
- `analyze_users.sh` - Full database analysis
- `quick_user_check.sh` - Fast user query
- `check_db_users.sh` - Database user listing
- `query_users.sql` - SQL query file

All scripts are ready to use!
