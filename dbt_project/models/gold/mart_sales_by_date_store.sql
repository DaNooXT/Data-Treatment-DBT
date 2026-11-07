{{
    config(
        materialized='table'
    )
}}

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
