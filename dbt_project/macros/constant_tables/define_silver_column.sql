{% macro define_silver_column(name_table) %}

    {% if name_table == "sales" %}
        {% do return({
            'sales_id': 'BIGINT',
            'date_sk': 'BIGINT',
            'store_sk': 'BIGINT',
            'product_sk': 'BIGINT',
            'customer_sk': 'BIGINT',
            'promotion_sk': 'BIGINT',
            'quantity': 'BIGINT',
            'unit_price': 'DECIMAL (10,2)',
            'gross_amount': 'DECIMAL (10,2)',
            'discount_amount': 'DECIMAL (10,2)',
            'net_amount': 'DECIMAL (10,2)',
            'payment_method': 'STRING'
        }) %}
    {% endif %}
  
{% endmacro %}