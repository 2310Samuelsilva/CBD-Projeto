
USE AdventureWorks;
GO

/*===============================================================================
 CLEANUP SCRIPT - POST MIGRATION TESTING
 Purpose:
   - Drop temp tables, legacy helper columns, and optionally clear migrated data.
   - Keeps schema intact for re-runs.
===============================================================================*/

PRINT('=== CLEANUP STARTED ===');
-------------------------------------------------------------------------------
-- 2. REMOVE LEGACY HELPER COLUMN FROM ProductVariant
-------------------------------------------------------------------------------
PRINT('Dropping legacy_product_key column from ProductVariant (if exists)...');
IF EXISTS (
    SELECT 1 
    FROM sys.columns 
    WHERE object_id = OBJECT_ID('dbo.ProductVariant') 
      AND name = 'legacy_product_key'
)
BEGIN
    ALTER TABLE dbo.ProductVariant DROP COLUMN legacy_product_key;
    PRINT('Column legacy_product_key dropped.');
END
ELSE
BEGIN
    PRINT('No legacy_product_key column found.');
END;
