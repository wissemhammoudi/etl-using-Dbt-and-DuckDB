WITH raw AS (
    SELECT
        invoice_no,
        customer_id,
        gender,
        age,
        category,
        quantity,
        price,
        payment_method,
        STRFTIME('%Y-%m-%d', CAST(invoice_date AS TIMESTAMP)) AS invoice_date,
        shopping_mall
    FROM raw_customer_shopping
)

SELECT
    invoice_no,
    customer_id,
    gender,
    age,
    category,
    quantity,
    price,
    payment_method,
    invoice_date,
    shopping_mall
FROM raw
