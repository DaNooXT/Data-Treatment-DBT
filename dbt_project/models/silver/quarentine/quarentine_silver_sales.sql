WITH

invalid_records AS (

    SELECT
        CAST(sales_id AS STRING) AS source_record_id,
        raw_record,
        quarentine_reasons AS quarentine_reasons,
        is_duplicated_id
    FROM 
        {{ ref('int_silver_sales') }} AS source
    WHERE 
        SIZE(quarentine_reasons) > 0

),

identified_records AS (

    SELECT 
        source_record_id,

        SHA2 (
            COALESCE(raw_record, ''), 
            256
        ) AS record_fingerprint,

        raw_record,
        quarentine_reasons,
        is_duplicated_id
    FROM 
        invalid_records
),

quarentine_records AS (

    SELECT 
        SHA2 (
            CONCAT ('bronze_sales:', record_fingerprint), 
            256
        ) AS quarentine_id,

        'bronze_sales' aS source_model,
        source_record_id,
        record_fingerprint,
        quarentine_reasons,
        raw_record,

        CURRENT_TIMESTAMP AS first_seen_at,
        CURRENT_TIMESTAMP AS last_seen_at,

        '{{ invocation_id }}' AS run_id,

        'open' AS status,
        
        CAST(null AS TIMESTAMP) as resolverd_at
    FROM 
        identified_records
)

SELECT
    *
FROM 
    quarentine_records