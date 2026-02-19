-- Optional SQL script to set default values for existing data
-- Run this AFTER the application has started and added the new columns

-- This is OPTIONAL - the application will work without it due to safe defaults in getters

-- Update existing users with default values
UPDATE users 
SET 
    salary_cap = 125.0,
    current_salary_used = 0.0,
    major_league_roster_count = 0,
    minor_league_roster_count = 0
WHERE salary_cap IS NULL;

-- Update existing players with default values
UPDATE players 
SET 
    is_minor_leaguer = false,
    is_rookie = false,
    at_bats = 0,
    innings_pitched = 0,
    is_on_forty_man_roster = false,
    contract_year = 0
WHERE is_minor_leaguer IS NULL;

-- Update existing auctions with default type
UPDATE auctions 
SET auction_type = 'IN_SEASON'
WHERE auction_type IS NULL;

-- Update existing auction items
UPDATE auction_items 
SET is_minor_leaguer = false
WHERE is_minor_leaguer IS NULL;

-- Calculate current salary used for existing teams (if you have player contracts)
UPDATE users u
SET current_salary_used = (
    SELECT COALESCE(SUM(COALESCE(p.average_annual_salary, p.contract_amount / NULLIF(p.contract_length, 0), 0)), 0)
    FROM players p
    WHERE p.owner_id = u.id
)
WHERE current_salary_used = 0.0 OR current_salary_used IS NULL;

-- Calculate roster counts for existing teams
UPDATE users u
SET major_league_roster_count = (
    SELECT COUNT(*)
    FROM players p
    WHERE p.owner_id = u.id 
      AND (COALESCE(p.is_on_forty_man_roster, false) = true OR COALESCE(p.is_minor_leaguer, false) = false)
)
WHERE major_league_roster_count = 0 OR major_league_roster_count IS NULL;

UPDATE users u
SET minor_league_roster_count = (
    SELECT COUNT(*)
    FROM players p
    WHERE p.owner_id = u.id 
      AND COALESCE(p.is_minor_leaguer, false) = true 
      AND COALESCE(p.is_on_forty_man_roster, false) = false
)
WHERE minor_league_roster_count = 0 OR minor_league_roster_count IS NULL;

-- Set average annual salary for existing players if not set
UPDATE players
SET average_annual_salary = contract_amount / NULLIF(contract_length, 0)
WHERE average_annual_salary IS NULL 
  AND contract_amount IS NOT NULL 
  AND contract_length IS NOT NULL
  AND contract_length > 0;

-- For players without contract length, set AAS to contract amount
UPDATE players
SET average_annual_salary = contract_amount
WHERE average_annual_salary IS NULL 
  AND contract_amount IS NOT NULL
  AND (contract_length IS NULL OR contract_length = 0);

COMMIT;

-- Verify the updates
SELECT 'Users with null salary cap:' as check_type, COUNT(*) as count FROM users WHERE salary_cap IS NULL
UNION ALL
SELECT 'Players with null is_minor_leaguer:', COUNT(*) FROM players WHERE is_minor_leaguer IS NULL
UNION ALL
SELECT 'Auctions with null auction_type:', COUNT(*) FROM auctions WHERE auction_type IS NULL
UNION ALL
SELECT 'Auction items with null is_minor_leaguer:', COUNT(*) FROM auction_items WHERE is_minor_leaguer IS NULL;
