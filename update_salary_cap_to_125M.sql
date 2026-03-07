-- Database update script to change salary cap from $100M to $125M for all teams
-- Run this script to update existing users in the database

-- Update all users who have salary_cap set to 100.0 (old default)
UPDATE users 
SET salary_cap = 125.0 
WHERE salary_cap = 100.0;

-- Update any users who have NULL salary cap (they will inherit the new default from code)
-- This is optional since the code default is now 125.0
-- UPDATE users SET salary_cap = 125.0 WHERE salary_cap IS NULL;

-- Verify the changes
SELECT username, role, salary_cap, current_salary_used 
FROM users 
ORDER BY username;

-- Optional: Show salary cap usage for all teams
SELECT 
    username,
    role,
    COALESCE(salary_cap, 125.0) as salary_cap,
    COALESCE(current_salary_used, 0.0) as current_salary_used,
    COALESCE(salary_cap, 125.0) - COALESCE(current_salary_used, 0.0) as available_cap_space
FROM users 
WHERE role IN ('MANAGER', 'COMMISSIONER')
ORDER BY username;