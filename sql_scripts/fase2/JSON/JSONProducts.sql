USE AdventureWorks;
GO

SELECT
    pv.product_variant_id,
    pm.model,
    pv.variant_name,
    pc.name AS category,
    pv.list_price,
    pv.standard_cost,
    pv.finished_goods_flag
FROM dbo.ProductVariant pv
JOIN dbo.ProductMaster pm ON pm.product_master_id = pv.product_master_id
LEFT JOIN dbo.ProductCategory pc ON pc.category_id = pm.category_id
FOR JSON PATH;
GO