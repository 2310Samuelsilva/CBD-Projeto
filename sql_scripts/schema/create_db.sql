
--=================================================================================
-- CREATE DATABASE (WITH COLLATION)
--=================================================================================
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'AdventureWorks')
BEGIN
    CREATE DATABASE AdventureWorks COLLATE Latin1_General_CI_AS;;
END
GO


USE AdventureWorks;
GO

--=================================================================================
--                                   PRODUCTS
--=================================================================================

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'ProductColor')
BEGIN
    CREATE TABLE dbo.ProductColor (
        color_id INT IDENTITY(1,1) CONSTRAINT PK_ProductColor PRIMARY KEY,
        name NVARCHAR(50)  NOT NULL
    );
END
GO

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'ProductCategory')
BEGIN
    CREATE TABLE dbo.ProductCategory (
        category_id INT IDENTITY(1,1) CONSTRAINT PK_ProductCategory PRIMARY KEY,
        name NVARCHAR(100)  NOT NULL
    );
END
GO

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'ProductSubcategory')
BEGIN
    CREATE TABLE dbo.ProductSubcategory (
        subcategory_id INT IDENTITY(1,1) CONSTRAINT PK_ProductSubcategory PRIMARY KEY,
        name NVARCHAR(100)  NOT NULL
    );
END
GO

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'ProductLine')
BEGIN
    CREATE TABLE dbo.ProductLine (
        product_line_id INT IDENTITY(1,1) CONSTRAINT PK_ProductLine PRIMARY KEY,
        name NVARCHAR(50)  NOT NULL
    );
END
GO

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'ProductClass')
BEGIN
    CREATE TABLE dbo.ProductClass (
        class_id INT IDENTITY(1,1) CONSTRAINT PK_ProductClass PRIMARY KEY,
        name NVARCHAR(50)  NOT NULL
    );
END
GO

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'ProductStyle')
BEGIN
    CREATE TABLE dbo.ProductStyle (
        style_id INT IDENTITY(1,1) CONSTRAINT PK_ProductStyle PRIMARY KEY,
        name NVARCHAR(50)  NOT NULL
    );
END
GO

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'ProductSizeRange')
BEGIN
    CREATE TABLE dbo.ProductSizeRange (
        size_range_id INT IDENTITY(1,1) CONSTRAINT PK_ProductSizeRange PRIMARY KEY,
        name NVARCHAR(50)  NOT NULL
    );
END
GO

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'UnitOfMeasure')
BEGIN
    CREATE TABLE dbo.UnitOfMeasure (
        unit_measure_code NVARCHAR(10)  CONSTRAINT PK_UnitOfMeasure PRIMARY KEY,
        name NVARCHAR(50)  NOT NULL,
        conversion_to_base DECIMAL(10,6)
    );
END
GO

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'ProductMaster')
BEGIN
    CREATE TABLE dbo.ProductMaster (
        product_master_id INT IDENTITY(1,1) CONSTRAINT PK_ProductMaster PRIMARY KEY,
        product_name NVARCHAR(255),
        model NVARCHAR(255) ,
        category_id INT,
        subcategory_id INT,
        product_line_id INT,
        class_id INT,
        description NVARCHAR(MAX) ,
        CONSTRAINT FK_ProductMaster_ProductCategory FOREIGN KEY (category_id) REFERENCES dbo.ProductCategory(category_id),
        CONSTRAINT FK_ProductMaster_ProductSubcategory FOREIGN KEY (subcategory_id) REFERENCES dbo.ProductSubcategory(subcategory_id),
        CONSTRAINT FK_ProductMaster_ProductLine FOREIGN KEY (product_line_id) REFERENCES dbo.ProductLine(product_line_id),
        CONSTRAINT FK_ProductMaster_ProductClass FOREIGN KEY (class_id) REFERENCES dbo.ProductClass(class_id)
    );
