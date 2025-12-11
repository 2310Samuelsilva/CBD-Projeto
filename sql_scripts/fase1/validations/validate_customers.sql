USE AdventureWorks;
GO

/*===============================================================================
 DATA VALIDATION SCRIPT: CUSTOMERS
 Purpose:
   Compare record counts and key values between AdventureWorksLegacy and AdventureWorks
   to verify that CountryRegion, StateProvince, Customer, and CustomerAddress 
   migrated correctly.
===============================================================================*/

PRINT('=== CUSTOMER DATA VALIDATION STARTED ===');

-------------------------------------------------------------------------------
-- 1. COUNTRY REGION VALIDATION
-------------------------------------------------------------------------------
PRINT('1. CountryRegion...');
SELECT 
    'Legacy' AS Source,
    COUNT(DISTINCT dbo.TrimSpaces(C.CountryRegionCode)) AS CountryRegionCount
FROM AdventureWorksLegacy.dbo.Customer AS C
WHERE C.CountryRegionCode IS NOT NULL
UNION ALL
SELECT 
    'New',
    COUNT(*) AS CountryRegionCount
FROM AdventureWorks.dbo.CountryRegion;

-- Check missing country codes
SELECT DISTINCT dbo.TrimSpaces(C.CountryRegionCode) AS MissingCountryRegionCode
FROM AdventureWorksLegacy.dbo.Customer AS C
WHERE C.CountryRegionCode IS NOT NULL
AND NOT EXISTS (
    SELECT 1 
    FROM AdventureWorks.dbo.CountryRegion AS CR
    WHERE CR.code = dbo.TrimSpaces(C.CountryRegionCode)
);

-------------------------------------------------------------------------------
-- 2. STATE / PROVINCE VALIDATION
-------------------------------------------------------------------------------
PRINT('2. StateProvince...');
SELECT 
    'Legacy' AS Source,
    COUNT(DISTINCT dbo.TrimSpaces(C.StateProvinceCode)) AS StateProvinceCount
FROM AdventureWorksLegacy.dbo.Customer AS C
WHERE C.StateProvinceCode IS NOT NULL
UNION ALL
SELECT 
    'New',
    COUNT(*) AS StateProvinceCount
FROM AdventureWorks.dbo.StateProvince;

-- Check missing state codes
SELECT DISTINCT dbo.TrimSpaces(C.StateProvinceCode) AS MissingStateProvinceCode
FROM AdventureWorksLegacy.dbo.Customer AS C
WHERE C.StateProvinceCode IS NOT NULL
AND NOT EXISTS (
    SELECT 1 
    FROM AdventureWorks.dbo.StateProvince AS SP
    WHERE SP.code = dbo.TrimSpaces(C.StateProvinceCode)
);

-------------------------------------------------------------------------------
-- 3. CUSTOMER VALIDATION
-------------------------------------------------------------------------------
PRINT('3. Customer...');
SELECT 
    'Legacy' AS Source,
    COUNT(*) AS CustomerCount
FROM AdventureWorksLegacy.dbo.Customer
WHERE EmailAddress IS NOT NULL
UNION ALL
SELECT 
    'New',
    COUNT(*) AS CustomerCount
FROM AdventureWorks.dbo.Customer;

-- Check for missing customers (by EmailAddress)
SELECT 
    L.EmailAddress AS MissingEmail
FROM AdventureWorksLegacy.dbo.Customer AS L
WHERE L.EmailAddress IS NOT NULL
AND NOT EXISTS (
    SELECT 1 
    FROM AdventureWorks.dbo.Customer AS N
    WHERE N.email_address = dbo.TrimSpaces(L.EmailAddress)
);

-------------------------------------------------------------------------------
-- 4. CUSTOMER ADDRESS VALIDATION
-------------------------------------------------------------------------------
PRINT('4. CustomerAddress...');
SELECT 
    'Legacy' AS Source,
    COUNT(*) AS AddressCount
FROM AdventureWorksLegacy.dbo.Customer
WHERE AddressLine1 IS NOT NULL
UNION ALL
SELECT 
    'New',
    COUNT(*) AS AddressCount
FROM AdventureWorks.dbo.CustomerAddress;

-- Check orphan addresses (no customer match)
SELECT 
    COUNT(*) AS OrphanCustomerAddresses
FROM AdventureWorks.dbo.CustomerAddress AS CA
LEFT JOIN AdventureWorks.dbo.Customer AS C
    ON CA.customer_id = C.customer_id
WHERE C.customer_id IS NULL;

-------------------------------------------------------------------------------
-- 5. SUMMARY
-------------------------------------------------------------------------------
PRINT('Validation Summary:');
SELECT
    (SELECT COUNT(*) FROM AdventureWorks.dbo.CountryRegion) AS TotalCountryRegions,
    (SELECT COUNT(*) FROM AdventureWorks.dbo.StateProvince) AS TotalStateProvinces,
    (SELECT COUNT(*) FROM AdventureWorks.dbo.Customer) AS TotalCustomers,
    (SELECT COUNT(*) FROM AdventureWorks.dbo.CustomerAddress) AS TotalCustomerAddresses;

PRINT('=== CUSTOMER DATA VALIDATION COMPLETE ===');
GO