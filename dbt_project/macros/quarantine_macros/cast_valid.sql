{% macro cast_valid(columns, source_alias='source', quarantine=False) %}
    {% for column, data_type in columns.items() %}

        {% if quarantine %}
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
            {% if quarantine %} OR {%  else %} AND {% endif %}
        {% endif %}

    {% endfor %}

{% endmacro %}