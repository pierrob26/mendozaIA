# Database Migration Guide for Free Agency Auction System

## Overview
This guide outlines the database changes needed to support the new Free Agency auction rules.

## Required Database Changes

### 1. Update `players` table
```sql
-- Add new columns for player tracking
ALTER TABLE players ADD COLUMN average_annual_salary DOUBLE;
ALTER TABLE players ADD COLUMN is_minor_leaguer BOOLEAN NOT NULL DEFAULT FALSE;
ALTER TABLE players ADD COLUMN is_rookie BOOLEAN NOT NULL DEFAULT FALSE;
ALTER TABLE players ADD COLUMN at_bats INTEGER DEFAULT 0;
ALTER TABLE players ADD COLUMN innings_pitched INTEGER DEFAULT 0;
ALTER TABLE players ADD COLUMN is_on_forty_man_roster BOOLEAN NOT NULL DEFAULT FALSE;
ALTER TABLE players ADD COLUMN contract_year INTEGER DEFAULT 0;

-- Update existing players to have AAS equal to contract amount divided by length
UPDATE players 
SET average_annual_salary = contract_amount / COALESCE(NULLIF(contract_length, 0), 1)
WHERE contract_amount IS NOT NULL;
```

### 2. Update `users` table
```sql
-- Add salary cap and roster tracking
ALTER TABLE users ADD COLUMN salary_cap DOUBLE NOT NULL DEFAULT 125.0;
ALTER TABLE users ADD COLUMN current_salary_used DOUBLE NOT NULL DEFAULT 0.0;
ALTER TABLE users ADD COLUMN major_league_roster_count INTEGER NOT NULL DEFAULT 0;
ALTER TABLE users ADD COLUMN minor_league_roster_count INTEGER NOT NULL DEFAULT 0;

-- Calculate current salary used for existing teams
UPDATE users u
SET current_salary_used = (
    SELECT COALESCE(SUM(p.average_annual_salary), 0)
    FROM players p
    WHERE p.owner_id = u.id
);

-- Calculate roster counts
UPDATE users u
SET major_league_roster_count = (
    SELECT COUNT(*)
    FROM players p
    WHERE p.owner_id = u.id AND (p.is_on_forty_man_roster = TRUE OR p.is_minor_leaguer = FALSE)
);

UPDATE users u
SET minor_league_roster_count = (
    SELECT COUNT(*)
    FROM players p
    WHERE p.owner_id = u.id AND p.is_minor_leaguer = TRUE AND p.is_on_forty_man_roster = FALSE
);
```

### 3. Update `auctions` table
```sql
-- Add auction type field
ALTER TABLE auctions ADD COLUMN auction_type VARCHAR(20) NOT NULL DEFAULT 'IN_SEASON';

-- Update existing auctions
UPDATE auctions SET auction_type = 'IN_SEASON' WHERE auction_type IS NULL;
```

### 4. Update `auction_items` table
```sql
-- Add new tracking fields
ALTER TABLE auction_items ADD COLUMN last_bid_time TIMESTAMP;
ALTER TABLE auction_items ADD COLUMN nominated_by_user_id BIGINT;
ALTER TABLE auction_items ADD COLUMN is_minor_leaguer BOOLEAN NOT NULL DEFAULT FALSE;
ALTER TABLE auction_items ADD COLUMN contract_deadline TIMESTAMP;

-- Update starting bids for existing items
UPDATE auction_items SET starting_bid = 0.5 WHERE starting_bid = 1.0;
```

### 5. Create `pending_contracts` table
```sql
CREATE TABLE pending_contracts (
    id BIGSERIAL PRIMARY KEY,
    auction_item_id BIGINT NOT NULL,
    player_id BIGINT NOT NULL,
    winner_id BIGINT NOT NULL,
    winning_bid DOUBLE PRECISION NOT NULL,
    won_time TIMESTAMP NOT NULL,
    contract_deadline TIMESTAMP NOT NULL,
    contract_years INTEGER,
    status VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    buyout_fee DOUBLE PRECISION,
    is_minor_leaguer BOOLEAN NOT NULL DEFAULT FALSE,
    FOREIGN KEY (auction_item_id) REFERENCES auction_items(id),
    FOREIGN KEY (player_id) REFERENCES players(id),
    FOREIGN KEY (winner_id) REFERENCES users(id)
);

CREATE INDEX idx_pending_contracts_winner ON pending_contracts(winner_id);
CREATE INDEX idx_pending_contracts_status ON pending_contracts(status);
CREATE INDEX idx_pending_contracts_deadline ON pending_contracts(contract_deadline);
```

