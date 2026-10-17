{% macro define_required_silver_column(table_name) %}

    {% if table_name == 'sales' %}
        {% do return([
            'sales_id',
            'date_sk',
            'store_sk',
            'product_sk',
            'customer_sk',
            'quantity',
            'unit_price',
            'gross_amount',
            'discount_amount',
            'net_amount',
            'payment_method'
        ]) %}
      
    {% endif %}
  
{% endmacro %}