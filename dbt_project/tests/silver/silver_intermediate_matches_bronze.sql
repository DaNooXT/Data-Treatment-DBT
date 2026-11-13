WITH bronze_records AS (
    SELECT source_record_key
    FROM {{ ref('bronze_sales') }}
    WHERE COALESCE(`exclude`, false) = false
),

intermediate_records AS (
    SELECT source_record_key
    FROM {{ ref('int_silver_sales') }}
)

SELECT
    bronze.source_record_key,
    'BRONZE_RECORD_MISSING_FROM_INTERMEDIATE' AS failure_reason
FROM bronze_records AS bronze
LEFT JOIN intermediate_records AS intermediate
    ON bronze.source_record_key = intermediate.source_record_key
WHERE intermediate.source_record_key IS NULL

UNION ALL

SELECT
    intermediate.source_record_key,
    'UNEXPECTED_INTERMEDIATE_RECORD' AS failure_reason
FROM intermediate_records AS intermediate
LEFT JOIN bronze_records AS bronze
    ON intermediate.source_record_key = bronze.source_record_key
WHERE bronze.source_record_key IS NULL
