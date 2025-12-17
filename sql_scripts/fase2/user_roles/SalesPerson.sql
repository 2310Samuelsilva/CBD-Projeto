/*============================================================
  SALESPERSON
  - Pode gerir encomendas (CRUD)
  - Apenas leitura para restantes objetos
============================================================*/
USE AdventureWorks;
GO
-- Criar role se não existir
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'roleSalesPerson')
BEGIN
    CREATE ROLE roleSalesPerson;
END
GO

-- Criar utilizador se não existir
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'SalesPersonUser')
BEGIN
    CREATE USER SalesPersonUser WITHOUT LOGIN;
END
GO

-- Associar utilizador à role se não estiver associado
IF NOT EXISTS (
    SELECT 1
    FROM sys.database_role_members rm
    JOIN sys.database_principals r ON rm.role_principal_id = r.principal_id
    JOIN sys.database_principals m ON rm.member_principal_id = m.principal_id
    WHERE r.name = 'roleSalesPerson' AND m.name = 'SalesPersonUser'
)
BEGIN
    ALTER ROLE roleSalesPerson ADD MEMBER SalesPersonUser;
END
GO

/*------------------------------------------------------------
  Permissões de ESCRITA (tabelas de vendas)
------------------------------------------------------------*/
GRANT SELECT, INSERT, UPDATE, DELETE ON dbo.SalesOrder     TO roleSalesPerson;
GRANT SELECT, INSERT, UPDATE, DELETE ON dbo.SalesOrderLine TO roleSalesPerson;
GRANT SELECT, INSERT, UPDATE, DELETE ON dbo.SalesTerritory TO roleSalesPerson;

/*------------------------------------------------------------
  Permissões de LEITURA (resto do esquema)
------------------------------------------------------------*/
GRANT SELECT ON dbo.Customer             TO roleSalesPerson; -- TODO: Keep readony or editable
GRANT SELECT ON dbo.CustomerAddress      TO roleSalesPerson;
GRANT SELECT ON dbo.ProductMaster        TO roleSalesPerson; -- TODO: Keep readony or editable
GRANT SELECT ON dbo.ProductVariant       TO roleSalesPerson; -- TODO: Keep readony or editable
GRANT SELECT ON dbo.ProductCategory      TO roleSalesPerson;
GRANT SELECT ON dbo.ProductSubcategory   TO roleSalesPerson;
GRANT SELECT ON dbo.ProductColor         TO roleSalesPerson;
GRANT SELECT ON dbo.ProductStyle         TO roleSalesPerson;
GRANT SELECT ON dbo.ProductClass         TO roleSalesPerson;
GRANT SELECT ON dbo.ProductLine          TO roleSalesPerson;
GRANT SELECT ON dbo.ProductSizeRange     TO roleSalesPerson;
GRANT SELECT ON dbo.UnitOfMeasure        TO roleSalesPerson;
GRANT SELECT ON dbo.SalesTerritory       TO roleSalesPerson;
GRANT SELECT ON dbo.Currency             TO roleSalesPerson;
GRANT SELECT ON dbo.CountryRegion        TO roleSalesPerson;
GRANT SELECT ON dbo.StateProvince        TO roleSalesPerson;
GRANT SELECT ON dbo.AppUser              TO roleSalesPerson;
GRANT SELECT ON dbo.PasswordRecoveryQuestion TO roleSalesPerson;
GRANT SELECT ON dbo.SentEmails           TO roleSalesPerson;
GO