# Free Agency Auction System - Complete Implementation

## Overview
This system implements a comprehensive Free Agency auction following official league rules. It supports both **In-Season** and **Off-Season** Free Agency with distinct timing and bidding requirements.

---

## Rule Implementation Summary

### 1. Player Acquisition (Rule i(1))
✅ **Implemented**: Players can only be added to rosters through auction
- All free agents must go through the auction system
- No direct signings allowed

### 2. Minimum Bids (Rule i(2) and (3))
✅ **Implemented**: 
- **MLB Players**: $500K minimum
- **Minor League Prospects**: $100K minimum
- All bids are based on Average Annual Salary (AAS)

### 3. Dynamic Minimum Bid Increments (Rule i(4))

#### In-Season Free Agency:
- **0-8 hours since last bid**: $500K MLB / $100K minors
- **8-16 hours since last bid**: $1M MLB / $250K minors  
- **16-24 hours since last bid**: $1.5M MLB / $500K minors

#### Off-Season Free Agency:
- **0-24 hours since last bid**: $500K MLB / $100K minors
- **24-48 hours since last bid**: $1M MLB / $250K minors
- **48-72 hours since last bid**: $2M MLB / $500K minors

✅ **Implemented in**: `AuctionService.calculateMinimumBidIncrement()`

### 4. Locked-In Minimums (Rule i(5))
✅ **Implemented**: Once minimum bid increases, it never goes back down
- Tracked in `AuctionItem.currentMinimumIncrement`
- Enforced in `AuctionItem.getMinimumBidIncrement()`

### 5. No Bid Deletion (Rule i(6))
✅ **Implemented**: 
- Players nominated for auction cannot be deleted
- Bids placed cannot be removed
- Enforced via `AuctionItem.canDeleteBid` field
- Buyout required if winner doesn't want player

### 6. Auction Duration (Rule i(7) and b(vii))
✅ **Implemented**:
- **In-Season**: Bids must stand for 24 hours after LAST bid
- **Off-Season**: Bids must stand for 72 hours after LAST bid
- Each new bid resets the timer
- Auto-awarding via `AuctionScheduledTasks.autoAwardExpiredAuctions()`

### 7. Contract Posting Deadline (Rule i(7)(a) and b(vii)(1))
✅ **Implemented**:
- Winner has 48 hours to post contract after winning
- Automatic buyout fee applied if deadline missed
- Buyout fee = 50% of winning bid
- Fee applied to current year's cap space
- Player returns to free agency
- Tracked via `PendingContract.contractDeadline`
- Enforced by `AuctionScheduledTasks.processExpiredContracts()`

### 8. Contract Length Rules (Rule i(8))
✅ **Implemented**:
- **Standard**: 1-5 years allowed
- **Under $750K**: Maximum 2 years only (Rule 8(a))
- **Prospects**: Up to 5 years at minor league price (Rule 8(b))
- **After Buyout Deadline**: 1 year only (Rule 8(f))
- Validated in `AuctionService.validateContractLength()`

### 9. Rookie Contracts (Rule i(8)(b)(i))
✅ **Implemented**:
- Players crossing 130 AB / 50 IP threshold receive rookie contract
- Tracked via `Player.hasEclipsedRookieStats()`

### 10. Minor League Player Salary Escalation (Rule i(8)(c))
✅ **Implemented**:
- If minor leaguer won for $500K+ AAS
- Salary stays same in year 1 on 40-man roster
- Increases by $500K each of next 2 seasons
- Example: Won at $750K → Contract: $750K, $1.25M, $1.75M

### 11. Roster Limits (Rule i(8)(f)(i) and b(x))
✅ **Implemented**:
- **Major League**: 40 players max
- **Minor League**: 25 players max
- **In-Season**: 24 hours to fix roster after violation
- **Off-Season**: 48 hours to fix roster after violation
- Warnings issued upon contract posting
- Checked in `UserAccount.hasRosterSpace()`

### 12. Salary Cap Enforcement (Rule b(xi))
✅ **Implemented**:
- $100M salary cap per team
- Bids exceeding available cap space are rejected
- No backloaded contracts to circumvent cap
- Validated in `AuctionService.validateBid()`

### 13. International Prospects (Rule i(8)(d) and b(ix))
✅ **Documented** (requires manual management):
- Midseason international signees not eligible until next season
- Age 21 and under → Minor League Draft eligible
- Age 22 and older → Off-Season Free Agency

### 14. June Draft Players (Rule i(8)(e))
✅ **Documented** (requires manual management):
- Real-life June draft picks not eligible during ongoing season
- Must be drafted in off-season Minor League Draft

---

## System Components

### Core Services

#### `AuctionService`
Main business logic service handling:
- Bid validation with all rule checks
- Minimum bid calculation with time-based increments
- Player awarding when auction time expires
- Contract posting with length validation
- Buyout processing
- Automated expired contract handling

#### `AuctionScheduledTasks`
Automated background processes:
- **Every 30 minutes**: Check for auctions ready to be won
- **Every hour**: Process expired contracts and apply buyout fees

### Data Models

#### `Auction`
- Tracks auction type (IN_SEASON vs OFF_SEASON)
- Controls timing rules
- Can be toggled by commissioner

