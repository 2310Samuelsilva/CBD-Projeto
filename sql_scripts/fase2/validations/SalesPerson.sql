/*============================================================
  TESTES DE ACESSO - SALESPERSON
  Utilizador: SalesPersonUser
  Objetivo: Validar permissões de leitura/escrita e falhas
============================================================*/

-- Assumir identidade do SalesPersonUser
EXECUTE AS USER = 'SalesPersonUser';
GO

PRINT('=== INÍCIO DOS TESTES SALESPERSON: SalesPersonUser ===');

--============================================================
-- 1. Testar permissões de leitura (SELECT) em tabelas não-vendas
--============================================================
PRINT('--- Tabelas de produtos (somente leitura) ---');
SELECT TOP 5 * FROM dbo.ProductMaster;
SELECT TOP 5 * FROM dbo.ProductVariant;
SELECT TOP 5 * FROM dbo.ProductCategory;
SELECT TOP 5 * FROM dbo.ProductSubcategory;

PRINT('--- Tabelas de clientes (somente leitura) ---');
SELECT TOP 5 * FROM dbo.Customer;
SELECT TOP 5 * FROM dbo.CustomerAddress;

PRINT('--- Tabelas de utilizadores (somente leitura) ---');
SELECT TOP 5 * FROM dbo.AppUser;
SELECT TOP 5 * FROM dbo.PasswordRecoveryQuestion;
SELECT TOP 5 * FROM dbo.SentEmails;

--============================================================
-- 2. Testar permissões de escrita (CRUD) em tabelas de vendas
--============================================================
PRINT('--- Inserir uma encomenda de teste ---');
INSERT INTO dbo.SalesOrder(sales_order_number, customer_id, sales_territory_id, currency_id, order_date, due_date)
VALUES ('SO-TEST-001', 1, 1, 1, GETDATE(), DATEADD(DAY, 7, GETDATE()));

SELECT * FROM dbo.SalesOrder WHERE sales_order_number = 'SO-TEST-001';

PRINT('--- Atualizar encomenda de teste ---');
UPDATE dbo.SalesOrder
SET sales_order_number = 'SO-TEST-001-UPDATED'
WHERE sales_order_number = 'SO-TEST-001';

SELECT * FROM dbo.SalesOrder WHERE sales_order_number = 'SO-TEST-001-UPDATED';

PRINT('--- Inserir no carrinho de encomenda ---');
INSERT INTO dbo.SalesOrderLine(sales_order_id, line_number, product_variant_id, unit_price, quantity)
SELECT TOP 1 sales_order_id, 1, product_variant_id, list_price, 1
FROM dbo.ProductVariant
CROSS JOIN dbo.SalesOrder
WHERE sales_order_number = 'SO-TEST-001-UPDATED';

SELECT * FROM dbo.SalesOrderLine WHERE sales_order_id = (SELECT TOP 1 sales_order_id FROM dbo.SalesOrder WHERE sales_order_number = 'SO-TEST-001-UPDATED');

PRINT('--- Atualizar linha de encomenda ---');
UPDATE dbo.SalesOrderLine
SET quantity = quantity + 1
WHERE sales_order_id = (SELECT TOP 1 sales_order_id FROM dbo.SalesOrder WHERE sales_order_number = 'SO-TEST-001-UPDATED');

SELECT * FROM dbo.SalesOrderLine WHERE sales_order_id = (SELECT TOP 1 sales_order_id FROM dbo.SalesOrder WHERE sales_order_number = 'SO-TEST-001-UPDATED');

PRINT('--- Apagar linha e encomenda de teste ---');
DELETE FROM dbo.SalesOrderLine WHERE sales_order_id = (SELECT TOP 1 sales_order_id FROM dbo.SalesOrder WHERE sales_order_number = 'SO-TEST-001-UPDATED');
DELETE FROM dbo.SalesOrder WHERE sales_order_number = 'SO-TEST-001-UPDATED';

-- Confirmar exclusão
SELECT * FROM dbo.SalesOrder WHERE sales_order_number LIKE 'SO-TEST%';
SELECT * FROM dbo.SalesOrderLine WHERE sales_order_id IS NULL OR sales_order_id NOT IN (SELECT sales_order_id FROM dbo.SalesOrder);

--============================================================
-- 3. Testar falhas: tentar escrever nas tabelas somente leitura
--============================================================
PRINT('--- Teste de falha: tentar INSERT em ProductMaster ---');
BEGIN TRY
    INSERT INTO dbo.ProductMaster(product_name, model)
    VALUES ('FailTest', 'FailModel');
END TRY
BEGIN CATCH
    PRINT 'Falha esperada: INSERT em ProductMaster não permitido.';
    PRINT ERROR_MESSAGE();
END CATCH;

PRINT('--- Teste de falha: tentar UPDATE em Customer ---');
BEGIN TRY
    UPDATE dbo.Customer
    SET first_name = 'FailUpdate'
    WHERE customer_id = 1;
END TRY
BEGIN CATCH
    PRINT 'Falha esperada: UPDATE em Customer não permitido.';
    PRINT ERROR_MESSAGE();
END CATCH;

PRINT('--- Teste de falha: tentar DELETE em ProductCategory ---');
BEGIN TRY
    DELETE FROM dbo.ProductCategory
    WHERE category_id = 1;
END TRY
BEGIN CATCH
    PRINT 'Falha esperada: DELETE em ProductCategory não permitido.';
    PRINT ERROR_MESSAGE();
END CATCH;

--============================================================
-- Concluir testes
--============================================================
PRINT('=== TESTES SALESPERSON CONCLUÍDOS ===');

-- Reverter para o Utilizador original da sessão
REVERT;
GO