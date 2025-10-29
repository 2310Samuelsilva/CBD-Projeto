-- MS SQL Server


--=================================================================================
-- STEP 1: Migrate Product Categories
--=================================================================================
-- Plan:
-- 1. Select distinct categories from the legacy Products table
-- 2. Insert them into the new ProductCategory table
INSERT INTO AdventureWorks.dbo.ProductCategory (name)
SELECT DISTINCT EnglishProductCategoryName
FROM AdventureWorksLegacy.dbo.Products
WHERE EnglishProductCategoryName IS NOT NULL
  AND NOT EXISTS (
      SELECT 1
      FROM AdventureWorks.dbo.ProductCategory C
      WHERE C.name = Products.EnglishProductCategoryName
  );

--=================================================================================
-- STEP 2: Migrate Product Subcategories
--=================================================================================
-- Plan:
-- 1. Select distinct subcategories from the legacy ProductSubCategory table
-- 2. Insert them into the new ProductSubcategory table
INSERT INTO AdventureWorks.dbo.ProductSubcategory (name)
SELECT DISTINCT EnglishProductSubcategoryName
FROM AdventureWorksLegacy.dbo.ProductSubCategory
WHERE EnglishProductSubcategoryName IS NOT NULL
  AND NOT EXISTS (
      SELECT 1
      FROM AdventureWorks.dbo.ProductSubcategory SC
      WHERE SC.name = ProductSubCategory.EnglishProductSubcategoryName
  );

--=================================================================================
-- Section 3: Weight Units
-- Plan:
-- 1. Extract distinct WeightUnitMeasureCode from legacy Products.
-- 2. Map to new UnitOfMeasure codes and conversion to base (KG).
-- 3. Insert into UnitOfMeasure (if not already present).
-- Base unit: KG
--=================================================================================
WITH WeightUnitMap AS (
    SELECT DISTINCT 
        WeightUnitMeasureCode AS legacy_code,
        CASE 
            WHEN WeightUnitMeasureCode = 'LB' THEN 'LB'
            WHEN WeightUnitMeasureCode = 'G'  THEN 'G'
            WHEN WeightUnitMeasureCode = ''   THEN 'KG' -- default for empty
            ELSE 'KG' -- fallback
        END AS unit_measure_code,
        CASE 
            WHEN WeightUnitMeasureCode = 'LB' THEN 'Pounds'
            WHEN WeightUnitMeasureCode = 'G'  THEN 'Grams'
            ELSE 'Kilograms'
        END AS name,
        CASE 
            WHEN WeightUnitMeasureCode = 'LB' THEN 0.453592
            WHEN WeightUnitMeasureCode = 'G'  THEN 0.001
            ELSE 1 -- KG or default
        END AS conversion_to_base
    FROM AdventureWorksLegacy.dbo.Products
)
INSERT INTO AdventureWorks.dbo.UnitOfMeasure (unit_measure_code, name, conversion_to_base)
SELECT unit_measure_code, name, conversion_to_base
FROM WeightUnitMap W
WHERE NOT EXISTS (
    SELECT 1 
    FROM AdventureWorks.dbo.UnitOfMeasure U 
    WHERE U.unit_measure_code = W.unit_measure_code
);