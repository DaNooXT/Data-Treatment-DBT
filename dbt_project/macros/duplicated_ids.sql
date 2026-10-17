{% macro duplicated_ids(id_column, source_alias='source') %}

    count (*) OVER (
        PARTITION BY {{ source_alias }}.{{ id_column }}
    ) > 1

{% endmacro %}