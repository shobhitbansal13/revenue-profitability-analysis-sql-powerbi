# Data Dictionary

This document describes tables, columns, and definitions used in the analysis.

# Data Dictionary

This folder documents the structure, meaning, and usage of all datasets used in the project.

The data dictionary serves as:
- A reference for analysts and stakeholders
- A contract for how metrics should be interpreted
- A guide for safe and correct usage in BI tools

The dictionary is organized by data layer:
- Raw tables (as ingested)
- Staging tables (cleaned & standardized)
- Analytics tables (business-ready metrics)

# Raw Tables – Data Dictionary

## raw.orders

| Column Name | Data Type (Raw) | Description | Known Issues |
|------------|-----------------|-------------|--------------|
| order_id | TEXT | Unique identifier for each order | Header row ingested as data |
| order_date | TEXT | Date when order was placed | Multiple formats, missing values |
| customer_id | TEXT | Customer identifier | None |
| product_id | TEXT | Product identifier | None |
| quantity | TEXT | Units sold | Missing values, negative values |
| price | TEXT | Price per unit | Missing values |
| discount_amount | TEXT | Discount applied to order | Missing values |
| order_status | TEXT | Status of order | Encoding & casing issues |
| region | TEXT | Sales region | Encoding & casing issues |

---

## raw.customers

| Column Name | Data Type (Raw) | Description | Known Issues |
|------------|-----------------|-------------|--------------|
| customer_id | TEXT | Unique customer identifier | None |
| customer_name | TEXT | Customer name | Missing values |
| signup_date | TEXT | Customer signup date | Multiple date formats |
| city | TEXT | Customer city | Encoding & casing issues |
| region | TEXT | Customer region | Encoding & casing issues |

---

## raw.products

| Column Name | Data Type (Raw) | Description | Known Issues |
|------------|-----------------|-------------|--------------|
| product_id | TEXT | Unique product identifier | None |
| product_name | TEXT | Product name | Whitespace issues |
| category | TEXT | Product category | Encoding & casing issues |
| cost_price | TEXT | Cost per unit | Missing & negative values |


# Staging Tables – Data Dictionary

## staging.orders_clean

| Column Name | Data Type | Description |
|------------|----------|-------------|
| order_id | VARCHAR | Cleaned order identifier |
| order_date | DATE | Standardized order date |
| customer_id | VARCHAR | Cleaned customer identifier |
| product_id | VARCHAR | Cleaned product identifier |
| quantity | INT | Units sold (validated) |
| price | DECIMAL | Unit selling price |
| discount_amount | DECIMAL | Discount applied |
| order_status | VARCHAR | Normalized order status |
| region | VARCHAR | Normalized region |

---

## staging.customers_clean

| Column Name | Data Type | Description |
|------------|----------|-------------|
| customer_id | VARCHAR | Customer identifier |
| customer_name | VARCHAR | Cleaned customer name |
| signup_date | DATE | Standardized signup date |
| city | VARCHAR | Normalized city |
| region | VARCHAR | Normalized region |

---

## staging.products_clean

| Column Name | Data Type | Description |
|------------|----------|-------------|
| product_id | VARCHAR | Product identifier |
| product_name | VARCHAR | Cleaned product name |
| category | VARCHAR | Normalized category |
| cost_price | DECIMAL | Cost per unit |


# Analytics Tables – Data Dictionary

## analytics.order_fact

**Grain:** One row per order × product

| Column Name | Data Type | Description |
|------------|----------|-------------|
| order_id | VARCHAR | Order identifier |
| order_date | DATE | Order date |
| customer_id | VARCHAR | Customer identifier |
| product_id | VARCHAR | Product identifier |
| region | VARCHAR | Customer region |
| city | VARCHAR | Customer city |
| category | VARCHAR | Product category |
| product_name | VARCHAR | Product name |
| quantity | INT | Units sold |
| price | DECIMAL | Unit selling price |
| discount_amount | DECIMAL | Discount applied |
| cost_price | DECIMAL | Unit cost |
| gross_revenue | DECIMAL | price × quantity |
| net_revenue | DECIMAL | gross_revenue − discount |
| cost | DECIMAL | cost_price × quantity |
| profit | DECIMAL | net_revenue − cost |
| margin_pct | DECIMAL | profit / net_revenue |

---

## analytics.monthly_kpis

**Grain:** One row per year-month

| Column Name | Description |
|------------|-------------|
| year_month | Month (YYYY-MM-01) |
| total_orders | Distinct orders |
| total_units | Units sold |
| total_net_revenue | Monthly net revenue |
| total_cost | Monthly total cost |
| total_profit | Monthly profit |
| margin_pct | Profit margin |

---

## analytics.product_profitability

**Grain:** One row per product

| Column Name | Description |
|------------|-------------|
| product_id | Product identifier |
| product_name | Product name |
| category | Product category |
| total_orders | Orders containing product |
| total_units | Units sold |
| total_net_revenue | Product revenue |
| total_cost | Product cost |
| total_profit | Product profit |
| margin_pct | Product margin |

---

## analytics.region_performance

**Grain:** One row per region

| Column Name | Description |
|------------|-------------|
| region | Sales region |
| total_orders | Orders in region |
| total_units | Units sold |
| total_net_revenue | Regional revenue |
| total_cost | Regional cost |
| total_profit | Regional profit |
| margin_pct | Regional margin |

