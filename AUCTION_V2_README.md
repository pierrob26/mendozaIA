# Fantasy IA - Free Agency Auction System v2.0

## 🚨 GETTING STARTED - Fix Current 500 Error

If you're seeing a **500 Internal Server Error**, run this immediately:

```bash
chmod +x fix_500_error_v2.sh
./fix_500_error_v2.sh
```

Then read `FIX_500_ERROR_GUIDE.md` for details.

---

## 📚 Documentation Index

### Quick Start
- **FIX_500_ERROR_GUIDE.md** - ⚠️ **READ THIS FIRST** if you have errors
- **AUCTION_IMPLEMENTATION_SUMMARY.md** - Technical overview of what was built

### User Guides
- **FREE_AGENCY_SYSTEM.md** - Complete user guide with all rules explained
- **EXCEL_TESTING_GUIDE.md** - Import players from Excel

### Technical Documentation
- **DATABASE_MIGRATION_V2.md** - Database schema updates
- **AUTO_AUCTION_INTEGRATION.md** - Auction system integration details

### Deployment
- **DEPLOYMENT_CHECKLIST.md** - Pre-deployment checklist
- **DATABASE_MIGRATION_GUIDE.md** - General migration procedures

---

## 🎯 What's New in v2.0

### Complete Free Agency Rule Implementation

The auction system now **automatically enforces** all league rules:

✅ **Minimum Bids**: $500K MLB / $100K minors
✅ **Dynamic Increments**: Time-based increases (8h, 16h, 24h)
✅ **Locked Minimums**: Once increased, never goes back down
✅ **Salary Cap**: $125M enforced on all bids
✅ **Roster Limits**: 40 MLB / 25 minors
✅ **Contract Rules**: 1-5 years with restrictions
✅ **Auto-Award**: Players automatically awarded after 24/72 hours
✅ **Auto-Buyout**: Missed contracts trigger 50% penalty
✅ **Auction Types**: IN_SEASON vs OFF_SEASON with different timing

### New Features

- **AuctionService**: Centralized business logic
- **Scheduled Tasks**: Auto-award and auto-buyout every 30 min / 1 hour
- **Enhanced Validation**: All rules checked before accepting bids
- **Better Error Handling**: Custom error pages with useful messages
- **Commissioner Tools**: Toggle auction type, manage queue

---

## 🛠️ Quick Commands

### Fix Issues
```bash
# Fix 500 errors
./fix_500_error_v2.sh

# Rebuild everything
./rebuild.sh

# Deploy auction system
./deploy_auction_v2.sh
```

### Development
```bash
# Build
mvn clean package

# Run locally
mvn spring-boot:run

# Run tests
mvn test
```

### Docker
```bash
# Start all services
docker compose up -d

# View logs
docker compose logs -f app

# Restart app only
docker compose restart app

# Stop everything
docker compose down
```

### Database
```bash
# Access database
./access_db.sh

# Quick queries
./quick_db_queries.sh

# Check tables
./check_tables_exist.sh
```

---

## 🏗️ System Architecture

```
User Browser
     ↓
Controllers (API Layer)
     ↓
AuctionService (Business Logic)
     ↓
Repositories (Data Access)
     ↓
PostgreSQL Database

[Scheduled Tasks] → Auto-award / Auto-buyout
```

### Key Components

- **Controllers**: Handle HTTP requests, authentication
- **AuctionService**: Enforces all Free Agency rules
- **Scheduled Tasks**: Background automation
- **Repositories**: Database access
- **Models**: Data entities (Auction, AuctionItem, Bid, Player, etc.)

---

## 📋 Feature Checklist

### Implemented ✅
- [x] Minimum bid enforcement ($500K / $100K)
- [x] Dynamic bid increments (time-based)
- [x] Locked-in minimums (never decrease)
- [x] Salary cap validation ($125M)
- [x] Roster limit checks (40/25)
- [x] Contract length validation (1-5 years)
- [x] Under $750K = max 2 years
- [x] 24/72 hour auction duration
- [x] 48 hour contract posting deadline
- [x] Auto-award expired auctions
- [x] Auto-buyout missed contracts
- [x] Buyout fee (50% of winning bid)
- [x] IN_SEASON vs OFF_SEASON toggle
- [x] Commissioner queue management
- [x] Released player workflow

### To Be Implemented 🚧
- [ ] Minor league salary escalation (Rule 8(c))
- [ ] Buyout deadline date tracking
- [ ] International prospect eligibility
- [ ] June draft integration
- [ ] Email notifications
- [ ] Mobile responsive UI
- [ ] Contract restructuring
- [ ] Advanced analytics

---

## 🎮 Usage Guide

### For Managers

1. **View Auctions**: Go to `/auction/view`
2. **Place Bid**: Enter amount, click "Place Bid"
3. **Monitor Bids**: See current bid and time remaining
4. **Post Contract**: After winning, select years (1-5)
5. **Buyout Option**: Choose buyout if you don't want player (50% fee)