## Data Conversion Notes

### Monetary Values
All monetary values are stored in millions of dollars for precision:
- $500,000 → 0.5
- $1,000,000 → 1.0
- $125,000,000 → 125.0

If your existing data uses different units, you'll need to convert:
```sql
-- If existing data is in actual dollars
UPDATE players SET contract_amount = contract_amount / 1000000.0;
UPDATE players SET average_annual_salary = average_annual_salary / 1000000.0;
UPDATE auction_items SET starting_bid = starting_bid / 1000000.0;
UPDATE auction_items SET current_bid = current_bid / 1000000.0;
```

### Player Classification
After migration, review and classify your players:
```sql
-- Mark prospects/minor leaguers
UPDATE players 
SET is_minor_leaguer = TRUE 
WHERE position IN ('P', 'C', '1B', '2B', '3B', 'SS', 'OF') 
  AND /* your criteria for minor leaguers */;

-- Mark rookies who haven't eclipsed thresholds
UPDATE players 
SET is_rookie = TRUE 
WHERE at_bats < 130 AND innings_pitched < 50;
```

## Rollback Plan
If you need to rollback the changes:

```sql
-- Drop new table
DROP TABLE IF EXISTS pending_contracts;

-- Remove new columns from existing tables
ALTER TABLE auction_items DROP COLUMN IF EXISTS last_bid_time;
ALTER TABLE auction_items DROP COLUMN IF EXISTS nominated_by_user_id;
ALTER TABLE auction_items DROP COLUMN IF EXISTS is_minor_leaguer;
ALTER TABLE auction_items DROP COLUMN IF EXISTS contract_deadline;

ALTER TABLE auctions DROP COLUMN IF EXISTS auction_type;

ALTER TABLE users DROP COLUMN IF EXISTS salary_cap;
ALTER TABLE users DROP COLUMN IF EXISTS current_salary_used;
ALTER TABLE users DROP COLUMN IF EXISTS major_league_roster_count;
ALTER TABLE users DROP COLUMN IF EXISTS minor_league_roster_count;

ALTER TABLE players DROP COLUMN IF EXISTS average_annual_salary;
ALTER TABLE players DROP COLUMN IF EXISTS is_minor_leaguer;
ALTER TABLE players DROP COLUMN IF EXISTS is_rookie;
ALTER TABLE players DROP COLUMN IF EXISTS at_bats;
ALTER TABLE players DROP COLUMN IF EXISTS innings_pitched;
ALTER TABLE players DROP COLUMN IF EXISTS is_on_forty_man_roster;
ALTER TABLE players DROP COLUMN IF EXISTS contract_year;
```

## Validation Queries

After migration, run these queries to validate data integrity:

```sql
-- Check that all players have AAS set
SELECT COUNT(*) FROM players WHERE owner_id IS NOT NULL AND average_annual_salary IS NULL;

-- Verify salary cap calculations
SELECT u.username, u.current_salary_used, SUM(p.average_annual_salary) as calculated
FROM users u
LEFT JOIN players p ON p.owner_id = u.id
GROUP BY u.id, u.username, u.current_salary_used
HAVING u.current_salary_used != COALESCE(SUM(p.average_annual_salary), 0);

-- Check roster counts
SELECT u.username, u.major_league_roster_count, COUNT(p.id) as actual
FROM users u
LEFT JOIN players p ON p.owner_id = u.id AND (p.is_on_forty_man_roster = TRUE OR p.is_minor_leaguer = FALSE)
GROUP BY u.id, u.username, u.major_league_roster_count;

-- Verify no one is over salary cap
SELECT username, current_salary_used, salary_cap, (current_salary_used - salary_cap) as over_cap
FROM users
WHERE current_salary_used > salary_cap;
```

## JPA/Hibernate Auto-DDL
If you're using Spring Boot with `spring.jpa.hibernate.ddl-auto=update`, the schema changes will be applied automatically when you restart the application. However, you'll still need to run the data conversion queries manually.

## Recommended Migration Process
1. **Backup your database** before making any changes
2. Stop the application
3. Run the ALTER TABLE statements
4. Run the CREATE TABLE statements
5. Run the data conversion UPDATE statements
6. Run the validation queries
7. Deploy the new application code
8. Test thoroughly with a few test auctions
9. Monitor logs for any errors

## Support for Existing Auctions
Existing active auctions will continue to work, but:
- They will default to "IN_SEASON" type
- Minimum bid increments will apply to new bids
- Old bids without `last_bid_time` will be treated as if they just happened
- Consider completing or canceling old auctions before the migration
