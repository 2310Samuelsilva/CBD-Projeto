/*============================================================
  AdventureWorks - Filegroup Configuration
  Author: Samuel Silva
  Purpose: Optimized filegroup layout for performance and data organization
============================================================*/

-- Drop existing DB (only if needed for rebuild)
-- DROP DATABASE AdventureWorks;
-- GO

--============================================================
-- 1. Create Database with Filegroups
--============================================================
CREATE DATABASE AdventureWorks
ON PRIMARY (
    NAME = AdventureWorks_Primary,
    FILENAME = 'D:\SQLData\AdventureWorks_Primary.mdf',
    SIZE = 10MB,
    FILEGROWTH = 10%
),

FILEGROUP FG_HighUsage (
    NAME = AdventureWorks_HighUsage,
    FILENAME = 'E:\SQLData\AdventureWorks_HighUsage.ndf',
    SIZE = 8192MB,             -- 8 GB initial size (high-activity tables)
    FILEGROWTH = 10%           -- dynamic growth
),

FILEGROUP FG_Secondary (
    NAME = AdventureWorks_Secondary,
    FILENAME = 'F:\SQLData\AdventureWorks_Secondary.ndf',
    SIZE = 2048MB,             -- 2 GB initial size (reference tables)
    FILEGROWTH = 512MB         -- fixed growth (controlled)
)

LOG ON (
    NAME = AdventureWorks_Log,
    FILENAME = 'G:\SQLLogs\AdventureWorks_Log.ldf',
    SIZE = 1024MB,
    FILEGROWTH = 512MB
);
GO

--============================================================
-- 2. Verify Filegroup Configuration
--============================================================
SELECT 
    name AS FilegroupName, 
    type_desc AS FileType, 
    physical_name AS FilePath,
    size * 8 / 1024 AS SizeMB,
    growth,
    is_default
FROM sys.master_files
WHERE database_id = DB_ID('AdventureWorks');
GO

--============================================================
-- SCHEMA CREATION
--============================================================
USE AdventureWorks;
GO

-- Product data and related reference tables
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'Product')
    EXEC('CREATE SCHEMA Product AUTHORIZATION dbo;');
GO

-- Customer data
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'Customer')
    EXEC('CREATE SCHEMA Customer AUTHORIZATION dbo;');
GO

-- Sales and transaction data
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'Sales')
    EXEC('CREATE SCHEMA Sales AUTHORIZATION dbo;');
GO

-- Application security and user management
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'Security')
    EXEC('CREATE SCHEMA Security AUTHORIZATION dbo;');
GO