# 🚚 Supply Chain Delay Intelligence Dashboard

<div align="center">

![Supply Chain](https://img.shields.io/badge/Domain-Supply%20Chain-0d2035?style=for-the-badge&logo=data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAyNCAyNCI+PHBhdGggZmlsbD0id2hpdGUiIGQ9Ik0xMiAyTDIgN2wxMCA1IDEwLTV6TTIgMTdsOSA1IDktNXYtNUwyIDEyeiIvPjwvc3ZnPg==)
![Power BI](https://img.shields.io/badge/Power%20BI-Dashboard-F2C811?style=for-the-badge&logo=powerbi&logoColor=black)
![SQL Server](https://img.shields.io/badge/SQL%20Server-Database-CC2927?style=for-the-badge&logo=microsoftsqlserver&logoColor=white)
![Status](https://img.shields.io/badge/Status-Live-22c55e?style=for-the-badge)

<br/>

**A real-time Power BI dashboard that transforms raw supply chain data into actionable delay intelligence — helping operations teams monitor supplier performance, track inventory health, and optimize freight costs.**

<br/>

[![Live Demo](https://img.shields.io/badge/🚀_Live_Demo-View_Project-22C55E?style=for-the-badge)](https://supplychain-delay-intelligence-harshvardhan-gholap.vercel.app/)
<br/>

</div>

---

## 📌 Problem Statement

> *"Without visibility into supply chain delays, businesses lose money silently — every day."*

A mid-size manufacturing company sources materials from **10 global suppliers** across China, India, Germany, USA, Vietnam and more — delivering to **8 warehouses** across India. The company was facing these critical problems:

| # | Problem | Business Impact |
|---|---------|----------------|
| 1 | ❌ No real-time delay visibility | Production halts, emergency procurement at 2–3× cost |
| 2 | ❌ Cannot identify unreliable suppliers | Bad suppliers retained without performance data |
| 3 | ❌ No root cause analysis on delays | Same problems repeat every quarter |
| 4 | ❌ Inventory blind spots | Stock-outs discovered only when production stops |
| 5 | ❌ Freight cost inefficiency | Overpaying for underperforming carriers |
| 6 | ❌ No financial impact tracking | Cannot quantify delay cost or justify fixes |

### 📊 Quantified Pain

| Metric | Current State | Target |
|--------|--------------|--------|
| On-time delivery rate | 67.4% | > 90% |
| Average delay days | 4.8 days | < 1.5 days |
| Critical delays (>7d) | 12 orders | 0 |
| Delay financial impact | ₹9.2L | Reduce by 60% |
| Supplier SLA breach | 3 suppliers > 50% | All < 20% |
| Inventory stock-outs | 3 products at 0 | Zero stock-outs |

---

## 💡 Solution

A **3-layer analytics solution** that turns raw supply chain data into actionable intelligence:

```
Excel Raw Data  →  SQL Server  →  Power Query  →  DAX Measures  →  Power BI Dashboard
```

Each business problem maps to a specific dashboard page with targeted visuals and KPIs.

| Problem | Solution | Dashboard Page |
|---------|----------|---------------|
| No delay visibility | Real-time KPI cards | Page 1 — Executive Overview |
| Unknown bad suppliers | On-time % + SLA breach table | Page 2 — Supplier Deep-Dive |
| No root cause | Pareto donut chart | Page 1 — Overview |
| Inventory blind spots | Stock vs reorder alert table | Page 3 — Inventory Health |
| Freight inefficiency | Cost vs on-time scatter plot | Page 4 — Freight & Carriers |
| No impact tracking | ₹ delay impact KPI card | Page 1 — Overview |

---

## 🛠️ Tools & Technologies

<table>
<tr>
<td align="center" width="120">
<img src="https://img.shields.io/badge/-SQL%20Server-CC2927?style=flat-square&logo=microsoftsqlserver&logoColor=white" /><br/>
<b>SQL Server</b><br/>
<sub>Database engine</sub>
</td>
<td align="center" width="120">
<img src="https://img.shields.io/badge/-Power%20BI-F2C811?style=flat-square&logo=powerbi&logoColor=black" /><br/>
<b>Power BI</b><br/>
<sub>Visualization</sub>
</td>
<td align="center" width="120">
<img src="https://img.shields.io/badge/-DAX-0078D4?style=flat-square&logo=microsoft&logoColor=white" /><br/>
<b>DAX</b><br/>
<sub>KPI measures</sub>
</td>
<td align="center" width="120">
<img src="https://img.shields.io/badge/-Power%20Query-217346?style=flat-square&logo=microsoft&logoColor=white" /><br/>
<b>Power Query</b><br/>
<sub>Data transformation</sub>
</td>
<td align="center" width="120">
<img src="https://img.shields.io/badge/-Excel-217346?style=flat-square&logo=microsoftexcel&logoColor=white" /><br/>
<b>Excel</b><br/>
<sub>Source data</sub>
</td>
</tr>
</table>

---

## 🗄️ Data Flow

```
📊 Excel                 🗄️ SQL Server              ⚙️ Power Query
Source Data       →      7 Tables + 8 SPs    →      Clean & Shape
                         2 Views                     Type fixes
                         500+ rows                   Null handling
                              ↓
🧮 DAX Measures          👁️ vw_OrderDelayFact        📈 Power BI
KPI Calculations  ←      Single Reporting   →       4-Page Dashboard
On-time %                View (all 5 tables          Dark Navy Theme
Delay Impact ₹           joined)                     Interactive filters
```

### Database Schema — 7 Tables

```
Warehouses ──┐
Suppliers ───┤
Products ────┼──► PurchaseOrders ──► DeliveryDelayLog
             │         │
Shipments ───┘         └──► vw_OrderDelayFact (main reporting view)

InventorySnapshot ──► vw_InventoryStatus
```

### SQL Files — Run in Order

| Order | File | Purpose |
|-------|------|---------|
| 1st | `01_schema.sql` | Creates database + 7 tables |
| 2nd | `02_sample_data.sql` | Inserts 500+ rows of realistic data |
| 3rd | `03_stored_procedures.sql` | Creates 8 analytical stored procedures |
| 4th | `04_views.sql` | Creates Power BI-ready views |

---

## 📸 Dashboard Preview

### Page 1 — Executive Overview
> *The single-screen command centre for leadership*

![Dashboard 1](https://raw.githubusercontent.com/harshgholap05/SupplyChain-Delay-Intelligence/main/Dashboard%20Images%20Preview/Dashboard%201.png)

**KPI Cards (5):**

| KPI | Value | Color | DAX Measure |
|-----|-------|-------|-------------|
| Total Orders | 100 | Purple `#A78BFA` | `COUNT(POID)` |
| On-time % | 67.4% | Green `#4ADE80` | `DIVIDE(OnTime, Total)` |
| Delayed Orders | 36 | Red `#F87171` | `COUNTROWS FILTER DelayDays > 0` |
| Avg Delay Days | 4.8d | Amber `#FBBF24` | `AVERAGEX DelayDays > 0` |
| Critical Delays | 12 | Red `#F87171` | `COUNTROWS "Critical Delay"` |

**Visuals:**
- 📈 12-month delay rate trend line chart
- 🍩 Root cause donut chart
- 🎯 4 ring charts
- 📊 Delivery status strip

---

### Page 2 — Supplier Deep-Dive
> *Identify which suppliers are hurting your business*

![Dashboard 2](https://raw.githubusercontent.com/harshgholap05/SupplyChain-Delay-Intelligence/main/Dashboard%20Images%20Preview/Dashboard%202.png)

**Visuals:**
- 📊 Horizontal bar chart — On-time % by supplier
- 🔥 Risk × Delay heatmap
- 📋 SLA breach table with action recommendations

**SLA Action Logic:**

```text
Breach % > 60%  →  🔴 Review Contract
Breach % > 30%  →  🟡 Issue Warning
Breach % ≤ 30%  →  🟢 Monitor
```

---

### Page 3 — Inventory Health
> *Never be surprised by a stock-out again*

![Dashboard 3](https://raw.githubusercontent.com/harshgholap05/SupplyChain-Delay-Intelligence/main/Dashboard%20Images%20Preview/Dashboard%203.png)

**Visuals:**
- ⚠️ Replenishment alert table
- 📊 Stock coverage by product category
- 🗺️ Available stock by warehouse region

**Stock Status Rules:**

```text
Stock = 0           → Out of Stock 🔴
Stock < Reorder     → Below Reorder 🔴
Stock < Reorder×1.2 → Near Reorder 🟡
Stock ≥ Reorder×1.2 → Adequate 🟢
```

---

### Page 4 — Freight & Carriers
> *Spend smarter on freight — optimize cost vs performance*

![Dashboard 4](https://raw.githubusercontent.com/harshgholap05/SupplyChain-Delay-Intelligence/main/Dashboard%20Images%20Preview/Dashboard%204.png)

**KPI Cards (3):**
- 💰 Total Freight Cost (₹L)
- ⏱️ Avg On-time % across all carriers
- 📦 Freight-to-order value ratio %

**Visuals:**
- 📊 Freight cost by carrier bar chart
- 🍩 Shipment mode mix donut
- 🎯 Cost vs On-time % scatter plot
- 📊 Carrier on-time performance horizontal bars


---

## 🎨 Color Theme

> Dark Navy theme with purple accents and semantic status colors

| Role | Color | Hex |
|------|-------|-----|
| Page background | Deep Navy | `#05101E` |
| Card fill | Dark Card | `#07131F` |
| Nav / header | Darkest Navy | `#030C17` |
| Borders | Border Blue | `#0D2035` |
| Primary accent | Vivid Purple | `#7C3AED` |
| Light purple | Lavender | `#A78BFA` |
| On-time / good | Bright Green | `#4ADE80` |
| Delayed / bad | Soft Red | `#F87171` |
| Warning | Amber | `#FBBF24` |
| Info / neutral | Sky Blue | `#60A5FA` |
| Body text | Slate | `#94A3B8` |
| KPI values | Off-White | `#E2E8F0` |

---

## ⚡ Key DAX Measures

```dax
-- On-time delivery %
% On Time =
DIVIDE(
    COUNTROWS(FILTER(vw_OrderDelayFact, DeliveryStatus = "On Time")),
    COUNTROWS(FILTER(vw_OrderDelayFact, ActualDate <> BLANK())),
    0) * 100

-- Total delay financial impact
Total Delay Impact =
SUMX(vw_OrderDelayFact, vw_OrderDelayFact[DelayImpactValue])

-- SLA breach action
SLA Action =
VAR _b = [Breach Pct]
RETURN IF(_b > 60, "🔴 Review Contract",
       IF(_b > 30, "🟡 Issue Warning", "🟢 Monitor"))

-- Month-over-month change
Orders MoM Text =
VAR _c = [Total Orders] - CALCULATE([Total Orders],
    DATEADD('Date Table'[Date], -1, MONTH))
RETURN IF(_c >= 0, "↑ +", "↓ ") & FORMAT(ABS(_c), "0") & " vs last month"
```

---

## 🗂️ Project Structure

```
supply-chain-delay-intelligence/
│
├── 📁 SQL/
│   ├── 01_schema.sql              # Database & 7 table definitions
│   ├── 02_sample_data.sql         # 500+ rows sample data
│   ├── 03_stored_procedures.sql   # 8 analytical stored procedures
│   └── 04_views.sql               # Power BI reporting views
│
├── 📁 PowerBI/
│   └── SupplyChain_Dashboard.pbix # Main Power BI file
│
├── 📁 Data/
│   └── SupplyChain_Analytics.xlsx # Source Excel data
│
├── 📁 Web/
│   ├── index.html                 # Project portfolio page
│   └── supply_chain_dashboard_v2.html  # Interactive HTML dashboard
│
└── README.md                      # This file
```

---

## 🚀 Getting Started

### Prerequisites
- SQL Server 2019+
- SSMS 19+
- Power BI Desktop (latest)

### Setup Steps

```bash
# Step 1 — Run SQL scripts in order
# Open SSMS → New Query → run each file:
01_schema.sql          # Creates SupplyChainDB + 7 tables
02_sample_data.sql     # Loads 500+ rows
03_stored_procedures.sql  # Creates 8 SPs
04_views.sql           # Creates reporting views

# Step 2 — Connect Power BI
# Get Data → SQL Server
# Server: localhost
# Database: SupplyChainDB
# Import: vw_OrderDelayFact + vw_InventoryStatus

# Step 3 — Open dashboard
# Open SupplyChain_Dashboard.pbix in Power BI Desktop
```

### Verify Setup
```sql
-- Run this to confirm everything loaded:
EXEC dbo.usp_KPISummary;
SELECT TOP 5 * FROM dbo.vw_OrderDelayFact ORDER BY DelayDays DESC;
```

---

## 📈 Stored Procedures (8)

| Procedure | Returns | Used In |
|-----------|---------|---------|
| `usp_KPISummary` | Single-row executive KPIs | KPI cards |
| `usp_SupplierPerformance` | Per-supplier on-time %, risk band | Supplier page |
| `usp_MonthlyDelayTrend` | Month-over-month delay rates | Trend line chart |
| `usp_DelayRootCause` | Pareto of delay reasons | Donut chart |
| `usp_SLABreachSummary` | Breach % + recommended action | SLA table |
| `usp_InventoryHealth` | Stock vs reorder alerts | Inventory table |
| `usp_FreightCostAnalysis` | Carrier cost + on-time % | Freight charts |
| `usp_CriticalDelayedOrders` | All critical delay rows | Alert table |

---

## 📸 Dashboard Preview

| Page | Description |
|------|-------------|
| **Overview** | 5 KPIs · Ring charts · Delay trend · Root cause donut |
| **Suppliers** | On-time bars · Risk heatmap · SLA breach table |
| **Inventory** | Alert table · Coverage bars · Region breakdown |
| **Freight** | Cost bars · Mode donut · Scatter plot · Carrier bars |

---

## 👤 Author

**Harshvardhan Gholap**

[![Portfolio](https://img.shields.io/badge/Portfolio-Live-7c3aed?style=flat-square)](https://supplychain-delay-intelligence-harshvardhan-gholap.vercel.app/)
<a href="https://www.linkedin.com/in/harshvardhan-gholap-821255326/" target="_blank">
  <img src="https://img.shields.io/badge/LinkedIn-Connect-0077B5?style=flat-square&logo=linkedin" alt="LinkedIn">
</a>

<div align="center">

**⭐ If this project helped you, please give it a star!**

*Built using · Excel · SQL Server · Power BI · DAX · Power Query*

</div>
