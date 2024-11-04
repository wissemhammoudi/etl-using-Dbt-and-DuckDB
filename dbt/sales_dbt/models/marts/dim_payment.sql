-- models/marts/dim_payment.sql

WITH staging AS (
    SELECT
        DISTINCT payment_method
    FROM {{ ref('stg_customer_shopping') }}
)

SELECT
    ROW_NUMBER() OVER (ORDER BY payment_method) AS payment_key,
    payment_method
FROM staging
