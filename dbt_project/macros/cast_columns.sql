{% macro cast_columns(columns, source_alias='source', safety=False) %}

    {% for column, data_type in columns.items() %}

        {% if safety %}
            TRY_CAST({{ source_alias }}.{{ column }} AS {{ data_type }}) AS {{ column }}
        {% else %}
            CAST({{ source_alias }}.{{column}} AS {{ data_type }}) AS {{ column }}
        {% endif %}

        {% if not loop.last %} , {% endif %}
      
    {% endfor %}

{% endmacro %}