-- ============================================================
--  SUPPLY CHAIN DELAY INTELLIGENCE SYSTEM
--  Script 03 : Stored Procedures (8 analytical procs)
-- ============================================================

USE SupplyChainDB;
GO

-- ────────────────────────────────────────────────────────────
-- SP 1: Supplier Performance Scorecard
--       On-time %, avg delay days, total delay cost, risk band
-- ────────────────────────────────────────────────────────────
CREATE OR ALTER PROCEDURE dbo.usp_SupplierPerformance
    @StartDate DATE = NULL,
    @EndDate   DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET @StartDate = ISNULL(@StartDate, DATEADD(YEAR,-1,GETDATE()));
    SET @EndDate   = ISNULL(@EndDate,   GETDATE());

    SELECT
        s.SupplierID,
        s.SupplierName,
        s.Country,
        s.Category,
        s.SLADays,
        s.RiskScore,
        COUNT(p.POID)                                               AS TotalOrders,
        SUM(CASE WHEN p.ActualDate <= p.ExpectedDate THEN 1 ELSE 0 END)  AS OnTimeDeliveries,
        ROUND(
            100.0 * SUM(CASE WHEN p.ActualDate <= p.ExpectedDate THEN 1 ELSE 0 END)
            / NULLIF(COUNT(CASE WHEN p.ActualDate IS NOT NULL THEN 1 END), 0)
        ,1)                                                         AS OnTimePct,
        ROUND(AVG(CAST(DATEDIFF(DAY, p.ExpectedDate, p.ActualDate) AS FLOAT)),1) AS AvgDelayDays,
        MAX(DATEDIFF(DAY, p.ExpectedDate, p.ActualDate))            AS MaxDelayDays,
        ROUND(SUM(ISNULL(d.ImpactValue, 0)), 2)                    AS TotalDelayImpactValue,
        CASE
            WHEN ROUND(100.0 * SUM(CASE WHEN p.ActualDate <= p.ExpectedDate THEN 1 ELSE 0 END)
                 / NULLIF(COUNT(CASE WHEN p.ActualDate IS NOT NULL THEN 1 END),0),1) >= 90 THEN 'Green'
            WHEN ROUND(100.0 * SUM(CASE WHEN p.ActualDate <= p.ExpectedDate THEN 1 ELSE 0 END)
                 / NULLIF(COUNT(CASE WHEN p.ActualDate IS NOT NULL THEN 1 END),0),1) >= 75 THEN 'Amber'
            ELSE 'Red'
        END                                                         AS PerformanceBand
    FROM dbo.Suppliers s
    LEFT JOIN dbo.PurchaseOrders p
        ON s.SupplierID = p.SupplierID
        AND p.OrderDate BETWEEN @StartDate AND @EndDate
    LEFT JOIN dbo.DeliveryDelayLog d
        ON p.POID = d.POID
    GROUP BY s.SupplierID, s.SupplierName, s.Country, s.Category, s.SLADays, s.RiskScore
    ORDER BY OnTimePct ASC;
END;
GO

-- ────────────────────────────────────────────────────────────
-- SP 2: Monthly Delay Trend
--       Orders, delayed count, delay rate, avg delay days per month
-- ────────────────────────────────────────────────────────────
CREATE OR ALTER PROCEDURE dbo.usp_MonthlyDelayTrend
    @Months INT = 12
