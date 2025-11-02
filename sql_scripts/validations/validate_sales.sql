/*===============================================================================
 DATA VALIDATION SCRIPT: SALES MIGRATION
 Purpose:
   Validate migrated Sales data (Currency, SalesTerritory, SalesOrder, SalesOrderLine)
   between AdventureWorksLegacy and AdventureWorks.
===============================================================================*/

USE AdventureWorks;
GO

PRINT('=== VALIDATION: SALES MIGRATION ===');

-------------------------------------------------------------------------------
-- 1. VALIDATE CURRENCY
-------------------------------------------------------------------------------
PRINT('1. VALIDATING CURRENCY...');
SELECT 
    'Legacy' AS Source,
    COUNT(DISTINCT L.CurrencyAlternateKey) AS CurrencyCount
FROM AdventureWorksLegacy.dbo.Currency AS L
UNION ALL
SELECT 
    'New',
    COUNT(*) 
FROM AdventureWorks.dbo.Currency;

-------------------------------------------------------------------------------
-- 2. VALIDATE SALES TERRITORY
-------------------------------------------------------------------------------
PRINT('2. VALIDATING SALES TERRITORY...');
SELECT 
    'Legacy' AS Source,
    COUNT(DISTINCT L.SalesTerritoryRegion) AS TerritoryCount
FROM AdventureWorksLegacy.dbo.SalesTerritory AS L
UNION ALL
SELECT 
    'New',
    COUNT(*) 
FROM AdventureWorks.dbo.SalesTerritory;

-------------------------------------------------------------------------------
-- 3. VALIDATE SALES ORDERS
-------------------------------------------------------------------------------
PRINT('3. VALIDATING SALES ORDERS...');
SELECT 
    'Legacy' AS Source,
    COUNT(DISTINCT S.SalesOrderNumber) AS SalesOrderCount
FROM AdventureWorksLegacy.dbo.Sales AS S
UNION ALL
SELECT 
    'New',
    COUNT(*) 
FROM AdventureWorks.dbo.SalesOrder;

-- Check for unmapped legacy sales orders
PRINT('3A. Checking unmapped legacy SalesOrders...');
SELECT 
    COUNT(*) AS UnmappedLegacyOrders
FROM AdventureWorksLegacy.dbo.Sales AS S
LEFT JOIN AdventureWorks.dbo.SalesOrder AS SO
    ON dbo.TrimSpaces(S.SalesOrderNumber) = dbo.TrimSpaces(SO.sales_order_number)
WHERE SO.sales_order_id IS NULL;

-------------------------------------------------------------------------------
-- 4. VALIDATE SALES ORDER LINES
-------------------------------------------------------------------------------
PRINT('4. VALIDATING SALES ORDER LINES...');
SELECT 
    'Legacy' AS Source,
    COUNT(*) AS SalesOrderLineCount
FROM AdventureWorksLegacy.dbo.Sales AS S
UNION ALL
SELECT 
    'New',
    COUNT(*) 
FROM AdventureWorks.dbo.SalesOrderLine;

-- Check for NULL or mismatched product_variant_id
PRINT('4A. Checking SalesOrderLines with NULL or invalid ProductVariant...');
SELECT 
    COUNT(*) AS LinesWithoutValidVariant
FROM AdventureWorks.dbo.SalesOrderLine AS L
LEFT JOIN AdventureWorks.dbo.ProductVariant AS PV
    ON L.product_variant_id = PV.product_variant_id
WHERE PV.product_variant_id IS NULL;

-------------------------------------------------------------------------------
-- 5. VALIDATE QUANTITY CALCULATION
-------------------------------------------------------------------------------
PRINT('5. VALIDATING QUANTITY CALCULATION (sanity check)...');
SELECT TOP 10
    S.SalesOrderNumber,
    S.TotalSalesAmount,
    S.UnitPrice,
    CAST(
        ROUND(
            TRY_CONVERT(DECIMAL(18,4), S.TotalSalesAmount) / 
            NULLIF(TRY_CONVERT(DECIMAL(18,4), S.UnitPrice), 0), 
        0) AS INT
    ) AS ExpectedQuantityFromLegacy,
    L.quantity AS MigratedQuantity
FROM AdventureWorksLegacy.dbo.Sales AS S
JOIN AdventureWorks.dbo.SalesOrder AS SO
    ON dbo.TrimSpaces(S.SalesOrderNumber) = dbo.TrimSpaces(SO.sales_order_number)
JOIN AdventureWorks.dbo.SalesOrderLine AS L
    ON SO.sales_order_id = L.sales_order_id
ORDER BY S.SalesOrderNumber;

-------------------------------------------------------------------------------
-- 6. VALIDATE CUSTOMER LINK
-------------------------------------------------------------------------------
PRINT('6. VALIDATING CUSTOMER LINK...');
SELECT 
    COUNT(*) AS OrphanedOrders
FROM AdventureWorks.dbo.SalesOrder AS SO
LEFT JOIN AdventureWorks.dbo.Customer AS C
    ON SO.customer_id = C.customer_id
WHERE C.customer_id IS NULL;

-------------------------------------------------------------------------------
-- 7. SUMMARY
-------------------------------------------------------------------------------
PRINT('=== VALIDATION SUMMARY ===');
SELECT 
    (SELECT COUNT(*) FROM AdventureWorks.dbo.Currency) AS TotalCurrency,
    (SELECT COUNT(*) FROM AdventureWorks.dbo.SalesTerritory) AS TotalTerritories,
    (SELECT COUNT(*) FROM AdventureWorks.dbo.SalesOrder) AS TotalSalesOrders,
    (SELECT COUNT(*) FROM AdventureWorks.dbo.SalesOrderLine) AS TotalSalesOrderLines
    --(SELECT COUNT(*) FROM AdventureWorks.dbo.ProductVariant WHERE legacy_product_key IS NOT NULL) AS TotalVariantsWithLegacyKey;
GO