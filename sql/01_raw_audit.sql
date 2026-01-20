/* ============================================================
   RAW DATA AUDIT
   Project: Revenue & Profitability Analysis
   Purpose:
   - Assess data quality before any transformation
   - Identify risks, inconsistencies, and assumptions
   - Ensure transparency before staging & analytics
   ------------------------------------------------------------
   IMPORTANT:
   - No data is modified in this file
   - All queries are read-only (SELECT only)
   ============================================================ */


/* ============================================================
   1. ORDERS TABLE AUDIT
   Table: raw.orders
   Grain (expected): One row per order × product
   ============================================================ */

-- 1.1 Row count & basic structure check
SELECT COUNT(*) AS total_rows FROM raw.orders;

-- 1.2 Header row ingestion check (CSV import artifact)
SELECT *
FROM raw.orders
WHERE order_id = 'order_id';

-- Finding:
-- One header row was ingested as data due to CSV import behavior.
-- This row is handled explicitly in the staging layer.


-- 1.3 Primary key validation (order_id)
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT order_id) AS distinct_order_ids
FROM raw.orders;

-- Finding:
-- No duplicate order_id values observed (excluding header row).
-- order_id has no NULL or blank values.


-- 1.4 Missing value checks (critical numeric & date fields)
SELECT
    SUM(order_date IS NULL OR TRIM(order_date) = '') AS missing_order_date,
    SUM(quantity IS NULL OR TRIM(quantity) = '') AS missing_quantity,
    SUM(price IS NULL OR TRIM(price) = '') AS missing_price,
    SUM(discount_amount IS NULL OR TRIM(discount_amount) = '') AS missing_discount
FROM raw.orders;

-- Finding:
-- order_date, quantity, price, and discount_amount contain missing values.
-- These require explicit handling during staging.


-- 1.5 Invalid numeric values
SELECT COUNT(*) AS negative_quantity_rows
FROM raw.orders
WHERE CAST(quantity AS SIGNED) < 0;

-- Finding:
-- Negative quantity values detected.
-- These represent invalid transactions and are handled in staging.


-- 1.6 Data type contamination check
-- Numeric fields containing non-numeric characters
SELECT DISTINCT quantity
FROM raw.orders
WHERE quantity REGEXP '[^0-9.-]';

-- Finding:
-- No irrational characters found in numeric fields beyond formatting issues.


-- 1.7 Categorical consistency (region & order_status)
SELECT DISTINCT region, HEX(region) FROM raw.orders;
SELECT DISTINCT order_status, HEX(order_status) FROM raw.orders;

-- Finding:
-- Inconsistent casing and encoding observed.
-- Same semantic values appear with different HEX representations.
-- Normalized in staging.


-- 1.8 Date format inconsistency
SELECT DISTINCT order_date FROM raw.orders;

-- Finding:
-- Multiple date formats detected (YYYY-MM-DD, DD/MM/YYYY, MM-DD-YYYY).
-- Ambiguous dates handled conservatively in staging.


-- 1.9 Referential integrity (orders → customers, products)
SELECT COUNT(*) AS orphan_customers
FROM raw.orders o
LEFT JOIN raw.customers c
  ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

SELECT COUNT(*) AS orphan_products
FROM raw.orders o
LEFT JOIN raw.products p
  ON o.product_id = p.product_id
WHERE p.product_id IS NULL;

-- Finding:
-- No orphan customer_id or product_id values detected.
-- Referential integrity is intact.


/* ============================================================
   2. CUSTOMERS TABLE AUDIT
   Table: raw.customers
   Grain (expected): One row per customer
   ============================================================ */

-- 2.1 Row count & structure
SELECT COUNT(*) AS total_rows FROM raw.customers;


-- 2.2 Primary key validation
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT customer_id) AS distinct_customer_ids
FROM raw.customers;

-- Finding:
-- No duplicate customer_id values detected.


-- 2.3 Missing value checks
SELECT
    SUM(customer_name IS NULL OR TRIM(customer_name) = '') AS missing_customer_name,
    SUM(signup_date IS NULL OR TRIM(signup_date) = '') AS missing_signup_date
FROM raw.customers;

-- Finding:
-- Missing values present in customer_name and signup_date.
-- These are handled explicitly in staging.


-- 2.4 Date format inconsistency
SELECT DISTINCT signup_date FROM raw.customers;

-- Finding:
-- Multiple date formats detected.
-- Same parsing logic as orders is applied in staging.


-- 2.5 Categorical consistency (city, region)
SELECT DISTINCT city, HEX(city) FROM raw.customers;
SELECT DISTINCT region, HEX(region) FROM raw.customers;

-- Finding:
-- Inconsistent casing and encoding observed.
-- Normalized in staging.


/* ============================================================
   3. PRODUCTS TABLE AUDIT
   Table: raw.products
   Grain (expected): One row per product
   ============================================================ */

-- 3.1 Row count & structure
SELECT COUNT(*) AS total_rows FROM raw.products;


-- 3.2 Primary key validation
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT product_id) AS distinct_product_ids
FROM raw.products;

-- Finding:
-- No duplicate product_id values detected.


-- 3.3 Missing and invalid cost values
SELECT
    SUM(cost_price IS NULL OR TRIM(cost_price) = '') AS missing_cost_price,
    SUM(CAST(cost_price AS DECIMAL(10,2)) < 0) AS negative_cost_price
FROM raw.products;

-- Finding:
-- Missing and negative cost_price values detected.
-- Explicitly handled during staging and analytics.


-- 3.4 Categorical consistency (category)
SELECT DISTINCT category, HEX(category) FROM raw.products;

-- Finding:
-- Category values show casing and encoding inconsistencies.
-- Normalized in staging.


/* ============================================================
   RAW AUDIT SUMMARY
   ============================================================ */

-- Key Risks Identified:
-- - Missing values in critical numeric and date fields
-- - Inconsistent text encoding and casing
-- - Multiple date formats
-- - Negative quantities and costs
-- - CSV header row ingestion

-- Mitigation Strategy:
-- - All issues handled explicitly in staging views
-- - No silent corrections or row drops in raw layer
-- - Financial metrics calculated only after data integrity checks

-- End of raw audit
