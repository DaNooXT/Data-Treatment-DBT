{{
    config(
        materialized='incremental',
        incremental_strategy='merge',
        unique_key='source_record_key',
        file_format='delta'
    )
}}

SELECT
    *
FROM
    {{ source('source', 'raw_sales') }}