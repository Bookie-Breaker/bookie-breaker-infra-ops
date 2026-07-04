-- Sample paper bets, grades, and bankroll history for development testing.
-- Fictional bets for testing only. Graded games are in the past; the OPEN
-- bets reference the same game_external_ids as sample-lines.sql so CLV and
-- odds lookups against seeded lines data resolve.
--
-- Idempotent: unique keys (idempotency_key, bet_id, snapshot id) make
-- re-running the seed a no-op.

-- ── Graded bets (6 WON, 4 LOST, 1 PUSH) ────────────────────────────────

INSERT INTO emulator.paper_bets
    (id, game_id, game_external_id, league, market_type, selection, side, line_value,
     sportsbook_key, odds_american, odds_decimal, stake, predicted_probability,
     edge_at_placement, kelly_fraction, reasoning, idempotency_key, game_start_at,
     status, placed_at, graded_at)
VALUES
    ('a0000001-0000-4000-8000-000000000001', '10000001-0000-5000-8000-000000000001', 'nba_lal_den_20260620', 'NBA', 'SPREAD', 'LAL -3.5', 'HOME', -3.5,
     'draftkings', -110, 1.9091, 1.5, 0.5620, 0.0384, 0.0364, 'Home rest advantage; opponent on back-to-back.', 'seed-bet-001', NOW() - INTERVAL '14 days',
     'WON', NOW() - INTERVAL '14 days 6 hours', NOW() - INTERVAL '13 days 21 hours'),
    ('a0000001-0000-4000-8000-000000000002', '10000001-0000-5000-8000-000000000002', 'nba_bos_mia_20260621', 'NBA', 'TOTAL', 'Over 224.5', 'OVER', 224.5,
     'fanduel', -108, 1.9259, 1.2, 0.5510, 0.0318, 0.0289, 'Both teams top-10 pace; simulation projects 228.', 'seed-bet-002', NOW() - INTERVAL '13 days',
     'LOST', NOW() - INTERVAL '13 days 5 hours', NOW() - INTERVAL '12 days 20 hours'),
    ('a0000001-0000-4000-8000-000000000003', '10000001-0000-5000-8000-000000000003', 'nba_mil_chi_20260622', 'NBA', 'MONEYLINE', 'MIL', 'HOME', NULL,
     'pinnacle', -140, 1.7143, 2.0, 0.6210, 0.0376, 0.0412, 'Injury-adjusted ratings favor home side strongly.', 'seed-bet-003', NOW() - INTERVAL '12 days',
     'WON', NOW() - INTERVAL '12 days 4 hours', NOW() - INTERVAL '11 days 20 hours'),
    ('a0000001-0000-4000-8000-000000000004', '10000001-0000-5000-8000-000000000004', 'nba_den_okc_20260623', 'NBA', 'SPREAD', 'DEN -4', 'HOME', -4.0,
     'draftkings', -110, 1.9091, 1.0, 0.5540, 0.0304, 0.0270, 'Altitude edge underpriced by market.', 'seed-bet-004', NOW() - INTERVAL '11 days',
     'PUSH', NOW() - INTERVAL '11 days 7 hours', NOW() - INTERVAL '10 days 22 hours'),
    ('a0000001-0000-4000-8000-000000000005', '10000001-0000-5000-8000-000000000005', 'nba_nyk_phi_20260624', 'NBA', 'SPREAD', 'NYK +2.5', 'AWAY', 2.5,
     'fanduel', -112, 1.8929, 1.4, 0.5580, 0.0296, 0.0301, 'Road underdog with superior defensive rating.', 'seed-bet-005', NOW() - INTERVAL '10 days',
     'LOST', NOW() - INTERVAL '10 days 5 hours', NOW() - INTERVAL '9 days 20 hours'),
    ('a0000001-0000-4000-8000-000000000006', '10000001-0000-5000-8000-000000000006', 'nba_lac_sac_20260625', 'NBA', 'TOTAL', 'Under 219.5', 'UNDER', 219.5,
     'pinnacle', -105, 1.9524, 1.1, 0.5470, 0.0345, 0.0338, 'Slow pace matchup; both defenses top-5 last 10 games.', 'seed-bet-006', NOW() - INTERVAL '9 days',
     'WON', NOW() - INTERVAL '9 days 6 hours', NOW() - INTERVAL '8 days 21 hours'),
    ('a0000001-0000-4000-8000-000000000007', '10000001-0000-5000-8000-000000000007', 'nba_gsw_pho_20260626', 'NBA', 'MONEYLINE', 'GSW', 'AWAY', NULL,
     'draftkings', 120, 2.2000, 1.0, 0.4890, 0.0344, 0.0296, 'Live dog: market overreacting to last-game blowout.', 'seed-bet-007', NOW() - INTERVAL '8 days',
     'WON', NOW() - INTERVAL '8 days 4 hours', NOW() - INTERVAL '7 days 20 hours'),
    ('a0000001-0000-4000-8000-000000000008', '10000001-0000-5000-8000-000000000008', 'nba_dal_hou_20260627', 'NBA', 'SPREAD', 'DAL -5.5', 'HOME', -5.5,
     'fanduel', -110, 1.9091, 1.75, 0.5710, 0.0474, 0.0455, 'Largest edge of the slate; model confident on margin.', 'seed-bet-008', NOW() - INTERVAL '7 days',
     'LOST', NOW() - INTERVAL '7 days 5 hours', NOW() - INTERVAL '6 days 21 hours'),
    ('a0000001-0000-4000-8000-000000000009', '10000001-0000-5000-8000-000000000009', 'nba_mem_nop_20260628', 'NBA', 'TOTAL', 'Over 230.5', 'OVER', 230.5,
     'draftkings', -110, 1.9091, 1.0, 0.5550, 0.0314, 0.0284, 'Pace-up spot with both backup centers out.', 'seed-bet-009', NOW() - INTERVAL '6 days',
     'WON', NOW() - INTERVAL '6 days 6 hours', NOW() - INTERVAL '5 days 21 hours'),
    ('a0000001-0000-4000-8000-000000000010', '10000001-0000-5000-8000-000000000010', 'nba_atl_orl_20260629', 'NBA', 'MONEYLINE', 'ORL', 'AWAY', NULL,
     'pinnacle', 155, 2.5500, 0.8, 0.4310, 0.0388, 0.0251, 'Road dog with rest edge and favorable matchup data.', 'seed-bet-010', NOW() - INTERVAL '5 days',
     'LOST', NOW() - INTERVAL '5 days 4 hours', NOW() - INTERVAL '4 days 20 hours'),
    ('a0000001-0000-4000-8000-000000000011', '10000001-0000-5000-8000-000000000011', 'nba_bkn_tor_20260630', 'NBA', 'SPREAD', 'TOR +6.5', 'AWAY', 6.5,
     'draftkings', -110, 1.9091, 2.0, 0.5730, 0.0494, 0.0473, 'Big line move against sharp side; grabbing stale number.', 'seed-bet-011', NOW() - INTERVAL '4 days',
     'WON', NOW() - INTERVAL '4 days 6 hours', NOW() - INTERVAL '3 days 21 hours')
