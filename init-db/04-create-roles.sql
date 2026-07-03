-- Per-service database roles with schema-scoped access.
-- Each role has full access to its own schema and read access to public (for shared enums).

-- lines-service role
CREATE ROLE lines_svc WITH LOGIN PASSWORD 'localdev';
GRANT CONNECT ON DATABASE bookiebreaker TO lines_svc;
GRANT USAGE ON SCHEMA public TO lines_svc;
GRANT ALL PRIVILEGES ON SCHEMA lines TO lines_svc;
ALTER DEFAULT PRIVILEGES IN SCHEMA lines GRANT ALL ON TABLES TO lines_svc;
ALTER DEFAULT PRIVILEGES IN SCHEMA lines GRANT ALL ON SEQUENCES TO lines_svc;

-- prediction-engine role
CREATE ROLE predictions_svc WITH LOGIN PASSWORD 'localdev';
GRANT CONNECT ON DATABASE bookiebreaker TO predictions_svc;
GRANT USAGE ON SCHEMA public TO predictions_svc;
GRANT ALL PRIVILEGES ON SCHEMA predictions TO predictions_svc;
ALTER DEFAULT PRIVILEGES IN SCHEMA predictions GRANT ALL ON TABLES TO predictions_svc;
ALTER DEFAULT PRIVILEGES IN SCHEMA predictions GRANT ALL ON SEQUENCES TO predictions_svc;

-- bookie-emulator role
CREATE ROLE emulator_svc WITH LOGIN PASSWORD 'localdev';
GRANT CONNECT ON DATABASE bookiebreaker TO emulator_svc;
GRANT USAGE ON SCHEMA public TO emulator_svc;
GRANT ALL PRIVILEGES ON SCHEMA emulator TO emulator_svc;
ALTER DEFAULT PRIVILEGES IN SCHEMA emulator GRANT ALL ON TABLES TO emulator_svc;
ALTER DEFAULT PRIVILEGES IN SCHEMA emulator GRANT ALL ON SEQUENCES TO emulator_svc;

-- Grant enum type usage to all service roles
GRANT USAGE ON TYPE league_enum TO lines_svc, predictions_svc, emulator_svc;
GRANT USAGE ON TYPE market_type_enum TO lines_svc, predictions_svc, emulator_svc;
GRANT USAGE ON TYPE sport_enum TO lines_svc, predictions_svc, emulator_svc;
GRANT USAGE ON TYPE bet_result_enum TO lines_svc, predictions_svc, emulator_svc;
