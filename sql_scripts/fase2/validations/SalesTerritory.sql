/*============================================================
  TESTES DE ACESSO - SALESTERRITORY
  Utilizador: SalesTerritoryUser
  Objetivo: Validar permissões de leitura apenas para Southwest
============================================================*/

-- Assumir identidade do SalesTerritoryUser
USE AdventureWorks;
EXECUTE AS USER = 'SalesTerritoryUser';
GO

PRINT('=== INÍCIO DOS TESTES SALESTERRITORY: SalesTerritoryUser ===');

--============================================================
-- 1. Consultar views filtradas (permitido)
--============================================================
PRINT('--- Sales Orders Southwest ---');
SELECT TOP 5 * FROM dbo.vw_Sales_Southwest;

PRINT('--- Linhas de venda Southwest ---');
SELECT TOP 5 * FROM dbo.vw_SalesLines_Southwest;

PRINT('--- Clientes Southwest ---');
SELECT TOP 5 * FROM dbo.vw_Customers_Southwest;

PRINT('--- Produtos vendidos Southwest ---');
SELECT TOP 5 * FROM dbo.vw_Products_Southwest;

PRINT('--- Resumo de vendas Southwest ---');
SELECT * FROM dbo.vw_SalesSummary_Southwest;

--============================================================
-- 2. Testar permissões de leitura direta (somente leitura)
--============================================================
PRINT('--- Customer (somente leitura) ---');
SELECT TOP 5 * FROM dbo.Customer;

PRINT('--- ProductMaster (somente leitura) ---');
SELECT TOP 5 * FROM dbo.ProductMaster;

--============================================================
-- 3. Testes de falha: tentar inserir/atualizar/excluir
--============================================================
PRINT('--- Tentar INSERT em SalesOrder (falha esperada) ---');
BEGIN TRY
    INSERT INTO dbo.SalesOrder(sales_order_number, customer_id, sales_territory_id, currency_id, order_date, due_date)
    VALUES ('FAIL-TEST-001', 1, 2, 1, GETDATE(), DATEADD(DAY, 7, GETDATE())); -- fora do Southwest
END TRY
BEGIN CATCH
    PRINT 'Falha esperada: INSERT em SalesOrder não permitido.';
    PRINT ERROR_MESSAGE();
END CATCH;

PRINT('--- Tentar UPDATE em Customer (falha esperada) ---');
BEGIN TRY
    UPDATE dbo.Customer
    SET first_name = 'FailUpdate'
    WHERE customer_id = 1;
END TRY
BEGIN CATCH
    PRINT 'Falha esperada: UPDATE em Customer não permitido.';
    PRINT ERROR_MESSAGE();
END CATCH;

PRINT('--- Tentar DELETE em ProductVariant (falha esperada) ---');
BEGIN TRY
    DELETE FROM dbo.ProductVariant
    WHERE product_variant_id = 1;
END TRY
BEGIN CATCH
    PRINT 'Falha esperada: DELETE em ProductVariant não permitido.';
    PRINT ERROR_MESSAGE();
END CATCH;

--============================================================
-- 4. Testar acesso a dados fora do território (falha esperada)
--============================================================
PRINT('--- Tentar selecionar SalesOrder fora de Southwest ---');
BEGIN TRY
    SELECT *
    FROM dbo.SalesOrder SO
    JOIN dbo.SalesTerritory ST ON SO.sales_territory_id = ST.sales_territory_id
    WHERE ST.region <> 'Southwest';
END TRY
BEGIN CATCH
    PRINT 'Falha esperada: acesso fora do território Southwest não permitido.';
    PRINT ERROR_MESSAGE();
END CATCH;

--============================================================
-- Concluir testes
--============================================================
PRINT('=== TESTES SALESTERRITORY CONCLUÍDOS ===');

-- Reverter para o utilizador original da sessão
REVERT;
GO