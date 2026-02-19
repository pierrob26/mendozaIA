# 🗄️ DATABASE ACCESS GUIDE

## Quick Access

### Option 1: Interactive Shell (Recommended)
```bash
chmod +x access_db.sh
./access_db.sh
```

This will connect you directly to the PostgreSQL database with psql.

### Option 2: Direct Command
```bash
docker exec -it fantasyia-db-1 psql -U fantasyia -d fantasyia
```

### Option 3: Web Interface (pgAdmin)
```
URL: http://localhost:8081
Email: admin@admin.com
Password: admin
```

Then add a new server:
- Name: FantasyIA
- Host: db
- Port: 5432
- Database: fantasyia
- Username: fantasyia
- Password: fantasyia

---

## 📊 Useful Database Commands

Once connected via psql, use these commands:

### View All Tables
```sql
\dt
```

### View Table Structure
```sql
\d players
\d released_players_queue
\d auction_items
\d users
```

### View All Players
```sql
SELECT id, name, position, team, contract_length, contract_amount, owner_id 
FROM players 
ORDER BY name;
```

### View Players by Owner
```sql
SELECT u.username, COUNT(p.id) as player_count
FROM users u
LEFT JOIN players p ON u.id = p.owner_id
GROUP BY u.username;
```

### View Released Players Queue
```sql
SELECT id, player_name, position, mlb_team, status, released_at
FROM released_players_queue
WHERE status = 'PENDING'
ORDER BY released_at DESC;
```

### View Free Agents
```sql
SELECT id, name, position, team
FROM players
WHERE owner_id IS NULL
ORDER BY position, name;
```

### View Active Auctions
```sql
SELECT ai.id, p.name as player_name, p.position, ai.current_bid, ai.status
FROM auction_items ai
JOIN players p ON ai.player_id = p.id
WHERE ai.status = 'ACTIVE';
```

### Count Records
```sql
SELECT 
    (SELECT COUNT(*) FROM players) as total_players,
    (SELECT COUNT(*) FROM players WHERE owner_id IS NULL) as free_agents,
    (SELECT COUNT(*) FROM released_players_queue WHERE status = 'PENDING') as pending_releases,
    (SELECT COUNT(*) FROM auction_items WHERE status = 'ACTIVE') as active_auctions;
```

---

## 🔧 Database Management Commands

### Backup Database
```bash
docker exec fantasyia-db-1 pg_dump -U fantasyia fantasyia > backup_$(date +%Y%m%d).sql
```

### Restore Database
```bash
cat backup_20260217.sql | docker exec -i fantasyia-db-1 psql -U fantasyia -d fantasyia
```

### View Database Size
```sql
SELECT pg_size_pretty(pg_database_size('fantasyia'));
```

### View Table Sizes
```sql
SELECT 
    tablename,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS size
FROM pg_tables
WHERE schemaname = 'public'
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;
```

---

## 🧹 Maintenance Commands

### Clear All Player Contracts (Make Free Agents)
```sql
UPDATE players SET contract_length = 0, contract_amount = 0.0, owner_id = NULL;
```

### Clear Released Players Queue
```sql
DELETE FROM released_players_queue WHERE status != 'PENDING';
```

### Remove Orphaned Auction Items
```sql
DELETE FROM auction_items 
WHERE player_id NOT IN (SELECT id FROM players);
```

### Reset Auction System
```sql
UPDATE auction_items SET status = 'REMOVED' WHERE status = 'ACTIVE';
DELETE FROM bids;
```

---

## 🔍 Debugging Queries

### Find Players with Issues
```sql
-- Players with no position
SELECT * FROM players WHERE position IS NULL OR position = '';

-- Players with negative contracts
SELECT * FROM players WHERE contract_length < 0 OR contract_amount < 0;

-- Auction items for missing players
SELECT ai.* 
FROM auction_items ai 
LEFT JOIN players p ON ai.player_id = p.id 
WHERE p.id IS NULL AND ai.status = 'ACTIVE';
```

### Check Released Queue Status
```sql
SELECT status, COUNT(*) 
FROM released_players_queue 
GROUP BY status;
```

### View Recent Activity
```sql
-- Recent bids
SELECT b.*, p.name as player_name, u.username
FROM bids b
JOIN auction_items ai ON b.auction_item_id = ai.id
JOIN players p ON ai.player_id = p.id
JOIN users u ON b.bidder_id = u.id
ORDER BY b.bid_time DESC
LIMIT 20;

-- Recent releases
SELECT * 
FROM released_players_queue 
ORDER BY released_at DESC 
LIMIT 10;
```

---

## 📤 Export Data

### Export Players to CSV
```bash
docker exec fantasyia-db-1 psql -U fantasyia -d fantasyia -c "\COPY (SELECT * FROM players) TO STDOUT WITH CSV HEADER" > players.csv
```

### Export Released Queue to CSV
```bash
docker exec fantasyia-db-1 psql -U fantasyia -d fantasyia -c "\COPY (SELECT * FROM released_players_queue WHERE status='PENDING') TO STDOUT WITH CSV HEADER" > released_queue.csv
```

---

## 🆘 Common Issues

### "Container not found"
```bash
# Check container name
docker ps | grep postgres

# If different name, replace in command:
docker exec -it <actual-container-name> psql -U fantasyia -d fantasyia
```

### "Connection refused"
```bash
# Check if database is running
docker-compose ps

# Restart database
docker-compose restart db
```

### "Permission denied"
```bash
# Make sure you're in the project directory
cd /Users/robbypierson/IdeaProjects/fantasyIA

# Try with sudo (if needed)
sudo docker exec -it fantasyia-db-1 psql -U fantasyia -d fantasyia
```

---

## 🎓 psql Quick Reference

Once connected to psql:

| Command | Description |
|---------|-------------|
| `\l` | List all databases |
| `\dt` | List all tables |
| `\d table_name` | Describe table structure |
| `\du` | List all users |
| `\q` | Quit psql |
| `\?` | Show all commands |
| `\h` | SQL help |
| `\timing` | Toggle query timing |

---

## 🔐 Connection Details

**Database System**: PostgreSQL 15  
**Host** (from host): localhost  
**Host** (from Docker): db  
**Port**: 5432  
**Database**: fantasyia  
**Username**: fantasyia  
**Password**: fantasyia  

**Data Location**: Docker volume `pgdata`  
**pgAdmin URL**: http://localhost:8081  
**pgAdmin Login**: admin@admin.com / admin

---

## 🚀 Quick Start

**1. Connect to database:**
```bash
./access_db.sh
```

**2. View all tables:**
```sql
\dt
```

**3. See some players:**
```sql
SELECT * FROM players LIMIT 10;
```

**4. Exit:**
```sql
\q
```

---

**Ready to explore your database!** 🎉
