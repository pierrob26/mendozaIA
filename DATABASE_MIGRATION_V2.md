# Database Migration for Free Agency System v2.0

## Overview
This migration adds new fields to support the comprehensive Free Agency auction system with all league rules.

---

## Required Schema Updates

### 1. AuctionItem Table Updates

Add the following columns to `auction_items` table:

```sql
-- Track if bid can be deleted (Rule 6: Cannot delete nominations/bids)
ALTER TABLE auction_items 
ADD COLUMN can_delete_bid BOOLEAN DEFAULT true;

-- Track roster compliance deadline (24h in-season, 48h off-season)
ALTER TABLE auction_items 
ADD COLUMN roster_compliance_deadline TIMESTAMP;

-- Track if after buyout deadline (affects contract length)
ALTER TABLE auction_items 
ADD COLUMN is_buyout_deadline_passed BOOLEAN DEFAULT false;

-- Track locked-in minimum increment (Rule 5: Once increased, doesn't go back down)
ALTER TABLE auction_items 
ADD COLUMN current_minimum_increment DOUBLE PRECISION DEFAULT 0.0;
```

### 2. Player Table Updates (if not already present)

Ensure these columns exist in `players` table:

```sql
-- Track if player is a minor leaguer
ALTER TABLE players 
ADD COLUMN is_minor_leaguer BOOLEAN DEFAULT false;

-- Track if player is a rookie (under 130 AB / 50 IP)
ALTER TABLE players 
ADD COLUMN is_rookie BOOLEAN DEFAULT false;

-- Track at-bats for rookie status
ALTER TABLE players 
ADD COLUMN at_bats INTEGER DEFAULT 0;

-- Track innings pitched for rookie status
ALTER TABLE players 
ADD COLUMN innings_pitched INTEGER DEFAULT 0;

-- Track if on 40-man roster
ALTER TABLE players 
ADD COLUMN is_on_forty_man_roster BOOLEAN DEFAULT false;

-- Track current year of contract
ALTER TABLE players 
ADD COLUMN contract_year INTEGER DEFAULT 0;
```

### 3. UserAccount Table Updates (if not already present)

Ensure these columns exist in `users` table:

```sql
-- Salary cap ($125M default)
ALTER TABLE users 
ADD COLUMN salary_cap DOUBLE PRECISION DEFAULT 125.0;

-- Current salary used
ALTER TABLE users 
ADD COLUMN current_salary_used DOUBLE PRECISION DEFAULT 0.0;

-- Major league roster count (max 40)
ALTER TABLE users 
ADD COLUMN major_league_roster_count INTEGER DEFAULT 0;

-- Minor league roster count (max 25)
ALTER TABLE users 
ADD COLUMN minor_league_roster_count INTEGER DEFAULT 0;
```

### 4. Auction Table Updates (if not already present)

Ensure these columns exist in `auctions` table:

```sql
-- Track auction type (IN_SEASON vs OFF_SEASON)
ALTER TABLE auctions 
ADD COLUMN auction_type VARCHAR(20) DEFAULT 'IN_SEASON';
```

---

## Data Migration Scripts

### Update Existing Auction Items

```sql
-- Set can_delete_bid to false for items with bids
UPDATE auction_items 
SET can_delete_bid = false 
WHERE first_bid_time IS NOT NULL;

-- Set can_delete_bid to false for nominated items
UPDATE auction_items 
SET can_delete_bid = false 
WHERE nominated_by_user_id IS NOT NULL;

-- Initialize current_minimum_increment based on time elapsed
UPDATE auction_items 
SET current_minimum_increment = 
    CASE 
        WHEN last_bid_time IS NULL THEN 0.0
        WHEN is_minor_leaguer = true THEN
            CASE 
                WHEN EXTRACT(EPOCH FROM (NOW() - last_bid_time))/3600 >= 16 THEN 0.5
                WHEN EXTRACT(EPOCH FROM (NOW() - last_bid_time))/3600 >= 8 THEN 0.25
                ELSE 0.1
            END
        ELSE
            CASE 
                WHEN EXTRACT(EPOCH FROM (NOW() - last_bid_time))/3600 >= 16 THEN 1.5
                WHEN EXTRACT(EPOCH FROM (NOW() - last_bid_time))/3600 >= 8 THEN 1.0
                ELSE 0.5
            END
    END
WHERE last_bid_time IS NOT NULL;
```

### Initialize User Accounts

```sql
-- Set default salary cap for existing users
UPDATE users 
SET salary_cap = 125.0 
WHERE salary_cap IS NULL;

-- Calculate current salary used from existing players
UPDATE users u
SET current_salary_used = (
    SELECT COALESCE(SUM(average_annual_salary), 0.0)
    FROM players 
    WHERE owner_id = u.id
)
WHERE current_salary_used IS NULL;

-- Calculate major league roster count
UPDATE users u
SET major_league_roster_count = (
    SELECT COUNT(*)
    FROM players 
    WHERE owner_id = u.id 
    AND (is_minor_leaguer = false OR is_minor_leaguer IS NULL)
)
WHERE major_league_roster_count IS NULL;

-- Calculate minor league roster count
UPDATE users u
SET minor_league_roster_count = (
    SELECT COUNT(*)
    FROM players 
    WHERE owner_id = u.id 
    AND is_minor_leaguer = true
)
WHERE minor_league_roster_count IS NULL;
```

