{% set required_columns = define_required_silver_column('sales') %}
{% set required_non_negative_columns = define_non_negative_columns('sales') %}

SELECT
    silver.sales_id,
    'MISSING_REQUIRED_COLUMN' AS failure_reason
FROM 
    {{ ref('silver_sales') }} AS silver
WHERE 
    {{ missing_required_column(required_columns, source_alias='silver') }}

UNION ALL

SELECT
    silver.sales_id,
    'NEGATIVE_VALUE' AS failure_reason
FROM 
    {{ ref('silver_sales') }} AS silver
WHERE
    {{ non_negative_columns(required_non_negative_columns, source_alias='silver') }}