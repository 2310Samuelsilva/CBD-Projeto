USE AdventureWorks;
GO

--=================================================================================
-- DATA VALIDATION SCRIPT
-- Purpose: Compare migrated data between AdventureWorksLegacy and AdventureWorks
--=================================================================================
PRINT('=== DATA VALIDATION STARTED ===');

------------------------------------------------------------
-- 1. PRODUCT CATEGORIES
------------------------------------------------------------
PRINT('1. Product Categories...');
SELECT
    'Legacy' AS Source,
    COUNT(DISTINCT EnglishProductCategoryName) AS CategoryCount
FROM AdventureWorksLegacy.dbo.Products
UNION ALL
SELECT
    'New',
    COUNT(*) AS CategoryCount
FROM AdventureWorks.dbo.ProductCategory;

------------------------------------------------------------
-- 2. PRODUCT SUBCATEGORIES
------------------------------------------------------------
PRINT('2. Product Subcategories...');
SELECT
    'Legacy' AS Source,
    COUNT(*) AS SubCategoryCount
FROM AdventureWorksLegacy.dbo.ProductSubCategory
UNION ALL
SELECT
    'New',
    COUNT(*) AS SubCategoryCount
FROM AdventureWorks.dbo.ProductSubcategory;

------------------------------------------------------------
-- 3. PRODUCT COLORS
------------------------------------------------------------
PRINT('3. Product Colors...');
SELECT
    'Legacy' AS Source,
    COUNT(DISTINCT L.Color) AS ColorCount
FROM AdventureWorksLegacy.dbo.Products AS L
WHERE L.Color IS NOT NULL AND L.Color <> ''
UNION ALL
SELECT
    'New',
    COUNT(*) AS ColorCount
FROM AdventureWorks.dbo.ProductColor;

------------------------------------------------------------
-- 4. PRODUCT SIZE RANGES
------------------------------------------------------------
PRINT('4. Product Size Ranges...');
SELECT
    'Legacy' AS Source,
    COUNT(DISTINCT dbo.TrimSpaces(L.SizeRange)) AS SizeRangeCount
FROM AdventureWorksLegacy.dbo.Products AS L
WHERE L.SizeRange IS NOT NULL AND L.SizeRange <> ''
UNION ALL
SELECT
    'New',
    COUNT(*) AS SizeRangeCount
FROM AdventureWorks.dbo.ProductSizeRange;

------------------------------------------------------------
-- 5. PRODUCT LINES
------------------------------------------------------------
PRINT('5. Product Lines...');
SELECT
    'Legacy' AS Source,
    COUNT(DISTINCT dbo.TrimSpaces(L.ProductLine)) AS ProductLineCount
FROM AdventureWorksLegacy.dbo.Products AS L
WHERE L.ProductLine IS NOT NULL AND L.ProductLine <> ''
UNION ALL
SELECT
    'New',
    COUNT(*) AS ProductLineCount
FROM AdventureWorks.dbo.ProductLine;

------------------------------------------------------------
-- 6. PRODUCT CLASSES
------------------------------------------------------------
PRINT('6. Product Classes...');
SELECT
    'Legacy' AS Source,
    COUNT(DISTINCT dbo.TrimSpaces(L.Class)) AS ProductClassCount
FROM AdventureWorksLegacy.dbo.Products AS L
WHERE L.Class IS NOT NULL AND L.Class <> ''
UNION ALL
SELECT
    'New',
    COUNT(*) AS ProductClassCount
FROM AdventureWorks.dbo.ProductClass;

------------------------------------------------------------
-- 7. PRODUCT STYLES
------------------------------------------------------------
PRINT('7. Product Styles...');
SELECT
    'Legacy' AS Source,
    COUNT(DISTINCT dbo.TrimSpaces(L.Style)) AS ProductStyleCount
FROM AdventureWorksLegacy.dbo.Products AS L
WHERE L.Style IS NOT NULL AND L.Style <> ''
UNION ALL
SELECT
    'New',
    COUNT(*) AS ProductStyleCount
FROM AdventureWorks.dbo.ProductStyle;

------------------------------------------------------------
-- 8. PRODUCT MASTERS
------------------------------------------------------------
PRINT('8. Product Masters...');
SELECT
    'Legacy' AS Source,
    COUNT(DISTINCT dbo.TrimSpaces(L.ModelName)) AS ProductMasterCount
FROM AdventureWorksLegacy.dbo.Products AS L
WHERE L.ModelName IS NOT NULL AND L.ModelName <> ''
UNION ALL
SELECT
    'New',
    COUNT(*) AS ProductMasterCount
FROM AdventureWorks.dbo.ProductMaster;

------------------------------------------------------------
-- 9. PRODUCT VARIANTS
------------------------------------------------------------
PRINT('9. Product Variants...');
SELECT 
    'Legacy' AS Source, 
    COUNT(*) AS ProductVariantCount
FROM AdventureWorksLegacy.dbo.Products
UNION ALL
SELECT 
    'New', 
    COUNT(*) AS ProductVariantCount
FROM AdventureWorks.dbo.ProductVariant;

------------------------------------------------------------
-- 10. CROSS CHECKS
------------------------------------------------------------
PRINT('10. Cross-Checks for Integrity...');

-- Check missing models (legacy models not found in ProductMaster)
SELECT DISTINCT 
    L.ModelName
FROM AdventureWorksLegacy.dbo.Products AS L
WHERE L.ModelName NOT IN (
    SELECT PM.model FROM AdventureWorks.dbo.ProductMaster AS PM
);

-- Check ProductVariants without ProductMaster linkage
SELECT COUNT(*) AS OrphanVariants
FROM AdventureWorks.dbo.ProductVariant AS PV
LEFT JOIN AdventureWorks.dbo.ProductMaster AS PM
    ON PV.product_master_id = PM.product_master_id
WHERE PM.product_master_id IS NULL;

------------------------------------------------------------
PRINT('=== DATA VALIDATION COMPLETE ===');
GO