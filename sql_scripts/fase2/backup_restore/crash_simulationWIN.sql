/*======================================================================
  SIMULAÇÃO DE CRASH E RECUPERAÇÃO DA BASE DE DADOS – SQL SERVER
  Objetivo:
    - Simular uma falha (crash) da base de dados
    - Demonstrar perda de dados
    - Executar recuperação usando:
        * Backup FULL
        * Backup DIFFERENTIAL
        * (Opcional) Backup TRANSACTION LOG
  ======================================================================*/

-----------------------------------------------------------------------
-- 0. VARIÁVEIS E PRESSUPOSTOS
-----------------------------------------------------------------------

-- Usado neste script:
-- C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\BackupProgram Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\Backup\AdventureWorks_FULL.bak

-----------------------------------------------------------------------
-- 1. CONFIGURAÇÃO INICIAL
-----------------------------------------------------------------------

USE master;
GO

-- Garantir modelo de recuperação FULL
ALTER DATABASE AdventureWorks
SET RECOVERY FULL;
GO

-----------------------------------------------------------------------
-- 2. BACKUP FULL (ESTADO BASE)
-----------------------------------------------------------------------

BACKUP DATABASE AdventureWorks
TO DISK = 'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\Backup\AdventureWorks_FULL.bak'
WITH INIT, FORMAT;
GO

-----------------------------------------------------------------------
-- 3. VALIDAR ESTADO INICIAL DOS DADOS
-----------------------------------------------------------------------

USE AdventureWorks;
GO

SELECT COUNT(*) AS TotalCategories
FROM dbo.ProductCategory;
GO

-----------------------------------------------------------------------
-- 4. INSERIR DADOS APÓS BACKUP FULL
-----------------------------------------------------------------------

INSERT INTO dbo.ProductCategory (Name)
VALUES ('Crash Test Category 1'),
       ('Crash Test Category 2');
GO

SELECT *
FROM dbo.ProductCategory
WHERE Name LIKE 'Crash Test%';
GO

-----------------------------------------------------------------------
-- 5. BACKUP DIFFERENTIAL
-----------------------------------------------------------------------

USE master;
GO

BACKUP DATABASE AdventureWorks
TO DISK = 'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\Backup\AdventureWorks_DIFF.bak'
WITH DIFFERENTIAL, INIT;
GO

USE AdventureWorks;
Go

INSERT INTO dbo.ProductCategory (Name)
VALUES ('DIFF BACKUP');
GO

/*======================================================================
  EXTENSÃO: BACKUP E RECUPERAÇÃO DO TRANSACTION LOG
  Objetivo:
    - Demonstrar recuperação até ao último backup de log
    - Evidenciar diferença entre:
        * Dados protegidos por LOG
        * Dados efetivamente perdidos
======================================================================*/

-----------------------------------------------------------------------
-- 5.1 BACKUP DO TRANSACTION LOG (APÓS O BACKUP DIFFERENTIAL)
-----------------------------------------------------------------------

USE master;
GO

BACKUP LOG AdventureWorks
TO DISK = 'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\Backup\AdventureWorks_LOG.trn'
WITH INIT;
GO

-----------------------------------------------------------------------
-- 6.1 INSERIR DADOS APÓS BACKUP DO LOG
-- Estes dados só estarão protegidos se houver novo backup de log
-----------------------------------------------------------------------

USE AdventureWorks;
GO

INSERT INTO dbo.ProductCategory (Name)
VALUES ('Protected By Log Backup');
GO

SELECT name
FROM dbo.ProductCategory;
GO

-----------------------------------------------------------------------
-- 6.2 NOVO BACKUP DO TRANSACTION LOG
-----------------------------------------------------------------------

USE master;
GO

BACKUP LOG AdventureWorks
TO DISK = 'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\Backup\AdventureWorks_LOG2.trn'
WITH INIT;
GO

-----------------------------------------------------------------------
-- 6.3 INSERIR DADOS SEM BACKUP DE LOG (PERDA ESPERADA)
-----------------------------------------------------------------------

USE AdventureWorks;
GO

INSERT INTO dbo.ProductCategory (Name)
VALUES ('Lost After Crash - No Log Backup');
GO

SELECT name
FROM dbo.ProductCategory;
GO

-----------------------------------------------------------------------
-- 7. SIMULAÇÃO DE CRASH
-----------------------------------------------------------------------
-- DESLIGAR SERVIÇO / ALTERAR FICHEIRO MDF
-- >>> AQUI OCORRE O "CRASH" SIMULADO <<<


-----------------------------------------------------------------------
-- 9. RESTAURO DO BACKUP FULL (ALTERADO PARA SUPORTAR LOGS)
-----------------------------------------------------------------------

USE master;
GO
RESTORE DATABASE AdventureWorks
FROM DISK = 'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\Backup\AdventureWorks_FULL.bak'
WITH
    REPLACE,
    NORECOVERY;
GO

-----------------------------------------------------------------------
-- 10. RESTAURO DO BACKUP DIFFERENTIAL (SEM RECOVERY)
-----------------------------------------------------------------------

RESTORE DATABASE AdventureWorks
FROM DISK = 'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\Backup\AdventureWorks_DIFF.bak'
WITH NORECOVERY;
GO

-----------------------------------------------------------------------
-- 10.1 RESTAURO DO TRANSACTION LOG
-----------------------------------------------------------------------

RESTORE LOG AdventureWorks
FROM DISK = 'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\Backup\AdventureWorks_LOG.trn'
WITH NORECOVERY;
GO

-----------------------------------------------------------------------
-- 10.2 RESTAURO DO TRANSACTION LOG2
-----------------------------------------------------------------------

RESTORE LOG AdventureWorks
FROM DISK = 'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\Backup\AdventureWorks_LOG2.trn'
WITH RECOVERY ;
GO


-----------------------------------------------------------------------
-- 13. VALIDAÇÃO FINAL DOS DADOS
-----------------------------------------------------------------------

USE AdventureWorks;
GO

-- Dados restaurados
SELECT name
FROM dbo.ProductCategory;
GO


-- Resultado esperado:
-- ✔ 'Protected By Log Backup' EXISTE
-- ✘ 'Lost After Crash - No Log Backup' NÃO EXISTE