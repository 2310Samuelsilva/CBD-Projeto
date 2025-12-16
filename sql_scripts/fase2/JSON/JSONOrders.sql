USE AdventureWorks;
GO

SELECT
    so.sales_order_id,
    so.sales_order_number,
    so.customer_id,
    st.region AS sales_region,
    so.order_date,
    so.due_date,
    so.ship_date,
    (
        SELECT
            sol.sales_order_line_id,
            sol.line_number,
            sol.product_variant_id,
            sol.currency_id,
            sol.unit_price,
            sol.quantity,
            sol.tax_amt,
            sol.freight
        FROM dbo.SalesOrderLine sol
        WHERE sol.sales_order_id = so.sales_order_id
        FOR JSON PATH
    ) AS lines
FROM dbo.SalesOrder so
LEFT JOIN dbo.SalesTerritory st ON st.sales_territory_id = so.sales_territory_id
FOR JSON PATH;
GO