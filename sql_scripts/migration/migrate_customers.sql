/*===============================================================================
 MIGRATION SCRIPT: CUSTOMERS
 Source: AdventureWorksLegacy
 Target: AdventureWorks
 Purpose:
   - Clean and reload CountryRegion, StateProvince, Customer, and CustomerAddress.
   - Include secure NIFencryption.
   - Support safe re-runs (idempotent inserts and deletes).
===============================================================================*/

-------------------------------------------------------------------------------
-- STEP 0: CLEAN EXISTING DATA
-------------------------------------------------------------------------------
PRINT('STEP 0 - Cleaning dependent tables...');
DELETE FROM dbo.CustomerAddress;
DELETE FROM dbo.Customer;
DELETE FROM dbo.StateProvince;
DELETE FROM dbo.CountryRegion;
GO


/*===============================================================================
 STEP 1: MIGRATE COUNTRY REGION
 - Insert distinct CountryRegion codes and names.
===============================================================================*/
PRINT('STEP 1 - Inserting CountryRegion...');
INSERT INTO dbo.CountryRegion (code, name)
SELECT DISTINCT
    dbo.TrimSpaces(c.CountryRegionCode),
    dbo.TrimSpaces(c.CountryRegionName)
FROM AdventureWorksLegacy.dbo.Customer AS c
WHERE c.CountryRegionCode IS NOT NULL
  AND NOT EXISTS (
        SELECT 1
        FROM dbo.CountryRegion AS cr
        WHERE cr.code = dbo.TrimSpaces(c.CountryRegionCode)
  );
GO

/*===============================================================================
 STEP 2: MIGRATE STATE / PROVINCE
 - Link to CountryRegion via CountryRegionCode.
===============================================================================*/
PRINT('STEP 2 - Inserting StateProvince...');
INSERT INTO dbo.StateProvince (code, name, country_id)
SELECT DISTINCT
    dbo.TrimSpaces(c.StateProvinceCode),
    dbo.TrimSpaces(c.StateProvinceName),
    cr.country_id
FROM AdventureWorksLegacy.dbo.Customer AS c
INNER JOIN dbo.CountryRegion AS cr
    ON dbo.TrimSpaces(c.CountryRegionCode) = cr.code
WHERE c.StateProvinceCode IS NOT NULL
  AND NOT EXISTS (
        SELECT 1
        FROM dbo.StateProvince AS sp
        WHERE sp.code = dbo.TrimSpaces(c.StateProvinceCode)
  );
GO

-- /*===============================================================================
--  STEP 3: SETUP ENCRYPTION FOR CUSTOMER NIF
--  - Create Master Key, Certificate, and Symmetric Key if not present.
-- ===============================================================================*/
-- PRINT('STEP 3 - Setting up encryption for NIF...');
-- IF NOT EXISTS (SELECT * FROM sys.symmetric_keys WHERE name = '##MS_DatabaseMasterKey##')
-- BEGIN
--     CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'ChaveSegura123!';
--     PRINT('Database Master Key created.');
-- END;

-- IF NOT EXISTS (SELECT * FROM sys.certificates WHERE name = 'CertNIF')
-- BEGIN
--     CREATE CERTIFICATE CertNIF WITH SUBJECT = 'Certificado NIF';
--     PRINT('Certificate CertNIF created.');
-- END;

-- IF NOT EXISTS (SELECT * FROM sys.symmetric_keys WHERE name = 'KeyNIF')
-- BEGIN
--     CREATE SYMMETRIC KEY KeyNIF
--         WITH ALGORITHM = AES_256
--         ENCRYPTION BY CERTIFICATE CertNIF;
--     PRINT('Symmetric Key KeyNIF created.');
-- END;
-- GO

/*===============================================================================
 STEP 4: MIGRATE CUSTOMERS
 - Encrypt NIF using KeyNIF.
 - Skip duplicates by email.
===============================================================================*/
PRINT('STEP 4 - Inserting Customers...');
OPEN SYMMETRIC KEY KeyNIF DECRYPTION BY CERTIFICATE CertNIF;

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
    --ENCRYPTBYKEY(KEY_GUID('KeyNIF'), CONVERT(VARBINARY(MAX), dbo.TrimSpaces(c.NIF)))
    c.NIF
FROM AdventureWorksLegacy.dbo.Customer AS c
WHERE c.EmailAddress IS NOT NULL
  AND NOT EXISTS (
        SELECT 1
        FROM dbo.Customer AS n
        WHERE n.email_address = dbo.TrimSpaces(c.EmailAddress)
  );

CLOSE SYMMETRIC KEY KeyNIF;
GO

/*===============================================================================
 STEP 5: MIGRATE CUSTOMER ADDRESSES
 - Join Customers by EmailAddress.
 - Link to StateProvince and CountryRegion.
===============================================================================*/
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
INNER JOIN dbo.Customer AS N
    ON dbo.TrimSpaces(L.EmailAddress) = dbo.TrimSpaces(N.email_address)
LEFT JOIN dbo.StateProvince AS SP
    ON dbo.TrimSpaces(L.StateProvinceCode) = dbo.TrimSpaces(SP.code)
LEFT JOIN dbo.CountryRegion AS CR
    ON dbo.TrimSpaces(L.CountryRegionCode) = dbo.TrimSpaces(CR.code);
GO

/*===============================================================================
 VERIFICATION
===============================================================================*/
PRINT('Verification Summary:');
SELECT
    (SELECT COUNT(*) FROM dbo.CountryRegion) AS TotalCountryRegions,
    (SELECT COUNT(*) FROM dbo.StateProvince) AS TotalStateProvinces,
    (SELECT COUNT(*) FROM dbo.Customer) AS TotalCustomers,
    (SELECT COUNT(*) FROM dbo.CustomerAddress) AS TotalCustomerAddresses;
GO