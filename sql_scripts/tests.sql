USE AdventureWorks;
GO

/*============================================================
  USER MANAGEMENT TEST SCRIPT (CLEAN NAMING)
============================================================*/

-- === GLOBAL TEST VARIABLES (run once per session) ===
IF OBJECT_ID('tempdb..#test_vars') IS NOT NULL DROP TABLE #test_vars;
CREATE TABLE #test_vars (
    test_customer_email NVARCHAR(100),
    test_email NVARCHAR(100),
    test_password NVARCHAR(255),
    test_question NVARCHAR(255),
    test_answer NVARCHAR(255)
);

INSERT INTO #test_vars VALUES (
    'testcustomer@example.com',
    'testuser2@example.com',
    'MyTestPassword123',
    'Favorite color?',
    'Blue'
);
GO


/*============================================================
 STEP 0: Ensure Test Customer Exists
============================================================*/
DECLARE 
    @test_customer_email NVARCHAR(100),
    @test_email NVARCHAR(100),
    @test_password NVARCHAR(255),
    @test_question NVARCHAR(255),
    @test_answer NVARCHAR(255),
    @customer_id INT,
    @app_user_id INT;

SELECT 
    @test_customer_email = test_customer_email,
    @test_email = test_email,
    @test_password = test_password,
    @test_question = test_question,
    @test_answer = test_answer
FROM #test_vars;

PRINT('=== TEST SETUP ===');

IF NOT EXISTS (SELECT 1 FROM dbo.customer WHERE email_address = @test_email)
BEGIN
    INSERT INTO dbo.customer (first_name, last_name, email_address)
    VALUES ('Test', 'User2', @test_email);
    PRINT('Test customer created.');
END
ELSE
    PRINT('Test customer already exists.');

SELECT @customer_id = customer_id 
FROM dbo.customer 
WHERE email_address = @test_email;

PRINT('CustomerID: ' + CAST(@customer_id AS NVARCHAR(10)));
GO


/*============================================================
 STEP 1: Add New Application User
============================================================*/
DECLARE 
    @test_email NVARCHAR(100),
    @test_password NVARCHAR(255),
    @test_question NVARCHAR(255),
    @test_answer NVARCHAR(255),
    @customer_id INT,
    @app_user_id INT;

SELECT 
    @test_email = test_email,
    @test_password = test_password,
    @test_question = test_question,
    @test_answer = test_answer
FROM #test_vars;

SELECT @customer_id = customer_id FROM dbo.customer WHERE email_address = @test_email;

PRINT('=== ADDING NEW USER ===');
BEGIN TRY
    EXEC dbo.sp_add_app_user
        @customer_id = @customer_id,
        @email = @test_email,
        @password = @test_password,
        @question = @test_question,
        @answer = @test_answer;
END TRY
BEGIN CATCH
    PRINT('sp_add_app_user Error: ' + ERROR_MESSAGE());
END CATCH;

-- Verify user creation
SELECT @app_user_id = app_user_id 
FROM dbo.AppUser 
WHERE email = @test_email;

PRINT('AppUserID: ' + ISNULL(CAST(@app_user_id AS NVARCHAR(10)), 'NULL'));
PRINT('--- VERIFY USER TABLES ---');
SELECT * FROM dbo.AppUser WHERE app_user_id = @app_user_id;
SELECT * FROM dbo.PasswordRecoveryQuestion WHERE app_user_id = @app_user_id;
GO


/*============================================================
 STEP 2: Authenticate (Login)
============================================================*/
DECLARE 
    @test_email NVARCHAR(100),
    @test_password NVARCHAR(255);

SELECT 
    @test_email = test_email,
    @test_password = test_password
FROM #test_vars;

PRINT('=== LOGIN TEST (VALID PASSWORD) ===');
BEGIN TRY
    EXEC dbo.sp_authenticate_user
        @email = @test_email,
        @password = @test_password;
END TRY
BEGIN CATCH
    PRINT('Auth Error (valid pw): ' + ERROR_MESSAGE());
END CATCH;

PRINT('=== LOGIN TEST (INVALID PASSWORD) ===');
BEGIN TRY
    EXEC dbo.sp_authenticate_user
        @email = @test_email,
        @password = 'WrongPassword';
END TRY
BEGIN CATCH
    PRINT('Expected error (invalid pw): ' + ERROR_MESSAGE());
END CATCH;
GO


/*============================================================
 STEP 3: Recover Password
============================================================*/
DECLARE 
    @test_email NVARCHAR(100),
    @test_answer NVARCHAR(255);

SELECT 
    @test_email = test_email,
    @test_answer = test_answer
FROM #test_vars;

PRINT('=== PASSWORD RECOVERY ===');
BEGIN TRY
    EXEC dbo.sp_recover_password
        @email = @test_email,
        @answer = @test_answer;
END TRY
BEGIN CATCH
    PRINT('sp_recover_password Error: ' + ERROR_MESSAGE());
END CATCH;

PRINT('--- VERIFY UPDATED PASSWORD HASH ---');
SELECT password_hash FROM dbo.AppUser WHERE email = @test_email;
GO


/*============================================================
 STEP 4: View Logged Emails
============================================================*/
PRINT('=== SENT EMAILS ===');
EXEC dbo.sp_list_sent_emails;
GO


/*============================================================
 STEP 5: Cleanup (Optional)
============================================================*/
DECLARE 
    @test_email NVARCHAR(100),
    @app_user_id INT,
    @customer_id INT;

SELECT @test_email = test_email FROM #test_vars;

PRINT('=== CLEANING UP TEST DATA ===');
SELECT @app_user_id = app_user_id FROM dbo.AppUser WHERE email = @test_email;
SELECT @customer_id = customer_id FROM dbo.customer WHERE email_address = @test_email;

IF @app_user_id IS NOT NULL
BEGIN
    EXEC dbo.sp_delete_app_user @app_user_id = @app_user_id;
    PRINT('App user deleted.');
END

IF @customer_id IS NOT NULL
BEGIN
    DELETE FROM dbo.customer WHERE customer_id = @customer_id;
    PRINT('Customer deleted.');
END

PRINT('=== CLEANUP COMPLETE ===');
GO