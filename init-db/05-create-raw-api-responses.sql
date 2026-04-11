-- Shared raw API response archive. Both lines-service and statistics-service
-- store every external API response here for future LLM fine-tuning and replay.

CREATE TABLE public.raw_api_responses (
    id            UUID NOT NULL DEFAULT gen_random_uuid(),
    service       TEXT NOT NULL,
    source        TEXT NOT NULL,
    endpoint      TEXT NOT NULL,
    http_status   INTEGER NOT NULL,
    request_body  TEXT,
    response_body TEXT NOT NULL,
    captured_at   TIMESTAMPTZ NOT NULL,
    PRIMARY KEY (id, captured_at)
);

COMMENT ON TABLE public.raw_api_responses IS 'Append-only archive of every external API response. TimescaleDB hypertable partitioned by captured_at.';
COMMENT ON COLUMN public.raw_api_responses.service IS 'Which service captured this response (lines-service, statistics-service).';
COMMENT ON COLUMN public.raw_api_responses.source IS 'External API source (the_odds_api, nba_com, sharp_api, etc.).';

SELECT create_hypertable(
    'public.raw_api_responses',
    by_range('captured_at', INTERVAL '1 day')
);

CREATE INDEX idx_raw_api_responses_service_source
    ON public.raw_api_responses (service, source, captured_at DESC);

-- Grant INSERT + SELECT to service roles that archive responses
GRANT INSERT, SELECT ON public.raw_api_responses TO lines_svc;
GRANT INSERT, SELECT ON public.raw_api_responses TO predictions_svc;

-- Compression: compress after 7 days
ALTER TABLE public.raw_api_responses SET (
    timescaledb.compress,
    timescaledb.compress_segmentby = 'service, source',
    timescaledb.compress_orderby = 'captured_at DESC'
);

SELECT add_compression_policy('public.raw_api_responses', INTERVAL '7 days');

-- Retention: keep raw responses for 12 months
SELECT add_retention_policy('public.raw_api_responses', INTERVAL '12 months');
