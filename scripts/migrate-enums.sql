-- Idempotent shared-enum extension for existing database volumes.
-- Fresh volumes get the full value set from init-db/02-create-enums.sql; this
-- script brings pre-Phase-6 volumes up to date without a db:reset.
-- Must run outside an explicit transaction block per ALTER TYPE semantics
-- (psql autocommit satisfies this).

ALTER TYPE public.league_enum ADD VALUE IF NOT EXISTS 'FIFA_WC';
ALTER TYPE public.league_enum ADD VALUE IF NOT EXISTS 'EPL';
ALTER TYPE public.league_enum ADD VALUE IF NOT EXISTS 'NHL';
ALTER TYPE public.league_enum ADD VALUE IF NOT EXISTS 'NCAA_HKY';

ALTER TYPE public.sport_enum ADD VALUE IF NOT EXISTS 'SOCCER';
ALTER TYPE public.sport_enum ADD VALUE IF NOT EXISTS 'HOCKEY';
