SELECT
    *
FROM 
    {{ ref('int_silver_sales') }}
WHERE
    COALESCE(SIZE(quarentine_reasons), 0) = 0
