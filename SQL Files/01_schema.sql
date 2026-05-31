-- ============================================================
--  SUPPLY CHAIN DELAY INTELLIGENCE SYSTEM
--  Script 01 : Database & Schema Creation
-- ============================================================

-- IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'SupplyChainDB')
CREATE DATABASE SupplyChainDB;
GO

USE SupplyChainDB;
GO

-- ── 1. Warehouses ────────────────────────────────────────────
CREATE TABLE dbo.Warehouses (
    WarehouseID   INT           IDENTITY(1,1) PRIMARY KEY,
    WarehouseName NVARCHAR(100) NOT NULL,
    City          NVARCHAR(100) NOT NULL,
    Country       NVARCHAR(100) NOT NULL,
    Region        NVARCHAR(50)  NOT NULL,   -- North / South / East / West
    Capacity      INT           NOT NULL    -- max pallet positions
);

-- ── 2. Suppliers ─────────────────────────────────────────────
CREATE TABLE dbo.Suppliers (
    SupplierID    INT           IDENTITY(1,1) PRIMARY KEY,
    SupplierName  NVARCHAR(150) NOT NULL,
    Country       NVARCHAR(100) NOT NULL,
    Category      NVARCHAR(100) NOT NULL,   -- Electronics / Raw Materials / Packaging …
    ContractStart DATE          NOT NULL,
    ContractEnd   DATE          NULL,
    SLADays       INT           NOT NULL,   -- agreed lead time in days
    RiskScore     DECIMAL(3,1)  NOT NULL    -- 1.0 (low) – 10.0 (high)
);

-- ── 3. Products ──────────────────────────────────────────────
CREATE TABLE dbo.Products (
    ProductID     INT           IDENTITY(1,1) PRIMARY KEY,
    ProductName   NVARCHAR(200) NOT NULL,
    SKU           NVARCHAR(50)  NOT NULL UNIQUE,
    Category      NVARCHAR(100) NOT NULL,
    UnitCost      DECIMAL(12,2) NOT NULL,
    ReorderLevel  INT           NOT NULL,
    SupplierID    INT           NOT NULL REFERENCES dbo.Suppliers(SupplierID)
);

-- ── 4. Purchase Orders ───────────────────────────────────────
CREATE TABLE dbo.PurchaseOrders (
    POID            INT           IDENTITY(1,1) PRIMARY KEY,
    PONumber        NVARCHAR(20)  NOT NULL UNIQUE,
    SupplierID      INT           NOT NULL REFERENCES dbo.Suppliers(SupplierID),
    ProductID       INT           NOT NULL REFERENCES dbo.Products(ProductID),
    WarehouseID     INT           NOT NULL REFERENCES dbo.Warehouses(WarehouseID),
    OrderDate       DATE          NOT NULL,
    ExpectedDate    DATE          NOT NULL,
    ActualDate      DATE          NULL,       -- NULL = not yet received
    Quantity        INT           NOT NULL,
    UnitPrice       DECIMAL(12,2) NOT NULL,
    Status          NVARCHAR(20)  NOT NULL    -- Pending / In-Transit / Delivered / Cancelled
        CHECK (Status IN ('Pending','In-Transit','Delivered','Cancelled')),
    DelayReason  NVARCHAR(255)    NULL        -- e.g. Port Strike / Weather / Customs / Supplier Issue
);

-- ── 5. Shipments ─────────────────────────────────────────────
CREATE TABLE dbo.Shipments (
    ShipmentID      INT           IDENTITY(1,1) PRIMARY KEY,
    POID            INT           NOT NULL REFERENCES dbo.PurchaseOrders(POID),
    CarrierName     NVARCHAR(150) NOT NULL,
    TrackingNumber  NVARCHAR(100) NULL,
    ShipmentMode    NVARCHAR(30)  NOT NULL   -- Air / Sea / Road / Rail
        CHECK (ShipmentMode IN ('Air','Sea','Road','Rail')),
    DepartureDate   DATE          NOT NULL,
    EstimatedArrival DATE         NOT NULL,
    ActualArrival   DATE          NULL,
    FreightCost     DECIMAL(12,2) NOT NULL
);

-- ── 6. Inventory Snapshot (daily) ────────────────────────────
CREATE TABLE dbo.InventorySnapshot (
    SnapshotID    INT  IDENTITY(1,1) PRIMARY KEY,
    SnapshotDate  DATE NOT NULL,
    ProductID     INT  NOT NULL REFERENCES dbo.Products(ProductID),
    WarehouseID   INT  NOT NULL REFERENCES dbo.Warehouses(WarehouseID),
    StockOnHand   INT  NOT NULL,
    StockInTransit INT NOT NULL,
    StockReserved INT  NOT NULL
);

-- ── 7. Delay Log (derived / audit) ───────────────────────────
CREATE TABLE dbo.DeliveryDelayLog (
    LogID         INT           IDENTITY(1,1) PRIMARY KEY,
    POID          INT           NOT NULL REFERENCES dbo.PurchaseOrders(POID),
    DelayDays     INT           NOT NULL,
    ImpactValue   DECIMAL(14,2) NOT NULL,  -- DelayDays * Quantity * UnitPrice
    LoggedAt      DATETIME      NOT NULL DEFAULT GETDATE(),
    Category      NVARCHAR(50)  NOT NULL   -- Minor(<3d) / Moderate(3-7d) / Critical(>7d)
);
GO

PRINT 'Schema created successfully.';
GO

/*

Select * from Warehouses;
select * from Suppliers;
select * from Products;
select * from PurchaseOrders;
select * from Shipments;
select * from InventorySnapshot;
select * from DeliveryDelayLog;
GO

*/