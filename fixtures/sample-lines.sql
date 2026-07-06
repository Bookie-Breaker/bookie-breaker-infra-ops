-- Sample NBA, FIFA_WC, MLB, and NFL line snapshots for development testing.
-- Uses sportsbook keys from the sportsbooks seed data.
-- These are fictional lines for testing purposes only.

DO $$
DECLARE
    dk_id UUID;
    fd_id UUID;
    pin_id UUID;
BEGIN
    SELECT id INTO dk_id FROM lines.sportsbooks WHERE key = 'draftkings';
    SELECT id INTO fd_id FROM lines.sportsbooks WHERE key = 'fanduel';
    SELECT id INTO pin_id FROM lines.sportsbooks WHERE key = 'pinnacle';

    -- Game 1: LAL vs BOS
    INSERT INTO lines.line_snapshots
        (game_external_id, sportsbook_id, league, market_type, selection, line_value, odds_american, odds_decimal, is_live, captured_at, source)
    VALUES
        ('nba_lal_bos_20260410', dk_id, 'NBA', 'SPREAD', 'LAL -3.5', -3.5, -110, 1.909, FALSE, NOW() - INTERVAL '2 hours', 'the_odds_api'),
        ('nba_lal_bos_20260410', dk_id, 'NBA', 'SPREAD', 'BOS +3.5', 3.5, -110, 1.909, FALSE, NOW() - INTERVAL '2 hours', 'the_odds_api'),
        ('nba_lal_bos_20260410', dk_id, 'NBA', 'TOTAL', 'Over 220.5', 220.5, -110, 1.909, FALSE, NOW() - INTERVAL '2 hours', 'the_odds_api'),
        ('nba_lal_bos_20260410', dk_id, 'NBA', 'TOTAL', 'Under 220.5', 220.5, -110, 1.909, FALSE, NOW() - INTERVAL '2 hours', 'the_odds_api'),
        ('nba_lal_bos_20260410', dk_id, 'NBA', 'MONEYLINE', 'LAL', NULL, -165, 1.606, FALSE, NOW() - INTERVAL '2 hours', 'the_odds_api'),
        ('nba_lal_bos_20260410', dk_id, 'NBA', 'MONEYLINE', 'BOS', NULL, 140, 2.400, FALSE, NOW() - INTERVAL '2 hours', 'the_odds_api'),

        ('nba_lal_bos_20260410', fd_id, 'NBA', 'SPREAD', 'LAL -3', -3.0, -108, 1.926, FALSE, NOW() - INTERVAL '2 hours', 'the_odds_api'),
        ('nba_lal_bos_20260410', fd_id, 'NBA', 'SPREAD', 'BOS +3', 3.0, -112, 1.893, FALSE, NOW() - INTERVAL '2 hours', 'the_odds_api'),
        ('nba_lal_bos_20260410', fd_id, 'NBA', 'TOTAL', 'Over 221', 221.0, -112, 1.893, FALSE, NOW() - INTERVAL '2 hours', 'the_odds_api'),
        ('nba_lal_bos_20260410', fd_id, 'NBA', 'TOTAL', 'Under 221', 221.0, -108, 1.926, FALSE, NOW() - INTERVAL '2 hours', 'the_odds_api'),

        ('nba_lal_bos_20260410', pin_id, 'NBA', 'SPREAD', 'LAL -3.5', -3.5, -105, 1.952, FALSE, NOW() - INTERVAL '2 hours', 'the_odds_api'),
        ('nba_lal_bos_20260410', pin_id, 'NBA', 'SPREAD', 'BOS +3.5', 3.5, -105, 1.952, FALSE, NOW() - INTERVAL '2 hours', 'the_odds_api'),

        -- Line movement: LAL line moved from -3.5 to -4
        ('nba_lal_bos_20260410', dk_id, 'NBA', 'SPREAD', 'LAL -4', -4.0, -110, 1.909, FALSE, NOW() - INTERVAL '1 hour', 'the_odds_api'),
        ('nba_lal_bos_20260410', dk_id, 'NBA', 'SPREAD', 'BOS +4', 4.0, -110, 1.909, FALSE, NOW() - INTERVAL '1 hour', 'the_odds_api'),

        -- Game 2: GSW vs MIL
        ('nba_gsw_mil_20260410', dk_id, 'NBA', 'SPREAD', 'GSW +1.5', 1.5, -110, 1.909, FALSE, NOW() - INTERVAL '3 hours', 'the_odds_api'),
        ('nba_gsw_mil_20260410', dk_id, 'NBA', 'SPREAD', 'MIL -1.5', -1.5, -110, 1.909, FALSE, NOW() - INTERVAL '3 hours', 'the_odds_api'),
        ('nba_gsw_mil_20260410', dk_id, 'NBA', 'TOTAL', 'Over 228.5', 228.5, -110, 1.909, FALSE, NOW() - INTERVAL '3 hours', 'the_odds_api'),
        ('nba_gsw_mil_20260410', dk_id, 'NBA', 'TOTAL', 'Under 228.5', 228.5, -110, 1.909, FALSE, NOW() - INTERVAL '3 hours', 'the_odds_api'),
        ('nba_gsw_mil_20260410', dk_id, 'NBA', 'MONEYLINE', 'GSW', NULL, 120, 2.200, FALSE, NOW() - INTERVAL '3 hours', 'the_odds_api'),
        ('nba_gsw_mil_20260410', dk_id, 'NBA', 'MONEYLINE', 'MIL', NULL, -140, 1.714, FALSE, NOW() - INTERVAL '3 hours', 'the_odds_api');

    -- Game 3 (FIFA_WC): France vs Brazil, 2026-07-14 semifinal.
    -- line_snapshots has no side column: lines-service derives side at read
    -- time (ADR-027) — 'Draw' maps to DRAW directly, while HOME/AWAY come
    -- from prefix-matching this lines.games row (ingestion maintains it in
    -- production; seeded here so the three-way market resolves fully).
    INSERT INTO lines.games (game_external_id, league, home_team, away_team, commence_time)
    VALUES ('fifawc_fra_bra_20260714', 'FIFA_WC', 'France', 'Brazil', TIMESTAMPTZ '2026-07-14 19:00:00+00')
    ON CONFLICT (game_external_id) DO NOTHING;

    INSERT INTO lines.line_snapshots
        (game_external_id, sportsbook_id, league, market_type, selection, line_value, odds_american, odds_decimal, is_live, captured_at, source)
    VALUES
        -- Three-way moneyline: HOME / AWAY / DRAW (ADR-027)
        ('fifawc_fra_bra_20260714', dk_id, 'FIFA_WC', 'MONEYLINE', 'France', NULL, 145, 2.450, FALSE, NOW() - INTERVAL '1 hour', 'the_odds_api'),
        ('fifawc_fra_bra_20260714', dk_id, 'FIFA_WC', 'MONEYLINE', 'Brazil', NULL, 190, 2.900, FALSE, NOW() - INTERVAL '1 hour', 'the_odds_api'),
        ('fifawc_fra_bra_20260714', dk_id, 'FIFA_WC', 'MONEYLINE', 'Draw', NULL, 220, 3.200, FALSE, NOW() - INTERVAL '1 hour', 'the_odds_api'),

        -- Total goals (settles on the 90-minute score, ADR-027)
        ('fifawc_fra_bra_20260714', dk_id, 'FIFA_WC', 'TOTAL', 'Over 2.5', 2.5, -115, 1.870, FALSE, NOW() - INTERVAL '1 hour', 'the_odds_api'),
        ('fifawc_fra_bra_20260714', dk_id, 'FIFA_WC', 'TOTAL', 'Under 2.5', 2.5, -105, 1.952, FALSE, NOW() - INTERVAL '1 hour', 'the_odds_api'),

        -- Goal line (soccer spread)
        ('fifawc_fra_bra_20260714', pin_id, 'FIFA_WC', 'SPREAD', 'France -1.5', -1.5, 180, 2.800, FALSE, NOW() - INTERVAL '1 hour', 'the_odds_api'),
        ('fifawc_fra_bra_20260714', pin_id, 'FIFA_WC', 'SPREAD', 'Brazil +1.5', 1.5, -220, 1.455, FALSE, NOW() - INTERVAL '1 hour', 'the_odds_api');

    -- Game 4 (MLB): New York Yankees vs Los Angeles Dodgers, 2026-07-12.
    -- line_snapshots has no side column: lines-service derives side at read
    -- time (ADR-027) — HOME/AWAY come from prefix-matching this lines.games
    -- row (ingestion maintains it in production; seeded here so the
    -- moneyline market resolves fully).
    INSERT INTO lines.games (game_external_id, league, home_team, away_team, commence_time)
    VALUES ('mlb_nyy_lad_20260712', 'MLB', 'New York Yankees', 'Los Angeles Dodgers', TIMESTAMPTZ '2026-07-12 23:00:00+00')
    ON CONFLICT (game_external_id) DO NOTHING;

    INSERT INTO lines.line_snapshots
        (game_external_id, sportsbook_id, league, market_type, selection, line_value, odds_american, odds_decimal, is_live, captured_at, source)
    VALUES
        -- Two-way moneyline: HOME / AWAY
        ('mlb_nyy_lad_20260712', dk_id, 'MLB', 'MONEYLINE', 'New York Yankees', NULL, -130, 1.769, FALSE, NOW() - INTERVAL '1 hour', 'the_odds_api'),
        ('mlb_nyy_lad_20260712', dk_id, 'MLB', 'MONEYLINE', 'Los Angeles Dodgers', NULL, 110, 2.100, FALSE, NOW() - INTERVAL '1 hour', 'the_odds_api'),

        -- Total runs
        ('mlb_nyy_lad_20260712', dk_id, 'MLB', 'TOTAL', 'Over 8.5', 8.5, -110, 1.909, FALSE, NOW() - INTERVAL '1 hour', 'the_odds_api'),
        ('mlb_nyy_lad_20260712', dk_id, 'MLB', 'TOTAL', 'Under 8.5', 8.5, -110, 1.909, FALSE, NOW() - INTERVAL '1 hour', 'the_odds_api'),

        -- Run line (baseball spread)
        ('mlb_nyy_lad_20260712', pin_id, 'MLB', 'SPREAD', 'New York Yankees -1.5', -1.5, 140, 2.400, FALSE, NOW() - INTERVAL '1 hour', 'the_odds_api'),
        ('mlb_nyy_lad_20260712', pin_id, 'MLB', 'SPREAD', 'Los Angeles Dodgers +1.5', 1.5, -165, 1.606, FALSE, NOW() - INTERVAL '1 hour', 'the_odds_api');

    -- Game 5 (NFL): Kansas City Chiefs vs Buffalo Bills, 2026-09-13 week 1.
    -- line_snapshots has no side column: lines-service derives side at read
    -- time (ADR-027) — HOME/AWAY come from prefix-matching this lines.games
    -- row (ingestion maintains it in production; seeded here so the
    -- moneyline market resolves fully).
    INSERT INTO lines.games (game_external_id, league, home_team, away_team, commence_time)
    VALUES ('nfl_kc_buf_20260913', 'NFL', 'Kansas City Chiefs', 'Buffalo Bills', TIMESTAMPTZ '2026-09-13 17:00:00+00')
    ON CONFLICT (game_external_id) DO NOTHING;

    INSERT INTO lines.line_snapshots
        (game_external_id, sportsbook_id, league, market_type, selection, line_value, odds_american, odds_decimal, is_live, captured_at, source)
    VALUES
        -- Two-way moneyline: HOME / AWAY
        ('nfl_kc_buf_20260913', dk_id, 'NFL', 'MONEYLINE', 'Kansas City Chiefs', NULL, -125, 1.800, FALSE, NOW() - INTERVAL '1 hour', 'the_odds_api'),
        ('nfl_kc_buf_20260913', dk_id, 'NFL', 'MONEYLINE', 'Buffalo Bills', NULL, 105, 2.050, FALSE, NOW() - INTERVAL '1 hour', 'the_odds_api'),

        -- Total points
        ('nfl_kc_buf_20260913', dk_id, 'NFL', 'TOTAL', 'Over 47.5', 47.5, -110, 1.909, FALSE, NOW() - INTERVAL '1 hour', 'the_odds_api'),
        ('nfl_kc_buf_20260913', dk_id, 'NFL', 'TOTAL', 'Under 47.5', 47.5, -110, 1.909, FALSE, NOW() - INTERVAL '1 hour', 'the_odds_api'),

        -- Point spread
        ('nfl_kc_buf_20260913', pin_id, 'NFL', 'SPREAD', 'Kansas City Chiefs -2.5', -2.5, -110, 1.909, FALSE, NOW() - INTERVAL '1 hour', 'the_odds_api'),
        ('nfl_kc_buf_20260913', pin_id, 'NFL', 'SPREAD', 'Buffalo Bills +2.5', 2.5, -110, 1.909, FALSE, NOW() - INTERVAL '1 hour', 'the_odds_api');
END $$;
