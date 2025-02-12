#!/bin/bash
# Скрипт для полного сетапа PostgreSQL в Docker и загрузки данных из sample_data.zip

set -e

# Проверяем наличие архива с данными
if [ ! -f sample_data.zip ]; then
  echo "Архив sample_data.zip не найден! Поместите его в текущую директорию."
  exit 1
fi

# Создаём папку для данных, если её ещё нет, и извлекаем архив
if [ ! -d data ]; then
  echo "Создаём папку data..."
  mkdir -p data
fi

echo "Извлекаем sample_data.zip в папку data..."
unzip -o sample_data.zip -d data

# Если контейнер уже существует, удаляем его
if docker ps -a --format '{{.Names}}' | grep -Eq "^some-postgres\$"; then
    echo "Удаляем существующий контейнер some-postgres..."
    docker rm -f some-postgres
fi

echo "Запускаем Docker-контейнер PostgreSQL..."
docker run --name some-postgres \
  -e POSTGRES_PASSWORD=mysecretpassword \
  -p 5432:5432 \
  -v "$(pwd)/data":/var/lib/postgresql/csv \
  -d postgres

echo "Ожидаем запуск PostgreSQL (примерно 10 секунд)..."
sleep 10

# Формируем SQL-скрипт для создания базы, таблиц и загрузки данных.
cat > init.sql <<'EOF'
-- Удаляем базу данных sampledb, если она существует, и создаём новую
DROP DATABASE IF EXISTS sampledb;
CREATE DATABASE sampledb;

\connect sampledb

-- Устанавливаем параметр сеанса для разбора дат в формате DMY (например, "20-05-2017 14:56")
SET datestyle TO 'DMY';

-- Удаляем таблицы, если они существуют (важен порядок удаления из-за внешних ключей)
DROP TABLE IF EXISTS fact_table;
DROP TABLE IF EXISTS payment_dim;
DROP TABLE IF EXISTS customer_dim;
DROP TABLE IF EXISTS item_dim;
DROP TABLE IF EXISTS store_dim;
DROP TABLE IF EXISTS time_dim;

-- Создаём таблицу платежей
CREATE TABLE payment_dim (
    payment_key TEXT PRIMARY KEY,
    trans_type  TEXT,
    bank_name   TEXT
);

-- Создаём таблицу клиентов
CREATE TABLE customer_dim (
    customer_key TEXT PRIMARY KEY,
    name         TEXT,
    contact_no   TEXT,
    nid          TEXT
);

-- Создаём таблицу товаров
CREATE TABLE item_dim (
    item_key    TEXT PRIMARY KEY,
    item_name   TEXT,
    description TEXT,
    unit_price  NUMERIC(10,2),
    man_country TEXT,
    supplier    TEXT,
    unit        TEXT
);

-- Создаём таблицу магазинов
CREATE TABLE store_dim (
    store_key TEXT PRIMARY KEY,
    division  TEXT,
    district  TEXT,
    upazila   TEXT
);

-- Создаём таблицу времени
CREATE TABLE time_dim (
    time_key TEXT PRIMARY KEY,
    date TIMESTAMP,       -- Пример: "20-05-2017 14:56"
    hour INTEGER,         -- Час
    day INTEGER,          -- День месяца (число)
    week TEXT,            -- Неделя (например, "3rd Week")
    month INTEGER,        -- Месяц (например, 5)
    quarter TEXT,         -- Квартал (например, "Q2")
    year INTEGER          -- Год
);

-- Создаём факт-таблицу
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

-- Загрузка данных из CSV-файлов с указанием кодировки WIN1252

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
EOF

# Копируем init.sql в контейнер
echo "Копируем init.sql в контейнер..."
docker cp init.sql some-postgres:/init.sql

echo "Выполняем SQL-скрипт внутри контейнера..."
docker exec -i some-postgres psql -U postgres -f /init.sql

echo "Сетап завершён!"
echo "Подключайтесь к PostgreSQL по адресу localhost:5432, база данных 'sampledb', пользователь 'postgres', пароль 'mysecretpassword'."
echo "postgresql://postgres:mysecretpassword@localhost:5432/sampledb"
echo "host=localhost port=5432 dbname=sampledb user=postgres password=mysecretpassword"
