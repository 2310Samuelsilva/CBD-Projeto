/*===============================================================================
 STEP 3: SETUP ENCRYPTION FOR CUSTOMER NIF
 - Create Master Key, Certificate, and Symmetric Key if not present.
===============================================================================*/

USE AdventureWorks;

IF NOT EXISTS (SELECT * FROM sys.symmetric_keys WHERE name = '##MS_DatabaseMasterKey##')
BEGIN
    CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'Password123!';
    PRINT('Database Master Key created.');
END;

IF NOT EXISTS (SELECT * FROM sys.certificates WHERE name = 'CertNIF')
BEGIN
    CREATE CERTIFICATE CertNIF WITH SUBJECT = 'Certificado NIF';
    PRINT('Certificate CertNIF created.');
END;

IF NOT EXISTS (SELECT * FROM sys.symmetric_keys WHERE name = 'KeyNIF')
BEGIN
    CREATE SYMMETRIC KEY KeyNIF
        WITH ALGORITHM = AES_256
        ENCRYPTION BY CERTIFICATE CertNIF;
    PRINT('Symmetric Key KeyNIF created.');
END;
GO