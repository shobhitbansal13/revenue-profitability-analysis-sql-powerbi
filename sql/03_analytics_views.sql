/* ============================================================
   ANALYTICS LAYER
   Project: Revenue & Profitability Analysis
   Purpose:
   - Build analytics-ready fact and summary views
   - Calculate business metrics at the correct grain
   - Preserve mathematical and financial integrity
   ------------------------------------------------------------
   DESIGN PRINCIPLES:
   - Single source of truth for profit calculation
   - Metrics calculated once, aggregated many times
   - No data cleaning or type fixing at this layer
   - Views designed for direct BI consumption
   ============================================================ */


/* ============================================================
   1. ORDER FACT TABLE
   View: analytics.order_fact
   Grain: One row per order × product
   ============================================================ */

CREATE OR REPLACE VIEW analytics.order_fact AS
SELECT
    /* =====================
       Identifiers
       ===================== */
    o.order_id,
    o.order_date,
    o.customer_id,
    o.product_id,

    /* =====================
       Dimensional attributes
       ===================== */
    c.region,
    c.city,
    p.category,
    p.product_name,

    /* =====================
       Base measures (NULL-safe)
       ===================== */
    COALESCE(o.quantity, 0)        AS quantity,
    COALESCE(o.price, 0)           AS price,
    COALESCE(o.discount_amount, 0) AS discount_amount,
    COALESCE(p.cost_price, 0)      AS cost_price,

    /* =====================
       Derived metrics
       ===================== */
    (COALESCE(o.quantity, 0) * COALESCE(o.price, 0)) AS gross_revenue,

    (COALESCE(o.quantity, 0) * COALESCE(o.price, 0))
        - COALESCE(o.discount_amount, 0) AS net_revenue,

    (COALESCE(o.quantity, 0) * COALESCE(p.cost_price, 0)) AS cost,

    (
        (COALESCE(o.quantity, 0) * COALESCE(o.price, 0))
        - COALESCE(o.discount_amount, 0)
    )
    - (COALESCE(o.quantity, 0) * COALESCE(p.cost_price, 0)) AS profit,

    CASE
        WHEN (
            (COALESCE(o.quantity, 0) * COALESCE(o.price, 0))
            - COALESCE(o.discount_amount, 0)
        ) = 0
        THEN NULL
        ELSE
            100 * (
                (
                    (COALESCE(o.quantity, 0) * COALESCE(o.price, 0))
                    - COALESCE(o.discount_amount, 0)
                )
                - (COALESCE(o.quantity, 0) * COALESCE(p.cost_price, 0))
            )
            /
            (
                (COALESCE(o.quantity, 0) * COALESCE(o.price, 0))
                - COALESCE(o.discount_amount, 0)
            )
    END AS margin_pct

FROM staging.orders_clean o
JOIN staging.customers_clean c
  ON o.customer_id = c.customer_id
JOIN staging.products_clean p
  ON o.product_id = p.product_id;


/* ============================================================
   2. MONTHLY KPI SUMMARY
   View: analytics.monthly_kpis
   Grain: One row per year-month
   ============================================================ */

CREATE OR REPLACE VIEW analytics.monthly_kpis AS
SELECT
    DATE_FORMAT(order_date, '%Y-%m-01') AS year_month,

    COUNT(DISTINCT order_id) AS total_orders,
    SUM(quantity) AS total_units,

    SUM(net_revenue) AS total_net_revenue,
    SUM(cost) AS total_cost,
    SUM(profit) AS total_profit,

    CASE
        WHEN SUM(net_revenue) = 0 THEN NULL
        ELSE 100 * SUM(profit) / SUM(net_revenue)
    END AS margin_pct

FROM analytics.order_fact
GROUP BY DATE_FORMAT(order_date, '%Y-%m-01');


/* ============================================================
   3. PRODUCT PROFITABILITY
   View: analytics.product_profitability
   Grain: One row per product
   ============================================================ */

CREATE OR REPLACE VIEW analytics.product_profitability AS
SELECT
    product_id,
    product_name,
    category,

    COUNT(DISTINCT order_id) AS total_orders,
    SUM(quantity) AS total_units,

    SUM(net_revenue) AS total_net_revenue,
    SUM(cost) AS total_cost,
    SUM(profit) AS total_profit,

    CASE
        WHEN SUM(net_revenue) = 0 THEN NULL
        ELSE 100 * SUM(profit) / SUM(net_revenue)
    END AS margin_pct

FROM analytics.order_fact
GROUP BY
    product_id,
    product_name,
    category;


/* ============================================================
   4. REGIONAL PERFORMANCE
   View: analytics.region_performance
   Grain: One row per region
   ============================================================ */

CREATE OR REPLACE VIEW analytics.region_performance AS
SELECT
    region,

    COUNT(DISTINCT order_id) AS total_orders,
    SUM(quantity) AS total_units,

    SUM(net_revenue) AS total_net_revenue,
    SUM(cost) AS total_cost,
    SUM(profit) AS total_profit,

    CASE
        WHEN SUM(net_revenue) = 0 THEN NULL
        ELSE 100 * SUM(profit) / SUM(net_revenue)
    END AS margin_pct

FROM analytics.order_fact
GROUP BY region;


/* ============================================================
   5. DISCOUNT vs MARGIN ANALYSIS
   View: analytics.discount_margin_analysis
   Grain: One row per year-month
   ============================================================ */

CREATE OR REPLACE VIEW analytics.discount_margin_analysis AS
SELECT
    DATE_FORMAT(order_date, '%Y-%m-01') AS year_month,

    AVG(
        CASE
            WHEN (price * quantity) = 0 THEN NULL
            ELSE discount_amount / (price * quantity)
        END
    ) * 100 AS avg_discount_pct,

    CASE
        WHEN SUM(net_revenue) = 0 THEN NULL
        ELSE 100 * SUM(profit) / SUM(net_revenue)
    END AS margin_pct

FROM analytics.order_fact
GROUP BY DATE_FORMAT(order_date, '%Y-%m-01');


/* ============================================================
   ANALYTICS SUMMARY
   ============================================================ */

-- analytics.order_fact:
--   - Single source of truth for all financial metrics
--   - Profit calculated exactly once at atomic grain
--
-- All summary views:
--   - Aggregate existing metrics only
--   - Never recompute profit
--   - Safe for BI consumption
--
-- This layer guarantees:
--   - Mathematical consistency
--   - Reproducible insights
--   - Correct executive reporting
--
-- End of analytics views