### Update Player Rookie Status

```sql
-- Mark players as rookies if under thresholds
UPDATE players 
SET is_rookie = true 
WHERE (at_bats < 130 OR at_bats IS NULL) 
  AND (innings_pitched < 50 OR innings_pitched IS NULL)
  AND contract_year <= 1;
```

---

## Verification Queries

### Check AuctionItem Updates

```sql
-- Verify all auction items have required fields
SELECT 
    COUNT(*) as total_items,
    COUNT(can_delete_bid) as has_can_delete,
    COUNT(current_minimum_increment) as has_min_increment
FROM auction_items;

-- View items that cannot be deleted
SELECT 
    id, 
    player_id, 
    can_delete_bid, 
    nominated_by_user_id,
    first_bid_time
FROM auction_items 
WHERE can_delete_bid = false;
```

### Check User Account Updates

```sql
-- Verify all users have salary/roster tracking
SELECT 
    username,
    salary_cap,
    current_salary_used,
    major_league_roster_count,
    minor_league_roster_count,
    (salary_cap - current_salary_used) as available_cap
FROM users
ORDER BY username;

-- Identify users over roster limits
SELECT 
    username,
    major_league_roster_count,
    minor_league_roster_count
FROM users
WHERE major_league_roster_count > 40 
   OR minor_league_roster_count > 25;
```

### Check Player Updates

```sql
-- View rookie status distribution
SELECT 
    is_rookie,
    COUNT(*) as player_count
FROM players
GROUP BY is_rookie;

-- View minor leaguer distribution
SELECT 
    is_minor_leaguer,
    COUNT(*) as player_count
FROM players
GROUP BY is_minor_leaguer;
```

---

## Rollback Instructions

If you need to rollback the changes:

```sql
-- Rollback AuctionItem changes
ALTER TABLE auction_items DROP COLUMN IF EXISTS can_delete_bid;
ALTER TABLE auction_items DROP COLUMN IF EXISTS roster_compliance_deadline;
ALTER TABLE auction_items DROP COLUMN IF EXISTS is_buyout_deadline_passed;
ALTER TABLE auction_items DROP COLUMN IF EXISTS current_minimum_increment;

-- Rollback Player changes
ALTER TABLE players DROP COLUMN IF EXISTS is_minor_leaguer;
ALTER TABLE players DROP COLUMN IF EXISTS is_rookie;
ALTER TABLE players DROP COLUMN IF EXISTS at_bats;
ALTER TABLE players DROP COLUMN IF EXISTS innings_pitched;
ALTER TABLE players DROP COLUMN IF EXISTS is_on_forty_man_roster;
ALTER TABLE players DROP COLUMN IF EXISTS contract_year;

-- Rollback UserAccount changes
ALTER TABLE users DROP COLUMN IF EXISTS salary_cap;
ALTER TABLE users DROP COLUMN IF EXISTS current_salary_used;
ALTER TABLE users DROP COLUMN IF EXISTS major_league_roster_count;
ALTER TABLE users DROP COLUMN IF EXISTS minor_league_roster_count;

-- Rollback Auction changes
ALTER TABLE auctions DROP COLUMN IF EXISTS auction_type;
```

---

## Running the Migration

### Option 1: Spring Boot Auto-Migration (Recommended)

If using Spring Boot with Hibernate auto-DDL:

1. Ensure `application.properties` has:
   ```properties
   spring.jpa.hibernate.ddl-auto=update
   ```

2. Restart the application. Hibernate will automatically add the new columns.

3. Run the data migration scripts manually to populate values.

### Option 2: Manual Migration

1. Connect to your PostgreSQL database:
   ```bash
   ./access_db.sh
   ```

2. Run each ALTER TABLE statement one at a time

3. Run the data migration scripts

4. Run verification queries to confirm success

### Option 3: Migration Script

Create a file `migrate_v2.sql` with all the ALTER TABLE statements, then:

```bash
psql -h localhost -p 5433 -U fantasyia -d fantasyia_db -f migrate_v2.sql
```

---

## Post-Migration Steps

1. **Restart Application**: Ensure Spring Boot picks up new schema
2. **Verify Scheduled Tasks**: Check logs for automated task execution
3. **Test Auction Flow**: 
   - Place a bid
   - Check minimum increment calculation
   - Verify salary cap enforcement
   - Test contract posting
4. **Monitor Logs**: Watch for any errors related to new fields

---

## Troubleshooting

### Column Already Exists Error
If you get "column already exists" errors:
```sql
-- Check which columns exist
SELECT column_name 
FROM information_schema.columns 
WHERE table_name = 'auction_items';
```

### Null Value Errors
If you get null constraint violations:
```sql
-- Set default values for any nulls
UPDATE auction_items SET can_delete_bid = true WHERE can_delete_bid IS NULL;
UPDATE auction_items SET current_minimum_increment = 0.0 WHERE current_minimum_increment IS NULL;
```

### Type Mismatch Errors
Ensure column types match Java entity definitions:
- `BOOLEAN` for Boolean fields
- `DOUBLE PRECISION` for Double fields
- `INTEGER` for Integer fields
- `TIMESTAMP` for LocalDateTime fields

---

**Migration Version**: 2.0.0
**Date**: February 18, 2026
**Tested On**: PostgreSQL 13+
