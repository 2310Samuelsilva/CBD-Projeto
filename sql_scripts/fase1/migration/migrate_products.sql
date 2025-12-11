--=================================================================================
-- MIGRATION SCRIPT: PRODUCTS
-- Target: AdventureWorks
-- Source: AdventureWorksLegacy
--=================================================================================
-- This script migrates legacy product data into the new AdventureWorks schema.
-- It assumes both databases exist on the same SQL Server instance.
-- Run after all schema and helper functions (TrimSpaces, CleanProductName) are created.
--=================================================================================

USE AdventureWorks;
GO


--=================================================================================
-- STEP 1: MIGRATE PRODUCT CATEGORIES
--=================================================================================
-- 1. Extract distinct category names from legacy data.
-- 2. Trim and insert if not already present.
--=================================================================================
INSERT INTO AdventureWorks.dbo.ProductCategory (name)
SELECT DISTINCT dbo.TrimSpaces(L.EnglishProductCategoryName)
FROM AdventureWorksLegacy.dbo.Products AS L
WHERE L.EnglishProductCategoryName IS NOT NULL
  AND NOT EXISTS (
      SELECT 1
      FROM AdventureWorks.dbo.ProductCategory AS C
      WHERE dbo.TrimSpaces(C.name) = dbo.TrimSpaces(L.EnglishProductCategoryName)
  );
GO


--=================================================================================
-- STEP 2: MIGRATE PRODUCT SUBCATEGORIES
--=================================================================================
-- 1. Pull from legacy ProductSubCategory table.
-- 2. Avoid duplicates by trimmed name.
--=================================================================================
INSERT INTO AdventureWorks.dbo.ProductSubcategory (name)
SELECT DISTINCT dbo.TrimSpaces(L.EnglishProductSubcategoryName)
FROM AdventureWorksLegacy.dbo.ProductSubCategory AS L
WHERE L.EnglishProductSubcategoryName IS NOT NULL
  AND NOT EXISTS (
      SELECT 1
      FROM AdventureWorks.dbo.ProductSubcategory AS SC
      WHERE dbo.TrimSpaces(SC.name) = dbo.TrimSpaces(L.EnglishProductSubcategoryName)
  );
GO


--=================================================================================
-- STEP 3: MIGRATE WEIGHT UNITS OF MEASURE
--=================================================================================
-- 1. Map distinct WeightUnitMeasureCode values to base units.
-- 2. Define conversion factors.
-- 3. Insert only new unit codes.
--=================================================================================
;WITH WeightUnitMap AS (
    SELECT DISTINCT 
        dbo.TrimSpaces(L.WeightUnitMeasureCode) AS legacy_code,
        CASE 
            WHEN L.WeightUnitMeasureCode = 'LB' THEN 'LB'
            WHEN L.WeightUnitMeasureCode = 'G'  THEN 'G'
            WHEN L.WeightUnitMeasureCode = ''   THEN 'KG'
            ELSE 'KG'
        END AS unit_measure_code,
        CASE 
            WHEN L.WeightUnitMeasureCode = 'LB' THEN 'Pounds'
            WHEN L.WeightUnitMeasureCode = 'G'  THEN 'Grams'
            ELSE 'Kilograms'
        END AS name,
        CASE 
            WHEN L.WeightUnitMeasureCode = 'LB' THEN 0.453592
            WHEN L.WeightUnitMeasureCode = 'G'  THEN 0.001
            ELSE 1.0
        END AS conversion_to_base
    FROM AdventureWorksLegacy.dbo.Products AS L
)
INSERT INTO AdventureWorks.dbo.UnitOfMeasure (unit_measure_code, name, conversion_to_base)
SELECT W.unit_measure_code, W.name, W.conversion_to_base
FROM WeightUnitMap AS W
WHERE NOT EXISTS (
    SELECT 1 
    FROM AdventureWorks.dbo.UnitOfMeasure AS U 
    WHERE U.unit_measure_code = W.unit_measure_code
);
GO


--=================================================================================
-- STEP 4: MIGRATE SIZE UNITS OF MEASURE
--=================================================================================
-- 1. Identify size unit codes from legacy data.
-- 2. Default blanks to 'NA' (Not Applicable).
-- 3. Insert new units if missing.
--=================================================================================
;WITH SizeUnitMap AS (
    SELECT DISTINCT  
        dbo.TrimSpaces(L.SizeUnitMeasureCode) AS legacy_code,
        CASE 
            WHEN L.SizeUnitMeasureCode IS NULL OR L.SizeUnitMeasureCode = '' THEN 'NA'
            ELSE L.SizeUnitMeasureCode
        END AS unit_measure_code,
        CASE 
            WHEN L.SizeUnitMeasureCode IS NULL OR L.SizeUnitMeasureCode = '' THEN 'NOT DEFINED'
            ELSE 'Centimeters'
        END AS name,
        1.0 AS conversion_to_base
    FROM AdventureWorksLegacy.dbo.Products AS L
)
INSERT INTO dbo.UnitOfMeasure (unit_measure_code, name, conversion_to_base)
SELECT S.unit_measure_code, S.name, S.conversion_to_base
FROM SizeUnitMap AS S
WHERE NOT EXISTS (
    SELECT 1 
    FROM dbo.UnitOfMeasure AS U 
    WHERE U.unit_measure_code = S.unit_measure_code
);
GO


