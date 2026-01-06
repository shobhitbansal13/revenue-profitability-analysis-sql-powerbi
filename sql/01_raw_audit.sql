/*
========================================================
RAW DATA AUDIT
========================================================
Purpose:
- Validate ingestion correctness
- Understand data quality issues
- Document risks before cleaning
- NO data modifications performed here

Schemas audited:
- raw.orders
- raw.customers
- raw.products
========================================================
*/

--------------------------------------------------------
-- ORDERS TABLE : RAW AUDIT FINDINGS
--------------------------------------------------------

-- Ingestion & Volume
-- ~102k rows ingested successfully.
-- One header row detected due to CSV import behavior.

-- Primary Identifier Health
-- order_id contains no NULL or blank values.
-- No duplicate order_id values observed.
-- Orders are uniquely identifiable.

-- Missing Values
-- Missing values observed in:
-- - order_date
-- - quantity
-- - price
-- - discount_amount
-- No missing values in:
-- - order_id
-- - customer_id
-- - product_id
-- - order_status
-- - region

-- Invalid / Illogical Values
-- quantity contains negative values.
-- Numeric fields contain numeric-like values but violate business rules.

-- Date Quality
-- order_date contains inconsistent date formats.
-- Requires standardization during staging.

-- Categorical Consistency
-- order_status and region contain casing and encoding inconsistencies
-- (logically identical values appearing as distinct).

-- Referential Integrity
-- Orders reference valid customers and products.
-- No orphan orders detected.

--------------------------------------------------------
-- CUSTOMERS TABLE : RAW AUDIT FINDINGS
--------------------------------------------------------

-- Ingestion & Structure
-- All columns ingested as text by design (raw layer).
-- Column structure is consistent.

-- Primary Identifier Health
-- customer_id contains no duplicates.

-- Missing Values
-- Missing values observed in:
-- - signup_date
-- - customer_name

-- Date Quality
-- signup_date contains multiple date formats.

-- Categorical Consistency
-- city and region contain casing / encoding inconsistencies.
-- Values are semantically consistent but not normalized.

--------------------------------------------------------
-- PRODUCTS TABLE : RAW AUDIT FINDINGS
--------------------------------------------------------

-- Ingestion & Structure
-- Column structure matches expectation.
-- All columns stored as text by raw ingestion design.

-- Primary Identifier Health
-- product_id contains no duplicates.

-- Missing Values
-- cost_price contains missing values.

-- Invalid / Illogical Values
-- cost_price contains negative numeric values.

-- Categorical Consistency
-- category column contains casing / encoding inconsistencies,
-- causing logically identical categories to appear distinct.

--------------------------------------------------------
-- END OF RAW AUDIT
--------------------------------------------------------

