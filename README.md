# Supply Chain Delay Intelligence Dashboard 🚚📊

![Power BI](https://img.shields.io/badge/Power_BI-F2C811?style=for-the-badge&logo=powerbi&logoColor=black)
![SQL Server](https://img.shields.io/badge/SQL_Server-CC292B?style=for-the-badge&logo=microsoft-sql-server&logoColor=white)
![DAX](https://img.shields.io/badge/DAX-0078D4?style=for-the-badge&logo=microsoft&logoColor=white)

An end-to-end business intelligence solution designed to track, analyze, and mitigate supply chain delays.

---

## 🎥 Dashboard Preview

*(Below is the demonstration of the dashboard)*

<video src="Dashboard%20Video.mp4" controls="controls" style="max-width: 100%;">
  Your browser does not support the video tag.
</video>

*(For high-quality screenshots, please view the [Images Document](SupplyChain%20Dashboard%20images.pdf) included in the folder)*

---

## ⚠️ Problem Statement

A mid-size manufacturing company faces significant financial losses due to supply chain delays, emergency procurement, and production line stoppages. Management needed real-time visibility to act before the damage is done.

**Core Challenges Addressed:**
1. **No real-time delay visibility:** Production halts, emergency procurement at 2-3x cost.
2. **Supplier unreliability:** Good suppliers not rewarded, bad ones retained.
3. **No root cause analysis:** Repeating issues without preventive action.
4. **Inventory blind spots:** Stock-outs causing revenue loss.
5. **Freight inefficiency:** Overpaying for underperforming carriers.
6. **No financial tracking:** Cannot quantify the exact cost of delays.

---

## 💡 Solution Design

A 3-layer architecture designed to resolve the business pain points:

1. **Database Layer (SQL Server):** 
   - 7 normalized tables storing master and transactional data (Purchase Orders, Shipments, Inventory, Delay Logs).
2. **Analytics Layer (SQL Stored Procedures & Views):** 
   - 8 pre-computed Stored Procedures for backend aggregation.
   - 2 flattened Views for Power BI reporting.
3. **Visualization Layer (Power BI):** 
   - An interactive 4-page dashboard featuring a dark navy theme, conditional formatting, and DAX-driven KPIs.

---

## 📈 Key Insights & Dashboard Pages

- **Executive Overview:** Real-time KPI cards (Total Orders, On-time %, Avg Delay Days), 12-month delay trend, and root cause donut chart.
- **Supplier Deep-Dive:** Supplier performance bar charts, risk vs. delay heatmap, and SLA breach tracking.
- **Inventory Health:** Stock vs. reorder alerts, coverage by category, and regional stock availability.
- **Freight & Carriers:** Cost vs. performance scatter plots and freight cost analysis by shipment mode.

---
*For detailed DAX formulas, theme JSON, and in-depth architecture, please refer to the attached `SupplyChain_Complete_Guide.pdf`.*
