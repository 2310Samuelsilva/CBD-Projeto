/*
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

GO */