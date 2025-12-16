USE AdventureWorks;
GO

SELECT
(
    SELECT
        PM.product_master_id       AS _id,
        PM.model                  AS model,
        PM.description            AS description,

        PC.name                   AS category,
        PSC.name                  AS subcategory,
        PL.name                   AS product_line,
        PCL.name                  AS class,

        (
            SELECT
                PV.product_variant_id      AS variant_id,
                PV.variant_name,
                COL.name                   AS color,
                PS.name                    AS style,
                PV.size,
                SR.name                    AS size_range,
                PV.size_unit_measure_code,
                PV.weight,
                PV.weight_unit_measure_code,
                PV.standard_cost,
                PV.list_price,
                PV.dealer_price,
                PV.days_to_manufacture,
                PV.safety_stock_level,
                PV.finished_goods_flag
            FROM dbo.ProductVariant PV
            LEFT JOIN dbo.ProductColor COL       ON PV.color_id = COL.color_id
            LEFT JOIN dbo.ProductStyle PS        ON PV.style_id = PS.style_id
            LEFT JOIN dbo.ProductSizeRange SR    ON PV.size_range_id = SR.size_range_id
            WHERE PV.product_master_id = PM.product_master_id
            FOR JSON PATH
        ) AS variants

    FROM dbo.ProductMaster PM
    LEFT JOIN dbo.ProductCategory PC     ON PM.category_id = PC.category_id
    LEFT JOIN dbo.ProductSubcategory PSC ON PM.subcategory_id = PSC.subcategory_id
    LEFT JOIN dbo.ProductLine PL         ON PM.product_line_id = PL.product_line_id
    LEFT JOIN dbo.ProductClass PCL       ON PM.class_id = PCL.class_id

    WHERE PM.model IS NOT NULL

    FOR JSON PATH
) AS products_json;
GO