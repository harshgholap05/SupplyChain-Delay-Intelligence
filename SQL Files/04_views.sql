-- ============================================================
--  SUPPLY CHAIN DELAY INTELLIGENCE SYSTEM
--  Script 04 : Views for Power BI Import / DirectQuery
-- ============================================================

USE SupplyChainDB;
GO

-- View 1: Master fact table Power BI will use as central table
CREATE OR ALTER VIEW dbo.vw_OrderDelayFact AS
SELECT
    p.POID,
    p.PONumber,
    p.OrderDate,
    p.ExpectedDate,
    p.ActualDate,
    p.Status,
    p.Quantity,
    p.UnitPrice,
    ROUND(p.Quantity * p.UnitPrice, 2)              AS OrderValue,
    DATEDIFF(DAY, p.ExpectedDate, p.ActualDate)     AS DelayDays,
    CASE
        WHEN p.ActualDate IS NULL THEN 'Pending'
        WHEN p.ActualDate <= p.ExpectedDate THEN 'On Time'
        WHEN DATEDIFF(DAY,p.ExpectedDate,p.ActualDate) <= 2 THEN 'Minor Delay'
        WHEN DATEDIFF(DAY,p.ExpectedDate,p.ActualDate) <= 7 THEN 'Moderate Delay'
        ELSE 'Critical Delay'
    END                                             AS DeliveryStatus,
    ISNULL(p.DelayReason,'No Delay')                AS DelayReason,
    ROUND(ISNULL(d.ImpactValue,0), 2)               AS DelayImpactValue,
    -- Supplier dims
    s.SupplierName,
    s.Country      AS SupplierCountry,
    s.Category     AS SupplierCategory,
    s.SLADays,
    s.RiskScore,
    -- Product dims
    pr.ProductName,
    pr.SKU,
    pr.Category    AS ProductCategory,
    -- Warehouse dims
    w.WarehouseName,
    w.City         AS WarehouseCity,
    w.Region       AS WarehouseRegion,
    -- Shipment dims
    sh.CarrierName,
    sh.ShipmentMode,
    ROUND(ISNULL(sh.FreightCost,0),2) AS FreightCost,
    -- Date helpers for Power BI time intelligence
    YEAR(p.OrderDate)                               AS OrderYear,
    MONTH(p.OrderDate)                              AS OrderMonth,
    FORMAT(p.OrderDate,'MMM yyyy')                  AS OrderMonthLabel,
    DATEPART(QUARTER, p.OrderDate)                  AS OrderQuarter,
    DATENAME(WEEKDAY, p.OrderDate)                  AS OrderDayOfWeek
FROM dbo.PurchaseOrders p
JOIN  dbo.Suppliers s    ON p.SupplierID  = s.SupplierID
JOIN  dbo.Products  pr   ON p.ProductID   = pr.ProductID
JOIN  dbo.Warehouses w   ON p.WarehouseID = w.WarehouseID
LEFT JOIN dbo.DeliveryDelayLog d ON p.POID = d.POID
LEFT JOIN dbo.Shipments sh       ON p.POID = sh.POID;
GO

-- View 2: Latest inventory status per product-warehouse
CREATE OR ALTER VIEW dbo.vw_InventoryStatus AS
WITH Latest AS (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY ProductID, WarehouseID ORDER BY SnapshotDate DESC) rn
    FROM dbo.InventorySnapshot
)
SELECT
    pr.SKU, pr.ProductName, pr.Category AS ProductCategory,
    w.WarehouseName, w.Region,
    l.SnapshotDate, l.StockOnHand, l.StockInTransit, l.StockReserved,
    l.StockOnHand + l.StockInTransit - l.StockReserved AS AvailableStock,
    pr.ReorderLevel,
    CASE
        WHEN l.StockOnHand = 0                        THEN 'Out of Stock'
        WHEN l.StockOnHand < pr.ReorderLevel          THEN 'Below Reorder'
        WHEN l.StockOnHand < pr.ReorderLevel * 1.2    THEN 'Near Reorder'
        ELSE 'Adequate'
    END AS StockStatus
FROM Latest l
JOIN dbo.Products  pr ON l.ProductID   = pr.ProductID
JOIN dbo.Warehouses w ON l.WarehouseID = w.WarehouseID
WHERE l.rn = 1;
GO

PRINT 'Views created successfully.';
GO
