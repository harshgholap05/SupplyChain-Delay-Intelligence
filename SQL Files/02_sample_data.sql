-- ============================================================
--  SUPPLY CHAIN DELAY INTELLIGENCE SYSTEM
--  Script 02 : Sample Data (500+ rows across all tables)
-- ============================================================

USE SupplyChainDB;
GO

-- ── Warehouses ───────────────────────────────────────────────
INSERT INTO dbo.Warehouses (WarehouseName, City, Country, Region, Capacity) VALUES
('Mumbai Central WH',    'Mumbai',    'India',         'West',  5000),
('Delhi North Hub',      'Delhi',     'India',         'North', 4200),
('Chennai South Depot',  'Chennai',   'India',         'South', 3800),
('Kolkata East Store',   'Kolkata',   'India',         'East',  3100),
('Pune Distribution',    'Pune',      'India',         'West',  2800),
('Bangalore Tech Hub',   'Bangalore', 'India',         'South', 4500),
('Hyderabad Logistics',  'Hyderabad', 'India',         'South', 3600),
('Ahmedabad Gateway',    'Ahmedabad', 'India',         'West',  2900);

-- ── Suppliers ────────────────────────────────────────────────
INSERT INTO dbo.Suppliers (SupplierName, Country, Category, ContractStart, ContractEnd, SLADays, RiskScore) VALUES
('TechParts Asia Ltd',      'China',        'Electronics',    '2022-01-01', '2025-12-31', 14, 6.5),
('GlobalRaw Materials',     'Australia',    'Raw Materials',  '2021-06-01', '2026-05-31', 21, 4.2),
('PackEdge Solutions',      'India',        'Packaging',      '2023-03-01', NULL,          7, 2.8),
('SwiftLogistics GmbH',     'Germany',      'Electronics',    '2022-09-01', '2025-08-31', 18, 5.1),
('EastWest Traders',        'Vietnam',      'Textiles',       '2023-01-01', NULL,         10, 7.3),
('Apex Chemical Corp',      'USA',          'Chemicals',      '2021-11-01', '2026-10-31', 25, 3.9),
('SunFarm Agro Exports',    'India',        'Agri Products',  '2022-07-01', NULL,          5, 2.1),
('MetalWorks Shanghai',     'China',        'Raw Materials',  '2020-04-01', '2025-03-31', 20, 7.8),
('NordicComponents AB',     'Sweden',       'Electronics',    '2023-06-01', NULL,         22, 4.4),
('AfriSource Ltd',          'South Africa', 'Raw Materials',  '2022-02-01', '2025-01-31', 30, 6.0);

-- ── Products ─────────────────────────────────────────────────
INSERT INTO dbo.Products (ProductName, SKU, Category, UnitCost, ReorderLevel, SupplierID) VALUES
('Microcontroller Unit v3',  'MCU-V3-001',  'Electronics',   850.00,  200, 1),
('Aluminium Sheet 3mm',      'ALU-3MM-002', 'Raw Materials',  45.50, 1000, 2),
('Bubble Wrap Roll 50m',     'PKG-BW-003',  'Packaging',      12.00, 5000, 3),
('PCB Assembly Board A',     'PCB-AA-004',  'Electronics',  1200.00,  150, 4),
('Polyester Fabric 100m',    'TEX-PF-005',  'Textiles',       78.00,  800, 5),
('Industrial Solvent X10',   'CHM-SX-006',  'Chemicals',     220.00,  300, 6),
('Basmati Rice Grade A',     'AGR-BR-007',  'Agri Products',  35.00, 2000, 7),
('Steel Rod 12mm',           'STL-12-008',  'Raw Materials',  62.00, 1200, 8),
('Sensor Module IoT-7',      'SEN-I7-009',  'Electronics',  2400.00,   80, 9),
('Copper Wire Spool 2mm',    'CPR-WR-010',  'Raw Materials',  95.00,  600, 8),
('Corrugated Box Medium',    'PKG-CB-011',  'Packaging',       8.50, 8000, 3),
('Cotton Yarn 20s',          'TEX-CY-012',  'Textiles',       42.00,  700, 5),
('Lithium Battery Pack',     'BAT-LB-013',  'Electronics',  680.00,  400, 1),
('Rubber Gasket Set',        'RBR-GS-014',  'Raw Materials',  18.00, 1500, 2),
('LCD Display 7inch',        'LCD-7I-015',  'Electronics', 1800.00,  120, 9);

-- ── Purchase Orders (100 rows) ───────────────────────────────
SET NOCOUNT ON;

DECLARE @i INT = 1;
DECLARE @status NVARCHAR(20);
DECLARE @delayReasons TABLE (r NVARCHAR(255));
INSERT @delayReasons VALUES 
('Port Congestion'),('Customs Hold'),('Supplier Production Delay'),
('Weather Disruption'),('Documentation Error'),('Transport Strike'),
('Quality Rejection'),('Carrier Capacity Issue'),(NULL),(NULL),(NULL);

