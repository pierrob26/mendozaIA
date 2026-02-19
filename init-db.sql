-- Initialize FantasyIA Database
-- This script runs when the PostgreSQL container starts for the first time

-- Create database if it doesn't exist (handled by POSTGRES_DB env var)
-- CREATE DATABASE IF NOT EXISTS fantasyia;

-- Switch to fantasyia database
\c fantasyia;

-- Create extensions if needed
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Set timezone
SET timezone = 'UTC';

-- Basic database configuration
ALTER DATABASE fantasyia SET timezone TO 'UTC';

-- Grant privileges
GRANT ALL PRIVILEGES ON DATABASE fantasyia TO fantasyia;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO fantasyia;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO fantasyia;

-- Log successful initialization
SELECT 'FantasyIA database initialized successfully' as status;