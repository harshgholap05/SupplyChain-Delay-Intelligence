# SupplyChain-Delay-Intelligence

<div align="center">
  
  # 🚚 Supply Chain Delay Intelligence
  **Turning Supply Chain Blind Spots into Actionable Intelligence**
  
  ![Power BI](https://img.shields.io/badge/Power_BI-F2C811?style=for-the-badge&logo=powerbi&logoColor=black)
  ![SQL Server](https://img.shields.io/badge/SQL_Server-CC292B?style=for-the-badge&logo=microsoft-sql-server&logoColor=white)
  ![DAX](https://img.shields.io/badge/DAX-0078D4?style=for-the-badge&logo=microsoft&logoColor=white)
</div>
<br>
> **TL;DR:** An end-to-end business intelligence solution that identifies, tracks, and mitigates supply chain delays. It connects SQL Server backends to a Dark Navy-themed Power BI frontend to give executives real-time, quantified answers to *“Why are we late, and how much is it costing us?”*
---
## 🎥 Dashboard in Action
*(Click play to see the interactive dashboard or view high-res screenshots in the `SupplyChain Dashboard images.pdf` file included in this repository).*
<div align="center">
  <video src="Dashboard%20Video.mp4" controls="controls" width="100%" style="border-radius: 8px; box-shadow: 0px 4px 15px rgba(0,0,0,0.2);">
    Your browser does not support the video tag.
  </video>
</div>
---
## 🛑 The Pain: Why This Project Exists
For a mid-sized manufacturing company, **every day of supply chain delay bleeds money**. 
When raw materials don't arrive on time, production lines halt, emergency shipping costs 3x the normal rate, and customers demand penalties. 
Before this dashboard, management was flying blind:
- 📉 **No visibility:** 30%+ of orders arrived late, but nobody knew until it was too late.
- 🤝 **Bad Supplier Relationships:** We were retaining unreliable suppliers and failing to reward the great ones.
- 📦 **Inventory Nightmares:** Constant stock-outs causing massive revenue loss.
- 💸 **The "Cost of Delay" Unknown:** We couldn't quantify the financial impact to justify fixing the root causes.
---
## 💡 The Cure: Solution Architecture
We built a **3-Layer Architecture** that attacks the problem from raw data to final executive decision-making.
|
 Layer 
|
 Technology 
|
 What it does 
|
|
:---
|
:---
|
:---
|
|
**
1. Database
**
|
`SQL Server`
|
 7 normalized tables storing Master Data (Suppliers, Warehouses) and Transactional Data (POs, Shipments, Delay Logs). 
|
|
**
2. Analytics
**
|
`SQL SPs & Views`
|
 8 pre-computed Stored Procedures processing aggregations. 2 flattened, squeaky-clean Views optimized for BI ingestion. 
|
|
**
3. Visualization
**
|
`Power BI & DAX`
|
 A 4-page interactive dashboard with custom traffic-light conditional formatting and advanced DAX measures. 
|
---
## 🎯 What's Inside the Dashboard?
### 1️⃣ Executive Overview
**The 30,000-foot view.** Real-time KPI cards track Total Orders, On-time %, and Average Delay Days. A root-cause donut chart immediately identifies *why* delays happen (Port strikes? Weather? Bad suppliers?).
### 2️⃣ Supplier Deep-Dive
**Holding vendors accountable.** Features a Risk vs. Delay heatmap and tracks exact SLA Breach Rates. Instantly know who needs a formal warning and who deserves a contract renewal.
### 3️⃣ Inventory Health
**Preventing the stock-out.** Real-time alert tables showing Stock vs. Reorder levels. Coverage by category ensures the assembly line never stops.
### 4️⃣ Freight & Carriers
**Optimizing the route.** Scatter plots mapping Cost vs. Performance. Stop overpaying for underperforming sea, air, and road carriers.
---
<div align="center">
  <i>💡 Note: The complete step-by-step build guide, DAX formulas, and exact hex color codes can be found in the <code>SupplyChain_Complete_Guide.pdf</code> file included in this repository.</i>
</div>