WHILE @i <= 100
BEGIN
    DECLARE @orderDate   DATE = DATEADD(DAY, -ABS(CHECKSUM(NEWID())) % 365, GETDATE());
    DECLARE @sla         INT  = (SELECT TOP 1 SLADays FROM dbo.Suppliers ORDER BY NEWID());
    DECLARE @expected    DATE = DATEADD(DAY, @sla, @orderDate);
    DECLARE @delayDays   INT  = (ABS(CHECKSUM(NEWID())) % 20) - 5; -- -5 to +14
    DECLARE @actual      DATE = CASE WHEN @i % 8 = 0 THEN NULL 
                                     ELSE DATEADD(DAY, @delayDays, @expected) END;
    SET @status = CASE 
        WHEN @actual IS NULL AND @expected > CAST(GETDATE() AS DATE) THEN 'Pending'
        WHEN @actual IS NULL THEN 'In-Transit'
        WHEN @i % 25 = 0    THEN 'Cancelled'
        ELSE 'Delivered' END;

    DECLARE @reason NVARCHAR(255) = CASE 
        WHEN @delayDays > 0 THEN (SELECT TOP 1 r FROM @delayReasons WHERE r IS NOT NULL ORDER BY NEWID())
        ELSE NULL END;

    INSERT INTO dbo.PurchaseOrders 
        (PONumber, SupplierID, ProductID, WarehouseID, OrderDate, ExpectedDate, ActualDate, Quantity, UnitPrice, Status, DelayReason)
    VALUES (
        'PO-2024-' + RIGHT('0000'+CAST(@i AS VARCHAR),4),
        (ABS(CHECKSUM(NEWID())) % 10) + 1,
        (ABS(CHECKSUM(NEWID())) % 15) + 1,
        (ABS(CHECKSUM(NEWID())) %  8) + 1,
        @orderDate, @expected, @actual,
        (ABS(CHECKSUM(NEWID())) % 500) + 50,
        (SELECT TOP 1 UnitCost FROM dbo.Products ORDER BY NEWID()),
        @status, @reason
    );
    SET @i = @i + 1;
END;

-- ── Shipments (one per delivered/in-transit PO) ───────────────
INSERT INTO dbo.Shipments (POID, CarrierName, TrackingNumber, ShipmentMode, DepartureDate, EstimatedArrival, ActualArrival, FreightCost)
SELECT 
    p.POID,
    CASE (p.POID % 5) 
        WHEN 0 THEN 'DHL Express'
        WHEN 1 THEN 'FedEx Freight'
        WHEN 2 THEN 'Maersk Line'
        WHEN 3 THEN 'DTDC India'
        ELSE 'Blue Dart' END,
    'TRK-' + CAST(p.POID * 1171 AS VARCHAR),
    CASE (p.POID % 4) WHEN 0 THEN 'Air' WHEN 1 THEN 'Sea' WHEN 2 THEN 'Road' ELSE 'Rail' END,
    p.OrderDate,
    p.ExpectedDate,
    p.ActualDate,
    ROUND((p.Quantity * p.UnitPrice * 0.03), 2)
FROM dbo.PurchaseOrders p
WHERE p.Status IN ('Delivered','In-Transit');

-- ── Inventory Snapshot (30 days x 8 warehouses x 5 products) ──
DECLARE @d INT = 0;
WHILE @d < 30
BEGIN
    INSERT INTO dbo.InventorySnapshot (SnapshotDate, ProductID, WarehouseID, StockOnHand, StockInTransit, StockReserved)
    SELECT 
        DATEADD(DAY, -@d, CAST(GETDATE() AS DATE)),
        p.ProductID,
        w.WarehouseID,
        ABS(CHECKSUM(NEWID())) % 1000 + 50,
        ABS(CHECKSUM(NEWID())) % 300,
        ABS(CHECKSUM(NEWID())) % 200
    FROM dbo.Products p
    CROSS JOIN dbo.Warehouses w
    WHERE p.ProductID <= 8;
    SET @d = @d + 1;
END;

-- ── Populate Delay Log from POs ───────────────────────────────
INSERT INTO dbo.DeliveryDelayLog (POID, DelayDays, ImpactValue, Category)
SELECT 
    p.POID,
    DATEDIFF(DAY, p.ExpectedDate, p.ActualDate) AS DelayDays,
    ROUND(DATEDIFF(DAY, p.ExpectedDate, p.ActualDate) * p.Quantity * p.UnitPrice, 2),
    CASE 
        WHEN DATEDIFF(DAY, p.ExpectedDate, p.ActualDate) BETWEEN 1 AND 2 THEN 'Minor'
        WHEN DATEDIFF(DAY, p.ExpectedDate, p.ActualDate) BETWEEN 3 AND 7 THEN 'Moderate'
        ELSE 'Critical' END
FROM dbo.PurchaseOrders p
WHERE p.ActualDate > p.ExpectedDate
  AND p.Status = 'Delivered';

SET NOCOUNT OFF;
PRINT 'Sample data inserted.';
GO
