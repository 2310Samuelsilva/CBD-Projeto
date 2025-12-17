
USE AdventureWorks;
GO


-- JSON limpo para exportação

SELECT
(
    SELECT TOP 2
    customer_id AS _id,
    email_address,
    first_name,
    last_name,
    birth_date,
    number_cars_owned
FROM dbo.Customer
WHERE email_address IS NOT NULL
FOR JSON AUTO, ROOT('customers')) AS test;  
GO

