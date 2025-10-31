USE AdventureWorks;
GO

------------------------------------------------------------
-- STEP 0: CLEAN EXISTING DATA
-------------------------------------------------------------
-- Purpose: Remove all data from the main tables to allow re-runs of the migration without duplicates.
------------------------------------------------------------
PRINT('STEP 0 - Cleaning main tables...');
DELETE FROM SalesOrderLine;
DELETE FROM SalesOrder;
DELETE FROM SalesTerritory;
DELETE FROM Currency;
DELETE FROM CustomerAddress;
DELETE FROM Customer;
DELETE FROM StateProvince;
DELETE FROM CountryRegion;
GO

------------------------------------------------------------
-- STEP 0B: ENSURE NIF COLUMN IS VARBINARY(MAX)
-------------------------------------------------------------
-- Purpose: Drop and recreate the NIF column in Customer table to store encrypted NIFs.
------------------------------------------------------------
IF EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Customer') AND name = 'nif')
BEGIN
    ALTER TABLE dbo.Customer DROP COLUMN nif;
    ALTER TABLE dbo.Customer ADD nif VARBINARY(MAX) NULL;
END
GO

--=================================================================================
-- STEP 1: MIGRATE COUNTRY REGION
--=================================================================================
-- 1. Extract distinct country codes and names from legacy Customer table.
-- 2. Trim spaces using dbo.TrimSpaces.
-- 3. Insert only if the country does not already exist.
--=================================================================================
PRINT('STEP 1: Inserting CountryRegion...');
INSERT INTO dbo.CountryRegion (code, name)
SELECT DISTINCT 
    dbo.TrimSpaces(c.CountryRegionCode) AS code,
    dbo.TrimSpaces(c.CountryRegionName) AS name
FROM AdventureWorksLegacy.dbo.Customer AS c
WHERE c.CountryRegionCode IS NOT NULL
  AND NOT EXISTS (
      SELECT 1 FROM dbo.CountryRegion AS cr 
      WHERE cr.code = dbo.TrimSpaces(c.CountryRegionCode)
  );
GO

--=================================================================================
-- STEP 2: MIGRATE STATE / PROVINCE
--=================================================================================
-- 1. Extract distinct state/province codes and names from legacy Customer table.
-- 2. Map to corresponding CountryRegion using trimmed code.
-- 3. Insert only if not already present.
--=================================================================================
PRINT('STEP 2: Inserting StateProvince...');
INSERT INTO dbo.StateProvince (code, name, country_id)
SELECT DISTINCT
    dbo.TrimSpaces(c.StateProvinceCode) AS code,
    dbo.TrimSpaces(c.StateProvinceName) AS name,
    cr.country_id
FROM AdventureWorksLegacy.dbo.Customer AS c
JOIN dbo.CountryRegion AS cr 
    ON dbo.TrimSpaces(c.CountryRegionCode) = cr.code
WHERE c.StateProvinceCode IS NOT NULL
  AND NOT EXISTS (
      SELECT 1 FROM dbo.StateProvince AS sp
      WHERE sp.code = dbo.TrimSpaces(c.StateProvinceCode)
  );
GO

--=================================================================================
-- STEP 3: SETUP ENCRYPTION FOR CUSTOMER NIF
--=================================================================================
-- 1. Create Database Master Key if missing.
-- 2. Create Certificate for NIF encryption.
-- 3. Create Symmetric Key for AES_256 encryption.
--=================================================================================
PRINT('STEP 3: Checking encryption keys...');
IF NOT EXISTS (SELECT * FROM sys.symmetric_keys WHERE name = '##MS_DatabaseMasterKey##')
BEGIN
    CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'ChaveSegura123!';
    PRINT('Master key created.');
END;

IF NOT EXISTS (SELECT * FROM sys.certificates WHERE name = 'CertNIF')
BEGIN
    CREATE CERTIFICATE CertNIF WITH SUBJECT = 'Certificado NIF';
    PRINT('Certificate CertNIF created.');
END;

IF NOT EXISTS (SELECT * FROM sys.symmetric_keys WHERE name = 'KeyNIF')
BEGIN
    CREATE SYMMETRIC KEY KeyNIF WITH ALGORITHM = AES_256 ENCRYPTION BY CERTIFICATE CertNIF;
    PRINT('Symmetric key KeyNIF created.');
END;
GO

--=================================================================================
-- STEP 4: MIGRATE CUSTOMERS
--=================================================================================
-- 1. Open symmetric key to encrypt NIF.
-- 2. Insert trimmed customer data.
-- 3. Encrypt NIF with KeyNIF.
-- 4. Skip duplicates based on email_address.
--=================================================================================
PRINT('STEP 4: Inserting Customers...');
OPEN SYMMETRIC KEY KeyNIF DECRYPTION BY CERTIFICATE CertNIF;
GO

