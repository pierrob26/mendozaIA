# 📋 How to Register PostgreSQL Server in pgAdmin

## You're almost there! pgAdmin is running, but you need to add your database as a server connection.

### 🔍 First: Verify Your Database Has Tables

Run this in your terminal:
```bash
cd /Users/robbypierson/IdeaProjects/fantasyIA
chmod +x check_tables_exist.sh
./check_tables_exist.sh
```

### 🌐 Step-by-Step: Register Server in pgAdmin

#### 1. Access pgAdmin
- Open: **http://localhost:8081**
- Email: **admin@admin.com**
- Password: **admin**

#### 2. Register New Server
1. **Right-click** on "Servers" in the left panel
2. Select **"Register" → "Server..."**

#### 3. General Tab
- **Name:** `FantasyIA Database` (or any name you like)

#### 4. Connection Tab - **CRITICAL SETTINGS:**
- **Hostname/address:** `db` ⚠️ **NOT localhost!**
- **Port:** `5432`
- **Maintenance database:** `fantasyia`
- **Username:** `fantasyia`
- **Password:** `fantasyia`
- **Save password:** ✅ (check this box)

#### 5. Click "Save"

### 🎯 Navigate to Your Tables

After registering, expand the tree:
```
📁 Servers
  📁 FantasyIA Database
    📁 Databases
      📁 fantasyia
        📁 Schemas
          📁 public
            📁 Tables ← YOUR TABLES ARE HERE!
```

### 📊 Expected Tables You Should See:
- `users` - User accounts
- `players` - Baseball players
- `auctions` - Auction events
- `auction_items` - Items being auctioned  
- `bids` - Auction bids
- `released_players_queue` - Players pending release

### 🚨 Troubleshooting

#### Problem: "Server doesn't exist" or connection fails
- ✅ Make sure hostname is `db` (not `localhost`)
- ✅ Check containers are running: `docker-compose ps`
- ✅ Restart if needed: `docker-compose restart db pgadmin`

#### Problem: Server connects but no tables visible
- ✅ Run the table check script first
- ✅ Make sure you're looking in the `public` schema
- ✅ Try refreshing: right-click server → "Refresh"
- ✅ Start the app: `docker-compose up -d app`

#### Problem: Empty tables
- ✅ The DataInitializer should create test data automatically
- ✅ Restart app: `docker-compose restart app`
- ✅ Check logs: `docker-compose logs app`

### 🔧 Alternative: Direct Database Access
If pgAdmin still doesn't work:
```bash
./access_db.sh
```

Then run SQL commands like:
```sql
\dt          -- List tables
SELECT * FROM users LIMIT 5;
SELECT * FROM players LIMIT 5;
```

---

**The key point:** You must register the server connection in pgAdmin first - it won't automatically show your database!