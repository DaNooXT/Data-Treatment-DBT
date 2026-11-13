SELECT
    quarantine.source_record_key,
    quarantine.status,
    quarantine.first_seen_at,
    quarantine.last_seen_at,
    quarantine.resolved_at
FROM {{ ref('quarentine_silver_sales') }} AS quarantine
WHERE quarantine.source_record_key IS NULL
    OR quarantine.status IS NULL
    OR quarantine.status NOT IN ('open', 'resolved', 'removed')
    OR quarantine.first_seen_at IS NULL
    OR quarantine.last_seen_at IS NULL
    OR quarantine.first_seen_at > quarantine.last_seen_at
    OR (quarantine.status IN ('open', 'removed') AND quarantine.resolved_at IS NOT NULL)
    OR (quarantine.status = 'resolved' AND quarantine.resolved_at IS NULL)
    OR (
        quarantine.status = 'open'
        AND NOT EXISTS (
            SELECT 1
            FROM {{ ref('int_silver_sales') }} AS S
            WHERE S.source_record_key = quarantine.source_record_key
                AND SIZE(S.quarentine_reasons) > 0
        )
    )
    OR (
        quarantine.status = 'removed'
        AND EXISTS (
            SELECT 1
            FROM {{ ref('int_silver_sales') }} AS S
            WHERE S.source_record_key = quarantine.source_record_key
        )
    )
    OR (
        quarantine.status = 'resolved'
        AND EXISTS (
            SELECT 1
            FROM {{ ref('int_silver_sales') }} AS S
            WHERE S.source_record_key = quarantine.source_record_key
                AND SIZE(S.quarentine_reasons) > 0
        )
    )
    OR (
        quarantine.resolved_at IS NOT NULL
        AND quarantine.resolved_at < quarantine.first_seen_at
    )
