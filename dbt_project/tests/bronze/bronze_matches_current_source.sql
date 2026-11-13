WITH source_records AS (
    SELECT
        source_record_key,
        sales_id,
        date_sk,
        store_sk,
        product_sk,
        customer_sk,
        promotion_sk,
        quantity,
        unit_price,
        gross_amount,
        discount_amount,
        net_amount,
        payment_method,
        `exclude` AS exclude_flag
    FROM {{ source('source', 'raw_sales') }}
),

bronze_records AS (
    SELECT
        source_record_key,
        sales_id,
        date_sk,
        store_sk,
        product_sk,
        customer_sk,
        promotion_sk,
        quantity,
        unit_price,
        gross_amount,
        discount_amount,
        net_amount,
        payment_method,
        `exclude` AS exclude_flag
    FROM {{ ref('bronze_sales') }}
)

SELECT
    source_records.source_record_key,
    'SOURCE_RECORD_MISSING_FROM_BRONZE' AS failure_reason
FROM source_records
LEFT JOIN bronze_records
    ON source_records.source_record_key = bronze_records.source_record_key
WHERE bronze_records.source_record_key IS NULL

UNION ALL

SELECT
    bronze_records.source_record_key,
    'BRONZE_RECORD_MISSING_FROM_SOURCE' AS failure_reason
FROM bronze_records
LEFT JOIN source_records
    ON bronze_records.source_record_key = source_records.source_record_key
WHERE source_records.source_record_key IS NULL

UNION ALL

SELECT
    source_records.source_record_key,
    'BRONZE_RECORD_DIFFERS_FROM_SOURCE' AS failure_reason
FROM source_records
INNER JOIN bronze_records
    ON source_records.source_record_key = bronze_records.source_record_key
WHERE NOT (
    source_records.sales_id <=> bronze_records.sales_id
    AND source_records.date_sk <=> bronze_records.date_sk
    AND source_records.store_sk <=> bronze_records.store_sk
    AND source_records.product_sk <=> bronze_records.product_sk
    AND source_records.customer_sk <=> bronze_records.customer_sk
    AND source_records.promotion_sk <=> bronze_records.promotion_sk
    AND source_records.quantity <=> bronze_records.quantity
    AND source_records.unit_price <=> bronze_records.unit_price
    AND source_records.gross_amount <=> bronze_records.gross_amount
    AND source_records.discount_amount <=> bronze_records.discount_amount
    AND source_records.net_amount <=> bronze_records.net_amount
    AND source_records.payment_method <=> bronze_records.payment_method
    AND source_records.exclude_flag <=> bronze_records.exclude_flag
)
