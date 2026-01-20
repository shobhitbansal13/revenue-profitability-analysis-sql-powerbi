/* ============================================================
   STAGING LAYER
   Project: Revenue & Profitability Analysis
   Purpose:
   - Clean and standardize raw data
   - Resolve data quality issues identified in raw audit
   - Preserve original business meaning
   - Prepare analytics-ready datasets
   ------------------------------------------------------------
   IMPORTANT PRINCIPLES:
   - No aggregations in staging
   - No business KPIs calculated
   - No joins across fact tables
   - All transformations are explicit and traceable
   ============================================================ */


/* ============================================================
   1. STAGING: ORDERS
   Source: raw.orders
   Target: staging.orders_clean
   ============================================================ */

CREATE OR REPLACE VIEW staging.orders_clean AS
SELECT
    /* =====================
       Identifiers
       ===================== */
    NULLIF(TRIM(o.order_id), '') AS order_id,
    NULLIF(TRIM(o.customer_id), '') AS customer_id,
    NULLIF(TRIM(o.product_id), '') AS product_id,

    /* =====================
       Order date normalization
       - Multiple formats handled conservatively
       - Ambiguous dates resolved consistently
       ===================== */
    CASE
        WHEN o.order_date REGEXP '^[0-9]{4}-[0-9]{1,2}-[0-9]{1,2}$'
            THEN STR_TO_DATE(TRIM(o.order_date), '%Y-%m-%d')

        WHEN o.order_date REGEXP '^[0-9]{4}/[0-9]{1,2}/[0-9]{1,2}$'
            THEN STR_TO_DATE(TRIM(o.order_date), '%Y/%m/%d')

        WHEN o.order_date REGEXP '^[0-9]{1,2}/[0-9]{1,2}/[0-9]{4}$'
             AND CAST(SUBSTRING_INDEX(o.order_date, '/', 1) AS UNSIGNED) > 12
            THEN STR_TO_DATE(TRIM(o.order_date), '%d/%m/%Y')

        WHEN o.order_date REGEXP '^[0-9]{1,2}-[0-9]{1,2}-[0-9]{4}$'
             AND CAST(SUBSTRING_INDEX(o.order_date, '-', 1) AS UNSIGNED) > 12
            THEN STR_TO_DATE(TRIM(o.order_date), '%d-%m-%Y')

        WHEN o.order_date REGEXP '^[0-9]{1,2}/[0-9]{1,2}/[0-9]{4}$'
             AND CAST(
                 SUBSTRING_INDEX(
                     SUBSTRING_INDEX(o.order_date, '/', 2),
                     '/',
                     -1
                 ) AS UNSIGNED
             ) > 12
            THEN STR_TO_DATE(TRIM(o.order_date), '%m/%d/%Y')

        WHEN o.order_date REGEXP '^[0-9]{1,2}-[0-9]{1,2}-[0-9]{4}$'
             AND CAST(
                 SUBSTRING_INDEX(
                     SUBSTRING_INDEX(o.order_date, '-', 2),
                     '-',
                     -1
                 ) AS UNSIGNED
             ) > 12
            THEN STR_TO_DATE(TRIM(o.order_date), '%m-%d-%Y')

        ELSE NULL
    END AS order_date,

    /* =====================
       Numeric fields (cleaned but not imputed)
       ===================== */
    CAST(NULLIF(TRIM(o.quantity), '') AS SIGNED) AS quantity,
    CAST(NULLIF(TRIM(o.price), '') AS DECIMAL(10,2)) AS price,
    CAST(NULLIF(TRIM(o.discount_amount), '') AS DECIMAL(10,2)) AS discount_amount,

    /* =====================
       Categorical normalization
       ===================== */
    UPPER(TRIM(o.order_status)) AS order_status,
    UPPER(TRIM(o.region)) AS region

FROM raw.orders o
WHERE
    o.order_id IS NOT NULL
    AND o.order_id <> 'order_id';


