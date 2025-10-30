

SELECT
    ModelName,
    COUNT(DISTINCT EnglishProductCategoryName) AS distinct_categories,
    COUNT(DISTINCT ProductSubcategoryKey) AS distinct_subcategories,
    COUNT(DISTINCT ProductLine) AS distinct_product_lines,
    COUNT(DISTINCT Class) AS distinct_classes,
    COUNT(DISTINCT Style) AS distinct_styles,
    COUNT(*) AS total_rows
FROM AdventureWorksLegacy.dbo.Products
GROUP BY ModelName
ORDER BY ModelName;


