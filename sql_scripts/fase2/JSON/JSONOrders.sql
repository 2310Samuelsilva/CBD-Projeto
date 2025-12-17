USE AdventureWorks;
GO

SELECT
(
    SELECT TOP (100)   -- ajusta/retira TOP para exportar tudo
        so.sales_order_id AS _id,
        so.sales_order_number,
        so.customer_id,
        so.sales_territory_id,
        so.order_date,
        so.due_date,
        so.ship_date,
        (
            SELECT
                sol.sales_order_line_id AS _id,
                sol.line_number,
                sol.product_variant_id,
                sol.product_standard_cost,
                sol.unit_price,
                sol.quantity,
                sol.tax_amt,
                sol.freight
            FROM dbo.SalesOrderLine AS sol
            WHERE sol.sales_order_id = so.sales_order_id
            FOR JSON PATH
        ) AS lines
    FROM dbo.SalesOrder AS so
    ORDER BY so.sales_order_id
    FOR JSON PATH, ROOT('orders')
) AS orders_json;
GO