USE AdventureWorks;
GO

DECLARE
    @productVariantId INT = 1,
    @safetyStock INT,
    @currentSales INT;

SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
BEGIN TRANSACTION;

PRINT 'Sessão A - Produto bloqueado';

SELECT
    @safetyStock = safety_stock_level
FROM ProductVariant WITH (UPDLOCK, HOLDLOCK)
WHERE product_variant_id = @productVariantId;

SELECT
    @currentSales = COUNT(*)
FROM SalesOrderLine
WHERE product_variant_id = @productVariantId;

IF @currentSales >= @safetyStock
BEGIN
    PRINT 'Stock insuficiente';
    ROLLBACK;
    RETURN;
END

WAITFOR DELAY '00:00:20';

INSERT INTO SalesOrderLine (
    sales_order_id,
    line_number,
    product_variant_id,
    unit_price,
    quantity
)
VALUES (1, 1, @productVariantId, 100, 1);

COMMIT;
PRINT 'Sessão A - Venda concluída';
GO