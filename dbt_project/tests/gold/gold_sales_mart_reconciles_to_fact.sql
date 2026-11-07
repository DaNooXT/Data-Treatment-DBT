WITH expected AS (
    SELECT
        date_sk,
        store_sk,
        COUNT(DISTINCT sales_id) AS sales_count,
        COUNT(DISTINCT customer_sk) AS customer_count,
        SUM(quantity) AS quantity_sold,
        SUM(gross_amount) AS gross_sales_amount,
        SUM(discount_amount) AS discount_amount,
        SUM(net_amount) AS net_sales_amount,
        AVG(net_amount) AS average_sale_amount
    FROM {{ ref('fct_sales') }}
    GROUP BY
        date_sk,
        store_sk
),

actual AS (
    SELECT
        date_sk,
        store_sk,
        sales_count,
        customer_count,
        quantity_sold,
        gross_sales_amount,
        discount_amount,
        net_sales_amount,
        average_sale_amount
    FROM {{ ref('mart_sales_by_date_store') }}
)

SELECT
    COALESCE(expected.date_sk, actual.date_sk) AS date_sk,
    COALESCE(expected.store_sk, actual.store_sk) AS store_sk,
    'GOLD_SALES_AGGREGATE_MISMATCH' AS failure_reason
FROM expected
FULL OUTER JOIN actual
    ON expected.date_sk = actual.date_sk
    AND expected.store_sk = actual.store_sk
WHERE expected.sales_count IS NULL
    OR actual.sales_count IS NULL
    OR expected.sales_count <> actual.sales_count
    OR expected.customer_count <> actual.customer_count
    OR expected.quantity_sold <> actual.quantity_sold
    OR expected.gross_sales_amount <> actual.gross_sales_amount
    OR expected.discount_amount <> actual.discount_amount
    OR expected.net_sales_amount <> actual.net_sales_amount
    OR ABS(expected.average_sale_amount - actual.average_sale_amount) > 0.000001