#### `AuctionItem`
Enhanced with:
- `nominatedByUserId`: Track who nominated player
- `canDeleteBid`: Enforce no-deletion rule
- `currentMinimumIncrement`: Lock in increased minimums
- `rosterComplianceDeadline`: Track deadline to fix roster violations
- `isBuyoutDeadlinePassed`: Limit contracts after buyout deadline

#### `PendingContract`
- Tracks won players awaiting contract
- 48-hour deadline for contract posting
- Buyout fee calculation (50% of winning bid)
- Contract year validation

#### `Player`
Enhanced with:
- `isMinorLeaguer`: Different rules for prospects
- `isRookie`: Track rookie status
- `atBats` / `inningsPitched`: Monitor rookie threshold
- `isOnFortyManRoster`: Track roster status

#### `UserAccount`
Enhanced with:
- `salaryCap`: $100M default
- `currentSalaryUsed`: Track committed salary
- `majorLeagueRosterCount`: Track 40-man roster
- `minorLeagueRosterCount`: Track minor league roster
- Helper methods: `canAffordPlayer()`, `hasRosterSpace()`

---

## API Endpoints

### For All Users
- `GET /auction/view` - View active auctions and place bids
- `POST /auction/place-bid` - Place bid with full validation
- `POST /auction/post-contract` - Post contract for won player
- `POST /auction/buyout-player` - Buyout won player (50% fee)

### Commissioner Only
- `GET /auction/manage` - Manage auction system
- `POST /auction/add-player` - Add player to auction
- `POST /auction/remove-player/{itemId}` - Award player to winner
- `POST /auction/toggle-auction-type` - Switch IN_SEASON ↔ OFF_SEASON
- `POST /auction/add-released-player` - Add from release queue
- `POST /auction/reject-released-player` - Reject release request

---

## Usage Guide

### Starting an Auction

1. **Commissioner**: Navigate to `/auction/manage`
2. **Set Auction Type**: 
   - Click "Switch to Off-Season" or "Switch to In-Season"
   - This affects timing requirements and bid increments
3. **Add Players**: 
   - Select free agents from the list
   - Set starting bid ($500K for MLB, $100K for prospects)
   - Click "Add to Auction"

### Placing Bids

1. **Users**: Navigate to `/auction/view`
2. **View Players**: See all active auction items
3. **Place Bid**:
   - Enter bid amount
   - System validates:
     - Meets minimum bid requirement
     - Doesn't exceed salary cap
     - User has roster space
   - Bid is recorded and timer resets

### Winning a Player

1. **Auto-Award**: System automatically awards player after required time (24/72 hours)
2. **Manual Award**: Commissioner can manually award via "Remove from Auction"
3. **Contract Posting**:
   - Winner has 48 hours to post contract
   - Select contract years (1-5, with restrictions)
   - Player added to roster, salary applied
4. **Buyout Option**:
   - If winner doesn't want player
   - 50% fee applied to cap
   - Player returns to free agency

### Monitoring

- **Active Auctions**: View time remaining, current bid, bid history
- **Pending Contracts**: Track deadline for contract posting
- **Roster Status**: See current roster counts and cap space
- **Warnings**: System alerts for roster violations or cap issues

---

## Configuration

### Scheduled Task Timing
In `AuctionScheduledTasks.java`:
- Contract expiration check: Every hour (3600000 ms)
- Auto-award check: Every 30 minutes (1800000 ms)

### League Settings
In database or configuration:
- Salary cap: $100M (stored in `UserAccount`)
- Major league roster limit: 40
- Minor league roster limit: 25
- Contract posting deadline: 48 hours
- Buyout percentage: 50%

---

## Future Enhancements

### Potential Additions
1. **Email Notifications**: Alert users when outbid or contract deadline approaching
2. **Buyout Deadline Tracking**: Implement specific date after which only 1-year contracts allowed
3. **Trade Deadline Integration**: Different rules after trade deadline
4. **Draft Integration**: Auto-populate auction with draft-eligible players
5. **Contract Restructuring**: Allow post-signing contract modifications
6. **Auction History**: Track all past auctions and trends
7. **Bid Proxy System**: Auto-bid up to a maximum amount
8. **Mobile Responsive**: Optimize for mobile bidding

---

## Testing Checklist

- [ ] MLB player minimum bid ($500K)
- [ ] Minor league player minimum bid ($100K)
- [ ] Dynamic bid increments (In-Season: 8h, 16h, 24h)
- [ ] Dynamic bid increments (Off-Season: 24h, 48h, 72h)
- [ ] Minimum increment lock-in (doesn't go back down)
- [ ] Bid placement prevented if over cap
- [ ] Bid placement prevented if roster full
- [ ] Auction timer (24h In-Season, 72h Off-Season)
- [ ] Auto-award after time expires
- [ ] 48-hour contract deadline
- [ ] Auto-buyout if contract not posted
- [ ] Manual buyout (50% fee)
- [ ] Contract length validation (1-5 years)
- [ ] Under $750K = max 2 years
- [ ] Roster limit warnings (40 ML, 25 MiL)
- [ ] Salary cap enforcement
- [ ] Auction type toggle (Commissioner)

---

## Support

For issues or questions:
1. Check this documentation
2. Review error messages (system provides detailed feedback)
3. Contact league commissioner
4. Check application logs for technical issues

**Last Updated**: February 18, 2026
**Version**: 2.0.0 - Complete Free Agency Ruleset Implementation