INSERT INTO dbo.Customer (
    title,
    first_name,
    middle_name,
    last_name,
    birth_date,
    marital_status,
    gender,
    email_address,
    yearly_income,
    education,
    occupation,
    number_cars_owned,
    date_first_purchase,
    nif
)
SELECT
    dbo.TrimSpaces(c.Title),
    dbo.TrimSpaces(c.FirstName),
    dbo.TrimSpaces(c.MiddleName),
    dbo.TrimSpaces(c.LastName),
    c.BirthDate,
    c.MaritalStatus,
    c.Gender,
    dbo.TrimSpaces(c.EmailAddress),
    c.YearlyIncome,
    dbo.TrimSpaces(c.Education),
    dbo.TrimSpaces(c.Occupation),
    c.NumberCarsOwned,
    c.DateFirstPurchase,
    ENCRYPTBYKEY(KEY_GUID('KeyNIF'), CONVERT(VARBINARY(MAX), dbo.TrimSpaces(c.NIF)))
FROM AdventureWorksLegacy.dbo.Customer AS c
WHERE c.EmailAddress IS NOT NULL
  AND NOT EXISTS (
      SELECT 1 FROM dbo.Customer AS n
      WHERE n.email_address = dbo.TrimSpaces(c.EmailAddress)
  );
GO

CLOSE SYMMETRIC KEY KeyNIF;
GO

--=================================================================================
-- STEP 5: MIGRATE CUSTOMER ADDRESSES
--=================================================================================
-- 1. Map legacy customer to new Customer using email_address.
-- 2. Map StateProvince and CountryRegion using trimmed codes.
--=================================================================================
PRINT('STEP 5 - Inserting CustomerAddress...');
INSERT INTO dbo.CustomerAddress (
    customer_id,
    address_line1,
    city,
    state_province_id,
    postal_code,
    country_id,
    phone
)
SELECT
    N.customer_id,
    L.AddressLine1,
    L.City,
    SP.state_province_id,
    L.PostalCode,
    CR.country_id,
    L.Phone
FROM AdventureWorksLegacy.dbo.Customer AS L
JOIN dbo.Customer AS N
    ON dbo.TrimSpaces(L.EmailAddress) = dbo.TrimSpaces(N.email_address)
LEFT JOIN dbo.StateProvince AS SP 
    ON dbo.TrimSpaces(L.StateProvinceCode) = SP.code
LEFT JOIN dbo.CountryRegion AS CR 
    ON dbo.TrimSpaces(L.CountryRegionCode) = CR.code;
GO

--=================================================================================
-- STEP 6: MIGRATE CURRENCY
--=================================================================================
-- 1. Use legacy Currency table for accurate code & name.
-- 2. Insert only if code does not exist in target.
--=================================================================================
PRINT('STEP 6 - Inserting Currency...');
INSERT INTO dbo.Currency (code, name)
SELECT
    dbo.TrimSpaces(L.CurrencyAlternateKey) AS code,
    dbo.TrimSpaces(L.CurrencyName) AS name
FROM AdventureWorksLegacy.dbo.Currency AS L
WHERE L.CurrencyAlternateKey IS NOT NULL
  AND NOT EXISTS (
      SELECT 1
      FROM dbo.Currency AS C
      WHERE C.code = dbo.TrimSpaces(L.CurrencyAlternateKey)
  );
GO

--=================================================================================
-- STEP 7: MIGRATE SALES TERRITORY
--=================================================================================
-- 1. Map legacy SalesTerritoryCountry to CountryRegion.
-- 2. Insert region, group, and link to country_region_id.
--=================================================================================
PRINT('STEP 7 - Inserting SalesTerritory...');
INSERT INTO dbo.SalesTerritory (region, country_region_id, territory_group)
SELECT
    dbo.TrimSpaces(L.SalesTerritoryRegion) AS region,
    CR.country_id,
    dbo.TrimSpaces(L.SalesTerritoryGroup) AS territory_group
FROM AdventureWorksLegacy.dbo.SalesTerritory AS L
JOIN dbo.CountryRegion AS CR
    ON dbo.TrimSpaces(CR.name) = dbo.TrimSpaces(L.SalesTerritoryCountry);
GO

--=================================================================================
-- STEP 8: CREATE TEMP CUSTOMER MAP
--=================================================================================
-- 1. Map legacy CustomerKey to new customer_id for Sales mapping.
--=================================================================================
PRINT('STEP 8 - Creating #CustomerMap...');
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
-- STEP 9: MIGRATE SALES ORDERS
--=================================================================================
-- 1. Map legacy SalesTerritory to new SalesTerritory via trimmed region.
-- 2. Insert sales orders for mapped customers.
--=================================================================================
PRINT('STEP 9 - Inserting SalesOrder...');
INSERT INTO dbo.SalesOrder (
    sales_order_number,
    customer_id,
    sales_territory_id,
    order_date,
    due_date,
    ship_date
)
SELECT DISTINCT
    S.SalesOrderNumber,
    CM.new_customer_id,
    ST.sales_territory_id,
    CAST(S.OrderDate AS DATE),
    CAST(S.DueDate AS DATE),
    CAST(S.ShipDate AS DATE)
