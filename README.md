````md
# Revenue & Profitability Analysis (SQL + Power BI)

## Executive Revenue & Profitability Diagnostic

---

## 📌 Project Overview

This project presents a full end-to-end analytics solution to diagnose a sustained **profitability decline** in a mid-sized retail / e-commerce business. Despite stable order volumes and significant net revenue, the business consistently operates at a loss.

The goal of this project is **not to fabricate positive outcomes**, but to demonstrate how a data analyst diagnoses real, uncomfortable business problems using **correct data modeling, disciplined SQL, and executive-level Power BI storytelling**.

---

## 🧩 Business Problem

The company observed:
- Stable to moderate growth in order volumes  
- Consistent net revenue generation  
- Persistent and worsening losses over time  

Leadership lacked clarity on:
- Whether losses were demand-driven or structural  
- The true impact of discounting on margins  
- Which products and regions were driving losses  
- Whether growth initiatives were improving or worsening profitability  

---

## 🎯 Objectives

- Diagnose the root causes of profitability decline  
- Separate **volume effects** from **unit-economics failures**  
- Identify loss concentration across products, regions, and discounts  
- Build a trustworthy analytics foundation suitable for executive decisions  

---

## 🗂️ Data Overview

The analysis uses **synthetic but realistic datasets** designed to mimic production systems and common enterprise data quality issues.

### Datasets Used
- **Orders** – transactional sales data  
- **Customers** – customer demographics and signup information  
- **Products** – product catalog and cost data  

### Simulated Real-World Data Issues
- Incorrect data types  
- Missing and NULL values  
- Hidden whitespace and encoding issues  
- Inconsistent text casing  
- Multiple date formats  
- Discount and cost anomalies  
- NULL propagation risks in financial calculations  

---

## 🏗️ Analytics Architecture

```text
RAW DATA
  ↓
STAGING (cleaning & standardization only)
  ↓
ANALYTICS (fact & summary views)
  ↓
POWER BI (visualization & insights)
````

This layered approach enforces **data quality, reproducibility, and mathematical integrity**.

---

## 🧪 Data Processing & Modeling Approach

### 1️⃣ Raw Data Audit

A comprehensive audit was performed **before any transformation** to:

* Identify missing, invalid, or inconsistent values
* Verify primary and foreign key integrity
* Confirm data grain assumptions
* Document all data risks transparently

**No data was modified during the audit phase.**

---

### 2️⃣ Staging Layer (Cleaning Only)

Staging views were created to:

* Enforce correct data types
* Normalize categorical text fields (region, category, status)
* Remove hidden whitespace and encoding artifacts
* Resolve inconsistent date formats
* Preserve original business meaning

**No metrics, aggregations, or KPIs were calculated in staging.**

---

### 3️⃣ Analytics Layer (Core Modeling)

#### Order Fact Table

A single atomic **order-level fact table** (`analytics.order_fact`) was created with:

* One row per **order × product**
* NULL-safe arithmetic using `COALESCE`
* Profit calculated **exactly once** at the lowest grain

#### Profit Formula

```text
Profit = Net Revenue − Total Cost

Net Revenue = (price × quantity) − discount_amount  
Total Cost  = cost_price × quantity
```

This ensures:

* Correct aggregation at all levels
* No profit distortion from joins or filters
* Consistency between SQL and BI

---

### 4️⃣ Analytics Views

All analytics views are built **only from the order fact**, including:

* Monthly KPIs (orders, revenue, cost, profit, margin)
* Product profitability
* Regional performance
* Discount vs margin analysis

Rules enforced:

* Profit is never recomputed
* Only aggregation (`SUM`, `COUNT`) is applied
* No re-joining of dimension tables

---

## ✅ Data Validation & Integrity Checks

Several explicit checks were performed to guarantee correctness:

* **Aggregation identity check**

  ```
  SUM(net_revenue) − SUM(cost) = SUM(profit)
  ```

* **Grain validation**

  * One row per order × product
  * No row multiplication after joins

* **NULL propagation handling**

  * All numeric inputs wrapped with `COALESCE`
  * Prevents silent loss distortion

* **Dimension integrity**

  * One customer → one region/city
  * One product → one category

These checks ensure the analytics layer is **financially trustworthy**.

---

## 📊 Power BI Dashboard

### Dashboard Purpose

The dashboard is designed as an **executive diagnostic tool**, not operational reporting.

### Core KPIs

* Total Orders
* Net Revenue
* Total Cost
* Total Profit
* Overall Margin %

### Visual Analysis

* Revenue, profit, and margin trends over time
* Discount rate vs margin relationship
* Product-level profitability comparison
* Regional profit and margin performance

A dedicated **Date dimension** ensures consistent filtering across all visuals.

---

## 🔍 Key Insights

* The business generates significant revenue but operates at a **persistent loss**, confirming **structurally negative unit economics**.
* Increased order volumes consistently **amplified losses rather than reducing them**.
* A brief margin improvement in 2022 was **temporary and unsustained**, driven by short-term mix or cost effects.
* Higher discount intensity shows a strong inverse relationship with margin, identifying **discounting as a key driver of profitability erosion**.
* Both top- and bottom-revenue products remain profitable; **losses originate from mid-volume products with weak unit economics**.
* Losses are regionally concentrated, with **North and East regions contributing disproportionately**.
* Reduced activity in 2025 lowered absolute losses, confirming that prior growth was loss-making.

---

## 🧠 Business Recommendations

* Pause volume-led growth until unit economics are corrected
* Redesign discount strategies with margin-based guardrails
* Audit mid-volume products for pricing, cost, and discount inefficiencies
* Implement region-specific pricing or operational adjustments
* Prioritize profitability recovery before scaling further

---

## 📁 Repository Structure

```text
revenue-profitability-analysis-sql-powerbi/
│
├── data/
│   └── raw/
│
├── sql/
│   ├── raw_audit.sql
│   ├── staging_views.sql
│   └── analytics_views.sql
│
├── powerbi/
│   └── revenue_profitability_dashboard.pbix
│
├── README.md
```

---

## 🛠️ Tools Used

* **SQL (MySQL)** – data auditing, cleaning, and analytics modeling
* **Power BI** – executive dashboards and insights
* **GitHub** – version control and documentation

---

## ⭐ Project Highlights

* Production-style SQL modeling with strict grain discipline
* Explicit handling of NULL propagation and aggregation integrity
* Clear separation of audit, staging, and analytics layers
* Business-driven insights instead of surface-level reporting

---

## 📝 Assumptions & Limitations

* Data is synthetic but designed to reflect real production systems
* Costs represent variable product costs only (no fixed overheads)
* Profitability conclusions are directional, not accounting-final

---

## 🧾 Final Note

This project intentionally analyzes a **loss-making business scenario**.
Its value lies in demonstrating:

* rigorous analytical thinking
* correct data modeling practices
* and the ability to explain complex business problems clearly

This mirrors real analytics work more accurately than artificially positive case studies.

---

