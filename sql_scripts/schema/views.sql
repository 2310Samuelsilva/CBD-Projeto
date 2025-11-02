/*====================================================================
 DATA QUALITY VALIDATION VIEWS
 Author: Samuel Silva 202200315
 Purpose:
   Validate the correctness and completeness of migration by comparing
   the new AdventureWorks DB with AdventureWorksLegacy.
=====================================================================*/

USE AdventureWorks;
GO

/*====================================================================
 1. Product Count
====================================================================*/
IF OBJECT_ID('dbo.vw_ProductCount', 'V') IS NOT NULL
    DROP VIEW dbo.vw_ProductCount;
GO
CREATE VIEW dbo.vw_ProductCount AS
SELECT 
    COUNT(*) AS ProductCount
FROM dbo.ProductVariant;
GO


/*====================================================================
 2. Sales Count (Distinct Orders)
====================================================================*/
IF OBJECT_ID('dbo.vw_SalesCount', 'V') IS NOT NULL
    DROP VIEW dbo.vw_SalesCount;
GO
CREATE VIEW dbo.vw_SalesCount AS
SELECT 
    COUNT(DISTINCT SO.sales_order_number) AS SalesCount
FROM dbo.SalesOrder AS SO;
GO


/*====================================================================
 3. Total Sales by Customer
====================================================================*/
IF OBJECT_ID('dbo.vw_SalesByCustomer', 'V') IS NOT NULL
    DROP VIEW dbo.vw_SalesByCustomer;
GO
CREATE VIEW dbo.vw_SalesByCustomer AS
SELECT 
    C.customer_id,
    C.first_name,
    C.last_name,
    C.email_address,
    SUM(ISNULL(SOL.quantity,0) * ISNULL(SOL.unit_price,0)) AS TotalSalesValue,
    COUNT(DISTINCT SO.sales_order_id) AS TotalOrders
FROM dbo.Customer AS C
JOIN dbo.SalesOrder AS SO
    ON C.customer_id = SO.customer_id
JOIN dbo.SalesOrderLine AS SOL
    ON SO.sales_order_id = SOL.sales_order_id
GROUP BY C.customer_id, C.first_name, C.last_name, C.email_address;
GO


/*====================================================================
 4. Total Sales by Year
====================================================================*/
IF OBJECT_ID('dbo.vw_SalesByYear', 'V') IS NOT NULL
    DROP VIEW dbo.vw_SalesByYear;
GO
CREATE VIEW dbo.vw_SalesByYear AS
SELECT 
    YEAR(SO.order_date) AS SalesYear,
    SUM(ISNULL(SOL.quantity,0) * ISNULL(SOL.unit_price,0)) AS TotalSalesValue,
    COUNT(DISTINCT SO.sales_order_id) AS TotalOrders
FROM dbo.SalesOrder AS SO
JOIN dbo.SalesOrderLine AS SOL
    ON SO.sales_order_id = SOL.sales_order_id
GROUP BY YEAR(SO.order_date);
GO


/*====================================================================
 5. Total Sales by Year and Product
====================================================================*/
IF OBJECT_ID('dbo.vw_SalesByYearProduct', 'V') IS NOT NULL
    DROP VIEW dbo.vw_SalesByYearProduct;
GO
CREATE VIEW dbo.vw_SalesByYearProduct AS
SELECT 
    YEAR(SO.order_date) AS SalesYear,
    PM.model AS ProductModel,
    SUM(ISNULL(SOL.quantity,0) * ISNULL(SOL.unit_price,0)) AS TotalSalesValue,
    COUNT(DISTINCT SO.sales_order_id) AS TotalOrders
FROM dbo.SalesOrder AS SO
JOIN dbo.SalesOrderLine AS SOL
    ON SO.sales_order_id = SOL.sales_order_id
JOIN dbo.ProductVariant AS PV
    ON SOL.product_variant_id = PV.product_variant_id
JOIN dbo.ProductMaster AS PM
    ON PV.product_master_id = PM.product_master_id
GROUP BY YEAR(SO.order_date), PM.model;
GO


/*====================================================================
 6. Sales by Region (Optional group-specific metric)
====================================================================*/
IF OBJECT_ID('dbo.vw_SalesByRegion', 'V') IS NOT NULL
    DROP VIEW dbo.vw_SalesByRegion;
GO
CREATE VIEW dbo.vw_SalesByRegion AS
SELECT 
    ST.region AS SalesRegion,
    SUM(ISNULL(SOL.quantity,0) * ISNULL(SOL.unit_price,0)) AS TotalSalesValue,
    COUNT(DISTINCT SO.sales_order_id) AS TotalOrders
FROM dbo.SalesOrder AS SO
JOIN dbo.SalesOrderLine AS SOL
    ON SO.sales_order_id = SOL.sales_order_id
JOIN dbo.SalesTerritory AS ST
    ON SO.sales_territory_id = ST.sales_territory_id
GROUP BY ST.region;
GO


/*====================================================================
 7. Customer Sales Summary (Extended Validation)
====================================================================*/
IF OBJECT_ID('dbo.vw_CustomerSalesSummary', 'V') IS NOT NULL
    DROP VIEW dbo.vw_CustomerSalesSummary;
GO
CREATE VIEW dbo.vw_CustomerSalesSummary AS
SELECT
    C.customer_id,
    C.first_name,
    C.last_name,
    C.email_address,
    COUNT(DISTINCT SO.sales_order_id) AS total_orders,
    COUNT(SOL.sales_order_line_id) AS total_lines,
    SUM(ISNULL(SOL.quantity,0)) AS total_quantity,
    SUM(ISNULL(SOL.unit_price,0) * ISNULL(SOL.quantity,0)) AS total_sales_amount,
    SUM(ISNULL(SOL.tax_amt,0)) AS total_tax,
    SUM(ISNULL(SOL.freight,0)) AS total_freight,
    MIN(SO.order_date) AS first_order_date,
    MAX(SO.order_date) AS last_order_date
