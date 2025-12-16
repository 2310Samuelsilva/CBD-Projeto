USE AdventureWorks;
GO

DECLARE @productVariantId INT = 1;

PRINT 'Sessão B - A verificar stock';

SELECT safety_stock_level
FROM ProductVariant
WHERE product_variant_id = @productVariantId;

INSERT INTO SalesOrderLine (
    sales_order_id,
    line_number,
    product_variant_id,
    unit_price,
    quantity
)
VALUES (2, 1, @productVariantId, 100, 1);

PRINT 'Sessão B - Venda registada';
SELECT * FROM SalesOrderLine WHERE sales_order_id = 1;
GO