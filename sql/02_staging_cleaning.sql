-- SQL staging layer for data cleaning and standardization

/* =========================================================
   STAGING LAYER
   Purpose:
   - Clean and standardize raw data
   - Preserve lineage (no updates to raw tables)
   - Prepare analytics-ready views
   ========================================================= */

------------------------------------------------------------
-- Orders (Fact Table)
------------------------------------------------------------
CREATE OR REPLACE VIEW staging.orders_clean AS
SELECT
    /* =====================
       Identifiers (whitespace-safe)
       ===================== */
    NULLIF(TRIM(REPLACE(REPLACE(REPLACE(o.order_id, '\r',''), '\n',''), '\t','')), '')     AS order_id,
    NULLIF(TRIM(REPLACE(REPLACE(REPLACE(o.customer_id, '\r',''), '\n',''), '\t','')), '')  AS customer_id,
    NULLIF(TRIM(REPLACE(REPLACE(REPLACE(o.product_id, '\r',''), '\n',''), '\t','')), '')   AS product_id,

    /* =====================
       Order Date (safe parsing, no guessing)
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
       Numeric fields (whitespace-safe before cast)
       ===================== */
    CAST(
        NULLIF(TRIM(REPLACE(REPLACE(REPLACE(o.quantity, '\r',''), '\n',''), '\t','')), '')
        AS SIGNED
    ) AS quantity,

    CAST(
        NULLIF(TRIM(REPLACE(REPLACE(REPLACE(o.price, '\r',''), '\n',''), '\t','')), '')
        AS DECIMAL(10,2)
    ) AS price,

    CAST(
        NULLIF(TRIM(REPLACE(REPLACE(REPLACE(o.discount_amount, '\r',''), '\n',''), '\t','')), '')
        AS DECIMAL(10,2)
    ) AS discount_amount,

    /* =====================
       Categorical fields (normalized)
       ===================== */
    UPPER(
        NULLIF(TRIM(REPLACE(REPLACE(REPLACE(o.order_status, '\r',''), '\n',''), '\t','')), '')
    ) AS order_status,

    UPPER(
        NULLIF(TRIM(REPLACE(REPLACE(REPLACE(o.region, '\r',''), '\n',''), '\t','')), '')
    ) AS region

FROM raw.orders o

/* =====================
   Structural cleanup
   ===================== */
WHERE
    NULLIF(TRIM(o.order_id), '') IS NOT NULL
    AND o.order_id <> 'order_id'

/* =====================
   Data quality enforcement
   ===================== */
    AND CAST(
        NULLIF(TRIM(REPLACE(REPLACE(REPLACE(o.quantity, '\r',''), '\n',''), '\t','')), '')
        AS SIGNED
    ) > 0

    AND CAST(
        NULLIF(TRIM(REPLACE(REPLACE(REPLACE(o.price, '\r',''), '\n',''), '\t','')), '')
        AS DECIMAL(10,2)
    ) >= 0

/* =====================
   Referential integrity
   ===================== */
    AND EXISTS (
        SELECT 1
        FROM raw.customers c
        WHERE c.customer_id = o.customer_id
    )
    AND EXISTS (
        SELECT 1
        FROM raw.products p
        WHERE p.product_id = o.product_id
    )
;