FROM dbo.Customer AS C
LEFT JOIN dbo.SalesOrder AS SO
    ON C.customer_id = SO.customer_id
LEFT JOIN dbo.SalesOrderLine AS SOL
    ON SO.sales_order_id = SOL.sales_order_id
GROUP BY C.customer_id, C.first_name, C.last_name, C.email_address;
GO


/* ============================================================================
   8 VIEW: vw_ProductDetailed
   Description: Combine ProductMaster and ProductVariant for a complete product overview
============================================================================ */
IF OBJECT_ID('dbo.vw_ProductDetailed', 'V') IS NOT NULL
    DROP VIEW dbo.vw_ProductDetailed;
GO
CREATE VIEW dbo.vw_ProductDetailed AS
SELECT
    PV.product_variant_id,
    PM.product_master_id,
    PM.model,
    PM.description,
    C.name AS category,
    SC.name AS subcategory,
    PL.name AS product_line,
    PC.name AS class,
    PV.variant_name,
    COL.name AS color,
    ST.name AS style,
    PV.size,
    SR.name AS size_range,
    PV.size_unit_measure_code,
    PV.weight,
    PV.weight_unit_measure_code,
    PV.finished_goods_flag,
    PV.standard_cost,
    PV.list_price,
    PV.dealer_price,
    PV.days_to_manufacture,
    PV.safety_stock_level
FROM dbo.ProductVariant AS PV
JOIN dbo.ProductMaster AS PM
    ON PV.product_master_id = PM.product_master_id
LEFT JOIN dbo.ProductCategory AS C
    ON PM.category_id = C.category_id
LEFT JOIN dbo.ProductSubcategory AS SC
    ON PM.subcategory_id = SC.subcategory_id
LEFT JOIN dbo.ProductLine AS PL
    ON PM.product_line_id = PL.product_line_id
LEFT JOIN dbo.ProductClass AS PC
    ON PM.class_id = PC.class_id
LEFT JOIN dbo.ProductColor AS COL
    ON PV.color_id = COL.color_id
LEFT JOIN dbo.ProductStyle AS ST
    ON PV.style_id = ST.style_id
LEFT JOIN dbo.ProductSizeRange AS SR
    ON PV.size_range_id = SR.size_range_id;
GO


/* ============================================================================
   9 VIEW: vw_CustomerFullInfo
   Description: Complete customer info including address, country, state, and linked app user info
============================================================================ */
IF OBJECT_ID('dbo.vw_CustomerFullInfo', 'V') IS NOT NULL
    DROP VIEW dbo.vw_CustomerFullInfo;
GO
CREATE VIEW dbo.vw_CustomerFullInfo AS
SELECT
    C.customer_id,
    C.title,
    C.first_name,
    C.middle_name,
    C.last_name,
    C.birth_date,
    C.marital_status,
    C.gender,
    C.email_address,
    C.yearly_income,
    C.education,
    C.occupation,
    C.number_cars_owned,
    C.date_first_purchase,
    C.nif,
    CA.customer_address_id,
    CA.address_line1,
    CA.city,
    CA.postal_code,
    CA.phone,
    SP.name AS state_province,
    SP.code AS state_code,
    CR.name AS country,
    CR.code AS country_code,
    AU.app_user_id,
    AU.email AS app_user_email,
    AU.is_active AS user_active,
    AU.created_at AS user_created_at,
    AU.last_login AS last_login_date,
    ST.region AS sales_territory
FROM dbo.Customer AS C
LEFT JOIN dbo.CustomerAddress AS CA
    ON C.customer_id = CA.customer_id
LEFT JOIN dbo.StateProvince AS SP
    ON CA.state_province_id = SP.state_province_id
LEFT JOIN dbo.CountryRegion AS CR
    ON CA.country_id = CR.country_id
LEFT JOIN dbo.AppUser AS AU
    ON C.customer_id = AU.customer_id
LEFT JOIN dbo.SalesOrder AS SO
    ON C.customer_id = SO.customer_id
LEFT JOIN dbo.SalesTerritory AS ST
    ON SO.sales_territory_id = ST.sales_territory_id;
GO


/* ============================================================================
   10 VIEW: vw_Top5BestSellingProducts
   Description: Top 5 best selling products
============================================================================ */

IF OBJECT_ID('dbo.vw_Top5BestSellingProducts', 'V') IS NOT NULL
    DROP VIEW dbo.vw_Top5BestSellingProducts;
GO

CREATE VIEW dbo.vw_Top5BestSellingProducts AS
SELECT TOP 5
    PM.model AS ProductModel,
    PV.variant_name AS ProductVariant,
    SUM(ISNULL(SOL.quantity, 0)) AS TotalQuantitySold,
    SUM(ISNULL(SOL.quantity, 0) * ISNULL(SOL.unit_price, 0)) AS TotalSalesAmount
FROM dbo.SalesOrderLine AS SOL
INNER JOIN dbo.ProductVariant AS PV
    ON SOL.product_variant_id = PV.product_variant_id
INNER JOIN dbo.ProductMaster AS PM
    ON PV.product_master_id = PM.product_master_id
GROUP BY PM.model, PV.variant_name
ORDER BY SUM(ISNULL(SOL.quantity, 0)) DESC;
GO