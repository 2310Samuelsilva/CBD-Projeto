use AdventureWorks
GO

-- =========================
-- INDEXES: Products
-- =========================

/* ProductVariant: índice por product_master_id para junções com ProductMaster. */
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes i JOIN sys.tables t ON i.object_id = t.object_id
    WHERE i.name = 'IX_ProductVariant_ProductMaster' AND t.name = 'ProductVariant'
)
BEGIN
    CREATE INDEX IX_ProductVariant_ProductMaster
    ON dbo.ProductVariant (product_master_id)
    INCLUDE (variant_name, color_id);
END;

/* ProductVariant: índice por legacy_product_key (se tiveres queries para mapear legacy -> novo). */
IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.ProductVariant') AND name = 'legacy_product_key')
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM sys.indexes i JOIN sys.tables t ON i.object_id = t.object_id
        WHERE i.name = 'IX_ProductVariant_LegacyKey' AND t.name = 'ProductVariant'
    )
    BEGIN
        CREATE INDEX IX_ProductVariant_LegacyKey
        ON dbo.ProductVariant (legacy_product_key);
    END
END;

/* ProductMaster: índice por category_id para agregações por categoria. */
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes i JOIN sys.tables t ON i.object_id = t.object_id
    WHERE i.name = 'IX_ProductMaster_Category' AND t.name = 'ProductMaster'
)
BEGIN
    CREATE INDEX IX_ProductMaster_Category
    ON dbo.ProductMaster (category_id);
END;

-- =========================
-- INDEXES: Dimension / Lookup tables
-- =========================

/* SalesTerritory: índice por region (usado em filtros por região). */
IF NOT EXISTS (
    SELECT 1 
    FROM sys.indexes i 
    JOIN sys.tables t ON i.object_id = t.object_id
    WHERE i.name = 'IX_SalesTerritory_Region'
      AND t.name = 'SalesTerritory'
)
BEGIN
    CREATE INDEX IX_SalesTerritory_Region
    ON dbo.SalesTerritory (region);
END;

/* Currency: índice por code para lookup rápido. */
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes i JOIN sys.tables t ON i.object_id = t.object_id
    WHERE i.name = 'IX_Currency_Code' AND t.name = 'Currency'
)
BEGIN
    CREATE INDEX IX_Currency_Code
    ON dbo.Currency (code);
END;

/* StateProvince: índice por code para lookup e joins. */
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes i JOIN sys.tables t ON i.object_id = t.object_id
    WHERE i.name = 'IX_StateProvince_Code' AND t.name = 'StateProvince'
)
BEGIN
    CREATE INDEX IX_StateProvince_Code
    ON dbo.StateProvince (code)
    INCLUDE (name, country_id);
END;

/* CountryRegion: índice por code. */
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes i JOIN sys.tables t ON i.object_id = t.object_id
    WHERE i.name = 'IX_CountryRegion_Code' AND t.name = 'CountryRegion'
)
BEGIN
    CREATE INDEX IX_CountryRegion_Code
    ON dbo.CountryRegion (code)
    INCLUDE (name);
END;

-- =========================
-- INDEXES: Users / Auth
-- =========================

/* AppUser: índice por email (login) e created_at include para relatórios. */
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes i JOIN sys.tables t ON i.object_id = t.object_id
    WHERE i.name = 'IX_AppUser_Email' AND t.name = 'AppUser'
)
BEGIN
    CREATE INDEX IX_AppUser_Email
    ON dbo.AppUser (email)
    INCLUDE (is_active, created_at, last_login);
END;

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