--=================================================================================
-- FUNCTION: dbo.TrimSpaces
-- Purpose : Removes leading and trailing spaces from NVARCHAR input.
--=================================================================================
IF OBJECT_ID('dbo.TrimSpaces', 'FN') IS NOT NULL
    DROP FUNCTION dbo.TrimSpaces;
GO

CREATE FUNCTION dbo.TrimSpaces (@Input NVARCHAR(MAX))
RETURNS NVARCHAR(MAX)
AS
BEGIN
    RETURN (
        CASE 
            WHEN @Input IS NULL THEN NULL
            ELSE LTRIM(RTRIM(@Input))
        END
    );
END;
GO



--=================================================================================
-- FUNCTION: dbo.ComputeHash
-- Description: Computes SHA2_256 hash for a given NVARCHAR input text.
--=================================================================================
IF OBJECT_ID('dbo.ComputeHash', 'FN') IS NOT NULL
    DROP FUNCTION dbo.ComputeHash;
GO

CREATE FUNCTION dbo.ComputeHash (@input NVARCHAR(MAX))
RETURNS VARBINARY(32)
AS
BEGIN
    -- Return NULL if input is NULL
    IF @input IS NULL 
        RETURN NULL;

    RETURN HASHBYTES('SHA2_256', @input);
END;
GO