AS
BEGIN
    SET NOCOUNT ON;

    WITH Monthly AS (
        SELECT
            FORMAT(p.OrderDate, 'yyyy-MM')                  AS YearMonth,
            YEAR(p.OrderDate)                               AS Yr,
            MONTH(p.OrderDate)                              AS Mn,
            COUNT(p.POID)                                   AS TotalOrders,
            SUM(CASE WHEN p.ActualDate > p.ExpectedDate AND p.ActualDate IS NOT NULL THEN 1 ELSE 0 END) AS DelayedOrders,
            ROUND(AVG(CAST(CASE WHEN p.ActualDate > p.ExpectedDate
                               THEN DATEDIFF(DAY, p.ExpectedDate, p.ActualDate)
                               ELSE 0 END AS FLOAT)),1)     AS AvgDelayDays,
            ROUND(SUM(ISNULL(d.ImpactValue,0)),2)           AS TotalImpact
        FROM dbo.PurchaseOrders p
        LEFT JOIN dbo.DeliveryDelayLog d ON p.POID = d.POID
        WHERE p.OrderDate >= DATEADD(MONTH, -@Months, GETDATE())
        GROUP BY FORMAT(p.OrderDate,'yyyy-MM'), YEAR(p.OrderDate), MONTH(p.OrderDate)
    )
    SELECT
        YearMonth,
        TotalOrders,
        DelayedOrders,
        ROUND(100.0 * DelayedOrders / NULLIF(TotalOrders,0), 1) AS DelayRatePct,
        AvgDelayDays,
        TotalImpact,
        -- Month-over-month change in delay rate
        ROUND(
            100.0 * DelayedOrders / NULLIF(TotalOrders,0)
            - LAG(100.0 * DelayedOrders / NULLIF(TotalOrders,0))
              OVER (ORDER BY Yr, Mn)
        , 1) AS MoMDelayRateChange
    FROM Monthly
    ORDER BY Yr, Mn;
END;
GO

-- ────────────────────────────────────────────────────────────
-- SP 3: Delay Root Cause Analysis
--       Groups delay reasons, calculates frequency & cost
-- ────────────────────────────────────────────────────────────
CREATE OR ALTER PROCEDURE dbo.usp_DelayRootCause
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        ISNULL(p.DelayReason, 'Unknown')        AS DelayReason,
        COUNT(*)                                 AS Occurrences,
        ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1) AS PctOfDelays,
        ROUND(AVG(CAST(d.DelayDays AS FLOAT)),1) AS AvgDelayDays,
        ROUND(SUM(d.ImpactValue),2)              AS TotalImpactValue,
        -- Running contribution (Pareto)
        ROUND(SUM(SUM(d.ImpactValue)) OVER (
            ORDER BY SUM(d.ImpactValue) DESC
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) / NULLIF(SUM(SUM(d.ImpactValue)) OVER (),0) * 100, 1) AS CumulativePct
    FROM dbo.PurchaseOrders p
    JOIN dbo.DeliveryDelayLog d ON p.POID = d.POID
    GROUP BY p.DelayReason
    ORDER BY TotalImpactValue DESC;
END;
GO

-- ────────────────────────────────────────────────────────────
-- SP 4: SLA Breach Summary by Supplier & Category
-- ────────────────────────────────────────────────────────────
CREATE OR ALTER PROCEDURE dbo.usp_SLABreachSummary
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        s.SupplierName,
        s.Category,
        s.SLADays                                       AS AgreedsLADays,
        COUNT(p.POID)                                   AS TotalDelivered,
        SUM(CASE WHEN DATEDIFF(DAY,p.ExpectedDate,p.ActualDate) > 0 THEN 1 ELSE 0 END) AS Breaches,
        ROUND(100.0 *
            SUM(CASE WHEN DATEDIFF(DAY,p.ExpectedDate,p.ActualDate) > 0 THEN 1 ELSE 0 END)
            / NULLIF(COUNT(p.POID),0), 1)               AS BreachRatePct,
        ROUND(AVG(CAST(
            CASE WHEN DATEDIFF(DAY,p.ExpectedDate,p.ActualDate) > 0
                 THEN DATEDIFF(DAY,p.ExpectedDate,p.ActualDate) ELSE 0 END AS FLOAT)),1) AS AvgBreachDays,
        -- Penalty tier
        CASE
            WHEN ROUND(100.0 *
                SUM(CASE WHEN DATEDIFF(DAY,p.ExpectedDate,p.ActualDate) > 0 THEN 1 ELSE 0 END)
                / NULLIF(COUNT(p.POID),0),1) > 40 THEN 'Review Contract'
            WHEN ROUND(100.0 *
                SUM(CASE WHEN DATEDIFF(DAY,p.ExpectedDate,p.ActualDate) > 0 THEN 1 ELSE 0 END)
                / NULLIF(COUNT(p.POID),0),1) > 20 THEN 'Issue Warning'
            ELSE 'Monitor'
        END AS RecommendedAction
    FROM dbo.Suppliers s
    JOIN dbo.PurchaseOrders p
        ON s.SupplierID = p.SupplierID
        AND p.Status = 'Delivered'
        AND p.ActualDate IS NOT NULL
    GROUP BY s.SupplierName, s.Category, s.SLADays
    ORDER BY BreachRatePct DESC;