/* ============================================================
   2. STAGING: CUSTOMERS
   Source: raw.customers
   Target: staging.customers_clean
   ============================================================ */

CREATE OR REPLACE VIEW staging.customers_clean AS
SELECT
    /* =====================
       Identifiers
       ===================== */
    NULLIF(TRIM(c.customer_id), '') AS customer_id,

    /* =====================
       Customer name (cleaned, not reconstructed)
       ===================== */
    NULLIF(TRIM(c.customer_name), '') AS customer_name,

    /* =====================
       Signup date normalization
       (same logic as orders)
       ===================== */
    CASE
        WHEN c.signup_date REGEXP '^[0-9]{4}-[0-9]{1,2}-[0-9]{1,2}$'
            THEN STR_TO_DATE(TRIM(c.signup_date), '%Y-%m-%d')

        WHEN c.signup_date REGEXP '^[0-9]{4}/[0-9]{1,2}/[0-9]{1,2}$'
            THEN STR_TO_DATE(TRIM(c.signup_date), '%Y/%m/%d')

        WHEN c.signup_date REGEXP '^[0-9]{1,2}/[0-9]{1,2}/[0-9]{4}$'
             AND CAST(SUBSTRING_INDEX(c.signup_date, '/', 1) AS UNSIGNED) > 12
            THEN STR_TO_DATE(TRIM(c.signup_date), '%d/%m/%Y')

        WHEN c.signup_date REGEXP '^[0-9]{1,2}-[0-9]{1,2}-[0-9]{4}$'
             AND CAST(SUBSTRING_INDEX(c.signup_date, '-', 1) AS UNSIGNED) > 12
            THEN STR_TO_DATE(TRIM(c.signup_date), '%d-%m-%Y')

        WHEN c.signup_date REGEXP '^[0-9]{1,2}/[0-9]{1,2}/[0-9]{4}$'
             AND CAST(
                 SUBSTRING_INDEX(
                     SUBSTRING_INDEX(c.signup_date, '/', 2),
                     '/',
                     -1
                 ) AS UNSIGNED
             ) > 12
            THEN STR_TO_DATE(TRIM(c.signup_date), '%m/%d/%Y')

        WHEN c.signup_date REGEXP '^[0-9]{1,2}-[0-9]{1,2}-[0-9]{4}$'
             AND CAST(
                 SUBSTRING_INDEX(
                     SUBSTRING_INDEX(c.signup_date, '-', 2),
                     '-',
                     -1
                 ) AS UNSIGNED
             ) > 12
            THEN STR_TO_DATE(TRIM(c.signup_date), '%m-%d-%Y')

        ELSE NULL
    END AS signup_date,

    /* =====================
       Location normalization
       ===================== */
    UPPER(TRIM(c.city)) AS city,
    UPPER(TRIM(c.region)) AS region

FROM raw.customers c
WHERE
    c.customer_id IS NOT NULL;


/* ============================================================
   3. STAGING: PRODUCTS
   Source: raw.products
   Target: staging.products_clean
   ============================================================ */

CREATE OR REPLACE VIEW staging.products_clean AS
SELECT
    /* =====================
       Identifiers
       ===================== */
    NULLIF(TRIM(p.product_id), '') AS product_id,

    /* =====================
       Product attributes
       ===================== */
    NULLIF(TRIM(p.product_name), '') AS product_name,
    UPPER(TRIM(p.category)) AS category,

    /* =====================
       Cost normalization
       ===================== */
    CAST(NULLIF(TRIM(p.cost_price), '') AS DECIMAL(10,2)) AS cost_price

FROM raw.products p
WHERE
    p.product_id IS NOT NULL;


/* ============================================================
   STAGING SUMMARY
   ============================================================ */

-- All data quality issues identified in raw audit
-- are explicitly handled here.
--
-- No aggregations, KPIs, or joins across facts
-- are performed in the staging layer.
--
-- This layer serves as the single source of truth
-- for clean, analytics-ready data.
--
-- End of staging views
