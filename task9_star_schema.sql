-- ================================
-- Task 9: SQL Data Modeling - Star Schema
-- Dataset: Global Superstore
-- ================================

-- ----------------
-- RAW SALES TABLE
-- ----------------
-- (This table is created from CSV using Python/SQLite)
-- Table name: sales_raw


-- ----------------
-- DIMENSION TABLES
-- ----------------

-- Customer Dimension
CREATE TABLE dim_customer (
    customer_id INTEGER PRIMARY KEY AUTOINCREMENT,
    customer_name TEXT
);

INSERT INTO dim_customer (customer_name)
SELECT DISTINCT "Customer Name"
FROM sales_raw;


-- Product Dimension
CREATE TABLE dim_product (
    product_id INTEGER PRIMARY KEY AUTOINCREMENT,
    product_name TEXT,
    category TEXT,
    sub_category TEXT
);

INSERT INTO dim_product (product_name, category, sub_category)
SELECT DISTINCT
    "Product Name",
    Category,
    "Sub-Category"
FROM sales_raw;


-- Date Dimension
CREATE TABLE dim_date (
    date_id INTEGER PRIMARY KEY AUTOINCREMENT,
    order_date TEXT,
    year INTEGER,
    month INTEGER
);

INSERT INTO dim_date (order_date, year, month)
SELECT DISTINCT
    "Order Date",
    substr("Order Date", -4),
    substr("Order Date", 4, 2)
FROM sales_raw;


-- ----------------
-- FACT TABLE
-- ----------------

CREATE TABLE fact_sales (
    sales_id INTEGER PRIMARY KEY AUTOINCREMENT,
    customer_id INTEGER,
    product_id INTEGER,
    date_id INTEGER,
    sales REAL,
    quantity INTEGER,
    profit REAL,
    FOREIGN KEY (customer_id) REFERENCES dim_customer(customer_id),
    FOREIGN KEY (product_id) REFERENCES dim_product(product_id),
    FOREIGN KEY (date_id) REFERENCES dim_date(date_id)
);


-- ----------------
-- LOAD FACT TABLE
-- ----------------

INSERT INTO fact_sales (
    customer_id,
    product_id,
    date_id,
    sales,
    quantity,
    profit
)
SELECT
    c.customer_id,
    p.product_id,
    d.date_id,
    s.Sales,
    s.Quantity,
    s.Profit
FROM sales_raw s
JOIN dim_customer c
    ON s."Customer Name" = c.customer_name
JOIN dim_product p
    ON s."Product Name" = p.product_name
JOIN dim_date d
    ON s."Order Date" = d.order_date;


-- ----------------
-- ANALYTICS QUERY
-- ----------------

-- Top customers by total sales
SELECT
    c.customer_name,
    SUM(f.sales) AS total_sales
FROM fact_sales f
JOIN dim_customer c
    ON f.customer_id = c.customer_id
GROUP BY c.customer_name
ORDER BY total_sales DESC
LIMIT 5;
