/*============================================================
 DATA QUALITY CHECKS
============================================================*/

--============================================================
-- 1. Function: Detect duplicate customer emails
--============================================================
CREATE OR ALTER FUNCTION dbo.fn_check_duplicate_customers()
RETURNS TABLE
AS
RETURN
(
    SELECT 
        email_address, 
        COUNT(*) AS duplicate_count
    FROM dbo.customer
    GROUP BY email_address
    HAVING COUNT(*) > 1
);
GO


-- --============================================================
-- -- 2. Procedure: Detect sales order lines with missing product references
-- --============================================================
-- CREATE OR ALTER PROCEDURE dbo.sp_check_sales_without_product
-- AS
-- BEGIN
--     SET NOCOUNT ON;

--     SELECT 
--         sol.sales_order_line_id,
--         so.sales_order_number
--     FROM dbo.sales_order_line AS sol
--     LEFT JOIN dbo.product_variant AS pv 
--         ON sol.product_variant_id = pv.product_variant_id
--     LEFT JOIN dbo.sales_order AS so 
--         ON sol.sales_order_id = so.sales_order_id
--     WHERE pv.product_variant_id IS NULL;
-- END;
-- GO


-- --============================================================
-- -- 3. Procedure: Run consolidated data quality verification
-- --============================================================
-- CREATE OR ALTER PROCEDURE dbo.sp_check_data_quality
-- AS
-- BEGIN
--     SET NOCOUNT ON;

--     PRINT('=== Data Quality Verification Started ===');

--     PRINT('--- Duplicate Customers ---');
--     SELECT * FROM dbo.fn_check_duplicate_customers();

--     PRINT('--- Sales Without Product ---');
--     EXEC dbo.sp_check_sales_without_product;

--     PRINT('=== Data Quality Verification Completed ===');
-- END;
-- GO


-- --============================================================
-- -- Run the consolidated quality check
-- --============================================================
-- EXEC dbo.sp_check_data_quality;
-- GO