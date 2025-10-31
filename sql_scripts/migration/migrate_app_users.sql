use AdventureWorks
GO

--=================================================================================
-- STEP 1: MIGRATE APP USERS
--=================================================================================
-- Purpose:
-- 1. Create an AppUser for each Customer in the new system.
-- 2. Link AppUser.customer_id to Customer.customer_id.
-- 3. Set email from Customer.email_address.
-- 4. Use legacy password hash (pbkdf2$sha256$...) from legacy Password column.
-- 5. Set default is_active = 1.
--=================================================================================
PRINT('STEP 1 - Migrating AppUsers with existing password hashes...');

INSERT INTO dbo.AppUser (
    customer_id, 
    email, 
    password_hash, 
    is_active, 
    created_at
)
SELECT
    C.customer_id,
    dbo.TrimSpaces(C.email_address),
    L.Password,
    1,
    GETDATE()
FROM AdventureWorksLegacy.dbo.Customer AS L
JOIN dbo.Customer AS C
    ON dbo.TrimSpaces(L.EmailAddress) = dbo.TrimSpaces(C.email_address)
WHERE NOT EXISTS (
    SELECT 1 
    FROM dbo.AppUser AS AU 
    WHERE AU.customer_id = C.customer_id
);
GO

--=================================================================================
-- STEP 2: OPTIONAL - Password Recovery Questions
--=================================================================================
-- Only populate if legacy system had recovery questions.
PRINT('STEP 2 - PasswordRecoveryQuestion table ready for future use.');
GO

--=================================================================================
-- STEP 3: OPTIONAL - Sent Emails
--=================================================================================
-- Empty by default; future system can log emails here.
PRINT('STEP 3 - SentEmails table ready for future records.');
GO

--=================================================================================
-- VERIFICATION
--=================================================================================
PRINT('Verification of AppUser migration:');
SELECT COUNT(*) AS TotalAppUsers FROM dbo.AppUser;
GO