ON CONFLICT (idempotency_key) DO NOTHING;

-- ── Open bets on the seeded sample-lines games ─────────────────────────

INSERT INTO emulator.paper_bets
    (id, game_id, game_external_id, league, market_type, selection, side, line_value,
     sportsbook_key, odds_american, odds_decimal, stake, predicted_probability,
     edge_at_placement, kelly_fraction, reasoning, idempotency_key, game_start_at,
     status, placed_at)
VALUES
    ('a0000001-0000-4000-8000-000000000012', '10000001-0000-5000-8000-000000000012', 'nba_lal_bos_20260410', 'NBA', 'SPREAD', 'LAL -3.5', 'HOME', -3.5,
     'draftkings', -110, 1.9091, 1.5, 0.5620, 0.0384, 0.0364, 'Model edge on home spread; line already moving our way.', 'seed-bet-012', NOW() + INTERVAL '6 hours',
     'OPEN', NOW() - INTERVAL '2 hours'),
    ('a0000001-0000-4000-8000-000000000013', '10000001-0000-5000-8000-000000000013', 'nba_lal_bos_20260410', 'NBA', 'TOTAL', 'Over 220.5', 'OVER', 220.5,
     'fanduel', -108, 1.9259, 1.0, 0.5560, 0.0368, 0.0341, 'Pace-up projection versus market total.', 'seed-bet-013', NOW() + INTERVAL '6 hours',
     'OPEN', NOW() - INTERVAL '2 hours'),
    ('a0000001-0000-4000-8000-000000000014', '10000001-0000-5000-8000-000000000014', 'nba_gsw_mil_20260410', 'NBA', 'MONEYLINE', 'GSW', 'HOME', NULL,
     'draftkings', 120, 2.2000, 1.2, 0.4900, 0.0354, 0.0306, 'Home dog value against public favorite.', 'seed-bet-014', NOW() + INTERVAL '8 hours',
     'OPEN', NOW() - INTERVAL '1 hour')
