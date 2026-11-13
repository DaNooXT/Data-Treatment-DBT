{{
    config(
        materialized='incremental',
        incremental_strategy='merge',
        unique_key='source_record_key',
        file_format='delta',
        merge_update_columns=[
            'last_seen_at',
            'quarentine_reasons',
            'raw_record',
            'record_fingerprint',
            'run_id',
            'status',
            'resolved_at'
        ]
    )
}}

WITH invalid_records AS (

    SELECT
        source_record_key,
        CAST(sales_id AS STRING) AS source_record_id,
        raw_record,
        quarentine_reasons,
        is_duplicated_id
    FROM {{ ref('int_silver_sales') }}
    WHERE SIZE(quarentine_reasons) > 0

),

identified_records AS (

    SELECT
        source_record_key,
        source_record_id,

        SHA2(
            COALESCE(raw_record, ''),
            256
        ) AS record_fingerprint,

        raw_record,
        quarentine_reasons,
        is_duplicated_id
    FROM invalid_records

),

quarentine_records AS (

    SELECT
        source_record_key,

        SHA2(
            CONCAT('bronze_sales:', source_record_key),
            256
        ) AS quarentine_id,

        'bronze_sales' AS source_model,
        source_record_id,
        record_fingerprint,
        quarentine_reasons,
        raw_record,

        CURRENT_TIMESTAMP AS first_seen_at,
        CURRENT_TIMESTAMP AS last_seen_at,

        '{{ invocation_id }}' AS run_id,

        'open' AS status,

        CAST(NULL AS TIMESTAMP) AS resolved_at
    FROM identified_records

)
{% if is_incremental() %}
    , resolved_records AS (
        
        SELECT
            QR.source_record_key,
            QR.quarentine_id,
            QR.source_model,
            QR.source_record_id,
            QR.record_fingerprint,
            QR.quarentine_reasons,
            QR.raw_record,
            QR.first_seen_at,
            QR.last_seen_at,

            '{{ invocation_id }}' AS run_id,

            'resolved' AS status,
            CURRENT_TIMESTAMP() AS resolved_at
        FROM 
            {{ this }} AS QR

        INNER JOIN {{ ref('int_silver_sales') }} AS S
            ON QR.source_record_key = S.source_record_key
        
        WHERE QR.status IN ('open', 'removed')
            AND COALESCE(SIZE(S.quarentine_reasons), 0) = 0
    )

    , removed_records AS (

        SELECT
            QR.source_record_key,
            QR.quarentine_id,
            QR.source_model,
            QR.source_record_id,
            QR.record_fingerprint,
            QR.quarentine_reasons,
            QR.raw_record,
            QR.first_seen_at,
            QR.last_seen_at,

            '{{ invocation_id }}' AS run_id,

            'removed' AS status,
            CAST(NULL AS TIMESTAMP) AS resolved_at
        FROM {{ this }} AS QR
        LEFT ANTI JOIN {{ ref('int_silver_sales') }} AS S
            ON QR.source_record_key = S.source_record_key
        WHERE QR.status = 'open'
    )
{% endif %}

{% if is_incremental() %}

    SELECT *
    FROM quarentine_records

    UNION ALL

    SELECT *
    FROM resolved_records

    UNION ALL

    SELECT *
    FROM removed_records
    
{% else %}

    SELECT *
    FROM quarentine_records

{% endif %}