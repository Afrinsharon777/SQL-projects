/* ============================================================
   File    : 05_stored_procedures.sql
   Purpose : Parameterised report procedures
   ============================================================ */
USE SalesAnalysisDB;
GO

-- Monthly sales report for a given year
CREATE OR ALTER PROCEDURE usp_MonthlySalesReport
    @Year INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT SalesMonth, Revenue, TotalOrders, UnitsSold
    FROM vw_MonthlySales
    WHERE SalesYear = @Year
    ORDER BY SalesMonth;
END;
GO

-- Top N products by revenue in a date range
CREATE OR ALTER PROCEDURE usp_TopNProducts
    @TopN      INT  = 5,
    @StartDate DATE,
    @EndDate   DATE
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TOP (@TopN)
           ProductName, Category,
           SUM(Quantity)  AS UnitsSold,
           SUM(LineTotal) AS Revenue
    FROM vw_SalesDetail
    WHERE OrderDate BETWEEN @StartDate AND @EndDate
    GROUP BY ProductName, Category
    ORDER BY Revenue DESC;
END;
GO

-- Region summary (NULL region returns all regions)
CREATE OR ALTER PROCEDURE usp_RegionSalesSummary
    @Region NVARCHAR(30) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT Region,
           COUNT(DISTINCT CustomerID) AS ActiveCustomers,
           COUNT(DISTINCT OrderID)    AS TotalOrders,
           SUM(LineTotal)             AS Revenue
    FROM vw_SalesDetail
    WHERE (@Region IS NULL OR Region = @Region)
    GROUP BY Region
    ORDER BY Revenue DESC;
END;
GO

-- Example calls
-- EXEC usp_MonthlySalesReport @Year = 2025;
-- EXEC usp_TopNProducts @TopN = 3, @StartDate = '2025-01-01', @EndDate = '2025-06-30';
-- EXEC usp_RegionSalesSummary @Region = 'South';
-- EXEC usp_RegionSalesSummary;
