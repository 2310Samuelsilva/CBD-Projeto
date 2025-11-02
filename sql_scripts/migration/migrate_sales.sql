--=================================================================================
-- MIGRATION SCRIPT: SALES (cleaned)
-- Target: AdventureWorks
-- Source: AdventureWorksLegacy
--=================================================================================
-- Assumptions:
--  - Both databases exist on the same SQL Server instance.
--  - Helper function dbo.TrimSpaces exists.
--  - ProductMaster/ProductVariant and related lookup tables already populated.
--  - This script uses temp tables; safe to re-run if you remove temp objects first.
--=================================================================================

USE AdventureWorks;
GO  

--=================================================================================
-- STEP 1: MIGRATE CURRENCY (from legacy Currency table)
--=================================================================================
PRINT('STEP 1 - Inserting Currency (from legacy table)...');

INSERT INTO dbo.Currency (code, name)
SELECT
    dbo.TrimSpaces(L.CurrencyAlternateKey) AS code,
    dbo.TrimSpaces(L.CurrencyName) AS name
FROM AdventureWorksLegacy.dbo.Currency AS L
WHERE dbo.TrimSpaces(L.CurrencyAlternateKey) IS NOT NULL
  AND NOT EXISTS (
      SELECT 1
      FROM dbo.Currency AS C
      WHERE dbo.TrimSpaces(C.code) = dbo.TrimSpaces(L.CurrencyAlternateKey)
  );
GO

--=================================================================================
-- STEP 2: MIGRATE SALES TERRITORY
--=================================================================================
PRINT('STEP 2 - Inserting SalesTerritory...');

INSERT INTO dbo.SalesTerritory (region, country_region_id, territory_group)
SELECT
    dbo.TrimSpaces(L.SalesTerritoryRegion) AS region,
    CR.country_id,
    dbo.TrimSpaces(L.SalesTerritoryGroup) AS territory_group
FROM AdventureWorksLegacy.dbo.SalesTerritory AS L
JOIN dbo.CountryRegion AS CR
    ON dbo.TrimSpaces(CR.name) = dbo.TrimSpaces(L.SalesTerritoryCountry)
WHERE NOT EXISTS (
    SELECT 1 FROM dbo.SalesTerritory ST
    WHERE dbo.TrimSpaces(ST.region) = dbo.TrimSpaces(L.SalesTerritoryRegion)
      AND ST.country_region_id = CR.country_id
);
GO

--=================================================================================
-- STEP 3: CREATE TEMP CUSTOMER MAP
--=================================================================================
PRINT('STEP 3 - Creating #CustomerMap (legacy_customer_key -> new_customer_id)...');

IF OBJECT_ID('tempdb..#CustomerMap') IS NOT NULL DROP TABLE #CustomerMap;
SELECT 
    L.CustomerKey AS old_customer_key,
    N.customer_id AS new_customer_id
INTO #CustomerMap
FROM AdventureWorksLegacy.dbo.Customer AS L
JOIN dbo.Customer AS N
    ON dbo.TrimSpaces(L.EmailAddress) = dbo.TrimSpaces(N.email_address);
GO

--=================================================================================
-- STEP 4: MIGRATE SALES ORDERS
--=================================================================================
PRINT('STEP 4 - Inserting SalesOrder...');

INSERT INTO dbo.SalesOrder (
    sales_order_number,
    customer_id,
    sales_territory_id,
    currency_id,
    order_date,
    due_date,
    ship_date
)
SELECT DISTINCT
    dbo.TrimSpaces(S.SalesOrderNumber),
    CM.new_customer_id,
    ST.sales_territory_id,
    C.currency_id,
    CAST(S.OrderDate AS DATE),
    CAST(S.DueDate AS DATE),
    CAST(S.ShipDate AS DATE)
