-- models/marts/fact_sales.sql

SELECT
    ROW_NUMBER() OVER (ORDER BY stg.invoice_no) AS sale_id,
    stg.invoice_no,
    dim_customer.customer_key,
    dim_product.product_key,
    dim_date.date_key,
    dim_payment.payment_key,
    dim_store.store_key,
    stg.quantity,
    stg.price,
    stg.quantity * stg.price AS total_amount
FROM {{ ref('stg_customer_shopping') }} AS stg
LEFT JOIN {{ ref('dim_customer') }} AS dim_customer
    ON stg.customer_id = dim_customer.customer_id
LEFT JOIN {{ ref('dim_product') }} AS dim_product
    ON stg.category = dim_product.category_name
LEFT JOIN {{ ref('dim_date') }} AS dim_date
    ON stg.invoice_date = dim_date.invoice_date
LEFT JOIN {{ ref('dim_payment') }} AS dim_payment
    ON stg.payment_method = dim_payment.payment_method
LEFT JOIN {{ ref('dim_store') }} AS dim_store
    ON stg.shopping_mall = dim_store.shopping_mall
