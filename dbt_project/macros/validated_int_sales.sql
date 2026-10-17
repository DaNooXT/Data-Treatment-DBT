{% macro validated_int_sales(source_model, columns, required_columns, required_non_negative_columns) %}

    WITH source_with_duplicated AS (

        SELECT
            source.*,

            {{ duplicated_ids(
                id_column='sales_id',
                source_alias='source'
            ) }} AS is_duplicated_id

        FROM {{ ref(source_model) }} AS source

    ),

    classified AS (

        SELECT
            source.*,

            {{ define_quarentine_reason(
                columns,
                required_columns,
                required_non_negative_columns,
                source_alias='source'
            ) }} AS quarentine_reasons

        FROM source_with_duplicated AS source

    )

    SELECT 
        {{ cast_columns(
            columns,
            source_alias='classified',
            safety=True
        ) }},

        classified.quarentine_reasons,
        classified.is_duplicated_id,

        TO_JSON (
            STRUCT (
                classified.sales_id AS sales_id,
                classified.date_sk AS date_sk,
                classified.store_sk AS store_sk,
                classified.product_sk AS product_sk,
                classified.customer_sk AS customer_sk,
                classified.promotion_sk AS promotion_sk,
                classified.quantity AS quantity,
                classified.unit_price AS unit_price,
                classified.gross_amount AS gross_amount,
                classified.discount_amount AS discount_amount,
                classified.net_amount AS net_amount,
                classified.payment_method AS payment_method
            )
        ) AS raw_record

    FROM classified 


{% endmacro %}