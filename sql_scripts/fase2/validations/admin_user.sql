/*============================================================
  TESTES DE ACESSO - ADMINISTRADOR
============================================================*/

USE AdventureWorks;
EXECUTE AS USER = 'AdminUser';
GO
PRINT('=== TESTES ADMINISTRADOR: AdminUser ===');

-- 1. Verificar permissões de leitura em todas as tabelas
PRINT('--- Tabelas de produtos ---');
SELECT TOP 5 * FROM dbo.ProductMaster;
SELECT TOP 5 * FROM dbo.ProductVariant;
SELECT TOP 5 * FROM dbo.ProductCategory;

PRINT('--- Tabelas de clientes ---');
SELECT TOP 5 * FROM dbo.Customer;
SELECT TOP 5 * FROM dbo.CustomerAddress;

PRINT('--- Tabelas de vendas ---');
SELECT TOP 5 * FROM dbo.SalesOrder;
SELECT TOP 5 * FROM dbo.SalesOrderLine;
SELECT TOP 5 * FROM dbo.SalesTerritory;

PRINT('--- Tabelas de utilizadores ---');
SELECT TOP 5 * FROM dbo.AppUser;
SELECT TOP 5 * FROM dbo.PasswordRecoveryQuestion;
SELECT TOP 5 * FROM dbo.SentEmails;

-- 2. Testar escrita: inserir um registo em ProductCategory
PRINT('--- Inserir um registo de teste em ProductCategory ---');
INSERT INTO dbo.ProductCategory(name) VALUES ('Test Category Admin');

-- Verificar inserção
SELECT * FROM dbo.ProductCategory WHERE name = 'Test Category Admin';

-- 3. Testar atualização: alterar o nome do registo inserido
PRINT('--- Atualizar o registo de teste ---');
UPDATE dbo.ProductCategory
SET name = 'Test Category Admin Updated'
WHERE name = 'Test Category Admin';

-- Verificar atualização
SELECT * FROM dbo.ProductCategory WHERE name = 'Test Category Admin Updated';

-- 4. Testar exclusão
PRINT('--- Apagar o registo de teste ---');
DELETE FROM dbo.ProductCategory
WHERE name = 'Test Category Admin Updated';

-- Verificar exclusão
SELECT * FROM dbo.ProductCategory WHERE name LIKE 'Test Category Admin%';

PRINT('=== TESTES ADMINISTRADOR CONCLUÍDOS ===');