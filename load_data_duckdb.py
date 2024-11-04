import duckdb
import pandas as pd

# Connect to the DuckDB database
conn = duckdb.connect('C:/Users/wissh/OneDrive/Bureau/etl/dbt/duckdb_database/sales_database.duckdb')

# Read the CSV file into a pandas DataFrame
df = pd.read_csv('C:/Users/wissh/OneDrive/Bureau/etl/data/customer_shopping_data.csv')

# Convert the 'invoice_date' column to the desired format (YYYY-MM-DD)
# Adjust the format to match your actual date format (DD/MM/YYYY)
df['invoice_date'] = pd.to_datetime(df['invoice_date'], format='%d/%m/%Y').dt.strftime('%Y-%m-%d')

# Create and populate the main table
conn.execute("DROP TABLE IF EXISTS raw_customer_shopping;")
# Use the DataFrame directly in the SQL query
conn.execute("CREATE TABLE raw_customer_shopping AS SELECT * FROM df;")

# Verify the data
result = conn.execute("SELECT * FROM raw_customer_shopping LIMIT 5;").fetchall()
print(result)

# Close the connection
conn.close()
