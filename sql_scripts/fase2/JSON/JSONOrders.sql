USE AdventureWorks;
GO

SELECT
    so.sales_order_id AS _id,
    so.sales_order_number,
    so.customer_id,
    (
        SELECT
            sol.sales_order_line_id,
            sol.product_variant_id,
            sol.unit_price,
            sol.quantity
        FROM dbo.SalesOrderLine sol
        WHERE sol.sales_order_id = so.sales_order_id
        FOR JSON PATH
    ) AS lines
FROM dbo.SalesOrder so
FOR JSON PATH;