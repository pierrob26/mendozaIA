# Data Persistence Through Rebuild - ANSWER

## ✅ YES - Your created user WILL be there after rebuild!

## Why Your Data Is Safe

Your `docker-compose.yml` is properly configured with **persistent volumes**:

```yaml
volumes:
  - pgdata:/var/lib/postgresql/data
```

This means:

### What Happens During Rebuild

1. **Application container** is rebuilt (fantasyia_app)
   - Old container is stopped and removed
   - New container is created with updated code
   - **NO data is stored here**

2. **Database container** either:
   - Keeps running (if only app is rebuilt), OR
   - Restarts but reconnects to the **same volume**

3. **Database volume** (pgdata)
   - Persists independently of containers
   - Contains all your PostgreSQL data
   - **NOT deleted or modified during rebuild**

### What Data Will Be Preserved

✅ **User accounts** - All registered users
✅ **Player contracts** - All owned players and rosters
✅ **Auction data** - All active and historical auctions
✅ **Bids** - Complete bid history
✅ **Pending contracts** - In-progress contract negotiations
✅ **Released players** - Release queue
✅ **All timestamps and relationships**

### What Won't Change

The only things that change during rebuild are:
- **Application code** (bug fixes, new features)
- **Application container** (rebuilt with new code)

### When Data WOULD Be Lost

Your data would ONLY be lost if you:
1. Run `docker-compose down -v` (the `-v` flag removes volumes)
2. Manually delete the volume: `docker volume rm fantasyia_pgdata`
3. Delete the Docker volume directory

### Safe Rebuild Commands

All of these are **SAFE** and preserve your data:

```bash
# Option 1: Use rebuild script
./rebuild_and_restart.sh

# Option 2: Use auction fix script
./apply_auction_fix.sh

# Option 3: Manual rebuild
docker-compose down          # Safe - keeps volumes
mvn clean package -DskipTests
docker-compose up -d --build

# Option 4: Restart just the app
docker-compose restart app
```

### Verification Commands

Check if your data volume exists:
```bash
docker volume ls | grep fantasyia_pgdata
```

Check current users before rebuild:
```bash
docker exec -i fantasyia_postgres psql -U fantasyia -d fantasyia -c "SELECT username FROM users;"
```

Check users after rebuild (same command):
```bash
docker exec -i fantasyia_postgres psql -U fantasyia -d fantasyia -c "SELECT username FROM users;"
```

### Important Notes

1. **Hibernate DDL setting**: Your app uses `SPRING_JPA_HIBERNATE_DDL_AUTO: update`
   - This means Hibernate will **update** schema, not recreate it
   - Existing data is preserved
   - New columns/tables are added if needed

2. **DataInitializer**: Uses `existsByUsername()` checks
   - Only creates users if they don't already exist
   - Won't duplicate or overwrite your created users

3. **Database persistence**: Docker named volume `pgdata`
   - Survives container restarts
   - Survives container removal
   - Survives host system reboots

## Recommendation

✅ **Go ahead and rebuild with confidence!**

Your created user and all other data will be there when the rebuild completes.

Run this to verify your current data before rebuilding:
```bash
chmod +x check_data_persistence.sh
./check_data_persistence.sh
```

Then rebuild:
```bash
./apply_auction_fix.sh
```

Your user will still be there! 🎉