ON CONFLICT (idempotency_key) DO NOTHING;

-- ── Grades for the graded bets ─────────────────────────────────────────

INSERT INTO emulator.bet_grades
    (id, bet_id, actual_result, actual_home_score, actual_away_score, actual_margin, actual_total,
     profit_loss, closing_line_value, closing_odds, clv, graded_at)
VALUES
    ('b0000001-0000-4000-8000-000000000001', 'a0000001-0000-4000-8000-000000000001', 'LAL won by 8, covering -3.5', 118, 110, 8, 228, 1.3636, -4.5, -110, 0.0180, NOW() - INTERVAL '13 days 21 hours'),
    ('b0000001-0000-4000-8000-000000000002', 'a0000001-0000-4000-8000-000000000002', 'Game landed 219, under 224.5', 112, 107, 5, 219, -1.2000, 223.5, -110, -0.0090, NOW() - INTERVAL '12 days 20 hours'),
    ('b0000001-0000-4000-8000-000000000003', 'a0000001-0000-4000-8000-000000000003', 'MIL won by 12', 121, 109, 12, 230, 1.4286, NULL, -155, 0.0210, NOW() - INTERVAL '11 days 20 hours'),
    ('b0000001-0000-4000-8000-000000000004', 'a0000001-0000-4000-8000-000000000004', 'DEN won by exactly 4, push on -4', 115, 111, 4, 226, 0.0000, -4.0, -108, 0.0020, NOW() - INTERVAL '10 days 22 hours'),
    ('b0000001-0000-4000-8000-000000000005', 'a0000001-0000-4000-8000-000000000005', 'PHI won by 6, NYK +2.5 loses', 109, 103, 6, 212, -1.4000, 3.0, -110, 0.0060, NOW() - INTERVAL '9 days 20 hours'),
    ('b0000001-0000-4000-8000-000000000006', 'a0000001-0000-4000-8000-000000000006', 'Game landed 214, under 219.5', 110, 104, 6, 214, 1.0476, 218.0, -110, -0.0110, NOW() - INTERVAL '8 days 21 hours'),
    ('b0000001-0000-4000-8000-000000000007', 'a0000001-0000-4000-8000-000000000007', 'GSW won outright at +120', 106, 112, -6, 218, 1.2000, NULL, 105, 0.0290, NOW() - INTERVAL '7 days 20 hours'),
    ('b0000001-0000-4000-8000-000000000008', 'a0000001-0000-4000-8000-000000000008', 'DAL won by 3, failed to cover -5.5', 114, 111, 3, 225, -1.7500, -6.0, -110, 0.0050, NOW() - INTERVAL '6 days 21 hours'),
    ('b0000001-0000-4000-8000-000000000009', 'a0000001-0000-4000-8000-000000000009', 'Game landed 236, over 230.5', 122, 114, 8, 236, 0.9091, 232.5, -110, 0.0190, NOW() - INTERVAL '5 days 21 hours'),
    ('b0000001-0000-4000-8000-000000000010', 'a0000001-0000-4000-8000-000000000010', 'ATL won by 9, ORL ML loses', 117, 108, 9, 225, -0.8000, NULL, 150, -0.0050, NOW() - INTERVAL '4 days 20 hours'),
    ('b0000001-0000-4000-8000-000000000011', 'a0000001-0000-4000-8000-000000000011', 'BKN won by 4, TOR +6.5 covers', 111, 107, 4, 218, 1.8182, 5.5, -110, -0.0100, NOW() - INTERVAL '3 days 21 hours')
