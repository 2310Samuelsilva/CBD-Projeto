/*============================================================
  SALESTERRITORY – Configuração de Segurança
  - O utilizador só pode consultar dados do território Southwest
  - Acesso sempre via VIEW filtrada
============================================================*/

USE AdventureWorks;
--------------------------------------------------------------
-- 1. Criar Role dedicado (se não existir)
--------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'roleSalesTerritory' AND type = 'R')
BEGIN
    CREATE ROLE roleSalesTerritory;
END
GO

--------------------------------------------------------------
-- 2. Criar utilizador (sem login – cenário académico) se não existir
--------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'SalesTerritoryUser' AND type = 'S')
BEGIN
    CREATE USER SalesTerritoryUser WITHOUT LOGIN;
END
GO

--------------------------------------------------------------
-- 3. Associar o utilizador ao Role se não estiver associado
--------------------------------------------------------------
IF NOT EXISTS (
    SELECT *
    FROM sys.database_role_members drm
    JOIN sys.database_principals r ON drm.role_principal_id = r.principal_id
    JOIN sys.database_principals m ON drm.member_principal_id = m.principal_id
    WHERE r.name = 'roleSalesTerritory' AND m.name = 'SalesTerritoryUser'
)
BEGIN
    ALTER ROLE roleSalesTerritory ADD MEMBER SalesTerritoryUser;
END
GO

/*============================================================
  4. VIEWS FILTRADAS (Southwest somente)
  Cada view fornece acesso apenas aos dados do território Southwest,
  garantindo segurança e isolamento conforme a política do SalesTerritoryUser
============================================================*/

-- vw_Sales_Southwest
-- Descrição: Retorna todas as encomendas do território Southwest.
DROP VIEW IF EXISTS dbo.vw_Sales_Southwest;
GO
CREATE VIEW dbo.vw_Sales_Southwest AS
SELECT SO.*
FROM SalesOrder SO
JOIN SalesTerritory ST ON SO.sales_territory_id = ST.sales_territory_id
WHERE ST.region = 'Southwest';
GO

-- vw_SalesLines_Southwest
-- Descrição: Retorna todas as linhas de encomenda (detalhes dos produtos) do território Southwest.
DROP VIEW IF EXISTS dbo.vw_SalesLines_Southwest;
GO
CREATE VIEW dbo.vw_SalesLines_Southwest AS
SELECT SOL.*
FROM SalesOrderLine SOL
JOIN SalesOrder SO ON SOL.sales_order_id = SO.sales_order_id
JOIN SalesTerritory ST ON SO.sales_territory_id = ST.sales_territory_id
WHERE ST.region = 'Southwest';
GO

-- vw_Customers_Southwest
-- Descrição: Retorna todos os clientes que têm encomendas no território Southwest.
DROP VIEW IF EXISTS dbo.vw_Customers_Southwest;
GO
CREATE VIEW dbo.vw_Customers_Southwest AS
SELECT DISTINCT C.*
FROM Customer C
JOIN SalesOrder SO ON C.customer_id = SO.customer_id
JOIN SalesTerritory ST ON SO.sales_territory_id = ST.sales_territory_id
WHERE ST.region = 'Southwest';
GO

-- vw_Products_Southwest
-- Descrição: Retorna todos os produtos que foram vendidos no território Southwest.
DROP VIEW IF EXISTS dbo.vw_Products_Southwest;
GO
CREATE VIEW dbo.vw_Products_Southwest AS
SELECT DISTINCT P.*
FROM ProductVariant P
JOIN SalesOrderLine SOL ON P.product_variant_id = SOL.product_variant_id
JOIN SalesOrder SO ON SOL.sales_order_id = SO.sales_order_id
JOIN SalesTerritory ST ON SO.sales_territory_id = ST.sales_territory_id
WHERE ST.region = 'Southwest';
GO

-- vw_SalesSummary_Southwest
-- Descrição: Fornece um resumo de vendas do território Southwest, incluindo total de encomendas e valor total das vendas.
DROP VIEW IF EXISTS dbo.vw_SalesSummary_Southwest;
GO
CREATE VIEW dbo.vw_SalesSummary_Southwest AS
SELECT
    ST.region AS TerritoryName,
    COUNT(*) AS TotalOrders,
    SUM(SOL.unit_price * SOL.quantity) AS TotalSalesAmount
FROM SalesOrder SO
JOIN SalesOrderLine SOL ON SO.sales_order_id = SOL.sales_order_id
JOIN SalesTerritory ST ON SO.sales_territory_id = ST.sales_territory_id
WHERE ST.region = 'Southwest'
GROUP BY ST.region;
GO

/*============================================================
  5. PERMISSÕES
============================================================*/
GRANT SELECT ON dbo.vw_Sales_Southwest        TO roleSalesTerritory;
GRANT SELECT ON dbo.vw_SalesLines_Southwest   TO roleSalesTerritory;
GRANT SELECT ON dbo.vw_Customers_Southwest    TO roleSalesTerritory;
GRANT SELECT ON dbo.vw_Products_Southwest     TO roleSalesTerritory;
GRANT SELECT ON dbo.vw_SalesSummary_Southwest TO roleSalesTerritory;

GRANT SELECT ON dbo.SalesTerritory TO roleSalesTerritory;

GRANT SELECT ON dbo.Customer            TO roleSalesTerritory;
GRANT SELECT ON dbo.ProductMaster       TO roleSalesTerritory;
GRANT SELECT ON dbo.ProductVariant      TO roleSalesTerritory;
GRANT SELECT ON dbo.ProductCategory     TO roleSalesTerritory;
GRANT SELECT ON dbo.ProductSubcategory  TO roleSalesTerritory;
GO