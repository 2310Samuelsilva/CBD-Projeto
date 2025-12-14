SET STATISTICS IO ON;
SET STATISTICS TIME ON;
-- (e no SSMS: Include Actual Execution Plan)
use AdventureWorks
GO



/* indices para as queries do enunciado */
/* Q1: vendas por cidade/estado
   - City + state_province_id: agrupa e distingue cidades por estado
   - INCLUDE customer_id: ajuda joins a partir da morada */
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_CustomerAddress_City_State' AND object_id=OBJECT_ID('dbo.CustomerAddress'))
BEGIN
    CREATE INDEX IX_CustomerAddress_City_State
    ON dbo.CustomerAddress (city, state_province_id)
    INCLUDE (customer_id);
END
GO

/* Q1/Q3: SalesOrder
   - customer_id: join ao Customer
   - order_date: agrupamento por ano (YEAR(order_date))
   - INCLUDE sales_territory_id: evita lookup quando precisas do território */
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_SalesOrder_Customer_OrderDate' AND object_id=OBJECT_ID('dbo.SalesOrder'))
BEGIN
    CREATE INDEX IX_SalesOrder_Customer_OrderDate
    ON dbo.SalesOrder (customer_id, order_date)
    INCLUDE (sales_territory_id);
END
GO

/* Q1: SalesOrderLine por sales_order_id
   - acelera join SO->SOL e o cálculo SUM(unit_price*quantity)
   - INCLUDE colunas usadas no cálculo e ligação ao produto */
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_SalesOrderLine_SalesOrder' AND object_id=OBJECT_ID('dbo.SalesOrderLine'))
BEGIN
    CREATE INDEX IX_SalesOrderLine_SalesOrder
    ON dbo.SalesOrderLine (sales_order_id)
    INCLUDE (unit_price, quantity, product_variant_id);
END
GO

/* Q2/Q3: SalesOrderLine por product_variant_id
   - acelera agregações por produto (HAVING > 1000 e por categoria/ano)
   - INCLUDE sales_order_id para join rápido ao cabeçalho */
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_SalesOrderLine_ProductVariant' AND object_id=OBJECT_ID('dbo.SalesOrderLine'))
BEGIN
    CREATE INDEX IX_SalesOrderLine_ProductVariant
    ON dbo.SalesOrderLine (product_variant_id)
    INCLUDE (unit_price, quantity, sales_order_id);
END
GO

PRINT 'Índices criados (ou já existentes).';

--Ver estatísticas de uso dos índices (DMV)
SELECT 
    db_name(ius.database_id) AS database_name,
    OBJECT_NAME(i.object_id) AS table_name,
    i.name AS index_name,
    i.index_id,
    ius.user_seeks, ius.user_scans, ius.user_lookups, ius.user_updates,
    ius.last_user_seek, ius.last_user_scan, ius.last_user_lookup, ius.last_user_update
FROM sys.indexes i
LEFT JOIN sys.dm_db_index_usage_stats ius
    ON i.object_id = ius.object_id AND i.index_id = ius.index_id AND ius.database_id = DB_ID()
WHERE OBJECTPROPERTY(i.object_id, 'IsUserTable') = 1
ORDER BY ius.user_seeks + ius.user_scans + ius.user_lookups DESC;


--Ver estatísticas físicas (fragmentação)
SELECT 
    OBJECT_NAME(ps.object_id) AS table_name,
    i.name AS index_name,
    ps.index_id,
    ps.avg_fragmentation_in_percent,
    ps.page_count
FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, 'LIMITED') ps
JOIN sys.indexes i ON ps.object_id = i.object_id AND ps.index_id = i.index_id
WHERE OBJECTPROPERTY(ps.object_id, 'IsUserTable') = 1
ORDER BY ps.avg_fragmentation_in_percent DESC;

--Query para listar todos os índices
SELECT 
    s.name AS schema_name,
    t.name AS table_name,
    i.name AS index_name,
    i.index_id,
    i.type_desc,
    i.is_unique,
    i.is_disabled,
    i.fill_factor
