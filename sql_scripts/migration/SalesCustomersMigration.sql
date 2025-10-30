USE AdventureWorks;
GO

------------------------------------------------------------
--  LIMPAR DADOS EXISTENTES (para reexecuções)
------------------------------------------------------------
PRINT('Limpando tabelas principais...');
DELETE FROM SalesOrderLine;
DELETE FROM SalesOrder;
DELETE FROM SalesTerritory;
DELETE FROM Currency;
DELETE FROM CustomerAddress;
DELETE FROM Customer;
DELETE FROM StateProvince;
DELETE FROM CountryRegion;
GO

------------------------------------------------------------
--  GARANTIR QUE COLUNA NIF É VARBINARY(MAX)
------------------------------------------------------------
IF EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Customer') AND name = 'nif')
BEGIN
    ALTER TABLE dbo.Customer DROP COLUMN nif;
    ALTER TABLE dbo.Customer ADD nif VARBINARY(MAX) NULL;
END
GO

------------------------------------------------------------
--  INSERIR PAÍSES (CountryRegion)
------------------------------------------------------------
PRINT('Inserindo CountryRegion...');
INSERT INTO dbo.CountryRegion (code, name)
SELECT DISTINCT c.CountryRegionCode, c.CountryRegionName
FROM AdventureWorksLegacy.dbo.Customer AS c
WHERE c.CountryRegionCode IS NOT NULL;
GO

------------------------------------------------------------
--  INSERIR ESTADOS / PROVÍNCIAS (StateProvince)
------------------------------------------------------------
PRINT('Inserindo StateProvince...');
INSERT INTO dbo.StateProvince (code, name, country_id)
SELECT DISTINCT
    c.StateProvinceCode,
    c.StateProvinceName,
    cr.country_id
FROM AdventureWorksLegacy.dbo.Customer AS c
JOIN dbo.CountryRegion AS cr ON c.CountryRegionCode = cr.code;
GO

------------------------------------------------------------
--  CONFIGURAR ENCRIPTAÇÃO (se ainda não existir)
------------------------------------------------------------
PRINT('Verificando chaves de encriptação...');
IF NOT EXISTS (SELECT * FROM sys.symmetric_keys WHERE name = '##MS_DatabaseMasterKey##')
    CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'ChaveSegura123!';

IF NOT EXISTS (SELECT * FROM sys.certificates WHERE name = 'CertNIF')
    CREATE CERTIFICATE CertNIF WITH SUBJECT = 'Certificado NIF';

IF NOT EXISTS (SELECT * FROM sys.symmetric_keys WHERE name = 'KeyNIF')
    CREATE SYMMETRIC KEY KeyNIF WITH ALGORITHM = AES_256 ENCRYPTION BY CERTIFICATE CertNIF;
GO

------------------------------------------------------------
--  INSERIR CLIENTES (Customer)
------------------------------------------------------------
PRINT('Inserindo Customers...');
OPEN SYMMETRIC KEY KeyNIF DECRYPTION BY CERTIFICATE CertNIF;
GO

INSERT INTO dbo.Customer (
    title,
    first_name,
    middle_name,
    last_name,
    birth_date,
    marital_status,
    gender,
    email_address,
    yearly_income,
    education,
    occupation,
    number_cars_owned,
    date_first_purchase,
    nif
)
SELECT
    c.Title,
    c.FirstName,
    c.MiddleName,
    c.LastName,
    c.BirthDate,
    c.MaritalStatus,
    c.Gender,
    c.EmailAddress,
    c.YearlyIncome,
    c.Education,
    c.Occupation,
    c.NumberCarsOwned,
    c.DateFirstPurchase,
    ENCRYPTBYKEY(KEY_GUID('KeyNIF'), CONVERT(VARBINARY(MAX), c.[NIF]))
FROM AdventureWorksLegacy.dbo.Customer AS c;
GO

CLOSE SYMMETRIC KEY KeyNIF;
GO

------------------------------------------------------------
--  INSERIR MORADAS (CustomerAddress)
------------------------------------------------------------
PRINT('Inserindo CustomerAddress...');
INSERT INTO dbo.CustomerAddress (
    customer_id,
    address_line1,
    city,
    state_province_id,
    postal_code,
    country_id,
    phone
)
SELECT
    nc.customer_id,
    lc.AddressLine1,
    lc.City,
    sp.state_province_id,
    lc.PostalCode,
    cr.country_id,
    lc.Phone
FROM AdventureWorksLegacy.dbo.Customer AS lc
JOIN dbo.Customer AS nc
    ON lc.EmailAddress = nc.email_address
