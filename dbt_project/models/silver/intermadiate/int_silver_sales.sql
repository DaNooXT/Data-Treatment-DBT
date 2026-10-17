{% set columns = define_silver_column('sales') %}
{% set required_columns = define_required_silver_column('sales') %}
{% set required_non_negative_columns = define_non_negative_columns('sales') %}

{{ validated_int_sales('bronze_sales', columns, required_columns, required_non_negative_columns) }}