------------------------------------------------------------
-- Customers (Dimension Table)
------------------------------------------------------------
CREATE OR REPLACE VIEW staging.customers_clean AS
SELECT
    /* =====================
       Identifiers (whitespace-safe, immutable)
       ===================== */
    NULLIF(
        TRIM(REPLACE(REPLACE(REPLACE(c.customer_id, '\r',''), '\n',''), '\t','')),
        ''
    ) AS customer_id,

    /* =====================
       Customer Name 
       ===================== */
    NULLIF(
        TRIM(REPLACE(REPLACE(REPLACE(c.customer_name, '\r',''), '\n',''), '\t','')),
        ''
    ) AS customer_name,

    /* =====================
       Signup Date (same logic as orders)
       ===================== */
    CASE
        /* ISO format YYYY-MM-DD */
        WHEN c.signup_date REGEXP '^[0-9]{4}-[0-9]{1,2}-[0-9]{1,2}$'
            THEN STR_TO_DATE(TRIM(c.signup_date), '%Y-%m-%d')

        /* ISO format YYYY/MM/DD */
        WHEN c.signup_date REGEXP '^[0-9]{4}/[0-9]{1,2}/[0-9]{1,2}$'
            THEN STR_TO_DATE(TRIM(c.signup_date), '%Y/%m/%d')

        /* DD/MM/YYYY where day > 12 */
        WHEN c.signup_date REGEXP '^[0-9]{1,2}/[0-9]{1,2}/[0-9]{4}$'
             AND CAST(SUBSTRING_INDEX(c.signup_date, '/', 1) AS UNSIGNED) > 12
            THEN STR_TO_DATE(TRIM(c.signup_date), '%d/%m/%Y')

        /* DD-MM-YYYY where day > 12 */
        WHEN c.signup_date REGEXP '^[0-9]{1,2}-[0-9]{1,2}-[0-9]{4}$'
             AND CAST(SUBSTRING_INDEX(c.signup_date, '-', 1) AS UNSIGNED) > 12
            THEN STR_TO_DATE(TRIM(c.signup_date), '%d-%m-%Y')

        /* MM/DD/YYYY where month > 12 */
        WHEN c.signup_date REGEXP '^[0-9]{1,2}/[0-9]{1,2}/[0-9]{4}$'
             AND CAST(
                 SUBSTRING_INDEX(
                     SUBSTRING_INDEX(c.signup_date, '/', 2),
                     '/',
                     -1
                 ) AS UNSIGNED
             ) > 12
            THEN STR_TO_DATE(TRIM(c.signup_date), '%m/%d/%Y')

        /* MM-DD-YYYY where month > 12 */
        WHEN c.signup_date REGEXP '^[0-9]{1,2}-[0-9]{1,2}-[0-9]{4}$'
             AND CAST(
                 SUBSTRING_INDEX(
                     SUBSTRING_INDEX(c.signup_date, '-', 2),
                     '-',
                     -1
                 ) AS UNSIGNED
             ) > 12
            THEN STR_TO_DATE(TRIM(c.signup_date), '%m-%d-%Y')

        /* Ambiguous or invalid */
        ELSE NULL
    END AS signup_date,

    /* =====================
       Location fields (normalized, not reconstructed)
       ===================== */
    UPPER(
        NULLIF(TRIM(REPLACE(REPLACE(REPLACE(c.city, '\r',''), '\n',''), '\t','')), '')
    ) AS city,

    UPPER(
        NULLIF(TRIM(REPLACE(REPLACE(REPLACE(c.region, '\r',''), '\n',''), '\t','')), '')
    ) AS region
     
     FROM raw.customers c

/* =====================
   Structural validity
   ===================== */
WHERE
    NULLIF(TRIM(c.customer_id), '') IS NOT NULL
    AND c.customer_id <> 'customer_id'
;

------------------------------------------------------------
-- Products (Dimension Table)
------------------------------------------------------------
CREATE OR REPLACE VIEW staging.products_clean AS
SELECT
    /* =====================
       Product Identifier (immutable)
       ===================== */
    NULLIF(
        TRIM(
            REPLACE(
                REPLACE(
                    REPLACE(p.product_id, '\r',''),
                '\n',''),
            '\t','')
        ),
        ''
    ) AS product_id,

    /* =====================
       Product Name (truthful)
       ===================== */
    NULLIF(
        TRIM(
            REPLACE(
                REPLACE(
                    REPLACE(p.product_name, '\r',''),
                '\n',''),
            '\t','')
        ),
        ''
    ) AS product_name,

    /* =====================
       Category (normalized, not reconstructed)
       ===================== */
    UPPER(
        NULLIF(
            TRIM(
                REPLACE(
                    REPLACE(
                        REPLACE(p.category, '\r',''),
                    '\n',''),
                '\t','')
            ),
            ''
        )
    ) AS category,

    /* =====================
       Cost Price (whitespace-safe numeric)
       ===================== */
    CAST(
        NULLIF(
            TRIM(
                REPLACE(
                    REPLACE(
                        REPLACE(p.cost_price, '\r',''),
                    '\n',''),
                '\t','')
            ),
            ''
        )
        AS DECIMAL(10,2)
    ) AS cost_price

FROM raw.products p

/* =====================
   Structural validity
   ===================== */
WHERE
    NULLIF(TRIM(p.product_id), '') IS NOT NULL
    AND p.product_id <> 'product_id';


