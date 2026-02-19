# pgAdmin Database Connection Guide

## The Issue
You can't see any tables or data in pgAdmin for your FantasyIA application.

## Quick Solution Steps

### 1. Run the Diagnostic Tool
```bash
cd /Users/robbypierson/IdeaProjects/fantasyIA
chmod +x run_pgladmin_diagnostic.sh
./run_pgladmin_diagnostic.sh
```

### 2. Most Likely Causes & Solutions

#### **Cause 1: Docker Containers Not Running**
```bash
# Start all containers
docker-compose up -d

# Or start specific containers
docker-compose up -d db pgadmin app
```

#### **Cause 2: Application Not Started (No Tables Created)**
Your JPA entities need the Spring Boot app running to create tables:
```bash
# Start the application
docker-compose up -d app

# Wait 30 seconds for initialization
sleep 30

# Check if tables are created
./quick_db_queries.sh
```

#### **Cause 3: Wrong pgAdmin Server Configuration**

**ACCESS pgAdmin:**
- URL: http://localhost:8081
- Email: admin@admin.com  
- Password: admin

**ADD DATABASE SERVER in pgAdmin:**
1. Right-click "Servers" → "Register" → "Server"
2. **General Tab:**
   - Name: FantasyIA Database
3. **Connection Tab:**
   - Hostname: `db` (NOT localhost!)
   - Port: `5432`
   - Database: `fantasyia`
   - Username: `fantasyia` 
   - Password: `fantasyia`

#### **Cause 4: Looking at Wrong Database/Schema**
Make sure you're looking at:
- Server: Your FantasyIA server
- Database: `fantasyia` 
- Schema: `public`
- Tables should be: `users`, `players`, `auctions`, etc.

### 3. Expected Tables
Your application should have these tables:
- `users` - User accounts
- `players` - Baseball players  
- `auctions` - Auction events
- `auction_items` - Items being auctioned
- `bids` - Auction bids
- `released_players_queue` - Players pending release

### 4. Direct Database Access
If pgAdmin still doesn't work, access the database directly:
```bash
# Interactive database connection
./access_db.sh

# Quick table view
./quick_db_queries.sh

# Database management tools
./db_tools.sh
```

### 5. Check Application Logs
If tables still don't exist:
```bash
# View application startup logs
docker-compose logs app

# Look for JPA/Hibernate errors
docker-compose logs app | grep -i error

# Check database connection
docker-compose logs app | grep -i "database"
```

### 6. Force Application Restart
Sometimes the DataInitializer doesn't run:
```bash
# Restart application to trigger DataInitializer
docker-compose restart app

# Check logs to verify initialization
docker-compose logs -f app
```

## Quick Verification Commands

```bash
# Check container status
docker-compose ps

# Test database connection
docker exec fantasyia-db-1 psql -U fantasyia -d fantasyia -c "SELECT 1;"

# List all tables
docker exec fantasyia-db-1 psql -U fantasyia -d fantasyia -c "\dt"

# Count records in users table
docker exec fantasyia-db-1 psql -U fantasyia -d fantasyia -c "SELECT COUNT(*) FROM users;"
```

## Still Having Issues?

1. **Complete Reset:**
   ```bash
   docker-compose down -v  # Removes volumes (data will be lost!)
   docker-compose up -d
   ```

2. **Check Database Logs:**
   ```bash
   docker-compose logs db
   ```

3. **Verify Docker Network:**
   ```bash
   docker network ls
   docker network inspect fantasyia_default
   ```

Once you run the diagnostic script, it will tell you exactly which of these issues applies to your situation!