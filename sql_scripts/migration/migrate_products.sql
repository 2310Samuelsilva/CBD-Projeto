--=================================================================================
-- MIGRATION SCRIPT: PRODUCTS
-- Target: AdventureWorks
-- Source: AdventureWorksLegacy
--=================================================================================
-- This script assumes both databases exist on the same SQL Server instance.
-- Run this after creating schema/tables in AdventureWorks.
--=================================================================================

USE AdventureWorks;

--=================================================================================
-- FUNCTION: dbo.TrimSpaces
-- Purpose: Remove leading and trailing spaces from an NVARCHAR string
--=================================================================================
IF OBJECT_ID('dbo.TrimSpaces', 'FN') IS NOT NULL
    DROP FUNCTION dbo.TrimSpaces;
GO
CREATE FUNCTION dbo.TrimSpaces (@Input NVARCHAR(MAX))
RETURNS NVARCHAR(MAX)
AS
BEGIN
    -- Check for NULL input
    IF @Input IS NULL
        RETURN NULL;

    -- Trim spaces
    RETURN LTRIM(RTRIM(@Input));
END;
GO



--=================================================================================
-- STEP 1: Migrate Product Categories
--=================================================================================
-- Plan:
-- 1. Select distinct categories from the legacy Products table.
-- 2. Insert them into the new ProductCategory table (if not already present).
INSERT INTO AdventureWorks.dbo.ProductCategory (name)
SELECT DISTINCT L.EnglishProductCategoryName
FROM AdventureWorksLegacy.dbo.Products AS L
WHERE L.EnglishProductCategoryName IS NOT NULL
  AND NOT EXISTS (
      SELECT 1
      FROM AdventureWorks.dbo.ProductCategory AS C
      WHERE C.name = L.EnglishProductCategoryName
  );
GO

--=================================================================================
-- STEP 2: Migrate Product Subcategories
--=================================================================================
-- Plan:
-- 1. Select distinct subcategories from the legacy ProductSubCategory table.
-- 2. Insert them into the new ProductSubcategory table (if not already present).
INSERT INTO AdventureWorks.dbo.ProductSubcategory (name)
SELECT DISTINCT L.EnglishProductSubcategoryName
FROM AdventureWorksLegacy.dbo.ProductSubCategory AS L
WHERE L.EnglishProductSubcategoryName IS NOT NULL
  AND NOT EXISTS (
      SELECT 1
      FROM AdventureWorks.dbo.ProductSubcategory AS SC
      WHERE SC.name = L.EnglishProductSubcategoryName
  );
GO

