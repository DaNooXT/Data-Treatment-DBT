{% macro cast_valid(columns, source_alias='source', quarentine=False) %}
    {% for column, data_type in columns.items() %}

        {% if quarentine %}
        (
            {{ source_alias }}.{{ column }} IS NOT NULL
            AND TRY_CAST({{ source_alias }}.{{ column }} AS {{  data_type }}) IS NULL
        )
        {% else %}
        (
            {{ source_alias }}.{{ column }} IS NULL
            OR TRY_CAST({{ source_alias }}.{{ column }} AS {{  data_type }}) IS NOT NULL
        )
        {% endif %}

        {% if not loop.last %}
            {% if quarentine %} OR {%  else %} AND {% endif %}
        {% endif %}

    {% endfor %}
{% endmacro %}