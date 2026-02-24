-- Query to find all users in the database
SELECT 
    id,
    username,
    role,
    salary_cap,
    current_salary_used,
    major_league_roster_count,
    minor_league_roster_count,
    LEFT(password, 10) || '...' as password_preview
FROM users
ORDER BY id;
