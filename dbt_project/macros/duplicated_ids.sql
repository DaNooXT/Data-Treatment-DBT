{% macro duplicated_ids(id_column, source_alias='source') %}

    (
        {{ source_alias }}.{{ id_column }} IS NOT NULL

        AND count (*) OVER (
            PARTITION BY {{ source_alias }}.{{ id_column }}
        ) > 1

    )

{% endmacro %}