ON CONFLICT (bet_id) DO NOTHING;

-- ── Bankroll trail (one snapshot per grading, cumulative) ──────────────

INSERT INTO emulator.bankroll_snapshots
    (id, balance, total_wagered, total_profit_loss, open_bets_count, total_bets, total_wins, total_losses, avg_clv, snapshot_at)
VALUES
    ('c0000001-0000-4000-8000-000000000001', 101.3636,  1.50,  1.3636, 0,  1, 1, 0, 0.0180, NOW() - INTERVAL '13 days 21 hours'),
    ('c0000001-0000-4000-8000-000000000002', 100.1636,  2.70,  0.1636, 0,  2, 1, 1, 0.0045, NOW() - INTERVAL '12 days 20 hours'),
    ('c0000001-0000-4000-8000-000000000003', 101.5922,  4.70,  1.5922, 0,  3, 2, 1, 0.0100, NOW() - INTERVAL '11 days 20 hours'),
    ('c0000001-0000-4000-8000-000000000004', 101.5922,  5.70,  1.5922, 0,  4, 2, 1, 0.0080, NOW() - INTERVAL '10 days 22 hours'),
    ('c0000001-0000-4000-8000-000000000005', 100.1922,  7.10,  0.1922, 0,  5, 2, 2, 0.0076, NOW() - INTERVAL '9 days 20 hours'),
    ('c0000001-0000-4000-8000-000000000006', 101.2398,  8.20,  1.2398, 0,  6, 3, 2, 0.0045, NOW() - INTERVAL '8 days 21 hours'),
    ('c0000001-0000-4000-8000-000000000007', 102.4398,  9.20,  2.4398, 0,  7, 4, 2, 0.0080, NOW() - INTERVAL '7 days 20 hours'),
    ('c0000001-0000-4000-8000-000000000008', 100.6898, 10.95,  0.6898, 0,  8, 4, 3, 0.0076, NOW() - INTERVAL '6 days 21 hours'),
    ('c0000001-0000-4000-8000-000000000009', 101.5989, 11.95,  1.5989, 0,  9, 5, 3, 0.0089, NOW() - INTERVAL '5 days 21 hours'),
    ('c0000001-0000-4000-8000-000000000010', 100.7989, 12.75,  0.7989, 0, 10, 5, 4, 0.0075, NOW() - INTERVAL '4 days 20 hours'),
    ('c0000001-0000-4000-8000-000000000011', 102.6171, 14.75,  2.6171, 0, 11, 6, 4, 0.0059, NOW() - INTERVAL '3 days 21 hours'),
    ('c0000001-0000-4000-8000-000000000012', 102.6171, 18.45,  2.6171, 3, 11, 6, 4, 0.0059, NOW() - INTERVAL '1 hour')
ON CONFLICT (id) DO NOTHING;
