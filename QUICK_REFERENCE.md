# Quick Reference - Released Players Queue

## 🚀 Quick Start

### Deploy the Changes
```bash
chmod +x restart_app.sh
./restart_app.sh
```

### Access Points
- **Home**: http://localhost:8080
- **Manage Auction**: http://localhost:8080/auction/manage
- **pgAdmin**: http://localhost:8081 (admin@admin.com / admin)

## 📋 Feature Checklist

### For Team Owners
- ✅ Release players from My Team page
- ✅ See confirmation message
- ✅ Roster slots replaced with "Empty [Position] Slot"

### For Commissioners
- ✅ See notification badge on home page
- ✅ View pending players in yellow queue section
- ✅ Add players to auction with custom starting bid
- ✅ Reject players from queue

## 🔑 Key Endpoints

| Endpoint | Method | Access | Purpose |
|----------|--------|--------|---------|
| `/team/release-players` | POST | Owners | Release players to queue |
| `/auction/add-released-player` | POST | Commissioner | Approve and add to auction |
| `/auction/reject-released-player` | POST | Commissioner | Reject from queue |
| `/auction/manage` | GET | Commissioner | View queue |

## 📊 Database

### New Table: `released_players_queue`
Automatically created by Hibernate on first run.

### Check Data
```sql
-- Connect to database
docker exec -it fantasyia-db-1 psql -U fantasyia -d fantasyia

-- View pending releases
SELECT * FROM released_players_queue WHERE status = 'PENDING';

-- View all releases with history
SELECT player_name, position, status, released_at 
FROM released_players_queue 
ORDER BY released_at DESC;
```

## 🧪 Testing Scenarios

### Test 1: Basic Release Flow
1. Login as regular user (not commissioner)
2. Go to My Team
3. Select 2-3 players
4. Click "Release Selected Players"
5. ✅ Verify success message
6. ✅ Verify roster shows "Empty [Position] Slot"

### Test 2: Commissioner Approval
1. Login as commissioner
2. ✅ Verify badge shows count on home page
3. Click "Manage Auction"
4. ✅ Verify yellow queue section appears
5. Set starting bid (e.g., $50)
6. Click "Add to Auction"
7. ✅ Verify player appears in Active Auctions
8. Go to Auction View page
9. ✅ Verify player is available for bidding

### Test 3: Commissioner Rejection
1. Login as commissioner
2. Go to Manage Auction
3. Find player in queue
4. Click "Reject"
5. ✅ Verify player disappears from queue
6. ✅ Verify player NOT in auction

### Test 4: Multiple Commissioners
1. Release player from one account
2. Login as different commissioner
3. ✅ Verify they can also see and approve

## 🐛 Troubleshooting

### Queue Not Showing
- Check if you're logged in as COMMISSIONER
- Check if there are any PENDING releases:
  ```sql
  SELECT COUNT(*) FROM released_players_queue WHERE status = 'PENDING';
  ```

### Players Not Appearing in Auction
- Verify status changed to 'ADDED_TO_AUCTION'
- Check players table for new free agent entry
- Check auction_items table for new entry

### Build Errors
```bash
# Clean everything and rebuild
mvn clean
docker-compose down -v  # WARNING: Removes database
docker-compose up -d db
sleep 10  # Wait for DB to start
mvn package -DskipTests
docker-compose up -d
```

## 📝 Important Notes

### Data Persistence
- Queue data is stored in PostgreSQL
- Survives application restarts
- Removed only on `docker-compose down -v`

### Permission Checks
- Only users with role="COMMISSIONER" can:
  - View the queue
  - Add to auction
  - Reject players

### Player Creation
- Approved players are created as NEW entries
- Original released player data is preserved in queue
- Previous contract info is shown but not applied

## 🎨 UI Elements

### Notification Badge
- Location: Home page, "Manage Auction" button
- Color: Yellow (#ffc107)
- Shows: Count of PENDING players
- Updates: Automatically on page load

### Queue Section
- Location: Top of Auction Management page
- Color: Yellow background (#fff3cd)
- Visibility: Only shown if pending players exist
- Displays: Player details, release time, previous contract

### Action Buttons
- **Add to Auction**: Green (#28a745)
- **Reject**: Red (#dc3545)
- Both require confirmation for safety

## 🔒 Security

### Authorization
```java
// Only commissioners can access these endpoints
if (user == null || !"COMMISSIONER".equals(user.getRole())) {
    redirectAttributes.addFlashAttribute("error", "Only commissioners...");
    return "redirect:/auction/manage";
}
```

### Ownership Validation
```java
// Non-commissioners can only release their own players
for (Player player : playersToRelease) {
    if (!isCommissioner && !user.getId().equals(player.getOwnerId())) {
        redirectAttributes.addFlashAttribute("error", "You can only release...");
        return "redirect:/team";
    }
}
```

## 📈 Future Enhancements

Ideas for future improvements:
- [ ] Email notifications to commissioners
- [ ] Bulk approve/reject functionality
- [ ] Add notes/comments when rejecting
- [ ] Release history report
- [ ] Automatic approval after X days
- [ ] Filter queue by position/team

## 💡 Tips

1. **Start with test data**: Release 2-3 sample players first
2. **Check logs**: `docker-compose logs -f app` to see debug output
3. **Use pgAdmin**: Great for viewing/debugging database state
4. **Test both paths**: Try both approve and reject flows
5. **Multiple commissioners**: Verify multiple users can manage queue

## 📞 Support Commands

```bash
# View application logs
docker-compose logs -f app

# View database logs
docker-compose logs -f db

# Restart just the app
docker-compose restart app

# Check container status
docker-compose ps

# Access database directly
docker exec -it fantasyia-db-1 psql -U fantasyia -d fantasyia
```

---

**Ready to Deploy!** 🚀

Run `./restart_app.sh` and test it out!
