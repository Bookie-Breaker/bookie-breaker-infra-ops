-- Per-service schemas. Each service owns its schema exclusively.
-- Cross-service data access happens via REST APIs, never direct DB queries.

CREATE SCHEMA IF NOT EXISTS lines;
CREATE SCHEMA IF NOT EXISTS predictions;
CREATE SCHEMA IF NOT EXISTS emulator;
CREATE SCHEMA IF NOT EXISTS agent;
