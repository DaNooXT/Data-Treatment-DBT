
{% macro define_quarentine_reason(
    columns,
    required_columns,
    required_non_negative_columns,
    source_alias='source'
) %}

    FILTER(
        ARRAY(
            CASE
                WHEN (
                    {{ cast_valid(columns, source_alias=source_alias, quarentine=True) }}
                )
                THEN 'INVALID_TYPE'
            END,

            CASE
                WHEN (
                    {{ missing_required_column(required_columns, source_alias=source_alias) }}
                )
                THEN 'MISSING_REQUIRED_COLUMN'
            END,

            CASE
                WHEN (
                    {{ non_negative_columns(required_non_negative_columns, source_alias=source_alias) }}
                )
                THEN 'NEGATIVE_VALUE'
            END,

            CASE
                WHEN (
                    {{ source_alias }}.is_duplicated_id
                )
                THEN 'DUPLICATED_ID'
            END
        ),
        reason -> reason IS NOT NULL
    )

{% endmacro %}