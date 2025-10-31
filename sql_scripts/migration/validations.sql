--=================================================================================
-- DATA VALIDATION SCRIPT
-- Purpose: Compare migrated data between AdventureWorksLegacy and AdventureWorks
--=================================================================================

-- 1. TOTAL NUMBER OF PRODUCTS
SELECT 
    'Legacy' AS Source, 
    COUNT(*) AS ProductCount
FROM AdventureWorksLegacy.dbo.Products
UNION ALL
SELECT 
    'New', 
    COUNT(*) 
FROM AdventureWorks.dbo.ProductVariant;


-- 2. TOTAL NUMBER OF SALES (Distinct Orders)
SELECT 
    'Legacy' AS Source,
    COUNT(DISTINCT SalesOrderNumber) AS SalesCount
FROM AdventureWorksLegacy.dbo.SalesHeader
UNION ALL
SELECT 
    'New',
    COUNT(DISTINCT sales_order_number)
FROM AdventureWorks.dbo.SalesHeader;


-- 3. TOTAL SALES VALUE BY CUSTOMER
SELECT 
    'Legacy' AS Source,
    C.CustomerID,
    SUM(SD.OrderQuantity * SD.UnitPrice) AS TotalSales
FROM AdventureWorksLegacy.dbo.SalesHeader AS SH
JOIN AdventureWorksLegacy.dbo.SalesDetail AS SD
    ON SH.SalesOrderID = SD.SalesOrderID
JOIN AdventureWorksLegacy.dbo.Customer AS C
    ON SH.CustomerID = C.CustomerID
GROUP BY C.CustomerID

UNION ALL

SELECT 
    'New',
    C.customer_id,
    SUM(SD.order_quantity * SD.unit_price)
FROM AdventureWorks.dbo.SalesHeader AS SH
JOIN AdventureWorks.dbo.SalesDetail AS SD
    ON SH.sales_order_id = SD.sales_order_id
JOIN AdventureWorks.dbo.Customer AS C
    ON SH.customer_id = C.customer_id
GROUP BY C.customer_id;


-- 4. TOTAL SALES VALUE PER YEAR
SELECT 
    'Legacy' AS Source,
    YEAR(SH.OrderDate) AS SalesYear,
    SUM(SD.OrderQuantity * SD.UnitPrice) AS TotalSales
FROM AdventureWorksLegacy.dbo.SalesHeader AS SH
JOIN AdventureWorksLegacy.dbo.SalesDetail AS SD
    ON SH.SalesOrderID = SD.SalesOrderID
GROUP BY YEAR(SH.OrderDate)

UNION ALL

SELECT 
    'New',
    YEAR(SH.order_date),
    SUM(SD.order_quantity * SD.unit_price)
FROM AdventureWorks.dbo.SalesHeader AS SH
JOIN AdventureWorks.dbo.SalesDetail AS SD
    ON SH.sales_order_id = SD.sales_order_id
GROUP BY YEAR(SH.order_date);


-- 5. TOTAL SALES VALUE PER YEAR AND PRODUCT
SELECT 
    'Legacy' AS Source,
    YEAR(SH.OrderDate) AS SalesYear,
    P.ModelName AS ProductModel,
    SUM(SD.OrderQuantity * SD.UnitPrice) AS TotalSales
FROM AdventureWorksLegacy.dbo.SalesHeader AS SH
JOIN AdventureWorksLegacy.dbo.SalesDetail AS SD
    ON SH.SalesOrderID = SD.SalesOrderID
JOIN AdventureWorksLegacy.dbo.Products AS P
    ON SD.ProductKey = P.ProductKey
GROUP BY YEAR(SH.OrderDate), P.ModelName

UNION ALL

SELECT 
    'New',
    YEAR(SH.order_date),
    PM.model,
    SUM(SD.order_quantity * SD.unit_price)
FROM AdventureWorks.dbo.SalesHeader AS SH
JOIN AdventureWorks.dbo.SalesDetail AS SD
    ON SH.sales_order_id = SD.sales_order_id
JOIN AdventureWorks.dbo.ProductVariant AS PV
    ON SD.product_variant_id = PV.product_variant_id
JOIN AdventureWorks.dbo.ProductMaster AS PM
    ON PV.product_master_id = PM.product_master_id
GROUP BY YEAR(SH.order_date), PM.model;