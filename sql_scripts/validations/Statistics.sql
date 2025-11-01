USE AdventureWorks;
GO

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'dbStatistics')
BEGIN
    CREATE TABLE dbo.dbStatistics (
        stat_id INT IDENTITY(1,1) PRIMARY KEY,
        table_name NVARCHAR(255) NOT NULL,
        record_count BIGINT,
        reserved_space_kb DECIMAL(18,2),
        data_space_kb DECIMAL(18,2),
        index_size_kb DECIMAL(18,2),
        unused_space_kb DECIMAL(18,2),
        collected_at DATETIME DEFAULT GETDATE()
    );
    PRINT('Tabela dbStatistics criada com sucesso.');
END
ELSE
    PRINT('Tabela dbStatistics já existe.');
GO


IF OBJECT_ID('dbo.sp_dbstatistics', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_dbstatistics;
GO

CREATE PROCEDURE dbo.sp_dbstatistics
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @table_name NVARCHAR(255);
    DECLARE @sql NVARCHAR(MAX);

    -- Tabela temporária para armazenar resultados intermédios
    CREATE TABLE #tmpStats (
        name NVARCHAR(255),
        rows BIGINT,
        reserved NVARCHAR(50),
        data NVARCHAR(50),
        index_size NVARCHAR(50),
        unused NVARCHAR(50)
    );

    -- Cursor para percorrer todas as tabelas do schema dbo
    DECLARE table_cursor CURSOR FOR
    SELECT name FROM sys.tables WHERE type = 'U';

    OPEN table_cursor;
    FETCH NEXT FROM table_cursor INTO @table_name;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Limpar tabela temporária
        DELETE FROM #tmpStats;

        -- Executar sp_spaceused para cada tabela
        SET @sql = 'INSERT INTO #tmpStats EXEC sp_spaceused [' + @table_name + ']';
        EXEC (@sql);

        -- Inserir resultados na tabela principal
        INSERT INTO dbo.dbStatistics (
            table_name,
            record_count,
            reserved_space_kb,
            data_space_kb,
            index_size_kb,
            unused_space_kb,
            collected_at
        )
        SELECT
            @table_name,
            rows,
            CONVERT(DECIMAL(18,2), REPLACE(reserved, ' KB', '')),
            CONVERT(DECIMAL(18,2), REPLACE(data, ' KB', '')),
            CONVERT(DECIMAL(18,2), REPLACE(index_size, ' KB', '')),
            CONVERT(DECIMAL(18,2), REPLACE(unused, ' KB', '')),
            GETDATE()
        FROM #tmpStats;

        FETCH NEXT FROM table_cursor INTO @table_name;
    END

    CLOSE table_cursor;
    DEALLOCATE table_cursor;

    DROP TABLE #tmpStats;

    PRINT('Estatísticas recolhidas com sucesso e registadas em dbStatistics.');
END
GO

EXEC dbo.sp_dbstatistics;

SELECT * 
FROM dbo.dbStatistics 
ORDER BY collected_at DESC, table_name;