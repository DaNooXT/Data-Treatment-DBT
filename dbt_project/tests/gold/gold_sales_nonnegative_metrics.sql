SELECT
    source_record_key,
    'NEGATIVE_SALES_METRIC' AS failure_reason
FROM {{ ref('fct_sales') }}
WHERE quantity < 0
    OR unit_price < 0
    OR gross_amount < 0
    OR discount_amount < 0
    OR net_amount < 0
