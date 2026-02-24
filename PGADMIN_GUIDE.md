# pgAdmin Access Guide for FantasyIA

## 🌐 Step 1: Access pgAdmin

**URL:** http://localhost:8081

**Login Credentials:**
- **Email:** `admin@admin.com`
- **Password:** `admin`

---

## 🗄️ Step 2: Add Database Server

After logging into pgAdmin:

1. **Right-click** on "Servers" in the left panel
2. Select **"Register" → "Server"**

### General Tab:
- **Name:** `FantasyIA Database` (or any name you like)

### Connection Tab:
- **Host name/address:** `db`
- **Port:** `5432`
- **Maintenance database:** `fantasyia`
- **Username:** `fantasyia`
- **Password:** `fantasyia`
- **Save password:** ✓ (check this box)

3. Click **"Save"**

---

## 📊 Step 3: Browse Your Data

Navigate through the tree:
```
FantasyIA Database
  └─ Databases
      └─ fantasyia
          └─ Schemas
              └─ public
                  └─ Tables
```

### Available Tables:
- **users** - User accounts (testuser, commissioner)
- **players** - Player contracts and rosters
- **auctions** - Auction information
- **auction_items** - Items currently in auction
- **bids** - Bid history
- **pending_contracts** - Contract negotiations
- **released_players** - Released player queue

---

## 💡 Useful SQL Queries

Right-click on the database → **"Query Tool"** to run these:

### View all users:
```sql
SELECT id, username, role, salary_cap, current_salary_used 
FROM users 
ORDER BY username;
```

### View all players with their owners:
```sql
SELECT p.id, p.name, p.position, p.team, p.years_remaining, 
       p.aas, u.username as owner
FROM players p
LEFT JOIN users u ON p.user_id = u.id
ORDER BY p.name;
```

### View active auctions:
```sql
SELECT * FROM auctions WHERE active = true;
```

### View current bids:
```sql
SELECT b.*, p.name as player_name, u.username as bidder
FROM bids b
JOIN players p ON b.player_id = p.id
JOIN users u ON b.user_id = u.id
ORDER BY b.bid_time DESC;
```

---

## 🔧 Troubleshooting

### pgAdmin not loading?
```bash
docker-compose ps
```
Check if `fantasyia_pgadmin` is running.

### Start pgAdmin:
```bash
docker-compose up -d pgadmin
```

### Can't connect to database?
Make sure the database container is running:
```bash
docker-compose ps | grep postgres
```

---

## 📝 Quick Reference

| Service | URL | Credentials |
|---------|-----|-------------|
| **pgAdmin** | http://localhost:8081 | admin@admin.com / admin |
| **Database** | localhost:5432 | fantasyia / fantasyia |
| **App** | http://localhost:8080 | testuser / password |

---

## 🚀 Quick Start Command

Run this script for guided setup:
```bash
chmod +x pgadmin_login.sh
./pgadmin_login.sh
```
