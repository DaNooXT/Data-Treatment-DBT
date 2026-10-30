WITH 

source_data AS (
    SELECT
        *
    FROM
        {{ source('source', 'fact_sales') }}
)

SELECT 
    source_data.*,

    SHA2 (
        TO_JSON (
            NAMED_STRUCT (
                'sales_id', sales_id
                'date_sk', date_sk,
                'store_sk', store_sk,
                'product_sk', product_sk,
                'customer_sk', customer_sk,
                'promotion_sk', promotion_sk,
                'quantity', quantity,
                'unit_price', unit_price,
                'gross_amount', gross_amount,
                'discount_amount', discount_amount,
                'net_amount', net_amount,
                'payment_method', payment_method
            ) 
        ),
        256 
    ) AS source_record_key

FROM source_data