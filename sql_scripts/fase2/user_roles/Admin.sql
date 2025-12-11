/*============================================================
  ADMINISTRATOR ROLE MODEL
  - Create custom admin role
  - Grant it full permissions by adding it to db_owner
  - Create admin user and add to custom role
============================================================*/

-- 1. Create custom administrator role
USE AdventureWorks;

IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'roleAdministrador')
BEGIN
    CREATE ROLE roleAdministrador;
    PRINT('Role roleAdministrador criada.');
END
ELSE
    PRINT('Role roleAdministrador já existe.');

IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'AdminUser')
BEGIN
    CREATE USER AdminUser WITHOUT LOGIN;
    PRINT('Utilizador AdminUser criado.');
END
ELSE
    PRINT('Utilizador AdminUser já existe.');

-- Adicionar Utilizador à roleAdministrador
IF NOT EXISTS (
    SELECT 1
    FROM sys.database_role_members drm
    JOIN sys.database_principals r ON drm.role_principal_id = r.principal_id
    JOIN sys.database_principals m ON drm.member_principal_id = m.principal_id
    WHERE r.name = 'roleAdministrador' AND m.name = 'AdminUser'
)
BEGIN
    ALTER ROLE roleAdministrador ADD MEMBER AdminUser;
    PRINT('AdminUser adicionado à roleAdministrador.');
END

