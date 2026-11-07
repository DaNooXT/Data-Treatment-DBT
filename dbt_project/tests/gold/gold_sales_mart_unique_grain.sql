SELECT
    date_sk,
    store_sk,
    'DUPLICATE_DATE_STORE_GRAIN' AS failure_reason
FROM {{ ref('mart_sales_by_date_store') }}
GROUP BY
    date_sk,
    store_sk
HAVING COUNT(*) > 1
