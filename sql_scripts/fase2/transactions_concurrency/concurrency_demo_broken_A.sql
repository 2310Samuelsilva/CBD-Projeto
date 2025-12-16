USE AdventureWorks;
GO

DECLARE @productVariantId INT = 1;

PRINT 'Sessão A - A verificar stock';

SELECT safety_stock_level
FROM ProductVariant
WHERE product_variant_id = @productVariantId;

WAITFOR DELAY '00:00:20';

INSERT INTO SalesOrderLine (
    sales_order_id,
    line_number,
    product_variant_id,
    unit_price,
    quantity
)
VALUES (1, 1, @productVariantId, 100, 1);
PRINT 'Sessão A - Venda registada';
SELECT * FROM SalesOrderLine WHERE sales_order_id = 1;
GO