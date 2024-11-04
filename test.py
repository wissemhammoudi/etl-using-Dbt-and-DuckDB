import duckdb

# Connect to your DuckDB database
con = duckdb.connect('C:/Users/wissh/OneDrive/Bureau/etl/dbt/duckdb_database/sales_database.duckdb')

# List of tables to fetch data from
tables = ['dim_customer',  'dim_payment', 'dim_product', 'dim_store','raw_customer_shopping','stg_customer_shopping','dim_date','fact_sales']
# Loop through each table and fetch 5 rows
for table in tables:
    print(f"\nFetching 5 rows from table: {table}")
    result = con.execute(f"SELECT * FROM {table} LIMIT 5").fetchdf()
    print(result)