FROM AdventureWorksLegacy.dbo.Sales AS S
LEFT JOIN AdventureWorksLegacy.dbo.SalesTerritory AS LST
    ON S.SalesTerritoryKey = LST.SalesTerritoryKey
LEFT JOIN dbo.SalesTerritory AS ST
    ON dbo.TrimSpaces(LST.SalesTerritoryRegion) = dbo.TrimSpaces(ST.region)
LEFT JOIN AdventureWorksLegacy.dbo.Currency AS LC
    ON S.CurrencyKey = LC.CurrencyKey
LEFT JOIN dbo.Currency AS C
    ON dbo.TrimSpaces(LC.CurrencyAlternateKey) = dbo.TrimSpaces(C.code)
JOIN #CustomerMap AS CM
    ON S.CustomerKey = CM.old_customer_key
WHERE CM.new_customer_id IS NOT NULL
  AND NOT EXISTS (
      SELECT 1 FROM dbo.SalesOrder SO
      WHERE dbo.TrimSpaces(SO.sales_order_number) = dbo.TrimSpaces(S.SalesOrderNumber)
  );
GO
--=================================================================================
-- STEP 5: MIGRATE SALES ORDER LINES (using ProductVariant.legacy_product_key)
--=================================================================================
PRINT('STEP 5 - Inserting SalesOrderLine records (linked by legacy_product_key)...');

INSERT INTO AdventureWorks.dbo.SalesOrderLine (
    sales_order_id,
    line_number,
    product_variant_id,
    product_standard_cost,
    unit_price,
    quantity,
    tax_amt,
    freight
)
SELECT
    SO.sales_order_id,
    S.SalesOrderLineNumber,
    PV.product_variant_id,
    TRY_CONVERT(DECIMAL(18,4), S.ProductStandardCost) AS product_standard_cost,
    TRY_CONVERT(DECIMAL(18,4), S.UnitPrice) AS unit_price,
    CAST(
        ROUND(
            TRY_CONVERT(DECIMAL(18,4), S.TotalSalesAmount) / 
            NULLIF(TRY_CONVERT(DECIMAL(18,4), S.UnitPrice), 0), 
        0) AS INT
    ) AS quantity,
    TRY_CONVERT(DECIMAL(18,4), S.TaxAmt) AS tax_amt,
    TRY_CONVERT(DECIMAL(18,4), S.Freight) AS freight
FROM AdventureWorksLegacy.dbo.Sales AS S
INNER JOIN AdventureWorks.dbo.SalesOrder AS SO
    ON dbo.TrimSpaces(S.SalesOrderNumber) = dbo.TrimSpaces(SO.sales_order_number)
INNER JOIN #CustomerMap AS CM
    ON S.CustomerKey = CM.old_customer_key
INNER JOIN AdventureWorks.dbo.ProductVariant AS PV
    ON S.ProductKey = PV.legacy_product_key
WHERE CM.new_customer_id IS NOT NULL
  AND NOT EXISTS (
      SELECT 1
      FROM AdventureWorks.dbo.SalesOrderLine AS SOL
      WHERE SOL.sales_order_id = SO.sales_order_id
        AND SOL.line_number = S.SalesOrderLineNumber
  );



--=================================================================================
-- Diagnostics
--=================================================================================
PRINT('STEP 12 COMPLETE - SalesOrderLine migration finished.');

SELECT
    (SELECT COUNT(*) FROM AdventureWorks.dbo.SalesOrder) AS TotalSalesOrders,
    (SELECT COUNT(*) FROM AdventureWorks.dbo.SalesOrderLine) AS TotalSalesOrderLines,
    (SELECT COUNT(*) FROM AdventureWorks.dbo.ProductVariant WHERE legacy_product_key IS NOT NULL) AS TotalProductVariantsWithLegacyKey;

-- Optional cleanup of the legacy key column (uncomment if desired after validation)
-- ALTER TABLE AdventureWorks.dbo.ProductVariant DROP COLUMN legacy_product_key;
GO