FROM sys.indexes i
JOIN sys.tables t ON i.object_id = t.object_id
JOIN sys.schemas s ON t.schema_id = s.schema_id
WHERE t.is_ms_shipped = 0
ORDER BY schema_name, table_name, i.name;


-- Seletividade e densidade da combinação (cidade, estado)

-- Q1 (vendas por cidade + estado): CustomerAddress(city, state_province_id)
SELECT
  COUNT(*) AS total_rows,
  COUNT(DISTINCT CONCAT(city,'|',state_province_id)) AS distinct_city_state,
  CAST(COUNT(DISTINCT CONCAT(city,'|',state_province_id)) AS float)/NULLIF(COUNT(*),0) AS selectivity,
  CAST(COUNT(*) AS float)/NULLIF(COUNT(DISTINCT CONCAT(city,'|',state_province_id)),0) AS density
FROM dbo.CustomerAddress;


-- Q2/Q3 (por produto): SalesOrderLine(product_variant_id)
SELECT
  COUNT(*) AS total_rows,
  COUNT(DISTINCT product_variant_id) AS distinct_products,
  CAST(COUNT(DISTINCT product_variant_id) AS float)/NULLIF(COUNT(*),0) AS selectivity,
  CAST(COUNT(*) AS float)/NULLIF(COUNT(DISTINCT product_variant_id),0) AS density
FROM dbo.SalesOrderLine;


-- Q3 (por ano): SalesOrder(order_date) (seletividade por dia; no relatório podes comentar “ano”)
SELECT
  COUNT(*) AS total_rows,
  COUNT(DISTINCT order_date) AS distinct_dates,
  CAST(COUNT(DISTINCT order_date) AS float)/NULLIF(COUNT(*),0) AS selectivity,
  CAST(COUNT(*) AS float)/NULLIF(COUNT(DISTINCT order_date),0) AS density
FROM dbo.SalesOrder;

-- script para apagar e comparar 

IF EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_SalesOrderLine_SalesOrder' AND object_id=OBJECT_ID('dbo.SalesOrderLine'))
    DROP INDEX IX_SalesOrderLine_SalesOrder ON dbo.SalesOrderLine;

IF EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_SalesOrderLine_ProductVariant' AND object_id=OBJECT_ID('dbo.SalesOrderLine'))
    DROP INDEX IX_SalesOrderLine_ProductVariant ON dbo.SalesOrderLine;

IF EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_SalesOrder_Customer_OrderDate' AND object_id=OBJECT_ID('dbo.SalesOrder'))
    DROP INDEX IX_SalesOrder_Customer_OrderDate ON dbo.SalesOrder;

IF EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_CustomerAddress_City_State' AND object_id=OBJECT_ID('dbo.CustomerAddress'))
    DROP INDEX IX_CustomerAddress_City_State ON dbo.CustomerAddress;
GO

-- Queries do enunciado

-- Q1
SELECT 
    ca.city,
    sp.code AS state_code,
    SUM(COALESCE(sol.unit_price,0) * COALESCE(sol.quantity,0)) AS total_sales_amount
FROM dbo.SalesOrder so
JOIN dbo.SalesOrderLine sol    ON so.sales_order_id = sol.sales_order_id
JOIN dbo.Customer c            ON so.customer_id = c.customer_id
JOIN dbo.CustomerAddress ca    ON c.customer_id = ca.customer_id
LEFT JOIN dbo.StateProvince sp ON ca.state_province_id = sp.state_province_id
GROUP BY ca.city, sp.code
ORDER BY total_sales_amount DESC;
GO

-- Q2
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
GO


-- Q3
SELECT 
    YEAR(so.order_date) AS sales_year,
    pc.name AS category,
    SUM(COALESCE(sol.quantity,0)) AS total_units
FROM dbo.SalesOrderLine sol
JOIN dbo.SalesOrder so       ON sol.sales_order_id = so.sales_order_id
JOIN dbo.ProductVariant pv   ON sol.product_variant_id = pv.product_variant_id
JOIN dbo.ProductMaster pm    ON pv.product_master_id = pm.product_master_id
LEFT JOIN dbo.ProductCategory pc ON pm.category_id = pc.category_id
GROUP BY YEAR(so.order_date), pc.name
ORDER BY sales_year, category;
GO