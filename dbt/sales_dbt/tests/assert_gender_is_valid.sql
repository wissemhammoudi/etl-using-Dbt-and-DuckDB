-- tests/assert_gender_is_valid.sql
SELECT
    customer_id,
    gender
FROM {{ ref('dim_customer') }}  -- Update with your actual model name
WHERE gender NOT IN ('Female', 'Male')
