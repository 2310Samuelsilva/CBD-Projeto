use AdventureWorks
GO 
--Detecta e devolve emails de clientes duplicados.
CREATE OR ALTER FUNCTION dbo.fn_VerificarClientesDuplicados()
RETURNS TABLE
AS
RETURN
(
    SELECT email_address, COUNT(*) AS Total
    FROM dbo.Customer
    GROUP BY email_address
    HAVING COUNT(*) > 1
);
GO




-- Procura linhas de vendas (SalesOrderLine) com produtos inválidos (FK nula).

CREATE OR ALTER PROCEDURE dbo.sp_VerificarVendasSemProduto
AS
BEGIN
    SET NOCOUNT ON;
    SELECT sol.sales_order_line_id, so.sales_order_number
    FROM dbo.SalesOrderLine AS sol
    LEFT JOIN dbo.ProductVariant AS pv ON sol.product_variant_id = pv.product_variant_id
    LEFT JOIN dbo.SalesOrder AS so ON sol.sales_order_id = so.sales_order_id
    WHERE pv.product_variant_id IS NULL;
END;
GO

--junta todas as verificações e devolve resultados consolidados
CREATE OR ALTER PROCEDURE dbo.sp_VerificarQualidadeDados
AS
BEGIN
    PRINT('Verificação de qualidade iniciada...');
    
    PRINT('Clientes duplicados:');
    SELECT * FROM dbo.fn_VerificarClientesDuplicados();

    PRINT('Vendas sem produto:');
    EXEC dbo.sp_VerificarVendasSemProduto;

    PRINT('Verificação concluída.');
END;
GO

EXEC dbo.sp_VerificarQualidadeDados;


