WITH expected_valid_records AS (
    SELECT source_record_key
    FROM {{ ref('int_silver_sales') }}
    WHERE COALESCE(SIZE(quarentine_reasons), 0) = 0
),

published_records AS (
    SELECT source_record_key
    FROM {{ ref('silver_sales') }}
)

SELECT
    expected.source_record_key,
    'VALID_RECORD_MISSING_FROM_SILVER' AS failure_reason
FROM expected_valid_records AS expected
LEFT JOIN published_records AS published
    ON expected.source_record_key = published.source_record_key
WHERE published.source_record_key IS NULL

UNION ALL

SELECT
    published.source_record_key,
    'INVALID_OR_UNEXPECTED_RECORD_IN_SILVER' AS failure_reason
FROM published_records AS published
LEFT JOIN expected_valid_records AS expected
    ON published.source_record_key = expected.source_record_key
WHERE expected.source_record_key IS NULL
