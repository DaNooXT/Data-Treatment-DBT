{% macro define_non_negative_columns(name_table) %}
    {% if name_table=='sales' %}
        {% do return ([
            'quantity',
            'unit_price',
            'gross_amount',
            'discount_amount',
            'net_amount'
        ]) %}
      
    {% endif %}
{% endmacro %}