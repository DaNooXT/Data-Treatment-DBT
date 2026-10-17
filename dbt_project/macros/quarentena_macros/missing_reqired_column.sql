{% macro missing_required_column(required_columns, source_alias='source') %}

    {% for column in required_columns %}

        {{ source_alias }}.{{ column }} IS NULL

        {% if not loop.last %} OR {% endif %}

    {% endfor %}

{% endmacro %}