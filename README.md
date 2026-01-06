# revenue-profitability-analysis-sql-powerbi
SQL-driven analysis to diagnose revenue and profitability decline, supported by executive-level Power BI dashboards and actionable business insights.

# Executive Revenue & Profitability Decline Diagnosis

## Business Context
A mid-sized Indian retail/e-commerce company observed a sustained decline in profitability 
over recent months despite stable order volumes. Existing reports were unreliable due to 
data quality issues in raw transactional systems.

## Objective
- Diagnose revenue and profit decline
- Identify key drivers across regions, products, and customers
- Deliver executive-level insights and actionable recommendations

## Data Overview
The analysis uses three raw datasets generated to simulate real-world production data:

- Orders (transactions)
- Customers
- Products

The datasets are **synthetic but designed to closely mirror real-life business data**, including common production issues such as incorrect data types, duplicate records, missing values, inconsistent categories, invalid transactions, and margin erosion patterns.


## Approach
1. Performed raw data audit to assess data quality
2. Built SQL staging views to clean and standardize data
3. Created analytics-ready views for KPIs and trends
4. Designed executive Power BI dashboards for decision-making

## Key Deliverables
- SQL-based staging and analytics layers
- Executive Power BI dashboard
- Insight and recommendation summary
- Full documentation of assumptions and data quality checks

## Tools Used
- SQL (MySQL Server)
- Power BI
- GitHub for version control and documentation


## Data Audit & Quality Assessment

A comprehensive raw data audit was performed prior to cleaning and transformation to understand data quality risks and guide staging logic.

### Orders (raw.orders)
- One header row ingested as data due to CSV import behavior
- No null or duplicate order IDs observed
- Missing values present in order_date, quantity, price, and discount_amount
- Negative quantity values detected
- Inconsistent date formats in order_date
- Categorical inconsistencies in order_status and region due to casing/encoding
- Referential integrity with customers and products is intact

### Customers (raw.customers)
- No duplicate customer IDs
- Missing values in signup_date and customer_name
- Multiple signup_date formats
- City and region fields contain casing/encoding inconsistencies

### Products (raw.products)
- No duplicate product IDs
- Missing values in cost_price
- Negative cost_price values detected
- Category field contains casing/encoding inconsistencies

No data was modified during the audit phase.  
All issues were addressed explicitly in the staging layer.


