WITH missing_from_gold AS (
    SELECT silver.source_record_key
    FROM {{ ref('silver_sales') }} AS silver
    LEFT JOIN {{ ref('fct_sales') }} AS gold
        ON silver.source_record_key = gold.source_record_key
    WHERE gold.source_record_key IS NULL
),

unexpected_in_gold AS (
    SELECT gold.source_record_key
    FROM {{ ref('fct_sales') }} AS gold
    LEFT JOIN {{ ref('silver_sales') }} AS silver
        ON gold.source_record_key = silver.source_record_key
    WHERE silver.source_record_key IS NULL
),

changed_in_gold AS (
    SELECT silver.source_record_key
    FROM {{ ref('silver_sales') }} AS silver
    INNER JOIN {{ ref('fct_sales') }} AS gold
        ON silver.source_record_key = gold.source_record_key
    WHERE NOT (
        silver.sales_id <=> gold.sales_id
        AND silver.date_sk <=> gold.date_sk
        AND silver.store_sk <=> gold.store_sk
        AND silver.product_sk <=> gold.product_sk
        AND silver.customer_sk <=> gold.customer_sk
        AND silver.promotion_sk <=> gold.promotion_sk
        AND silver.quantity <=> gold.quantity
        AND silver.unit_price <=> gold.unit_price
        AND silver.gross_amount <=> gold.gross_amount
        AND silver.discount_amount <=> gold.discount_amount
        AND silver.net_amount <=> gold.net_amount
        AND silver.payment_method <=> gold.payment_method
    )
)

SELECT
    source_record_key,
    'SILVER_RECORD_MISSING_FROM_GOLD_FACT' AS failure_reason
FROM missing_from_gold

UNION ALL

SELECT
    source_record_key,
    'UNEXPECTED_RECORD_IN_GOLD_FACT' AS failure_reason
FROM unexpected_in_gold

UNION ALL

SELECT
    source_record_key,
    'GOLD_FACT_VALUES_DIFFER_FROM_SILVER' AS failure_reason
FROM changed_in_gold
