## Data and Transformations Documentation

This document describes the source data, staging logic, dimensional models, and fact model implemented in `dbt_etl`.

### Source data

- Location: `dbt_etl/data/customer_shopping_data.csv`
- Loaded into table: `raw_customer_shopping` by `dbt_etl/load_data_duckdb.py`
- Expected columns:
  - `invoice_no`
  - `customer_id`
  - `gender`
  - `age`
  - `category`
  - `quantity`
  - `price`
  - `payment_method`
  - `invoice_date` (CSV format: `DD/MM/YYYY`, converted to `YYYY-MM-DD`)
  - `shopping_mall`

Loader highlights (`dbt_etl/load_data_duckdb.py`):
- Reads the CSV with pandas
- Converts `invoice_date` from `%d/%m/%Y` to `%Y-%m-%d`
- Creates `raw_customer_shopping` from the DataFrame

### Staging model

Model: `models/staging/stg_customer_shopping.sql`

- Normalizes `invoice_date` to `YYYY-MM-DD` and selects fields from `raw_customer_shopping`.
- Column tests (`models/staging/stg_customer_shopping.yaml`):
  - `invoice_no`: unique, not null
  - `customer_id`, `gender`, `age`, `category`, `quantity`, `price`, `payment_method`, `shopping_mall`: not null

Schema (staging):
- `invoice_no`, `customer_id`, `gender`, `age`, `category`, `quantity`, `price`, `payment_method`, `invoice_date`, `shopping_mall`

### Dimensional models

All dimensions are built from `stg_customer_shopping` using surrogate keys via `row_number()`.

1) `models/marts/dim_customer.sql`
- Columns: `customer_key` (surrogate), `customer_id`, `gender`, `age`
- Tests (`dim_customer.yml`):
  - `customer_id`: not null, unique
  - `gender`: not null, accepted values ['Male','Female']
  - `age`: not null

2) `models/marts/dim_product.sql`
- Columns: `product_key` (surrogate), `category_id` (surrogate), `category_name`
- Tests (`dim_product.yml`):
  - `product_key`: not null, unique
  - `category_id`: not null, unique
  - `category_name`: not null

3) `models/marts/dim_payment.sql`
- Columns: `payment_key` (surrogate), `payment_method`
- Tests (`dim_payment.yml`):
  - `payment_key`: not null, unique
  - `payment_method`: not null, unique, accepted values ['Credit Card','Cash','Debit Card']

4) `models/marts/dim_store.sql`
- Columns: `store_key` (surrogate), `shopping_mall`, `location`, `mall_type`
- Notes: `location` and `mall_type` are placeholders in SQL; replace with actual enrichment when available.
- Tests (`dim_store.yml`):
  - `store_key`: not null, unique
  - `shopping_mall`: not null, unique
  - `location`: not null
  - `mall_type`: not null

5) `models/marts/dim_date.sql`
- Columns: `date_key` (surrogate), `invoice_date` (DATE), `year`, `month`, `day`, `day_of_week`, `quarter`, `is_weekend`, `is_holiday`
- Logic:
  - Casts invoice_date to DATE
  - Derives calendar attributes
  - Weekend flag from weekday number; `is_holiday` default FALSE
- Tests (`dim_date.yml`):
  - `date_key`: not null, unique
  - `invoice_date`, `year`, `month`, `day`, `day_of_week`, `quarter`, `is_weekend`, `is_holiday`: not null
  - `quarter`: accepted values [1,2,3,4]

### Fact model

Model: `models/marts/fact_sales.sql`

- Grain: one row per invoice line item
- Surrogate `sale_id` via `row_number()` ordered by `invoice_no`
- Natural-key joins:
  - `stg.customer_id` -> `dim_customer.customer_id`
  - `stg.category` -> `dim_product.category_name`
  - `stg.invoice_date` -> `dim_date.invoice_date`
  - `stg.payment_method` -> `dim_payment.payment_method`
  - `stg.shopping_mall` -> `dim_store.shopping_mall`
- Measures:
  - `quantity`, `price`
  - `total_amount = quantity * price`

Fact schema:
- `sale_id`, `invoice_no`, `customer_key`, `product_key`, `date_key`, `payment_key`, `store_key`, `quantity`, `price`, `total_amount`

### Lineage

```
CSV -> load_data_duckdb.py -> raw_customer_shopping -> stg_customer_shopping ->
  ├─ dim_customer
  ├─ dim_product
  ├─ dim_date
  ├─ dim_payment
  └─ dim_store
                      \
                       -> fact_sales (joins all dims)
```

### Data quality tests (summary)

- Uniqueness and not-null checks on keys and important attributes
- Accepted values where applicable (gender, quarter, payment_method)
