-- Drop the database sampledb if it exists and create a new one
DROP DATABASE IF EXISTS sampledb;
CREATE DATABASE sampledb;

\connect sampledb

-- Set the session parameter to parse dates in DMY format (e.g., "20-05-2017 14:56")
SET datestyle TO 'DMY';

-- Drop tables if they exist (drop order is important due to foreign keys)
DROP TABLE IF EXISTS fact_table;
DROP TABLE IF EXISTS payment_dim;
DROP TABLE IF EXISTS customer_dim;
DROP TABLE IF EXISTS item_dim;
DROP TABLE IF EXISTS store_dim;
DROP TABLE IF EXISTS time_dim;

-- Create the payments table
CREATE TABLE payment_dim (
    payment_key TEXT PRIMARY KEY,
    trans_type  TEXT,
    bank_name   TEXT
);

-- Create the customers table
CREATE TABLE customer_dim (
    customer_key TEXT PRIMARY KEY,
    name         TEXT,
    contact_no   TEXT,
    nid          TEXT
);

-- Create the items table
CREATE TABLE item_dim (
    item_key    TEXT PRIMARY KEY,
    item_name   TEXT,
    description TEXT,
    unit_price  NUMERIC(10,2),
    man_country TEXT,
    supplier    TEXT,
    unit        TEXT
);

-- Create the stores table
CREATE TABLE store_dim (
    store_key TEXT PRIMARY KEY,
    division  TEXT,
    district  TEXT,
    upazila   TEXT
);

-- Create the time dimension table
CREATE TABLE time_dim (
    time_key TEXT PRIMARY KEY,
    date TIMESTAMP,       -- Example: "20-05-2017 14:56"
    hour INTEGER,         -- Hour
    day INTEGER,          -- Day of the month (number)
    week TEXT,            -- Week (e.g., "3rd Week")
    month INTEGER,        -- Month (e.g., 5)
    quarter TEXT,         -- Quarter (e.g., "Q2")
    year INTEGER          -- Year
);

-- Create the fact table
CREATE TABLE fact_table (
    payment_key TEXT,
    customer_key TEXT,
    time_key TEXT,
    item_key TEXT,
    store_key TEXT,
    quantity INTEGER,
    unit TEXT,
    unit_price NUMERIC(10,2),
    total_price NUMERIC(10,2),
    FOREIGN KEY (payment_key) REFERENCES payment_dim(payment_key),
    FOREIGN KEY (customer_key) REFERENCES customer_dim(customer_key),
    FOREIGN KEY (time_key) REFERENCES time_dim(time_key),
    FOREIGN KEY (item_key) REFERENCES item_dim(item_key),
    FOREIGN KEY (store_key) REFERENCES store_dim(store_key)
);

-- Load data from CSV files with WIN1252 encoding

COPY payment_dim(payment_key, trans_type, bank_name)
FROM '/var/lib/postgresql/csv/Trans_dim.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'WIN1252');

COPY customer_dim(customer_key, name, contact_no, nid)
FROM '/var/lib/postgresql/csv/customer_dim.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'WIN1252');

COPY item_dim(item_key, item_name, description, unit_price, man_country, supplier, unit)
FROM '/var/lib/postgresql/csv/item_dim.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'WIN1252');

COPY store_dim(store_key, division, district, upazila)
FROM '/var/lib/postgresql/csv/store_dim.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'WIN1252');

COPY time_dim(time_key, date, hour, day, week, month, quarter, year)
FROM '/var/lib/postgresql/csv/time_dim.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'WIN1252');

COPY fact_table(payment_key, customer_key, time_key, item_key, store_key, quantity, unit, unit_price, total_price)
FROM '/var/lib/postgresql/csv/fact_table.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'WIN1252');
