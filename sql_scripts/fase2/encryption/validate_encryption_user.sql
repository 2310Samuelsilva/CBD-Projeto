/*======================================================================
  DEMONSTRATION OF PASSWORD RECOVERY USING EXISTING PROCEDURE
======================================================================*/

USE AdventureWorks;
GO

/*======================================================================
  1. CREATE TEST CUSTOMER
======================================================================*/
INSERT INTO dbo.Customer (
    title,
    first_name,
    last_name,
    email_address,
    nif
)
VALUES (
    'Mr.',
    'Test',
    'User',
    'testuser@example.com',
    '123456789'
);
GO

-- Capture customer_id of new customer
DECLARE @customer_id INT = SCOPE_IDENTITY();
PRINT 'Test Customer created with customer_id = ' + CAST(@customer_id AS NVARCHAR(10));

/*======================================================================
  2. CREATE APP USER WITH PASSWORD AND RECOVERY QUESTION
======================================================================*/
INSERT INTO dbo.AppUser (customer_id, email, password_hash, is_active, created_at)
VALUES (
    @customer_id,
    'testuser@example.com',
    dbo.ComputeHash('InitialPassword123'),
    1,
    GETDATE()
);
GO

-- Capture app_user_id
DECLARE @app_user_id INT = SCOPE_IDENTITY();
PRINT 'AppUser created with app_user_id = ' + CAST(@app_user_id AS NVARCHAR(10));

-- Insert recovery question and answer (hashed)
INSERT INTO dbo.PasswordRecoveryQuestion (app_user_id, question_text, answer_hash)
VALUES (
    @app_user_id,
    'Cor favorita?',
    dbo.ComputeHash('Blue')
);
GO

/*======================================================================
  3. VIEW INITIAL PASSWORD HASH
======================================================================*/
SELECT
    AU.email,
    AU.password_hash
FROM dbo.AppUser AU
WHERE AU.app_user_id = @app_user_id;
GO

/*======================================================================
  4. SIMULATE PASSWORD RECOVERY USING EXISTING PROCEDURE
======================================================================*/
EXEC dbo.sp_recover_password
    @email = 'testuser@example.com',
    @answer = 'Blue';
GO

/*======================================================================
  5. VERIFY UPDATED PASSWORD HASH
======================================================================*/
SELECT
    AU.email,
    AU.password_hash
FROM dbo.AppUser AU
WHERE AU.app_user_id = @app_user_id;
GO

/*======================================================================
  6. CLEANUP (optional)
======================================================================*/
-- DELETE FROM dbo.PasswordRecoveryQuestion WHERE app_user_id = @app_user_id;
-- DELETE FROM dbo.AppUser WHERE app_user_id = @app_user_id;
-- DELETE FROM dbo.Customer WHERE customer_id = @customer_id;