FROM AdventureWorksLegacy.dbo.Sales AS S
LEFT JOIN AdventureWorksLegacy.dbo.SalesTerritory AS LST
    ON S.SalesTerritoryKey = LST.SalesTerritoryKey
LEFT JOIN dbo.SalesTerritory AS ST
    ON dbo.TrimSpaces(LST.SalesTerritoryRegion) = dbo.TrimSpaces(ST.region)
JOIN #CustomerMap AS CM
    ON S.CustomerKey = CM.old_customer_key
WHERE CM.new_customer_id IS NOT NULL;
GO

--=================================================================================
-- STEP 10: MAP PRODUCTS TO VARIANTS
--=================================================================================
-- 1. Match legacy ProductKey to new ProductVariant using TrimSpaces for all attributes.
--=================================================================================
IF OBJECT_ID('tempdb..#ProductVariantMap') IS NOT NULL DROP TABLE #ProductVariantMap;

SELECT 
    L.ProductKey AS legacy_product_key,
    PV.product_variant_id
INTO #ProductVariantMap
FROM AdventureWorksLegacy.dbo.Products AS L
INNER JOIN dbo.ProductMaster AS PM
    ON dbo.TrimSpaces(L.ModelName) = dbo.TrimSpaces(PM.model)
INNER JOIN dbo.ProductVariant AS PV
    ON PV.product_master_id = PM.product_master_id
   AND PV.color_id = ISNULL(
       (SELECT TOP 1 color_id FROM dbo.ProductColor WHERE dbo.TrimSpaces(name) = dbo.TrimSpaces(L.Color)),
       (SELECT TOP 1 color_id FROM dbo.ProductColor WHERE name = 'N/A')
   )
   AND PV.style_id = ISNULL(
       (SELECT TOP 1 style_id FROM dbo.ProductStyle WHERE dbo.TrimSpaces(name) = dbo.TrimSpaces(L.Style)),
       (SELECT TOP 1 style_id FROM dbo.ProductStyle WHERE name = 'N/A')
   )
   AND ISNULL(PV.size,'') = ISNULL(dbo.TrimSpaces(L.Size),'')
   AND ISNULL(PV.size_unit_measure_code,'NA') = ISNULL(dbo.TrimSpaces(L.SizeUnitMeasureCode),'NA');

SELECT COUNT(1) AS MappedRows FROM #ProductVariantMap;
GO

--=================================================================================
-- STEP 11: MIGRATE SALES ORDER LINES
--=================================================================================
-- 1. Map legacy ProductKey to ProductVariant via #ProductVariantMap.
-- 2. Map currency by trimmed code.
--=================================================================================
PRINT('STEP 11 - Inserting SalesOrderLine...');
INSERT INTO dbo.SalesOrderLine (
    sales_order_id,
    line_number,
    product_variant_id,
    currency_id,
    product_standard_cost,
    unit_price,
    quantity,
    tax_amt,
    freight
)
SELECT
    SO.sales_order_id,
    S.SalesOrderLineNumber,
    PVMap.product_variant_id,
    C.currency_id,
    S.ProductStandardCost,
    S.UnitPrice,
    1 AS quantity,
    S.TaxAmt,
    S.Freight
FROM AdventureWorksLegacy.dbo.Sales AS S
JOIN dbo.SalesOrder AS SO 
    ON S.SalesOrderNumber = SO.sales_order_number
JOIN #CustomerMap AS CM
    ON S.CustomerKey = CM.old_customer_key
JOIN #ProductVariantMap AS PVMap
    ON S.ProductKey = PVMap.legacy_product_key
LEFT JOIN dbo.Currency AS C 
    ON dbo.TrimSpaces(S.CurrencyKey) = dbo.TrimSpaces(C.code)
WHERE CM.new_customer_id IS NOT NULL;
GO

--=================================================================================
-- STEP 12: FINAL VERIFICATION
--=================================================================================
PRINT('STEP 12 - Verifying counts...');
SELECT 
    (SELECT COUNT(*) FROM Customer) AS Clientes,
    (SELECT COUNT(*) FROM CustomerAddress) AS Moradas,
    (SELECT COUNT(*) FROM CountryRegion) AS Paises,
    (SELECT COUNT(*) FROM StateProvince) AS Provincias,
    (SELECT COUNT(*) FROM SalesTerritory) AS Territorios,
    (SELECT COUNT(*) FROM Currency) AS Moedas,
    (SELECT COUNT(*) FROM SalesOrder) AS Encomendas,
    (SELECT COUNT(*) FROM SalesOrderLine) AS Linhas;

PRINT('MIGRAÇÃO CONCLUÍDA COM SUCESSO!');
GO