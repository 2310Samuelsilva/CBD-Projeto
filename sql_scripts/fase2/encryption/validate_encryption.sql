/*======================================================================
  DEMONSTRAÇÃO DE CRIAÇÃO DE CUSTOMER E APPUSER + DESENCRIPTAÇÃO DE NIF
======================================================================*/

USE AdventureWorks;
GO

/*======================================================================
  1. Criar novo customer com NIF encriptado
======================================================================*/
DECLARE @NewEmail NVARCHAR(100) = 'newcustomer@example.com';
DECLARE @NewNIF NVARCHAR(20) = '123456789';

-- Abrir symmetric key para encriptação
OPEN SYMMETRIC KEY KeyNIF
DECRYPTION BY CERTIFICATE CertNIF;

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
    'UserEncryption',
    @NewEmail,
    ENCRYPTBYKEY(KEY_GUID('KeyNIF'), CONVERT(VARBINARY(MAX), @NewNIF))
);

-- Fechar chave após uso
CLOSE SYMMETRIC KEY KeyNIF;
GO

/*======================================================================
  2. Criar AppUser associado com password hasheada
======================================================================*/
DECLARE @PlainPassword NVARCHAR(50) = 'password';
DECLARE @NewCustomerID INT;

-- Recuperar o ID do customer criado
SELECT @NewCustomerID = customer_id
FROM dbo.Customer
WHERE email_address = @NewEmail;

-- Inserir AppUser com password hasheada
INSERT INTO dbo.AppUser (
    customer_id,
    email,
    password_hash,
    is_active,
    created_at
)
VALUES (
    @NewCustomerID,
    @NewEmail,
    dbo.ComputeHash(@PlainPassword),
    1,
    GETDATE()
);
GO

/*======================================================================
  3. Visualizar dados encriptados (NIF) e password hash
======================================================================*/
PRINT('--- Dados encriptados e password hash ---');
SELECT
    C.customer_id,
    C.email_address,
    C.nif AS NIF_Encrypted,
    AU.password_hash AS Password_Hash
FROM dbo.Customer C
JOIN dbo.AppUser AU ON C.customer_id = AU.customer_id
WHERE C.email_address = @NewEmail;
GO

/*======================================================================
  4. Recuperar (desencriptar) NIF
======================================================================*/
PRINT('--- Recuperando NIF ---');
OPEN SYMMETRIC KEY KeyNIF
DECRYPTION BY CERTIFICATE CertNIF;

SELECT
    C.customer_id,
    C.email_address,
    CONVERT(NVARCHAR(20), DECRYPTBYKEY(C.nif)) AS NIF_Decrypted
FROM dbo.Customer C
WHERE C.email_address = @NewEmail;

-- Fechar symmetric key após uso
CLOSE SYMMETRIC KEY KeyNIF;
GO

/*======================================================================
  5. Observação sobre password
======================================================================*/
-- A password não pode ser recuperada do hash.
-- Para testar, podemos validar usando a função HASHBYTES / ComputeHash:
DECLARE @InputPassword NVARCHAR(50) = 'P@ssw0rd!';
DECLARE @ComputedHash VARBINARY(32);

SET @ComputedHash = dbo.ComputeHash(@InputPassword);

PRINT('--- Validando password ---');
IF EXISTS (
    SELECT 1 FROM dbo.AppUser
    WHERE customer_id = @NewCustomerID
      AND password_hash = @ComputedHash
)
    PRINT('Password válida!');
ELSE
    PRINT('Password inválida!');
GO