USE AdventureWorks;
GO

DECLARE @productVariantId INT = 1;

SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
BEGIN TRANSACTION;

INSERT INTO SalesOrderLine (
    sales_order_id,
    line_number,
    product_variant_id,
    unit_price,
    quantity
)
VALUES (2, 1, @productVariantId, 100, 1);

COMMIT;
PRINT 'Sessão B - Venda concluída';
GO