END
GO

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'ProductVariant')
BEGIN
    CREATE TABLE dbo.ProductVariant (
        product_variant_id INT IDENTITY(1,1) CONSTRAINT PK_ProductVariant PRIMARY KEY,
        product_master_id INT NOT NULL,
        variant_name NVARCHAR(255)  NOT NULL,
        color_id INT,
        style_id INT,
        size NVARCHAR(20) ,
        size_range_id INT,
        size_unit_measure_code NVARCHAR(10) ,
        weight DECIMAL(10,2),
        weight_unit_measure_code NVARCHAR(10) ,
        finished_goods_flag BIT DEFAULT 0,
        standard_cost DECIMAL(10,2),
        list_price DECIMAL(10,2),
        dealer_price DECIMAL(10,2),
        days_to_manufacture INT,
        safety_stock_level INT,
        CONSTRAINT FK_ProductVariant_ProductMaster FOREIGN KEY (product_master_id) REFERENCES dbo.ProductMaster(product_master_id),
        CONSTRAINT FK_ProductVariant_ProductColor FOREIGN KEY (color_id) REFERENCES dbo.ProductColor(color_id),
        CONSTRAINT FK_ProductMaster_ProductStyle FOREIGN KEY (style_id) REFERENCES dbo.ProductStyle(style_id),
        CONSTRAINT FK_ProductVariant_ProductSizeRange FOREIGN KEY (size_range_id) REFERENCES dbo.ProductSizeRange(size_range_id),
        CONSTRAINT FK_ProductVariant_SizeUnit FOREIGN KEY (size_unit_measure_code) REFERENCES dbo.UnitOfMeasure(unit_measure_code),
        CONSTRAINT FK_ProductVariant_WeightUnit FOREIGN KEY (weight_unit_measure_code) REFERENCES dbo.UnitOfMeasure(unit_measure_code)
    );
END
GO

--=================================================================================
--                                   CUSTOMER
--=================================================================================

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'CountryRegion')
BEGIN
    CREATE TABLE CountryRegion (
        country_id INT IDENTITY(1,1) CONSTRAINT PK_CountryRegion PRIMARY KEY,
        code NVARCHAR(10),
        name NVARCHAR(100)
    );
END
GO

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'StateProvince')
BEGIN
    CREATE TABLE StateProvince (
        state_province_id INT IDENTITY(1,1) CONSTRAINT PK_StateProvince PRIMARY KEY,
        code NVARCHAR(10),
        name NVARCHAR(100),
        country_id INT,
        CONSTRAINT FK_StateProvince_Country FOREIGN KEY (country_id)
            REFERENCES CountryRegion(country_id)
    );
END
GO

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Customer')
BEGIN
    CREATE TABLE Customer (
        customer_id INT IDENTITY(1,1) CONSTRAINT PK_Customer PRIMARY KEY,
        title NVARCHAR(20),
        first_name NVARCHAR(50),
        middle_name NVARCHAR(50),
        last_name NVARCHAR(50),
        birth_date DATE,
        marital_status CHAR(1),
        gender CHAR(1) NULL,
        email_address NVARCHAR(100),
        yearly_income DECIMAL(10,2),
        education NVARCHAR(50),
        occupation NVARCHAR(50),
        number_cars_owned INT,
        date_first_purchase DATE,
        nif NVARCHAR(20) -- To be encrypted
    );
END
GO

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'CustomerAddress')
BEGIN
    CREATE TABLE CustomerAddress (
        customer_address_id INT IDENTITY(1,1) CONSTRAINT PK_CustomerAddress PRIMARY KEY,
        customer_id INT NOT NULL,
        address_line1 NVARCHAR(255),
        city NVARCHAR(100),
        state_province_id INT,
        postal_code NVARCHAR(20),
        country_id INT,
        phone NVARCHAR(50),
        CONSTRAINT FK_CustomerAddress_Customer FOREIGN KEY (customer_id) REFERENCES Customer(customer_id),
        CONSTRAINT FK_CustomerAddress_StateProvince FOREIGN KEY (state_province_id) REFERENCES StateProvince(state_province_id),
        CONSTRAINT FK_CustomerAddress_Country FOREIGN KEY (country_id) REFERENCES CountryRegion(country_id)
    );
END
GO

