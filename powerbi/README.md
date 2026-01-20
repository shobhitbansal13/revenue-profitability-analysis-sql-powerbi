# Power BI Dashboard – Revenue & Profitability Analysis

## 📊 Dashboard Overview

This folder contains the Power BI dashboard built on top of the SQL analytics layer.

The dashboard is designed as an **executive diagnostic tool** to analyze:
- revenue trends
- cost behavior
- profitability drivers
- discount impact
- product and regional performance

It is **not operational reporting**, but a decision-support dashboard.

---

## 🧭 Dashboard Pages & Insights

### 1️⃣ Executive Overview
- Total Orders
- Net Revenue
- Total Profit
- Overall Margin %

Provides a high-level snapshot of business health.

📸 Screenshot:  
<p align="center">
  <img src="https://github.com/shobhitbansal13/revenue-profitability-analysis-sql-powerbi/blob/d155cf9980005dbdcab321c35b4ee88f2377282d/assets/Executive%20Overview.png" width="800">
</p>

---

### 2️⃣ Trend Analysis
- Monthly Net Revenue
- Monthly Profit
- Margin % trend

Used to identify structural profitability patterns over time.

📸 Screenshot:  
<p align="center">
  <img src="https://raw.githubusercontent.com/shobhitbansal13/revenue-profitability-analysis-sql-powerbi/6f5ef379f4162cf84fe01d3e4d8c66ee892c32dd/assets/Trend%20Analysis.png" width="800" alt="Trend Analysis">
</p>

---

### 3️⃣ Product Profitability
- Top and bottom products by revenue
- Product-level profit and margin comparison

Highlights products contributing to losses despite volume.

📸 Screenshot:  
`dashboard_screenshots/product_profitability.png`

---

### 4️⃣ Regional Performance
- Region-wise revenue and profit
- Margin comparison across regions

Identifies geographic concentration of losses.

📸 Screenshot:  
`dashboard_screenshots/regional_performance.png`

---

### 5️⃣ Discount vs Margin Analysis
- Average discount rate vs margin trend
- Impact of discounting on profitability

Shows discount-driven margin erosion.

📸 Screenshot:  
`dashboard_screenshots/discount_margin_analysis.png`

---

## 🧩 Data Model

The Power BI model is built around:
- a central **order-level fact table**
- a dedicated **Date dimension**
- all financial metrics originating from SQL

📸 Data model screenshot:  
`data_model.png`

---

## 📁 Files in This Folder

| File | Description |
|----|-------------|
| `revenue_profitability_dashboard.pbix` | Power BI dashboard file (optional) |
| `dashboard_screenshots/` | Dashboard preview images |
| `data_model.png` | Power BI model diagram |
| `README.md` | This documentation |

---

## 🔗 Live Dashboard (Optional)

If published to Power BI Service:

> **Live Dashboard:**  
> *(Add public link here if available)*

---

## ⚠️ Notes

- Data used is synthetic and for demonstration only
- All profit calculations originate from SQL
- Power BI is used only for aggregation and visualization
- Margin % is calculated using aggregated profit and revenue

---

## ✅ Summary

This Power BI dashboard complements the SQL analytics layer by:
- translating validated metrics into insights
- enabling executive-level analysis
- preserving metric correctness and consistency
