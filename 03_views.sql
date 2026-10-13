/* ============================================================
   File    : 03_views.sql
   Purpose : Reusable views for reporting and Power BI
   ============================================================ */
USE SalesAnalysisDB;
GO

-- Flat, report-ready view joining all four tables
CREATE OR ALTER VIEW vw_SalesDetail AS
SELECT
    o.OrderID,
    o.OrderDate,
    YEAR(o.OrderDate)   AS SalesYear,
    MONTH(o.OrderDate)  AS SalesMonth,
    c.CustomerID,
    c.CustomerName,
    c.Region,
    c.City,
    p.ProductID,
    p.ProductName,
    p.Category,
    od.Quantity,
    p.UnitPrice,
    od.DiscountPct,
    CAST(od.Quantity * p.UnitPrice * (1 - od.DiscountPct / 100.0) AS DECIMAL(12,2)) AS LineTotal
FROM Orders o
INNER JOIN OrderDetails od ON od.OrderID    = o.OrderID
INNER JOIN Customers    c  ON c.CustomerID  = o.CustomerID
INNER JOIN Products     p  ON p.ProductID   = od.ProductID;
GO

-- Monthly revenue, orders and units
CREATE OR ALTER VIEW vw_MonthlySales AS
SELECT
    SalesYear,
    SalesMonth,
    SUM(LineTotal)            AS Revenue,
    COUNT(DISTINCT OrderID)   AS TotalOrders,
    SUM(Quantity)             AS UnitsSold
FROM vw_SalesDetail
GROUP BY SalesYear, SalesMonth;
GO

-- Product-level performance
CREATE OR ALTER VIEW vw_ProductPerformance AS
SELECT
    ProductID,
    ProductName,
    Category,
    SUM(Quantity)            AS UnitsSold,
    SUM(LineTotal)           AS Revenue,
    COUNT(DISTINCT OrderID)  AS OrdersContaining
FROM vw_SalesDetail
GROUP BY ProductID, ProductName, Category;
GO
