# Sample PostgreSQL Star Schema Project

This repository contains a sample PostgreSQL database built using a star schema. The database comprises one fact table and five dimension tables. Data is loaded from CSV files (encoded in Windows-1252) using a Dockerized PostgreSQL instance.

![Database Schema](schema.jpg)

---

## Quick Start

1. **Prerequisites:**
   - [Docker Desktop](https://www.docker.com/products/docker-desktop) (ensure Docker is running)
   - A Bash environment (e.g., Git Bash or WSL on Windows)
   - `unzip` utility (to extract the data archive)

2. **Clone the Repository:**
   
   git clone <repository-url>
   cd <repository-folder>

3. **Run the Setup Script:**

Make the script executable and run it:
    
    chmod +x setup.sh
    ./setup.sh

The script will:
- Extract sample_data.zip (which contains all CSV data files) into a data folder.
- Remove any existing PostgreSQL Docker container named some-postgres.
- Launch a new PostgreSQL Docker container with port 5432 exposed.
- Mount the local data folder into the container at /var/lib/postgresql/csv.
- Copy and execute the init.sql script inside the container to create the database (sampledb), create the tables, and load the data.

4. **Connect to the Database:**

Use the following connection string:
postgresql://postgres:mysecretpassword@localhost:5432/sampledb

Or, if you prefer connection parameters:
host=localhost port=5432 dbname=sampledb user=postgres password=mysecretpassword


## Database Structure

### Fact Table: `fact_table`

- **payment_key**: Payment identifier (foreign key to `payment_dim`)
- **customer_key**: Customer identifier (foreign key to `customer_dim`)
- **time_key**: Time dimension identifier (foreign key to `time_dim`)
- **item_key**: Item identifier (foreign key to `item_dim`)
- **store_key**: Store identifier (foreign key to `store_dim`)
- **quantity**: Quantity sold
- **unit**: Unit of measurement
- **unit_price**: Price per unit
- **total_price**: Total price for the transaction

### Dimension Tables

#### `payment_dim`
- **payment_key**: Unique payment identifier
- **trans_type**: Transaction type (e.g., cash, credit)
- **bank_name**: Bank name

#### `customer_dim`
- **customer_key**: Unique customer identifier
- **name**: Customer name
- **contact_no**: Contact number
- **nid**: National ID

#### `item_dim`
- **item_key**: Unique item identifier
- **item_name**: Item name
- **description**: Item description
- **unit_price**: Price per unit
- **man_country**: Manufacturing country
- **supplier**: Supplier name
- **unit**: Unit of measurement

#### `store_dim`
- **store_key**: Unique store identifier
- **division**: Division
- **district**: District
- **upazila**: Upazila (sub-district)

#### `time_dim`
- **time_key**: Unique time identifier
- **date**: Timestamp (e.g., "20-05-2017 14:56")
- **hour**: Hour of the day
- **day**: Day of the month
- **week**: Week (as text, e.g., "3rd Week")
- **month**: Month (as an integer)
- **quarter**: Quarter (as text, e.g., "Q2")
- **year**: Year

---

## Data Files

All data is provided as CSV files encoded in Windows-1252:

- **Trans_dim.csv** – data for `payment_dim`
- **customer_dim.csv** – data for `customer_dim`
- **item_dim.csv** – data for `item_dim`
- **store_dim.csv** – data for `store_dim`
- **time_dim.csv** – data for `time_dim`
- **fact_table.csv** – data for `fact_table`


Originally data from https://www.kaggle.com/datasets/mmohaiminulislam/ecommerce-data-analysis?resource=download