END;
GO

-- ────────────────────────────────────────────────────────────
-- SP 5: Inventory Health – Stock vs Reorder Level
-- ────────────────────────────────────────────────────────────
CREATE OR ALTER PROCEDURE dbo.usp_InventoryHealth
AS
BEGIN
    SET NOCOUNT ON;

    WITH Latest AS (
        SELECT ProductID, WarehouseID, StockOnHand, StockInTransit, StockReserved,
               ROW_NUMBER() OVER (PARTITION BY ProductID, WarehouseID ORDER BY SnapshotDate DESC) AS rn
        FROM dbo.InventorySnapshot
    )
    SELECT
        pr.SKU,
        pr.ProductName,
        pr.Category,
        w.WarehouseName,
        w.Region,
        l.StockOnHand,
        l.StockInTransit,
        l.StockReserved,
        l.StockOnHand + l.StockInTransit - l.StockReserved AS AvailableStock,
        pr.ReorderLevel,
        CASE
            WHEN l.StockOnHand = 0 THEN 'Out of Stock'
            WHEN l.StockOnHand < pr.ReorderLevel THEN 'Below Reorder'
            WHEN l.StockOnHand < pr.ReorderLevel * 1.2 THEN 'Near Reorder'
            ELSE 'Adequate'
        END AS StockStatus,
        ROUND(100.0 * l.StockOnHand / NULLIF(pr.ReorderLevel,0), 1) AS StockVsReorderPct
    FROM Latest l
    JOIN dbo.Products  pr ON l.ProductID   = pr.ProductID
    JOIN dbo.Warehouses w ON l.WarehouseID = w.WarehouseID
    WHERE l.rn = 1
    ORDER BY StockVsReorderPct ASC;
END;
GO

-- ────────────────────────────────────────────────────────────
-- SP 6: Freight Cost Analysis by Carrier & Mode
-- ────────────────────────────────────────────────────────────
CREATE OR ALTER PROCEDURE dbo.usp_FreightCostAnalysis
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        sh.CarrierName,
        sh.ShipmentMode,
        COUNT(sh.ShipmentID)                     AS TotalShipments,
        ROUND(SUM(sh.FreightCost), 2)             AS TotalFreightCost,
        ROUND(AVG(sh.FreightCost), 2)             AS AvgFreightCost,
        ROUND(SUM(sh.FreightCost) /
              NULLIF(SUM(p.Quantity * p.UnitPrice),0) * 100, 2) AS FreightAsPctOfOrderValue,
        -- On-time for each carrier
        ROUND(100.0 *
            SUM(CASE WHEN sh.ActualArrival <= sh.EstimatedArrival THEN 1 ELSE 0 END)
            / NULLIF(COUNT(CASE WHEN sh.ActualArrival IS NOT NULL THEN 1 END),0),1) AS CarrierOnTimePct
    FROM dbo.Shipments sh
    JOIN dbo.PurchaseOrders p ON sh.POID = p.POID
    GROUP BY sh.CarrierName, sh.ShipmentMode
    ORDER BY TotalFreightCost DESC;
END;
GO