### For Commissioners

1. **Manage Auction**: Go to `/auction/manage`
2. **Set Type**: Toggle IN_SEASON ↔ OFF_SEASON
3. **Add Players**: Select from free agents or release queue
4. **Award Players**: Manually award or wait for auto-award
5. **Monitor**: See all pending contracts and violations

---

## 🔍 Troubleshooting

### Common Issues

| Issue | Solution |
|-------|----------|
| 500 Error | Run `./fix_500_error_v2.sh` |
| Can't login | Check database is running |
| Bid rejected | Check salary cap and roster space |
| Column missing | Run database migration |
| App won't start | Check logs: `docker compose logs app` |

### Getting Help

1. **Check Documentation**: See index above
2. **View Logs**: `docker compose logs -f app`
3. **Check Database**: `./access_db.sh`
4. **Debug Mode**: Enable in `application.properties`

---

## 📊 Database Schema

### Main Tables
- `auctions` - Auction events (IN_SEASON / OFF_SEASON)
- `auction_items` - Players in auction
- `bids` - All bids placed
- `pending_contracts` - Won players awaiting contracts
- `players` - All players (free agents + owned)
- `users` - User accounts (Managers + Commissioner)
- `released_players` - Player release queue

### Key Relationships
- Player → Owner (User)
- AuctionItem → Auction
- Bid → AuctionItem
- PendingContract → AuctionItem + Player + Winner

---

## ⚙️ Configuration

### Application Properties

Located in `src/main/resources/application.properties`:

```properties
# Database
spring.datasource.url=jdbc:postgresql://localhost:5432/fantasyia
spring.jpa.hibernate.ddl-auto=update  # Auto-create new columns

# Server
server.port=8080

# Thymeleaf (hot reload for development)
spring.thymeleaf.cache=false
```

### League Settings

Configured in code (in `AuctionService` and models):

- Salary Cap: $125M
- MLB Minimum Bid: $500K
- Minor League Minimum Bid: $100K
- Major League Roster Max: 40
- Minor League Roster Max: 25
- Contract Posting Deadline: 48 hours
- Buyout Percentage: 50%

### Scheduled Task Timing

In `AuctionScheduledTasks.java`:

- Auto-award check: Every 30 minutes
- Expired contracts: Every 1 hour

---

## 🚀 Deployment

### Production Deployment

1. **Review Checklist**: Read `DEPLOYMENT_CHECKLIST.md`
2. **Run Script**: `./deploy_auction_v2.sh`
3. **Verify**: Check logs and test auction flow
4. **Monitor**: Watch for errors in first hour

### Development

```bash
# Local development (no Docker)
mvn spring-boot:run

# With auto-restart on changes
mvn spring-boot:run -Dspring.devtools.restart.enabled=true
```

---

## 🧪 Testing

### Manual Test Flow

1. **Add Player**: Commissioner adds player to auction
2. **Place Bid**: Manager places initial bid
3. **Wait Time**: Simulate time passing (or wait)
4. **Check Increment**: Verify minimum bid increased
5. **Outbid**: Another user places higher bid
6. **Award**: Wait for auto-award or manually award
7. **Post Contract**: Winner posts 1-5 year contract
8. **Verify**: Check player added to roster, salary updated

### Test Scenarios

- [ ] Bid below minimum (should reject)
- [ ] Bid over salary cap (should reject)
- [ ] Bid when roster full (should reject)
- [ ] Under $750K with 3 years (should reject)
- [ ] Wait 24 hours (should auto-award)
- [ ] Miss 48h contract deadline (should auto-buyout)
- [ ] Toggle auction type (timing should change)

---

## 📞 Support

### Resources
- Documentation files (see index above)
- Application logs: `docker compose logs -f app`
- Database access: `./access_db.sh`

### Debug Steps
1. Check logs for errors
2. Verify database connection
3. Confirm all columns exist
4. Test with simple operations first
5. Enable debug logging if needed

---

## 📝 Version History

### v2.0.0 (February 18, 2026)
- ✅ Complete Free Agency rule implementation
- ✅ AuctionService business logic layer
- ✅ Scheduled tasks for automation
- ✅ Enhanced data models
- ✅ Better error handling
- ✅ Comprehensive documentation

### v1.0.0 (Previous)
- Basic auction functionality
- Player management
- User authentication

---

## 🏆 Credits

**System**: Fantasy IA Baseball League Manager
**Version**: 2.0.0
**Date**: February 18, 2026
**Implementation**: Complete Free Agency Ruleset

---

## 🎯 Next Steps

1. **Fix 500 Error**: Run `./fix_500_error_v2.sh`
2. **Read Guides**: Check documentation files
3. **Test Auction**: Try the complete workflow
4. **Monitor**: Watch logs for issues
5. **Enjoy**: The auction system now handles everything automatically!

**Happy Bidding! ⚾💰**
