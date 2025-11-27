use AdventureWorks
GO

-- Total de vendas = SUM(unit_price * quantity)
SELECT 
    ca.city,
    sp.code AS state_code,
    SUM(COALESCE(sol.unit_price,0) * COALESCE(sol.quantity,0)) AS total_sales_amount
FROM dbo.SalesOrder so
JOIN dbo.SalesOrderLine sol   ON so.sales_order_id = sol.sales_order_id
JOIN dbo.Customer c           ON so.customer_id = c.customer_id
JOIN dbo.CustomerAddress ca   ON c.customer_id = ca.customer_id
LEFT JOIN dbo.StateProvince sp ON ca.state_province_id = sp.state_province_id
GROUP BY ca.city, sp.code
ORDER BY total_sales_amount DESC;


-- Procura por sales_order_id nas linhas
CREATE INDEX IX_SalesOrderLine_order ON dbo.SalesOrderLine (sales_order_id) 
INCLUDE (unit_price, quantity);

-- Junções por customer_id e procura frequente por order_date (útil para Q3)
CREATE INDEX IX_SalesOrder_customer_date ON dbo.SalesOrder (customer_id, order_date);

-- Filtro/agrupamento por cidade/estado
CREATE INDEX IX_CustomerAddress_city_state ON dbo.CustomerAddress (city, state_province_id) 
INCLUDE (customer_id);

-- Junção por state_province_id -> pega o código rapidamente
CREATE INDEX IX_StateProvince_pk_include_code ON dbo.StateProvince (state_province_id) INCLUDE (code);

SELECT 
    pm.model,
    pv.product_variant_id,
    pv.variant_name,
    SUM(COALESCE(sol.unit_price,0) * COALESCE(sol.quantity,0)) AS total_product_sales
FROM dbo.SalesOrderLine sol
JOIN dbo.ProductVariant pv  ON sol.product_variant_id = pv.product_variant_id
JOIN dbo.ProductMaster pm   ON pv.product_master_id = pm.product_master_id
GROUP BY pm.model, pv.product_variant_id, pv.variant_name
HAVING SUM(COALESCE(sol.unit_price,0) * COALESCE(sol.quantity,0)) > 1000
ORDER BY total_product_sales DESC;


-- Junção e agregação por produto
CREATE INDEX IX_SalesOrderLine_product ON dbo.SalesOrderLine (product_variant_id)
INCLUDE (unit_price, quantity);

-- Acesso rápido ao model via PV -> PM
CREATE INDEX IX_ProductVariant_master ON dbo.ProductVariant (product_master_id)
INCLUDE (variant_name);


SELECT 
    YEAR(so.order_date) AS sales_year,
    pc.name AS category,
    SUM(COALESCE(sol.quantity,0)) AS total_units
FROM dbo.SalesOrderLine sol
JOIN dbo.SalesOrder so        ON sol.sales_order_id = so.sales_order_id
JOIN dbo.ProductVariant pv    ON sol.product_variant_id = pv.product_variant_id
JOIN dbo.ProductMaster pm     ON pv.product_master_id = pm.product_master_id
LEFT JOIN dbo.ProductCategory pc ON pm.category_id = pc.category_id
GROUP BY YEAR(so.order_date), pc.name
ORDER BY sales_year, category;


-- Usado na Q1 e Q3
CREATE INDEX IX_SalesOrder_orderdate ON dbo.SalesOrder (order_date);

-- Cadeia de junções por chaves
CREATE INDEX IX_ProductMaster_category ON dbo.ProductMaster (category_id);


SELECT 
    i.name,
    i.index_id,
    i.type_desc,
    t.name AS table_name
FROM sys.indexes AS i
JOIN sys.tables  AS t ON i.object_id = t.object_id
WHERE t.name = 'SalesOrderLine';