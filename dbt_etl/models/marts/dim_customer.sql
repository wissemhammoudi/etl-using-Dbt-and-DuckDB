-- models/marts/dim_customer.sql

WITH staging AS (
    SELECT
        DISTINCT
        customer_id,
        gender,
        age
    FROM {{ ref('stg_customer_shopping') }}
)

SELECT
    ROW_NUMBER() OVER (ORDER BY customer_id) AS customer_key,
    customer_id,
    gender,
    age
FROM staging
