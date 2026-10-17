SELECT 
    *
FROM 
    {{ ref('int_silver_sales') }}
WHERE
    SIZE(quarentine_reasons) > 0