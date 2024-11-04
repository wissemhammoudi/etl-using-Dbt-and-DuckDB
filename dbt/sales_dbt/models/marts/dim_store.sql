-- models/marts/dim_store.sql

WITH staging AS (
    SELECT
        DISTINCT shopping_mall,
        'Location Placeholder' AS location,  -- Update with actual location data if available
        'Mall Type Placeholder' AS mall_type    -- Update with actual mall type data if available
    FROM {{ ref('stg_customer_shopping') }}
)

SELECT
    ROW_NUMBER() OVER (ORDER BY shopping_mall) AS store_key,
    shopping_mall,
    location,
    mall_type
FROM staging