--=================================================================================
-- STEP 5: MIGRATE PRODUCT COLORS
--=================================================================================
-- 1. Extract distinct color names from legacy Products.
-- 2. Trim and insert new ones only.
--=================================================================================
INSERT INTO AdventureWorks.dbo.ProductColor (name)
SELECT DISTINCT dbo.TrimSpaces(L.Color)
FROM AdventureWorksLegacy.dbo.Products AS L
WHERE L.Color IS NOT NULL
  AND NOT EXISTS (
      SELECT 1
      FROM AdventureWorks.dbo.ProductColor AS C
      WHERE dbo.TrimSpaces(C.name) = dbo.TrimSpaces(L.Color)
  );
GO


--=================================================================================
-- STEP 6: MIGRATE PRODUCT SIZE RANGES
--=================================================================================
-- 1. Load distinct size range values.
-- 2. Insert trimmed names if not already present.
--=================================================================================
INSERT INTO AdventureWorks.dbo.ProductSizeRange (name)
SELECT DISTINCT dbo.TrimSpaces(L.SizeRange)
FROM AdventureWorksLegacy.dbo.Products AS L
WHERE dbo.TrimSpaces(L.SizeRange) <> ''
  AND NOT EXISTS (
      SELECT 1
      FROM AdventureWorks.dbo.ProductSizeRange AS SR
      WHERE dbo.TrimSpaces(SR.name) = dbo.TrimSpaces(L.SizeRange)
  );
GO


--=================================================================================
-- STEP 7: MIGRATE PRODUCT LINES
--=================================================================================
-- 1. Extract distinct ProductLine names.
-- 2. Insert if missing.
--=================================================================================
INSERT INTO AdventureWorks.dbo.ProductLine (name)
SELECT DISTINCT dbo.TrimSpaces(L.ProductLine)
FROM AdventureWorksLegacy.dbo.Products AS L
WHERE dbo.TrimSpaces(L.ProductLine) <> ''
  AND NOT EXISTS (
      SELECT 1
      FROM AdventureWorks.dbo.ProductLine AS PL
      WHERE dbo.TrimSpaces(PL.name) = dbo.TrimSpaces(L.ProductLine)
  );
GO


--=================================================================================
-- STEP 8: MIGRATE PRODUCT CLASSES
--=================================================================================
-- 1. Extract distinct Class values.
-- 2. Insert if missing.
--=================================================================================
INSERT INTO AdventureWorks.dbo.ProductClass (name)
SELECT DISTINCT dbo.TrimSpaces(L.Class)
FROM AdventureWorksLegacy.dbo.Products AS L
WHERE dbo.TrimSpaces(L.Class) <> ''
  AND NOT EXISTS (
      SELECT 1
      FROM AdventureWorks.dbo.ProductClass AS PC
      WHERE dbo.TrimSpaces(PC.name) = dbo.TrimSpaces(L.Class)
  );
GO


--=================================================================================
-- STEP 9: MIGRATE PRODUCT STYLES
--=================================================================================
-- 1. Extract distinct Style values.
-- 2. Insert if missing.
--=================================================================================
INSERT INTO AdventureWorks.dbo.ProductStyle (name)
SELECT DISTINCT dbo.TrimSpaces(L.Style)
FROM AdventureWorksLegacy.dbo.Products AS L
WHERE dbo.TrimSpaces(L.Style) <> ''
  AND NOT EXISTS (
      SELECT 1
      FROM AdventureWorks.dbo.ProductStyle AS PS
      WHERE dbo.TrimSpaces(PS.name) = dbo.TrimSpaces(L.Style)
  );
GO


--=================================================================================
-- STEP 10: MIGRATE PRODUCT MASTERS
--=================================================================================
-- 1. Each unique ModelName becomes one ProductMaster record.
-- 2. Link category, subcategory, line, and class by trimmed name.
-- 3. Insert only new model names.
--=================================================================================
INSERT INTO AdventureWorks.dbo.ProductMaster
(
    model,
    category_id,
    subcategory_id,
    product_line_id,
    class_id,
    description
)
SELECT DISTINCT
    dbo.TrimSpaces(L.ModelName) AS model,
    C.category_id,
    SC_new.subcategory_id,
    PL.product_line_id,
    PC.class_id,
    dbo.TrimSpaces(L.EnglishDescription) AS description
FROM AdventureWorksLegacy.dbo.Products AS L
LEFT JOIN AdventureWorks.dbo.ProductCategory AS C
    ON dbo.TrimSpaces(L.EnglishProductCategoryName) = dbo.TrimSpaces(C.name)
