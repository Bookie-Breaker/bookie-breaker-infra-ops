-- Shared enum types created in public schema, referenced by all service schemas.
-- Values from bookie-breaker-docs/schemas/database-schemas/README.md.

CREATE TYPE league_enum AS ENUM (
    'NFL', 'NBA', 'MLB', 'NCAA_FB', 'NCAA_BB', 'NCAA_BSB'
);

CREATE TYPE market_type_enum AS ENUM (
    'SPREAD', 'TOTAL', 'MONEYLINE', 'PLAYER_PROP', 'TEAM_PROP', 'GAME_PROP', 'FUTURE', 'LIVE'
);

CREATE TYPE sport_enum AS ENUM (
    'FOOTBALL', 'BASKETBALL', 'BASEBALL'
);

CREATE TYPE bet_result_enum AS ENUM (
    'OPEN', 'WON', 'LOST', 'PUSH', 'VOID'
);
