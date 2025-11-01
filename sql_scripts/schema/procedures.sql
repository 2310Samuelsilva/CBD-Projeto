/*============================================================
 USER MANAGEMENT PROCEDURES 
============================================================*/

/*============================================================
 1. Email Logging Procedure
============================================================*/
IF OBJECT_ID('dbo.sp_send_email', 'P') IS NOT NULL DROP PROCEDURE dbo.sp_send_email;
GO
CREATE PROCEDURE dbo.sp_send_email
    @recipient_email NVARCHAR(100),
    @subject NVARCHAR(255),
    @message NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.SentEmails (recipient_email, subject, message)
    VALUES (@recipient_email, @subject, @message);
END;
GO

/*============================================================
 2. Add New Application User
============================================================*/
IF OBJECT_ID('dbo.sp_add_app_user', 'P') IS NOT NULL DROP PROCEDURE dbo.sp_add_app_user;
GO
CREATE PROCEDURE dbo.sp_add_app_user
    @customer_id INT,
    @email NVARCHAR(100),
    @password NVARCHAR(255),
    @question NVARCHAR(255),
    @answer NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1 FROM dbo.app_user WHERE email = @email)
    BEGIN
        RAISERROR('Email already exists.', 16, 1);
        RETURN;
    END;

    INSERT INTO dbo.app_user (customer_id, email, password_hash, is_active)
    VALUES (@customer_id, dbo.trim_spaces(@email), dbo.compute_hash(@password), 1);

    DECLARE @new_app_user_id INT = SCOPE_IDENTITY();

    INSERT INTO dbo.password_recovery_question (app_user_id, question_hash, answer_hash)
    VALUES (@new_app_user_id, dbo.compute_hash(@question), dbo.compute_hash(@answer));

    PRINT 'User created successfully.';
END;
GO

/*============================================================
 3. Update User (Email / Active Status)
============================================================*/
IF OBJECT_ID('dbo.sp_update_app_user', 'P') IS NOT NULL DROP PROCEDURE dbo.sp_update_app_user;
GO
CREATE PROCEDURE dbo.sp_update_app_user
    @app_user_id INT,
    @email NVARCHAR(100) = NULL,
    @is_active BIT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE dbo.app_user
    SET 
        email = COALESCE(@email, email),
        is_active = COALESCE(@is_active, is_active)
    WHERE app_user_id = @app_user_id;

    PRINT 'User updated successfully.';
END;
GO

/*============================================================
 4. Delete User
============================================================*/
IF OBJECT_ID('dbo.sp_delete_app_user', 'P') IS NOT NULL DROP PROCEDURE dbo.sp_delete_app_user;
GO
CREATE PROCEDURE dbo.sp_delete_app_user
    @app_user_id INT
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM dbo.password_recovery_question WHERE app_user_id = @app_user_id;
    DELETE FROM dbo.app_user WHERE app_user_id = @app_user_id;

    PRINT 'User deleted successfully.';
END;
GO

/*============================================================
 5. Authenticate (Login)
============================================================*/
IF OBJECT_ID('dbo.sp_authenticate_user', 'P') IS NOT NULL DROP PROCEDURE dbo.sp_authenticate_user;
GO
CREATE PROCEDURE dbo.sp_authenticate_user
    @email NVARCHAR(100),
    @password NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @app_user_id INT;

    SELECT @app_user_id = app_user_id
    FROM dbo.app_user
    WHERE email = dbo.trim_spaces(@email)
      AND password_hash = dbo.compute_hash(@password)
      AND is_active = 1;

    IF @app_user_id IS NOT NULL
    BEGIN
        UPDATE dbo.app_user SET last_login = GETDATE() WHERE app_user_id = @app_user_id;
        SELECT @app_user_id AS app_user_id, 'Login successful' AS message;
    END
    ELSE
        RAISERROR('Invalid credentials or inactive account.', 16, 1);
END;
GO

/*============================================================
 6. Recover Password (Simulated Email)
============================================================*/
IF OBJECT_ID('dbo.sp_recover_password', 'P') IS NOT NULL DROP PROCEDURE dbo.sp_recover_password;
GO
CREATE PROCEDURE dbo.sp_recover_password
    @email NVARCHAR(100),
    @answer NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE 
        @app_user_id INT, 
        @new_password NVARCHAR(12),
        @email_message NVARCHAR(MAX);

    SELECT @app_user_id = app_user_id 
    FROM dbo.app_user 
    WHERE email = dbo.trim_spaces(@email);

    IF @app_user_id IS NULL
    BEGIN
        RAISERROR('User not found.', 16, 1);
        RETURN;
    END;

    IF NOT EXISTS (
        SELECT 1 
        FROM dbo.password_recovery_question
        WHERE app_user_id = @app_user_id
          AND answer_hash = dbo.compute_hash(@answer)
    )
    BEGIN
        RAISERROR('Incorrect recovery answer.', 16, 1);
        RETURN;
    END;

    -- Generate new temporary password
    SET @new_password = LEFT(CONVERT(NVARCHAR(50), NEWID()), 8);
    SET @email_message = 'Your new password is: ' + @new_password;

    UPDATE dbo.app_user 
    SET password_hash = dbo.compute_hash(@new_password)
    WHERE app_user_id = @app_user_id;

    EXEC dbo.sp_send_email 
        @recipient_email = @email,
        @subject = 'Password Recovery',
        @message = @email_message;

    PRINT 'Password reset successfully. Simulated email logged.';
END;
GO

/*============================================================
 7. List Sent Emails
============================================================*/
IF OBJECT_ID('dbo.sp_list_sent_emails', 'P') IS NOT NULL DROP PROCEDURE dbo.sp_list_sent_emails;
GO
CREATE PROCEDURE dbo.sp_list_sent_emails
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * FROM dbo.SentEmails ORDER BY sent_at DESC;
END;
GO