-- ────────────────────────────────────────────────────────────
-- SP 7: Critical Delayed Orders (for Power BI alert table)
-- ────────────────────────────────────────────────────────────
CREATE OR ALTER PROCEDURE dbo.usp_CriticalDelayedOrders
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        p.PONumber,
        s.SupplierName,
        pr.ProductName,
        w.WarehouseName,
        p.OrderDate,
        p.ExpectedDate,
        p.ActualDate,
        d.DelayDays,
        d.Category   AS DelayCategory,
        p.DelayReason,
        p.Quantity,
        p.UnitPrice,
        ROUND(p.Quantity * p.UnitPrice, 2) AS OrderValue,
        ROUND(d.ImpactValue, 2)            AS ImpactValue,
        sh.CarrierName,
        sh.ShipmentMode
    FROM dbo.PurchaseOrders p
    JOIN dbo.DeliveryDelayLog d  ON p.POID        = d.POID
    JOIN dbo.Suppliers s         ON p.SupplierID  = s.SupplierID
    JOIN dbo.Products  pr        ON p.ProductID   = pr.ProductID
    JOIN dbo.Warehouses w        ON p.WarehouseID = w.WarehouseID
    LEFT JOIN dbo.Shipments sh   ON p.POID        = sh.POID
    WHERE d.Category = 'Critical'
    ORDER BY d.DelayDays DESC;
END;
GO

-- ────────────────────────────────────────────────────────────
-- SP 8: KPI Summary (single-row exec summary for Power BI)
-- ────────────────────────────────────────────────────────────
CREATE OR ALTER PROCEDURE dbo.usp_KPISummary
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        COUNT(p.POID)                                                          AS TotalOrders,
        SUM(CASE WHEN p.Status = 'Delivered' THEN 1 ELSE 0 END)               AS DeliveredOrders,
        SUM(CASE WHEN p.Status IN ('Pending','In-Transit') THEN 1 ELSE 0 END) AS OpenOrders,
        SUM(CASE WHEN p.ActualDate > p.ExpectedDate THEN 1 ELSE 0 END)        AS DelayedOrders,
        ROUND(100.0 *
            SUM(CASE WHEN p.ActualDate <= p.ExpectedDate AND p.ActualDate IS NOT NULL THEN 1 ELSE 0 END)
            / NULLIF(COUNT(CASE WHEN p.ActualDate IS NOT NULL THEN 1 END),0), 1) AS OnTimePct,
        ROUND(AVG(CAST(CASE WHEN p.ActualDate > p.ExpectedDate
                            THEN DATEDIFF(DAY,p.ExpectedDate,p.ActualDate) ELSE 0 END AS FLOAT)),1) AS AvgDelayDays,
        ROUND(SUM(ISNULL(d.ImpactValue,0)),2)                                 AS TotalDelayImpact,
        ROUND(SUM(p.Quantity * p.UnitPrice),2)                                AS TotalOrderValue,
        ROUND(SUM(ISNULL(sh.FreightCost,0)),2)                                AS TotalFreightCost,
        COUNT(DISTINCT p.SupplierID)                                          AS ActiveSuppliers,
        SUM(CASE WHEN d.Category = 'Critical' THEN 1 ELSE 0 END)             AS CriticalDelays
    FROM dbo.PurchaseOrders p
    LEFT JOIN dbo.DeliveryDelayLog d ON p.POID = d.POID
    LEFT JOIN dbo.Shipments        sh ON p.POID = sh.POID;
END;
GO

PRINT 'All 8 stored procedures created.';
GO

-- ────────────────────────────────────────────────────────────
-- QUICK TEST: Run all procs
-- ────────────────────────────────────────────────────────────
/*
EXEC dbo.usp_KPISummary;
EXEC dbo.usp_SupplierPerformance;
EXEC dbo.usp_MonthlyDelayTrend @Months = 12;
EXEC dbo.usp_DelayRootCause;
EXEC dbo.usp_SLABreachSummary;
EXEC dbo.usp_InventoryHealth;
EXEC dbo.usp_FreightCostAnalysis;
EXEC dbo.usp_CriticalDelayedOrders;
*/
