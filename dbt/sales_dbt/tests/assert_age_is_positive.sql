-- tests/assert_age_is_positive.sql
SELECT
    customer_id,
    age
FROM {{ ref('dim_customer') }}  -- Update with your actual model name
WHERE age <= 0
