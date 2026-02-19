# Free Agency Auction Rules Implementation

## Overview
The auction system has been completely reworked to follow comprehensive Free Agency rules for both In-Season and Off-Season auctions.

## Auction Types

### In-Season Free Agency
- **Bidding Period**: 24 hours after first bid
- **Minimum MLB Player Bid**: $500K
- **Minimum Prospect Bid**: $100K
- **Dynamic Minimum Bid Increments**:
  - 0-8 hours since last bid: $500K for MLB / $100K for prospects
  - 8-16 hours since last bid: $1M for MLB / $250K for prospects
  - 16-24 hours since last bid: $1.5M for MLB / $500K for prospects

### Off-Season Free Agency
- **Bidding Period**: 72 hours after first bid
- **Minimum MLB Player Bid**: $500K
- **Minimum Prospect Bid**: $100K
- **Dynamic Minimum Bid Increments**:
  - 0-24 hours since last bid: $500K for MLB / $100K for prospects
  - 24-48 hours since last bid: $1M for MLB / $250K for prospects
  - 48-72 hours since last bid: $2M for MLB / $500K for prospects

## Key Features

### 1. Bidding Rules
- All bids are based on **Average Annual Salary (AAS)**
- Minimum bid increments increase based on time elapsed and **never decrease**
- Users cannot delete bids once placed
- Nominations cannot be deleted by the nominating user
- Bids that would exceed salary cap are rejected automatically

### 2. Contract Posting
- Winners have **48 hours** to post a contract after winning
- Contracts can be 1-5 years in length
- **Restrictions**:
  - Players under $750K: Maximum 2-year contracts
  - Prospects: Can receive up to 5-year deals at minor league price
  - Players after buyout deadline: Only 1-year contracts allowed

### 3. Buyout System
- If contract not posted within 48 hours: **Buyout fee = 50% of winning bid**
- Buyout fee applies against current year's cap space
- Player returns to free agency pool
- Winners can voluntarily buyout a player they won

### 4. Salary Cap & Roster Management
- **Salary Cap**: $100,000,000 per team
- **Major League Roster Limit**: 40 players
- **Minor League Roster Limit**: 25 players
- Bids that would violate cap or roster limits are rejected
- Teams have 24-48 hours (depending on auction type) to fix roster violations

### 5. Minor League Players
- Prospects signed at $500K+ AAS maintain salary in Year 1 on 40-man roster
- Salary increases by $500K each of next 2 seasons
- Example: ML Player won for $750K AAS
  - Year 1 on 40-man: $750K
  - Year 2: $1.25M
  - Year 3: $1.75M

### 6. Player Eligibility
- International prospects (midseason): Not eligible until after season completion
  - Age 21 and younger: Eligible for FYPD draft
  - Age 22 and older: Go to Off-Season Free Agency
- FYPD draft players: Not eligible during ongoing season, must be drafted in TML off-season

### 7. Rookie Status
- Rookie threshold: 130 AB or 50 IP
- Players who haven't eclipsed rookie stats have $100K minimum bids
- System tracks at-bats and innings pitched to auto-update rookie status

## New Database Entities

### Player Enhancements
- `isMinorLeaguer`: Boolean flag for prospects
- `isRookie`: Boolean flag for rookie status tracking
- `atBats`: Integer tracking at-bats for rookie threshold
- `inningsPitched`: Integer tracking IP for rookie threshold
- `isOnFortyManRoster`: Boolean for 40-man roster tracking
- `averageAnnualSalary`: Double for AAS (used in cap calculations)
- `contractYear`: Integer tracking current contract year

### UserAccount Enhancements
- `salaryCap`: Double (default $100M)
- `currentSalaryUsed`: Double tracking committed salary
- `majorLeagueRosterCount`: Integer (max 40)
- `minorLeagueRosterCount`: Integer (max 25)

### Auction Enhancements
- `auctionType`: String ("IN_SEASON" or "OFF_SEASON")

### AuctionItem Enhancements
- `lastBidTime`: Timestamp of most recent bid
- `nominatedByUserId`: User who nominated (prevents deletion)
- `isMinorLeaguer`: Boolean for applying correct bid increments
- `contractDeadline`: Timestamp for 48-hour contract posting deadline

### PendingContract (New Entity)
- Tracks players won in auction awaiting contract posting
- Enforces 48-hour deadline
- Calculates and applies buyout fees
- Validates contract length rules

## Commissioner Controls
- Toggle between In-Season and Off-Season auction types
- Add players to auction with appropriate minimum bids
- Remove players from auction (only after minimum time elapsed)
- View and manage pending contracts
- Monitor expired contracts and automatic buyout fees

## User Interface Updates
- Dynamic display of minimum next bid based on time elapsed
- Countdown timers showing time remaining in auction
- Pending contracts section showing awaiting actions
- Salary cap and roster space indicators
- Clear validation messages for failed bids

## Validation & Error Handling
- Salary cap validation on every bid
- Roster space validation (40-man vs 25-man)
- Time-based minimum increment enforcement
- Contract length validation based on winning bid amount
- Automatic handling of expired contract deadlines with buyout fees

## Implementation Notes
All monetary values are stored in millions of dollars:
- $500K = 0.5
- $1M = 1.0
- $100M = 100.0

This ensures precision and simplifies calculations throughout the system.
