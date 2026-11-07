WITH duplicated_sales_ids AS (
    SELECT sales_id
    FROM {{ ref('bronze_sales') }}
    WHERE sales_id IS NOT NULL
    GROUP BY sales_id
    HAVING COUNT(*) > 1
)

SELECT
    intermediate.source_record_key,
    'DUPLICATE_ID_CLASSIFICATION_MISMATCH' AS failure_reason
FROM {{ ref('int_silver_sales') }} AS intermediate
LEFT JOIN duplicated_sales_ids AS duplicated
    ON intermediate.sales_id = duplicated.sales_id
WHERE COALESCE(intermediate.is_duplicated_id, false)
    <> (duplicated.sales_id IS NOT NULL)
