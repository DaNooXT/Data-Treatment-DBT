SELECT
    *
FROM
    {{ source('source', 'raw_sales') }}