--=================================================================================
-- STEP 3: Migrate Weight Units of Measure
--=================================================================================
-- Plan:
-- 1. Extract distinct WeightUnitMeasureCode from legacy Products.
-- 2. Map to new UnitOfMeasure codes and conversion factors.
-- 3. Insert only if not already present.
-- Base Unit: Kilogram (KG)
;WITH WeightUnitMap AS (
    SELECT DISTINCT 
        L.WeightUnitMeasureCode AS legacy_code,
        CASE 
            WHEN L.WeightUnitMeasureCode = 'LB' THEN 'LB'
            WHEN L.WeightUnitMeasureCode = 'G'  THEN 'G'
            WHEN L.WeightUnitMeasureCode = ''   THEN 'KG'
            ELSE 'KG' -- default/fallback
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
-- STEP 4: Migrate Size Units of Measure (with default)
--=================================================================================
-- Plan:
-- 1. Extract distinct SizeUnitMeasureCode values from legacy Products table.
-- 2. Map recognized codes to base units; default unknown/empty to 'NA'.
-- 3. Insert into UnitOfMeasure only if not already present.

;WITH SizeUnitMap AS (
    SELECT DISTINCT  
        L.SizeUnitMeasureCode AS legacy_code,
        CASE 
            WHEN L.SizeUnitMeasureCode IS NULL OR L.SizeUnitMeasureCode = '' THEN 'NA'
            ELSE L.SizeUnitMeasureCode
        END AS unit_measure_code,
        CASE 
            WHEN L.SizeUnitMeasureCode IS NULL OR L.SizeUnitMeasureCode = '' THEN 'NOT DEFINED'
            ELSE 'Centimeters' -- all known codes mapped to CM
        END AS name,
        CASE 
            WHEN L.SizeUnitMeasureCode IS NULL OR L.SizeUnitMeasureCode = '' THEN 1.0
            ELSE 1.0 -- conversion factor to base unit (CM)
        END AS conversion_to_base
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
-- STEP 5: Migrate Product Colors
--=================================================================================
-- Plan:
-- 1. Select distinct colors from the legacy Products table.
-- 2. Insert them into the new ProductColor table (if not already present).
INSERT INTO AdventureWorks.dbo.ProductColor (name)
SELECT DISTINCT L.Color
FROM AdventureWorksLegacy.dbo.Products AS L
WHERE L.Color IS NOT NULL
  AND NOT EXISTS (
      SELECT 1
      FROM AdventureWorks.dbo.ProductColor AS C
      WHERE C.name = L.Color
  );
GO

--=================================================================================
-- STEP 6: Migrate Product Size Ranges
--=================================================================================
-- Plan:
-- 1. Select distinct size ranges from legacy Products table
-- 2. Insert them into ProductSizeRange table
INSERT INTO AdventureWorks.dbo.ProductSizeRange (name)
SELECT DISTINCT LTRIM(RTRIM(SizeRange))
FROM AdventureWorksLegacy.dbo.Products AS L
WHERE LTRIM(RTRIM(SizeRange)) <> ''
  AND NOT EXISTS (
      SELECT 1
      FROM AdventureWorks.dbo.ProductSizeRange AS SR
      WHERE LTRIM(RTRIM(SR.name)) = LTRIM(RTRIM(L.SizeRange))
  );
GO

--=================================================================================
-- STEP 7: Migrate Product Lines
--=================================================================================
-- Plan:
-- 1. Select distinct product lines from legacy Products table
-- 2. Insert them into ProductLine table
INSERT INTO AdventureWorks.dbo.ProductLine (name)
SELECT DISTINCT LTRIM(RTRIM(ProductLine))
FROM AdventureWorksLegacy.dbo.Products AS L
WHERE LTRIM(RTRIM(ProductLine)) <> ''
  AND NOT EXISTS (
      SELECT 1
      FROM AdventureWorks.dbo.ProductLine AS PL
      WHERE LTRIM(RTRIM(PL.name)) = LTRIM(RTRIM(L.ProductLine))
  );
GO

--=================================================================================
-- STEP 8: Migrate Product Classes
--=================================================================================
-- Plan:
-- 1. Select distinct product classes from legacy Products table
-- 2. Insert them into ProductClass table
INSERT INTO AdventureWorks.dbo.ProductClass (name)
SELECT DISTINCT LTRIM(RTRIM(Class))
FROM AdventureWorksLegacy.dbo.Products AS L
WHERE LTRIM(RTRIM(Class)) <> ''
  AND NOT EXISTS (
      SELECT 1
      FROM AdventureWorks.dbo.ProductClass AS PC
      WHERE LTRIM(RTRIM(PC.name)) = LTRIM(RTRIM(L.Class))
  );

--=================================================================================
-- STEP 9: Migrate Product Styles
--=================================================================================
-- Plan:
-- 1. Select distinct product styles from legacy Products table
-- 2. Insert them into ProductStyle table
INSERT INTO AdventureWorks.dbo.ProductStyle (name)
SELECT DISTINCT LTRIM(RTRIM(Style))
FROM AdventureWorksLegacy.dbo.Products AS L
WHERE LTRIM(RTRIM(Style)) <> ''
  AND NOT EXISTS (
      SELECT 1
      FROM AdventureWorks.dbo.ProductStyle AS PS
      WHERE LTRIM(RTRIM(PS.name)) = LTRIM(RTRIM(L.Style))
  );
GO


--=================================================================================
-- STEP 10: Migrate Product Masters (model_name as source of truth)
--=================================================================================
-- Plan:
-- 1. One master product per ModelName.
-- 2. Map category, subcategory, product line, class if available.
-- 3. Insert into ProductMaster table.

INSERT INTO AdventureWorks.dbo.ProductMaster
(
    --product_name,
    model,
    category_id,
    subcategory_id,
    product_line_id,
    class_id,
    description
)
SELECT DISTINCT
    --dbo.TrimSpaces(L.EnglishProductName) AS product_name,
    dbo.TrimSpaces(L.ModelName) AS model,
    C.category_id,
    SC.subcategory_id,
    PL.product_line_id,
    PC.class_id,
    dbo.TrimSpaces(L.EnglishDescription) AS description
FROM AdventureWorksLegacy.dbo.Products AS L
LEFT JOIN AdventureWorks.dbo.ProductCategory AS C
    ON dbo.TrimSpaces(L.EnglishProductCategoryName) = dbo.TrimSpaces(C.name)
LEFT JOIN AdventureWorks.dbo.ProductSubcategory AS SC
    ON dbo.TrimSpaces(L.EnglishProductSubcategoryName) = dbo.TrimSpaces(SC.name)
LEFT JOIN AdventureWorks.dbo.ProductLine AS PL
    ON dbo.TrimSpaces(L.ProductLine) = dbo.TrimSpaces(PL.name)
LEFT JOIN AdventureWorks.dbo.ProductClass AS PC
    ON dbo.TrimSpaces(L.Class) = dbo.TrimSpaces(PC.name)
WHERE NOT EXISTS (
    SELECT 1
    FROM AdventureWorks.dbo.ProductMaster AS PM
    WHERE PM.model = dbo.TrimSpaces(L.ModelName)
);