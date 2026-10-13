/* ============================================================
   SQL Sales Analysis and Reporting System
   File    : 01_schema.sql
   Purpose : Create database and tables (SQL Server / T-SQL)
   ============================================================ */

IF DB_ID('SalesAnalysisDB') IS NULL
    CREATE DATABASE SalesAnalysisDB;
GO

USE SalesAnalysisDB;
GO

-- Drop child tables first so foreign keys do not block the drop
DROP TABLE IF EXISTS OrderDetails;
DROP TABLE IF EXISTS Orders;
DROP TABLE IF EXISTS Products;
DROP TABLE IF EXISTS Customers;
GO

CREATE TABLE Customers (
    CustomerID   INT IDENTITY(1,1) PRIMARY KEY,
    CustomerName NVARCHAR(100) NOT NULL,
    Region       NVARCHAR(30)  NOT NULL,
    City         NVARCHAR(50)  NOT NULL
);

CREATE TABLE Products (
    ProductID   INT IDENTITY(1,1) PRIMARY KEY,
    ProductName NVARCHAR(100) NOT NULL,
    Category    NVARCHAR(50)  NOT NULL,
    UnitPrice   DECIMAL(10,2) NOT NULL CHECK (UnitPrice > 0)
);

CREATE TABLE Orders (
    OrderID    INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID INT  NOT NULL REFERENCES Customers(CustomerID),
    OrderDate  DATE NOT NULL
);

CREATE TABLE OrderDetails (
    OrderDetailID INT IDENTITY(1,1) PRIMARY KEY,
    OrderID       INT NOT NULL REFERENCES Orders(OrderID),
    ProductID     INT NOT NULL REFERENCES Products(ProductID),
    Quantity      INT NOT NULL CHECK (Quantity > 0),
    DiscountPct   DECIMAL(5,2) NOT NULL DEFAULT 0 CHECK (DiscountPct BETWEEN 0 AND 100)
);
GO

-- Indexes on foreign keys used heavily in joins
CREATE INDEX IX_Orders_CustomerID     ON Orders(CustomerID);
CREATE INDEX IX_Orders_OrderDate      ON Orders(OrderDate);
CREATE INDEX IX_OrderDetails_OrderID  ON OrderDetails(OrderID);
CREATE INDEX IX_OrderDetails_Product  ON OrderDetails(ProductID);
GO