--=================================================================================
--                                   SALES
--=================================================================================

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'SalesTerritory')
BEGIN
    CREATE TABLE dbo.SalesTerritory (
        sales_territory_id INT IDENTITY(1,1) CONSTRAINT PK_SalesTerritory PRIMARY KEY,
        region NVARCHAR(100) NOT NULL,
        country_region_id INT NOT NULL,
        territory_group NVARCHAR(100) NULL,
        CONSTRAINT FK_SalesTerritory_Country FOREIGN KEY (country_region_id) REFERENCES dbo.CountryRegion(country_id)
    );
END
GO

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Currency')
BEGIN
    CREATE TABLE Currency (
        currency_id INT IDENTITY(1,1) CONSTRAINT PK_Currency PRIMARY KEY,
        code NVARCHAR(10),
        name NVARCHAR(50)
    );
END
GO

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'SalesOrder')
BEGIN
    CREATE TABLE SalesOrder (
        sales_order_id INT IDENTITY(1,1) CONSTRAINT PK_SalesOrder PRIMARY KEY,
        sales_order_number NVARCHAR(50) NOT NULL,
        customer_id INT NOT NULL,
        sales_territory_id INT,
        order_date DATE,
        due_date DATE,
        ship_date DATE,
        CONSTRAINT FK_SalesOrder_Customer FOREIGN KEY (customer_id) REFERENCES Customer(customer_id),
        CONSTRAINT FK_SalesOrder_SalesTerritory FOREIGN KEY (sales_territory_id) REFERENCES SalesTerritory(sales_territory_id)
    );
END
GO

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'SalesOrderLine')
BEGIN
    CREATE TABLE SalesOrderLine (
        sales_order_line_id INT IDENTITY(1,1) CONSTRAINT PK_SalesOrderLine PRIMARY KEY,
        sales_order_id INT NOT NULL,
        line_number INT,
        product_variant_id INT NOT NULL,
        currency_id INT,
        product_standard_cost DECIMAL(10,2),
        unit_price DECIMAL(10,2),
        quantity INT,
        tax_amt DECIMAL(10,2),
        freight DECIMAL(10,2),
        CONSTRAINT FK_SalesOrderLine_SalesOrder FOREIGN KEY (sales_order_id) REFERENCES SalesOrder(sales_order_id),
        CONSTRAINT FK_SalesOrderLine_ProductVariant FOREIGN KEY (product_variant_id) REFERENCES ProductVariant(product_variant_id),
        CONSTRAINT FK_SalesOrderLine_Currency FOREIGN KEY (currency_id) REFERENCES Currency(currency_id)
    );
END
GO

--=================================================================================
--                                   APP USERS
--=================================================================================

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'AppUser')
BEGIN
    CREATE TABLE dbo.AppUser (
        app_user_id INT IDENTITY(1,1) CONSTRAINT PK_AppUser PRIMARY KEY,
        customer_id INT NULL,
        email NVARCHAR(100) NOT NULL UNIQUE,
        password_hash VARBINARY(32) NOT NULL,  -- SHA2_256 output (32 bytes)
        is_active BIT DEFAULT 1,
        created_at DATETIME DEFAULT GETDATE(),
        last_login DATETIME NULL,
        CONSTRAINT FK_AppUser_Customer FOREIGN KEY (customer_id) REFERENCES dbo.Customer(customer_id)
    );
END
--GO

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'PasswordRecoveryQuestion')
BEGIN
    CREATE TABLE dbo.PasswordRecoveryQuestion (
        question_id INT IDENTITY(1,1) CONSTRAINT PK_PasswordRecoveryQuestion PRIMARY KEY,
        app_user_id INT NOT NULL,
        question_text NVARCHAR(255) NOT NULL,
        answer_hash VARBINARY(32) NOT NULL,  -- SHA2_256 hash for obfuscation
        CONSTRAINT FK_PasswordRecoveryQuestion_AppUser FOREIGN KEY (app_user_id) REFERENCES dbo.AppUser(app_user_id)
    );
END
--GO

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'SentEmails')
BEGIN
    CREATE TABLE dbo.SentEmails (
        sent_email_id INT IDENTITY(1,1) CONSTRAINT PK_SentEmails PRIMARY KEY,
        recipient_email NVARCHAR(100) NOT NULL,
        subject NVARCHAR(255) NOT NULL,
        message NVARCHAR(MAX) NOT NULL,
        sent_at DATETIME DEFAULT GETDATE()
    );
END
--GO