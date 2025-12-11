/*===============================================================================
 DATA VALIDATION SCRIPT: APP USER MIGRATION
 Purpose:
   Validate AppUser migration from AdventureWorksLegacy.Customer → AdventureWorks.AppUser.
   - Checks record counts, customer linkage, and hashing completeness.
===============================================================================*/

USE AdventureWorks;
GO

PRINT('=== VALIDATION: APP USER MIGRATION ===');

-------------------------------------------------------------------------------
-- 1. VALIDATE APPUSER RECORD COUNT
-------------------------------------------------------------------------------
PRINT('1. VALIDATING AppUser count (should match Customer count)...');
SELECT
    'Legacy Customers with Passwords' AS Source,
    COUNT(*) AS Count
FROM AdventureWorksLegacy.dbo.Customer
WHERE Password IS NOT NULL
UNION ALL
SELECT
    'New AppUsers',
    COUNT(*) 
FROM AdventureWorks.dbo.AppUser;

-------------------------------------------------------------------------------
-- 2. VALIDATE CUSTOMER LINKAGE
-------------------------------------------------------------------------------
PRINT('2. VALIDATING AppUser ↔ Customer linkage...');
SELECT 
    COUNT(*) AS OrphanedAppUsers
FROM AdventureWorks.dbo.AppUser AS AU
LEFT JOIN AdventureWorks.dbo.Customer AS C
    ON AU.customer_id = C.customer_id
WHERE C.customer_id IS NULL;

-------------------------------------------------------------------------------
-- 3. VALIDATE EMAIL CONSISTENCY
-------------------------------------------------------------------------------
PRINT('3. VALIDATING email match between AppUser and Customer...');
SELECT TOP 10
    C.email_address AS CustomerEmail,
    AU.email AS AppUserEmail
FROM AdventureWorks.dbo.AppUser AS AU
JOIN AdventureWorks.dbo.Customer AS C
    ON AU.customer_id = C.customer_id
WHERE dbo.TrimSpaces(AU.email) <> dbo.TrimSpaces(C.email_address);

-------------------------------------------------------------------------------
-- 4. VALIDATE PASSWORD HASHING
-------------------------------------------------------------------------------
PRINT('4. VALIDATING password hashing (non-null, consistent length)...');
SELECT 
    COUNT(*) AS NullHashes
FROM AdventureWorks.dbo.AppUser
WHERE password_hash IS NULL;

SELECT 
    MIN(LEN(password_hash)) AS MinHashLength,
    MAX(LEN(password_hash)) AS MaxHashLength
FROM AdventureWorks.dbo.AppUser;

-------------------------------------------------------------------------------
-- 5. VALIDATE DEFAULTS
-------------------------------------------------------------------------------
PRINT('5. VALIDATING defaults (is_active = 1, created_at not null)...');
SELECT 
    SUM(CASE WHEN is_active = 1 THEN 1 ELSE 0 END) AS ActiveUsers,
    SUM(CASE WHEN is_active = 0 THEN 1 ELSE 0 END) AS InactiveUsers,
    SUM(CASE WHEN created_at IS NULL THEN 1 ELSE 0 END) AS MissingCreatedAt
FROM AdventureWorks.dbo.AppUser;

-------------------------------------------------------------------------------
-- 6. SUMMARY
-------------------------------------------------------------------------------
PRINT('=== VALIDATION SUMMARY ===');
SELECT 
    (SELECT COUNT(*) FROM AdventureWorks.dbo.AppUser) AS TotalAppUsers,
    (SELECT COUNT(DISTINCT customer_id) FROM AdventureWorks.dbo.AppUser) AS UniqueCustomerLinks,
    (SELECT COUNT(*) FROM AdventureWorks.dbo.Customer) AS TotalCustomers,
    (SELECT COUNT(*) FROM AdventureWorks.dbo.AppUser WHERE is_active = 1) AS ActiveAppUsers;
GO