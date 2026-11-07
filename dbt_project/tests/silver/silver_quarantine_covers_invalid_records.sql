WITH invalid_records AS (
    SELECT
        source_record_key,
        quarentine_reasons
    FROM {{ ref('int_silver_sales') }}
    WHERE SIZE(quarentine_reasons) > 0
),

open_quarantine_records AS (
    SELECT
        source_record_key,
        quarentine_reasons
    FROM {{ ref('quarentine_silver_sales') }}
    WHERE status = 'open'
)

SELECT
    invalid.source_record_key,
    'INVALID_RECORD_MISSING_FROM_OPEN_QUARANTINE' AS failure_reason
FROM invalid_records AS invalid
LEFT JOIN open_quarantine_records AS quarantine
    ON invalid.source_record_key = quarantine.source_record_key
WHERE quarantine.source_record_key IS NULL

UNION ALL

SELECT
    invalid.source_record_key,
    'QUARANTINE_REASON_MISMATCH' AS failure_reason
FROM invalid_records AS invalid
INNER JOIN open_quarantine_records AS quarantine
    ON invalid.source_record_key = quarantine.source_record_key
WHERE NOT (invalid.quarentine_reasons <=> quarantine.quarentine_reasons)