LEFT JOIN dbo.StateProvince AS sp ON lc.StateProvinceCode = sp.code
LEFT JOIN dbo.CountryRegion AS cr ON lc.CountryRegionCode = cr.code;
GO

------------------------------------------------------------
-- INSERIR MOEDAS (Currency)
------------------------------------------------------------
PRINT('Inserindo Currency...');
INSERT INTO dbo.Currency (code, name)
SELECT DISTINCT s.CurrencyKey, s.CurrencyKey
FROM AdventureWorksLegacy.dbo.Sales AS s
WHERE s.CurrencyKey IS NOT NULL;
GO

------------------------------------------------------------
-- INSERIR TERRITÓRIOS DE VENDA (SalesTerritory)
------------------------------------------------------------
PRINT('Inserindo SalesTerritory...');
INSERT INTO dbo.SalesTerritory (name, region)
SELECT DISTINCT st.SalesTerritoryCountry, st.SalesTerritoryRegion
FROM AdventureWorksLegacy.dbo.SalesTerritory AS st;
GO

------------------------------------------------------------
--  CRIAR MAPEAMENTO ENTRE CLIENTES (Legacy → Novo)
------------------------------------------------------------
PRINT('Criando mapeamento de clientes...');
IF OBJECT_ID('tempdb..#CustomerMap') IS NOT NULL DROP TABLE #CustomerMap;
SELECT 
    L.CustomerKey AS old_id,
    N.customer_id AS new_id
INTO #CustomerMap
FROM AdventureWorksLegacy.dbo.Customer AS L
JOIN AdventureWorks.dbo.Customer AS N
    ON L.EmailAddress = N.email_address;
GO

------------------------------------------------------------
-- INSERIR ENCOMENDAS (SalesOrder)
------------------------------------------------------------
PRINT('Inserindo SalesOrder...');
INSERT INTO dbo.SalesOrder (
    sales_order_number,
    customer_id,
    sales_territory_id,
    order_date,
    due_date,
    ship_date
)
SELECT DISTINCT
    s.SalesOrderNumber,
    m.new_id,
    st.sales_territory_id,
    CAST(s.OrderDate AS DATE),
    CAST(s.DueDate AS DATE),
    CAST(s.ShipDate AS DATE)
FROM AdventureWorksLegacy.dbo.Sales AS s
LEFT JOIN dbo.SalesTerritory AS st ON s.SalesTerritoryKey = st.sales_territory_id
LEFT JOIN #CustomerMap AS m ON s.CustomerKey = m.old_id
WHERE m.new_id IS NOT NULL;
GO

------------------------------------------------------------
--  INSERIR LINHAS DE ENCOMENDA (SalesOrderLine)
------------------------------------------------------------
PRINT('Inserindo SalesOrderLine...');
INSERT INTO dbo.SalesOrderLine (
    sales_order_id,
    line_number,
    product_variant_id,
    currency_id,
    product_standard_cost,
    unit_price,
    quantity,
    tax_amt,
    freight
)
SELECT
    o.sales_order_id,
    s.SalesOrderLineNumber,
    pv.product_variant_id,
    c.currency_id,
    s.ProductStandardCost,
    s.UnitPrice,
    1 AS quantity,
    s.TaxAmt,
    s.Freight
FROM AdventureWorksLegacy.dbo.Sales AS s
JOIN dbo.SalesOrder AS o 
    ON s.SalesOrderNumber = o.sales_order_number
LEFT JOIN AdventureWorksLegacy.dbo.Products AS p 
    ON s.ProductKey = p.ProductKey
LEFT JOIN dbo.ProductVariant AS pv 
    ON dbo.CleanProductName(p.EnglishProductName) = dbo.CleanProductName(pv.variant_name)
LEFT JOIN dbo.Currency AS c 
    ON s.CurrencyKey = c.code
WHERE pv.product_variant_id IS NOT NULL;
GO

------------------------------------------------------------
--  VERIFICAÇÃO FINAL
------------------------------------------------------------
PRINT('Verificando contagens...');

SELECT 
    (SELECT COUNT(*) FROM Customer) AS Clientes,
    (SELECT COUNT(*) FROM CustomerAddress) AS Moradas,
    (SELECT COUNT(*) FROM CountryRegion) AS Paises,
    (SELECT COUNT(*) FROM StateProvince) AS Provincias,
    (SELECT COUNT(*) FROM SalesTerritory) AS Territorios,
    (SELECT COUNT(*) FROM Currency) AS Moedas,
    (SELECT COUNT(*) FROM SalesOrder) AS Encomendas,
    (SELECT COUNT(*) FROM SalesOrderLine) AS Linhas;

PRINT('MIGRAÇÃO CONCLUÍDA COM SUCESSO!');
GO
