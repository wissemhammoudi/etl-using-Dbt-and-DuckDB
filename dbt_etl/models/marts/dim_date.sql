-- models/marts/dim_date.sql

WITH staging AS (
    SELECT
        DISTINCT CAST(invoice_date AS DATE) AS invoice_date  -- Ensure the date is cast to DATE
    FROM {{ ref('stg_customer_shopping') }}
)

SELECT
    ROW_NUMBER() OVER (ORDER BY invoice_date) AS date_key,
    invoice_date,
    STRFTIME('%Y', invoice_date) AS year,  -- Move format string to the first argument
    STRFTIME('%m', invoice_date) AS month,
    STRFTIME('%d', invoice_date) AS day,
    STRFTIME('%A', invoice_date) AS day_of_week,
    CASE
        WHEN STRFTIME('%m', invoice_date) IN ('01', '04', '07', '10') THEN 1
        WHEN STRFTIME('%m', invoice_date) IN ('02', '05', '08', '11') THEN 2
        WHEN STRFTIME('%m', invoice_date) IN ('03', '06', '09', '12') THEN 3
    END AS quarter,
    CASE
        WHEN STRFTIME('%w', invoice_date) IN ('0', '6') THEN TRUE
        ELSE FALSE
    END AS is_weekend,
    FALSE AS is_holiday
FROM staging