LEFT JOIN AdventureWorksLegacy.dbo.ProductSubCategory AS SC_legacy
    ON L.ProductSubcategoryKey = SC_legacy.ProductSubcategoryKey
LEFT JOIN AdventureWorks.dbo.ProductSubcategory AS SC_new
    ON dbo.TrimSpaces(SC_legacy.EnglishProductSubcategoryName) = dbo.TrimSpaces(SC_new.name)
LEFT JOIN AdventureWorks.dbo.ProductLine AS PL
    ON dbo.TrimSpaces(L.ProductLine) = dbo.TrimSpaces(PL.name)
LEFT JOIN AdventureWorks.dbo.ProductClass AS PC
    ON dbo.TrimSpaces(L.Class) = dbo.TrimSpaces(PC.name)
WHERE NOT EXISTS (
    SELECT 1
    FROM AdventureWorks.dbo.ProductMaster AS PM
    WHERE dbo.TrimSpaces(PM.model) = dbo.TrimSpaces(L.ModelName)
);
GO


--=================================================================================
-- STEP 11: MIGRATE PRODUCT VARIANTS
--=================================================================================
-- Strategy:
-- 1. Match legacy records to ProductMaster via ModelName.
-- 2. Map all related lookups (color, style, size, range, weight units).
-- 3. Include legacy_product_key to allow direct mapping in SalesOrderLine migration.
-- 4. Avoid duplicates per product_master_id + legacy_product_key.
--=================================================================================

PRINT('STEP 11 - Migrating ProductVariant records...');

-- Add tracking column if not already present
IF COL_LENGTH('AdventureWorks.dbo.ProductVariant', 'legacy_product_key') IS NULL
    ALTER TABLE AdventureWorks.dbo.ProductVariant ADD legacy_product_key INT NULL;
GO

INSERT INTO AdventureWorks.dbo.ProductVariant
(
    product_master_id,
    variant_name,
    color_id,
    style_id,
    size,
    size_range_id,
    size_unit_measure_code,
    weight,
    weight_unit_measure_code,
    finished_goods_flag,
    standard_cost,
    list_price,
    dealer_price,
    days_to_manufacture,
    safety_stock_level,
    legacy_product_key
)
SELECT
    PM.product_master_id,
    L.EnglishProductName AS variant_name,

    ISNULL(PC.color_id, (SELECT TOP 1 color_id FROM AdventureWorks.dbo.ProductColor WHERE name = 'N/A')) AS color_id,
    ISNULL(PS.style_id, (SELECT TOP 1 style_id FROM AdventureWorks.dbo.ProductStyle WHERE name = 'N/A')) AS style_id,

    dbo.TrimSpaces(L.Size) AS size,
    ISNULL(PSR.size_range_id, (SELECT TOP 1 size_range_id FROM AdventureWorks.dbo.ProductSizeRange WHERE name = 'N/A')) AS size_range_id,
    ISNULL(NULLIF(dbo.TrimSpaces(L.SizeUnitMeasureCode), ''), 'NA') AS size_unit_measure_code,

    TRY_CONVERT(DECIMAL(18,4), NULLIF(L.Weight, '')) AS weight,
    ISNULL(NULLIF(dbo.TrimSpaces(L.WeightUnitMeasureCode), ''), 'NA') AS weight_unit_measure_code,

    L.FinishedGoodsFlag,

    TRY_CONVERT(DECIMAL(18,4), NULLIF(L.StandardCost, '')) AS standard_cost,
    TRY_CONVERT(DECIMAL(18,4), NULLIF(L.ListPrice, '')) AS list_price,
    TRY_CONVERT(DECIMAL(18,4), NULLIF(L.DealerPrice, '')) AS dealer_price,

    TRY_CONVERT(INT, NULLIF(L.DaysToManufacture, '')) AS days_to_manufacture,
    TRY_CONVERT(INT, NULLIF(L.SafetyStockLevel, '')) AS safety_stock_level,

    L.ProductKey AS legacy_product_key
FROM AdventureWorksLegacy.dbo.Products AS L
INNER JOIN AdventureWorks.dbo.ProductMaster AS PM
    ON dbo.TrimSpaces(L.ModelName) = dbo.TrimSpaces(PM.model)
LEFT JOIN AdventureWorks.dbo.ProductColor AS PC
    ON dbo.TrimSpaces(L.Color) = dbo.TrimSpaces(PC.name)
LEFT JOIN AdventureWorks.dbo.ProductStyle AS PS
    ON dbo.TrimSpaces(L.Style) = dbo.TrimSpaces(PS.name)
LEFT JOIN AdventureWorks.dbo.ProductSizeRange AS PSR
    ON dbo.TrimSpaces(L.SizeRange) = dbo.TrimSpaces(PSR.name)
WHERE NOT EXISTS (
    SELECT 1 
    FROM AdventureWorks.dbo.ProductVariant AS PV
    WHERE PV.product_master_id = PM.product_master_id
      AND PV.legacy_product_key = L.ProductKey
);

GO
PRINT('STEP 11 COMPLETE - ProductVariant migration done.');

GO