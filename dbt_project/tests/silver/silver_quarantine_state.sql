SELECT
    source_record_key,
    status,
    first_seen_at,
    last_seen_at,
    resolved_at
FROM {{ ref('quarentine_silver_sales') }}
WHERE source_record_key IS NULL
    OR status IS NULL
    OR status NOT IN ('open', 'resolved')
    OR first_seen_at IS NULL
    OR last_seen_at IS NULL
    OR first_seen_at > last_seen_at
    OR (status = 'open' AND resolved_at IS NOT NULL)
    OR (status = 'resolved' AND resolved_at IS NULL)
    OR (resolved_at IS NOT NULL AND resolved_at < first_seen_at)
