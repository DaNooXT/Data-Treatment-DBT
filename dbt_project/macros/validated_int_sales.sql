{% macro validated_int_sales(source_model, columns, required_columns, required_non_negative_columns) %}

    WITH
    source_with_duplicated AS (
        SELECT 
            source.*,
            {{ duplicated_ids (
                id_column='sales_id',
                source_alias='source'
            ) }} AS is_duplicated_id
        FROM 
            {{ ref(source_model) }} AS source
    )

    SELECT
        source.*,
        {{ define_quarentine_reason(
            columns,
            required_columns,
            required_non_negative_columns,
            source_alias='source'
        ) }} AS quarentine_reasons

    FROM source_with_duplicated AS source

{% endmacro %}