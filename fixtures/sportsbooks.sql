-- Seed sportsbook registry with common books tracked by The Odds API.
-- is_sharp = true for market-making books whose lines are considered efficient.

INSERT INTO lines.sportsbooks (name, key, is_sharp, is_active) VALUES
    ('Pinnacle', 'pinnacle', TRUE, TRUE),
    ('Circa Sports', 'circasports', TRUE, TRUE),
    ('DraftKings', 'draftkings', FALSE, TRUE),
    ('FanDuel', 'fanduel', FALSE, TRUE),
    ('BetMGM', 'betmgm', FALSE, TRUE),
    ('Caesars Sportsbook', 'williamhill_us', FALSE, TRUE),
    ('PointsBet', 'pointsbetus', FALSE, TRUE),
    ('BetRivers', 'betrivers', FALSE, TRUE),
    ('Unibet', 'unibet_us', FALSE, TRUE),
    ('WynnBET', 'wynnbet', FALSE, TRUE),
    ('bet365', 'bet365', FALSE, TRUE),
    ('Bovada', 'bovada', FALSE, TRUE),
    ('BetOnline.ag', 'betonlineag', FALSE, TRUE),
    ('Betway', 'betway', FALSE, TRUE),
    ('Hard Rock Bet', 'hardrockbet', FALSE, TRUE),
    ('ESPN BET', 'espnbet', FALSE, TRUE),
    ('Fanatics', 'fanatics', FALSE, TRUE),
    ('Fliff', 'fliff', FALSE, TRUE),
    ('SuperBook', 'superbook', FALSE, TRUE),
    ('Betfred', 'betfred', FALSE, TRUE)
ON CONFLICT (key) DO NOTHING;
