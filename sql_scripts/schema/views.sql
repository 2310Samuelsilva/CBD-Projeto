--=================================================================================
-- VALIDATION VIEWS - NEW DATABASE (AdventureWorks)
-- Purpose: Provide summary metrics to compare against AdventureWorksLegacy
--=================================================================================
USE AdventureWorks;
GO


/* ============================================================================
   1 VIEW: vw_ProductCount
   Description: Total number of product variants
============================================================================ */
IF OBJECT_ID('vw_ProductCount', 'V') IS NOT NULL
    DROP VIEW vw_ProductCount;
GO
CREATE VIEW vw_ProductCount AS
SELECT 
    COUNT(*) AS ProductCount
FROM dbo.ProductVariant;
GO


/* ============================================================================
   2 VIEW: vw_SalesCount
   Description: Total number of distinct sales orders
============================================================================ */
IF OBJECT_ID('vw_SalesCount', 'V') IS NOT NULL
    DROP VIEW vw_SalesCount;
GO
CREATE VIEW vw_SalesCount AS
SELECT 
    COUNT(DISTINCT sales_order_number) AS SalesCount
FROM dbo.SalesOrder;
GO


/* ============================================================================
   3 VIEW: vw_SalesByCustomer
   Description: Total sales value by customer
============================================================================ */
IF OBJECT_ID('vw_SalesByCustomer', 'V') IS NOT NULL
    DROP VIEW vw_SalesByCustomer;
GO
CREATE VIEW vw_SalesByCustomer AS
SELECT 
    C.customer_id,
    SUM(ISNULL(SOL.quantity,0) * ISNULL(SOL.unit_price,0)) AS TotalSales
FROM dbo.SalesOrder AS SO
JOIN dbo.SalesOrderLine AS SOL
    ON SO.sales_order_id = SOL.sales_order_id
JOIN dbo.Customer AS C
    ON SO.customer_id = C.customer_id
GROUP BY C.customer_id;
GO


/* ============================================================================
   4 VIEW: vw_SalesByYear
   Description: Total monetary sales per year
============================================================================ */
IF OBJECT_ID('vw_SalesByYear', 'V') IS NOT NULL
    DROP VIEW vw_SalesByYear;
GO
CREATE VIEW vw_SalesByYear AS
SELECT 
    YEAR(SO.order_date) AS SalesYear,
    SUM(ISNULL(SOL.quantity,0) * ISNULL(SOL.unit_price,0)) AS TotalSales
FROM dbo.SalesOrder AS SO
JOIN dbo.SalesOrderLine AS SOL
    ON SO.sales_order_id = SOL.sales_order_id
GROUP BY YEAR(SO.order_date);
GO


/* ============================================================================
   5 VIEW: vw_SalesByYearProduct
   Description: Total sales value per year and product model
============================================================================ */
IF OBJECT_ID('vw_SalesByYearProduct', 'V') IS NOT NULL
    DROP VIEW vw_SalesByYearProduct;
GO
CREATE VIEW vw_SalesByYearProduct AS
SELECT 
    YEAR(SO.order_date) AS SalesYear,
    PM.model AS ProductModel,
    SUM(ISNULL(SOL.quantity,0) * ISNULL(SOL.unit_price,0)) AS TotalSales
FROM dbo.SalesOrder AS SO
JOIN dbo.SalesOrderLine AS SOL
    ON SO.sales_order_id = SOL.sales_order_id
JOIN dbo.ProductVariant AS PV
    ON SOL.product_variant_id = PV.product_variant_id
JOIN dbo.ProductMaster AS PM
    ON PV.product_master_id = PM.product_master_id
GROUP BY YEAR(SO.order_date), PM.model;
GO


/* ============================================================================
   6 VIEW: vw_SalesByRegion
   Description: Total sales per sales territory
============================================================================ */
IF OBJECT_ID('vw_SalesByRegion', 'V') IS NOT NULL
    DROP VIEW vw_SalesByRegion;
GO
CREATE VIEW vw_SalesByRegion AS
SELECT 
    ST.region AS SalesRegion,
    SUM(ISNULL(SOL.quantity,0) * ISNULL(SOL.unit_price,0)) AS TotalSales
FROM dbo.SalesOrder AS SO
JOIN dbo.SalesOrderLine AS SOL
    ON SO.sales_order_id = SOL.sales_order_id
JOIN dbo.SalesTerritory AS ST
    ON SO.sales_territory_id = ST.sales_territory_id
GROUP BY ST.region;
GO


/* ============================================================================
   7 VIEW: vw_ProductDetailed
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
   8 VIEW: vw_CustomerFullInfo
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
   9 VIEW: vw_CustomerSalesSummary
   Description: Provide sales summary metrics per customer
============================================================================ */
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