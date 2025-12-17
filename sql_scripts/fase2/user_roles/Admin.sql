/*============================================================
  ADMINISTRATOR ROLE MODEL
  - Create custom admin role
  - Grant it full permissions by adding it to db_owner
  - Create admin user and add to custom role
============================================================*/

------------------------------------------------------------
-- 1. Criar roleAdministrador (se não existir)
------------------------------------------------------------
IF NOT EXISTS (
    SELECT 1 FROM sys.database_principals 
    WHERE name = 'roleAdministrador'
)
BEGIN
    CREATE ROLE roleAdministrador;
    PRINT('Role roleAdministrador criada.');
END
ELSE
    PRINT('Role roleAdministrador já existe.');
GO

------------------------------------------------------------
-- 2. Dar permissões totais à roleAdministrador
--    (associando-a a db_owner)
------------------------------------------------------------
IF NOT EXISTS (
    SELECT 1
    FROM sys.database_role_members drm
    JOIN sys.database_principals r ON drm.role_principal_id = r.principal_id
    JOIN sys.database_principals m ON drm.member_principal_id = m.principal_id
    WHERE r.name = 'db_owner'
      AND m.name = 'roleAdministrador'
)
BEGIN
    ALTER ROLE db_owner ADD MEMBER roleAdministrador;
    PRINT('roleAdministrador adicionada à role db_owner.');
END
ELSE
    PRINT('roleAdministrador já pertence a db_owner.');
GO

------------------------------------------------------------
-- 3. Criar utilizador AdminUser (sem login, para testes)
------------------------------------------------------------
IF NOT EXISTS (
    SELECT 1 FROM sys.database_principals 
    WHERE name = 'AdminUser'
)
BEGIN
    CREATE USER AdminUser WITHOUT LOGIN;
    PRINT('Utilizador AdminUser criado.');
END
ELSE
    PRINT('Utilizador AdminUser já existe.');
GO

------------------------------------------------------------
-- 4. Associar AdminUser à roleAdministrador
------------------------------------------------------------
IF NOT EXISTS (
    SELECT 1
    FROM sys.database_role_members drm
    JOIN sys.database_principals r ON drm.role_principal_id = r.principal_id
    JOIN sys.database_principals m ON drm.member_principal_id = m.principal_id
    WHERE r.name = 'roleAdministrador'
      AND m.name = 'AdminUser'
)
BEGIN
    ALTER ROLE roleAdministrador ADD MEMBER AdminUser;
    PRINT('AdminUser adicionado à roleAdministrador.');
END
ELSE
    PRINT('AdminUser já pertence à roleAdministrador.');
GO

