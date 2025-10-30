--=================================================================================
-- FUNCTION: dbo.TrimSpaces
-- Purpose : Removes leading and trailing spaces from NVARCHAR input.
--=================================================================================
IF OBJECT_ID('dbo.TrimSpaces', 'FN') IS NOT NULL
    DROP FUNCTION dbo.TrimSpaces;
-- GO

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
-- GO


--=================================================================================
-- FUNCTION: dbo.CleanProductName
-- Purpose : Cleans legacy product names by:
--           - Trimming spaces
--           - Keeping only text before ',' or '-'
--           - Returning 'N/A' for NULL or empty input
--=================================================================================
IF OBJECT_ID('dbo.CleanProductName', 'FN') IS NOT NULL
    DROP FUNCTION dbo.CleanProductName;
-- GO

CREATE FUNCTION dbo.CleanProductName (@Input NVARCHAR(255))
RETURNS NVARCHAR(255)
AS
BEGIN
    DECLARE @Clean NVARCHAR(255);

    -- Handle NULL or empty input
    IF @Input IS NULL OR LTRIM(RTRIM(@Input)) = ''
        RETURN N'N/A';

    SET @Clean = LTRIM(RTRIM(@Input));

    -- Take text before first comma, if any
    IF CHARINDEX(',', @Clean) > 0
        SET @Clean = LEFT(@Clean, CHARINDEX(',', @Clean) - 1);

    -- Take text before first dash, if any (if earlier than comma or no comma)
    IF CHARINDEX('-', @Clean) > 0
        SET @Clean = LEFT(@Clean, CHARINDEX('-', @Clean) - 1);

    -- Final trim and fallback
    SET @Clean = LTRIM(RTRIM(@Clean));
    IF @Clean = '' SET @Clean = N'N/A';

    RETURN @Clean;
END;
-- GO