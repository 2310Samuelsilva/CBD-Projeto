USE AdventureWorks;
GO

--===============================================================
-- DROP ALL TABLES IN DEPENDENCY ORDER
--===============================================================

-- Disable foreign key constraints first
EXEC sp_MSforeachtable "ALTER TABLE ? NOCHECK CONSTRAINT ALL";

-- Drop tables that depend on others first (child tables → parent tables)
IF OBJECT_ID('dbo.PasswordRecoveryQuestion', 'U') IS NOT NULL DROP TABLE dbo.PasswordRecoveryQuestion;
IF OBJECT_ID('dbo.SentEmails', 'U') IS NOT NULL DROP TABLE dbo.SentEmails;
IF OBJECT_ID('dbo.AppUser', 'U') IS NOT NULL DROP TABLE dbo.AppUser;

IF OBJECT_ID('dbo.SalesOrderLine', 'U') IS NOT NULL DROP TABLE dbo.SalesOrderLine;
IF OBJECT_ID('dbo.SalesOrder', 'U') IS NOT NULL DROP TABLE dbo.SalesOrder;

IF OBJECT_ID('dbo.CustomerAddress', 'U') IS NOT NULL DROP TABLE dbo.CustomerAddress;
IF OBJECT_ID('dbo.Customer', 'U') IS NOT NULL DROP TABLE dbo.Customer;

IF OBJECT_ID('dbo.StateProvince', 'U') IS NOT NULL DROP TABLE dbo.StateProvince;
IF OBJECT_ID('dbo.CountryRegion', 'U') IS NOT NULL DROP TABLE dbo.CountryRegion;

IF OBJECT_ID('dbo.SalesTerritory', 'U') IS NOT NULL DROP TABLE dbo.SalesTerritory;
IF OBJECT_ID('dbo.Currency', 'U') IS NOT NULL DROP TABLE dbo.Currency;

IF OBJECT_ID('dbo.Product', 'U') IS NOT NULL DROP TABLE dbo.Product;
IF OBJECT_ID('dbo.ProductSubcategory', 'U') IS NOT NULL DROP TABLE dbo.ProductSubcategory;
IF OBJECT_ID('dbo.ProductCategory', 'U') IS NOT NULL DROP TABLE dbo.ProductCategory;
IF OBJECT_ID('dbo.ProductModel', 'U') IS NOT NULL DROP TABLE dbo.ProductModel;
IF OBJECT_ID('dbo.ProductName', 'U') IS NOT NULL DROP TABLE dbo.ProductName;
IF OBJECT_ID('dbo.ProductColor', 'U') IS NOT NULL DROP TABLE dbo.ProductColor;
IF OBJECT_ID('dbo.ProductLine', 'U') IS NOT NULL DROP TABLE dbo.ProductLine;
IF OBJECT_ID('dbo.ProductClass', 'U') IS NOT NULL DROP TABLE dbo.ProductClass;
IF OBJECT_ID('dbo.ProductStyle', 'U') IS NOT NULL DROP TABLE dbo.ProductStyle;
IF OBJECT_ID('dbo.ProductSizeRange', 'U') IS NOT NULL DROP TABLE dbo.ProductSizeRange;
IF OBJECT_ID('dbo.UnitOfMeasure', 'U') IS NOT NULL DROP TABLE dbo.UnitOfMeasure;

--===============================================================
-- Confirm cleanup
--===============================================================
PRINT '✅ All tables dropped successfully.';
GO