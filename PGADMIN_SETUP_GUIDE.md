# PgAdmin Setup Guide for FantasyIA

## Quick Start
Run this command to start PgAdmin and open it in your browser:
```bash
chmod +x start_pgadmin.sh
./start_pgadmin.sh
```

## Manual Setup Instructions

### Step 1: Start Services
```bash
docker compose up -d db pgadmin
```

### Step 2: Access PgAdmin
- Open your browser and go to: **http://localhost:8081**
- Login with:
  - **Email**: `admin@admin.com`
  - **Password**: `admin`

### Step 3: Add Database Server
1. Right-click on "Servers" in the left panel
2. Select "Create" → "Server..."
3. In the "General" tab:
   - **Name**: `FantasyIA Database` (or any name you prefer)
4. In the "Connection" tab:
   - **Host name/address**: `db`
   - **Port**: `5432`
   - **Maintenance database**: `fantasyia`
   - **Username**: `fantasyia`
   - **Password**: `fantasyia`
5. Click "Save"

### Step 4: Browse Your Data
After connecting, navigate to:
```
Servers → FantasyIA Database → Databases → fantasyia → Schemas → public → Tables
```

## Available Tables
Your FantasyIA database contains these main tables:
- **users** - User accounts and team information
- **players** - Player roster with contracts and salaries
- **auctions** - Auction events and settings
- **auction_items** - Items being auctioned
- **bids** - Bidding history
- **pending_contracts** - Contract negotiations
- **released_players** - Released player tracking

## Common Tasks in PgAdmin

### View Table Data
1. Navigate to the table you want to view
2. Right-click on the table name
3. Select "View/Edit Data" → "All Rows"

### Run Custom Queries
1. Right-click on the database name (`fantasyia`)
2. Select "Query Tool"
3. Enter your SQL query, for example:
   ```sql
   SELECT * FROM users;
   SELECT name, position, mlb_team, contract_amount FROM players WHERE owner_id IS NOT NULL;
   SELECT * FROM auctions WHERE auction_status = 'ACTIVE';
   ```
4. Click the "Execute" button (▶️) or press F5

### Export Data
1. Right-click on a table
2. Select "Import/Export Data..."
3. Choose your export format (CSV, etc.)

### View Table Structure
1. Navigate to the table
2. Click on the table name
3. Use the tabs at the top to see:
   - **Properties** - Basic table info
   - **Columns** - Column definitions
   - **Constraints** - Primary keys, foreign keys, etc.
   - **Indexes** - Database indexes

## Sample Queries to Try

```sql
-- View all users with their salary information
SELECT username, role, salary_cap, current_salary_used 
FROM users 
ORDER BY username;

-- View all players with their owners
SELECT p.name, p.position, p.mlb_team, p.contract_amount, u.username as owner
FROM players p
LEFT JOIN users u ON p.owner_id = u.id
ORDER BY p.name;

-- View active auctions
SELECT auction_name, start_time, end_time, auction_status
FROM auctions
WHERE auction_status = 'ACTIVE'
ORDER BY start_time;

-- Count players by position
SELECT position, COUNT(*) as player_count
FROM players
GROUP BY position
ORDER BY player_count DESC;
```

## Troubleshooting

### Can't Connect to Database
- Make sure both containers are running: `docker compose ps`
- Restart services: `docker compose restart db pgadmin`

### PgAdmin Won't Load
- Check if port 8081 is available: `lsof -i :8081`
- Try restarting: `docker compose restart pgladmin`

### Connection Refused
- Verify database is healthy: `docker compose exec db pg_isready -U fantasyia -d fantasyia`
- Check container logs: `docker compose logs db`