-- models/marts/dim_product.sql

WITH staging AS (
    SELECT
        DISTINCT
        category
    FROM {{ ref('stg_customer_shopping') }}
)

SELECT
    ROW_NUMBER() OVER (ORDER BY category) AS product_key,
    ROW_NUMBER() OVER (ORDER BY category) AS category_id,
    category AS category_name
FROM staging
