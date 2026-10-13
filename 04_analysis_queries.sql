/* ============================================================
   File    : 04_analysis_queries.sql
   Purpose : Analysis queries (joins, CTEs, window functions,
             aggregations). Run one query at a time.
   ============================================================ */
USE SalesAnalysisDB;
GO

-- 1. Revenue and order count by region (aggregation + view)
SELECT Region,
       SUM(LineTotal)          AS Revenue,
       COUNT(DISTINCT OrderID) AS TotalOrders
FROM vw_SalesDetail
GROUP BY Region
ORDER BY Revenue DESC;

-- 2. Top 3 products by revenue in each category (CTE + DENSE_RANK)
WITH ranked AS (
    SELECT Category, ProductName, Revenue,
           DENSE_RANK() OVER (PARTITION BY Category ORDER BY Revenue DESC) AS rnk
    FROM vw_ProductPerformance
)
SELECT Category, ProductName, Revenue, rnk
FROM ranked
WHERE rnk <= 3
ORDER BY Category, rnk;

-- 3. Second-highest revenue product overall (classic interview question)
WITH ranked AS (
    SELECT ProductName, Revenue,
           DENSE_RANK() OVER (ORDER BY Revenue DESC) AS rnk
    FROM vw_ProductPerformance
)
SELECT ProductName, Revenue FROM ranked WHERE rnk = 2;

-- 4. Month-over-month revenue growth (LAG)
SELECT SalesYear, SalesMonth, Revenue,
       LAG(Revenue) OVER (ORDER BY SalesYear, SalesMonth) AS PrevMonthRevenue,
       CAST(100.0 * (Revenue - LAG(Revenue) OVER (ORDER BY SalesYear, SalesMonth))
            / NULLIF(LAG(Revenue) OVER (ORDER BY SalesYear, SalesMonth), 0) AS DECIMAL(10,2)) AS MoMGrowthPct
FROM vw_MonthlySales
ORDER BY SalesYear, SalesMonth;

-- 5. Running (cumulative) revenue through the year
SELECT SalesYear, SalesMonth, Revenue,
       SUM(Revenue) OVER (PARTITION BY SalesYear ORDER BY SalesMonth
                          ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS RunningRevenue
FROM vw_MonthlySales
ORDER BY SalesYear, SalesMonth;

-- 6. Customers who spent more than the average customer (CTE + subquery logic)
WITH customer_spend AS (
    SELECT CustomerID, CustomerName, SUM(LineTotal) AS TotalSpend
    FROM vw_SalesDetail
    GROUP BY CustomerID, CustomerName
)
SELECT CustomerName, TotalSpend
FROM customer_spend
WHERE TotalSpend > (SELECT AVG(TotalSpend) FROM customer_spend)
ORDER BY TotalSpend DESC;

-- 7. Customers who never ordered (LEFT JOIN + IS NULL)
SELECT c.CustomerID, c.CustomerName
FROM Customers c
LEFT JOIN Orders o ON o.CustomerID = c.CustomerID
WHERE o.OrderID IS NULL;

-- 8. Categories with revenue above 500,000 (HAVING)
SELECT Category, SUM(LineTotal) AS Revenue
FROM vw_SalesDetail
GROUP BY Category
HAVING SUM(LineTotal) > 500000
ORDER BY Revenue DESC;

-- 9. Customer segment using CASE
WITH customer_spend AS (
    SELECT CustomerName, SUM(LineTotal) AS TotalSpend
    FROM vw_SalesDetail
    GROUP BY CustomerName
)
SELECT CustomerName, TotalSpend,
       CASE WHEN TotalSpend >= 500000 THEN 'High'
            WHEN TotalSpend >= 200000 THEN 'Medium'
            ELSE 'Low' END AS Segment
FROM customer_spend
ORDER BY TotalSpend DESC;
GO
