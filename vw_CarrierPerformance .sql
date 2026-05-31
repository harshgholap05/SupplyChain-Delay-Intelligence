use SupplyChainDB;

CREATE OR ALTER VIEW dbo.vw_CarrierPerformance AS
SELECT 
    CarrierName,
    COUNT(*) AS TotalDelivered,
    SUM(CASE WHEN DeliveryStatus = 'On Time' THEN 1 ELSE 0 END) AS OnTimeCount,
    ROUND(
        100.0 * SUM(CASE WHEN DeliveryStatus = 'On Time' THEN 1 ELSE 0 END)
        / NULLIF(COUNT(*), 0)
    , 1) AS OnTimePct
FROM dbo.vw_OrderDelayFact
WHERE CarrierName IS NOT NULL
AND DeliveryStatus <> 'Pending'
GROUP BY CarrierName;

-- SELECT * FROM dbo.vw_CarrierPerformance
-- order by OnTimePct desc

select * from vw_CarrierPerformance

CREATE OR ALTER VIEW dbo.vw_CarrierPerformance AS
SELECT 
    sh.CarrierName,
    sh.ShipmentMode,
    COUNT(*) AS TotalDelivered,
    SUM(CASE WHEN 
        CASE
            WHEN p.ActualDate IS NULL THEN 'Pending'
            WHEN p.ActualDate <= p.ExpectedDate THEN 'On Time'
            WHEN DATEDIFF(DAY,p.ExpectedDate,p.ActualDate) <= 2 THEN 'Minor Delay'
            WHEN DATEDIFF(DAY,p.ExpectedDate,p.ActualDate) <= 7 THEN 'Moderate Delay'
            ELSE 'Critical Delay'
        END = 'On Time' THEN 1 ELSE 0 END) AS OnTimeCount,
    ROUND(
        100.0 * SUM(CASE WHEN 
            CASE
                WHEN p.ActualDate IS NULL THEN 'Pending'
                WHEN p.ActualDate <= p.ExpectedDate THEN 'On Time'
                ELSE 'Delayed'
            END = 'On Time' THEN 1 ELSE 0 END)
        / NULLIF(COUNT(*), 0)
    , 1) AS OnTimePct,
    SUM(sh.FreightCost) AS TotalFreightCost,
    AVG(sh.FreightCost) AS AvgFreightCost
FROM dbo.Shipments sh
JOIN dbo.PurchaseOrders p ON sh.POID = p.POID
WHERE sh.CarrierName IS NOT NULL
AND p.Status <> 'Pending'
GROUP BY sh.CarrierName, sh.ShipmentMode;