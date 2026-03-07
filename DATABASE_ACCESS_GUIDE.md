# Database Access Guide

## Database Connection Details
- **Database**: PostgreSQL 15
- **Database Name**: `fantasyia`
- **Username**: `fantasyia`
- **Password**: `fantasyia`
- **Port**: `5432`

## Access Methods

### 1. PgAdmin Web Interface (Recommended for GUI)
The easiest way to access and manage your database:

```bash
# Start the services
docker compose up -d

# Access PgAdmin at: http://localhost:8081
# Login: admin@admin.com
# Password: admin
```

**Setting up server connection in PgAdmin:**
- Right-click "Servers" → "Create" → "Server"
- **Name**: FantasyIA DB
- **Host**: `db` (Docker internal network)
- **Port**: `5432`
- **Database**: `fantasyia`
- **Username**: `fantasyia`
- **Password**: `fantasyia`

### 2. Command Line Access via Docker

#### Interactive PostgreSQL Shell
```bash
# Connect to database directly
docker compose exec db psql -U fantasyia -d fantasyia

# Or if containers are not running:
docker compose up -d db
docker compose exec db psql -U fantasyia -d fantasyia
```

#### Execute SQL Files
```bash
# Run SQL script
docker compose exec -T db psql -U fantasyia -d fantasyia < your_script.sql
```

#### One-liner queries
```bash
# Execute single query
docker compose exec db psql -U fantasyia -d fantasyia -c "SELECT * FROM users;"
```

### 3. Direct Connection (if PostgreSQL client installed locally)
```bash
# Install PostgreSQL client if not installed
brew install postgresql

# Connect directly
psql -h localhost -p 5432 -U fantasyia -d fantasyia
```

### 4. Using IDE Database Tools
Most IDEs (IntelliJ, VSCode, etc.) have database tools:
- **Host**: `localhost`
- **Port**: `5432`
- **Database**: `fantasyia`
- **Username**: `fantasyia`
- **Password**: `fantasyia`

## Common Database Operations

### View all tables
```sql
\dt
```

### View table structure
```sql
\d table_name
-- Example: \d users
```

### Common queries
```sql
-- View all users
SELECT * FROM users;

-- View all players
SELECT * FROM players;

-- View active auctions
SELECT * FROM auctions WHERE auction_status = 'ACTIVE';

-- View recent bids
SELECT * FROM bids ORDER BY created_at DESC LIMIT 10;
```

### Backup database
```bash
docker compose exec db pg_dump -U fantasyia -d fantasyia > backup.sql
```

### Restore database
```bash
docker compose exec -T db psql -U fantasyia -d fantasyia < backup.sql
```

## Troubleshooting

### If containers are not running:
```bash
docker compose up -d
```

### Check container status:
```bash
docker compose ps
```

### View database logs:
```bash
docker compose logs db
```

### Reset database (WARNING: Deletes all data):
```bash
docker compose down -v
docker compose up -d
```