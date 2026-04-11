-- Sample NBA line snapshots for development testing.
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
END $$;
