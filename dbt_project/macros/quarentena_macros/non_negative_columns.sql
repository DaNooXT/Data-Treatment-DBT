{% macro non_negative_columns(required_non_negative_columns, source_alias='source') %}
    {% for column in required_non_negative_columns %}

        {{ source_alias }}.{{ column }} < 0

        {% if not loop.last %} OR {% endif %}
      
    {% endfor %}
{% endmacro %}