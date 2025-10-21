/**
Plano de trabalho para projecto CBD
*/



# Ideias, questoes, migraçao

1. Normalizar medidas

Devemos normalizar tamanhos (ex: converter peso em Kg, medidas a CM)?? No momento como está desenhado e como vi na internet devemos manter o valor original, 
temos sempre maneira de normalizar com a coluna 'ConversionToBase'.

2. Criar uma tabela de comparação (DOCUMENTACAO)

Devemos criar uma tabela, documentar, a mapear as "colunas" do CSV para a nova Tabela(s) colunas, ajuda a entender o que foi feito.?

3. Importação CSV não funcionou.

4. Migrar dados NULL

Muitas colunas têm diversos dados NULL, temos de ter atenção e desenvolver uma estratégia para os importar.
Converter em algo?

5. Limpar productos 

Muitos produtos parecem ser os mesmo, a diferença está no nome.. 
Fazer algo quanto a isto?

6. Sales colunas que nao entendo

TotalSalesAmount (possivelmente preco total para esse produto? a venda nao inclui quantas unidades foram vendidas.. sera que conseguimos calcular com base no preco unitario e este total?)

7. Encriptacao / Hashing

Password: Utilizar um algoritmo irreversivel
NIF: Enciptar, como?
Perguntas e respostas para recuperar passord: Utilizar HASH256 possibilidat recuperar.


# Conjuntos de Entidades

#---------------------------------------------------------------------------------
                                    PRODUCTS
#---------------------------------------------------------------------------------

### Product
**Representa um produto disponível**
- `ProductID`
- `ProductNameID` (FK → ProductNames)
- `ModelID` (FK → ProductModels)
- `ColorID` (FK → ProductColors)
- `CategoryID` (FK → ProductCategory)
- `SubcategoryID` (FK → SubCategory)
- `ProductLineID` (FK → ProductLine)
- `ClassID` (FK → ProductClass)
- `StyleID` (FK → ProductStyle)
- `Size` [TEXT *some have numbers other letters, 38/L/M/S...]
- `SizeRangeID` (FK → ProductSizeRange)
- `SizeUnitMeasureCode` (FK → UnitOfMeasure)
- `WeightUnitMeasureCode` (FK → UnitOfMeasure)
- `Weight`
- `FinishedGoodsFlag`
- `StandardCost`
- `ListPrice`
- `DealerPrice`
- `DaysToManufacture`
- `Description`

### ProductNames
**Representa os nomes dos produtos.**
- `ProductNameID`
- `Name` (ex.: “HL Road Frame - Black”)

### ProductModels
**Representa o modelo de um produto.**
- `ModelID`
- `Name` (ex.: “HL Road Frame”)

### ProductColors
**Representa a cor de um produto.**
- `ColorID`
- `Name` (ex.: “Black”)

### ProductCategory (Fazer uma tabela com referencia a ela propria???)
**Representa a categoria do produto.**
- `CategoryID`
- `Name` (ex.: “Components”)

### SubCategory
**Representa a subcategoria de um produto.**
- `SubcategoryID`
- `CategoryID` (FK → ProductCategory)
- `Name` (ex.: “Frames”)

### ProductLine
**Representa a linha do produto.**
- `ProductLineID`
- `Name` (ex.: “R”)

### ProductClass
**Representa a classe do produto.**
- `ClassID`
- `Name` (ex.: “H”)

### ProductStyle
**Representa o estilo do produto.**
- `StyleID`
- `Name` (ex.: “U”)

### ProductSizeRange
**Representa a gama de tamanhos de um produto.**
- `SizeRangeID`
- `Name` (ex.: “54-58 CM”)

### UnitOfMeasure
**Representa as unidades de medida.**
- `Code` (ex.: LB, CM)
- `Name` (ex.: Pounds, Centimeters)
- `ConversionToBase` (ex.: 0.453592 para LB → kg)


#---------------------------------------------------------------------------------
                                    SALES
#---------------------------------------------------------------------------------

### SalesOrder
**Representa uma venda.**
- `SalesOrderID` (PK, surrogate key)
- `SalesOrderNumber` (ex.: SO43697)
- `CustomerID` (FK → Customer)
- `SalesTerritoryID` (FK → SalesTerritory)
- `OrderDate` (ex.: 2010-12-29)
- `DueDate` (ex.: 2011-01-10)
- `ShipDate` (ex.: 2011-01-05)

### SalesOrderLine
**Representa um produto dentro de um pedido.**
- `SalesOrderLineID` (PK, surrogate key)
- `SalesOrderID` (FK → SalesOrder)
- `LineNumber` (ex.: 1)
- `ProductID` (FK → Product)
- `CurrencyID` (FK → Currency)
- `ProductStandardCost` (ex.: 2171.29)
- `UnitPrice` (ex.: 3578.27)
- `Quantity` (ex.: 1)
- `TotalSalesAmount` (ex.: 3578.27) !!! Para cortar, substituir com quantidade
- `TaxAmt` (ex.: 286.26)
- `Freight` (ex.: 89.46)


### SalesTerritory
**Representa uma região ou território de vendas.**
- `SalesTerritoryID`
- `Name` (ex.: Northwest)
- `Region` (opcional)

### Currency
**Representa a moeda usada nas transações.**
- `CurrencyID`
- `Code` (ex.: USD, EUR)
- `Name` (ex.: United States Dollar)

#---------------------------------------------------------------------------------
                                    CUSTOMER
#---------------------------------------------------------------------------------

### Customer
**Representa um cliente.**
- `CustomerID` (PK, surrogate key)
- `Title` (ex.: “Mr.”)
- `FirstName` (ex.: “Jon”)
- `MiddleName` (ex.: “V”)
- `LastName` (ex.: “Yang”)
- `BirthDate` (ex.: 1966-04-08)
- `MaritalStatus` (ex.: M, S)
- `Gender` (ex.: M, F)
- `EmailAddress` (ex.: jon24@adventure-works.com)
- `YearlyIncome` (ex.: 90000)
- `Education` (ex.: Bachelors)
- `Occupation` (ex.: Professional)
- `NumberCarsOwned` (ex.: 0)
- `DateFirstPurchase` (ex.: 2005-07-22)
- `PasswordHash` (ex.: pbkdf2$sha256$95830$b9c64076aacb75de)
- `NIF` (ex.: 269192666)

### CustomerAddress
**Representa o endereço do cliente.**
- `CustomerAddressID` (PK, surrogate key)
- `CustomerID` (FK → Customer)
- `AddressLine1` (ex.: 3761 N. 14th St)
- `City` (ex.: Rockhampton)
- `StateProvinceID` (FK → StateProvince)
- `PostalCode` (ex.: 4700)
- `CountryID` (FK → CountryRegion)
- `Phone` (ex.: 1 (11) 500 555-0162)

### StateProvince
**Representa estados ou províncias de um país.**
- `StateProvinceID` (PK)
- `Code` (ex.: QLD)
- `Name` (ex.: Queensland)
- `CountryID` (FK → CountryRegion)

### CountryRegion
**Representa um país ou região.**
- `CountryID` (PK)
- `Code` (ex.: AU)
- `Name` (ex.: Australia)

#---------------------------------------------------------------------------------
                                    CUSTOMER
#---------------------------------------------------------------------------------

### AppUser
**Representa um utilizador da aplicação (cliente ou administrativo).**
- `AppUserID` (PK)
- `CustomerID` (FK → Customer, opcional se for um cliente)
- `Email` (ex.: jon24@adventure-works.com)
- `PasswordHash` (ex.: pbkdf2$sha256$95830$b9c64076aacb75de)
- `IsActive` (bool, ex.: True/False)
- `CreatedAt` (timestamp)
- `LastLogin` (timestamp)

### PasswordRecoveryQuestion
**Pergunta de segurança para recuperação de password.**
- `QuestionID` (PK)
- `AppUserID` (FK → AppUser)
- `QuestionText` (ex.: “Qual é o nome da sua primeira escola?”)
- `AnswerHash` (hashed resposta do utilizador)

### SentEmails
**Simula envio de emails.**
- `SentEmailID` (PK)
- `RecipientEmail` (ex.: jon24@adventure-works.com)
- `Subject` (ex.: “Nova password gerada”)
- `Message` (ex.: “Sua nova password é …”)
- `SentAt` (timestamp)


## Conjuntos de Relacionamentos & Restrições

#---------------------------------------------------------------------------------
                                    PRODUCTS
#---------------------------------------------------------------------------------

---

### Product_ProductName (N:1)
- Um **Product** “tem” um **ProductName**.  
- **1 ProductName** pode estar associado a **N Products** *(participação parcial)*.  
- **1 Product** tem **sempre 1 ProductName** *(participação total)*.

---

### Product_ProductModel (N:1)
- Um **Product** “pertence a” um **ProductModel**.  
- **1 ProductModel** pode estar associado a **N Products** *(participação parcial)*.  
- **1 Product** tem **sempre 1 ProductModel** *(participação total)*.

---

### Product_ProductColor (N:1)
- Um **Product** “tem” uma **cor**.  
- **1 ProductColor** pode ser usada por **N Products** *(participação parcial)*.  
- **1 Product** pode **não ter cor** *(participação parcial)*.

---

### ProductCategory_SubCategory (1:N)
- Uma **ProductCategory** “possui” várias **SubCategories**.  
- **1 ProductCategory** pode ter **N SubCategories** *(participação parcial)*.  
- **1 SubCategory** pertence **sempre** a **1 ProductCategory** *(participação total)*.

---

### SubCategory_Product (1:N)
- Uma **SubCategory** “contém” vários **Products**.  
- **1 SubCategory** pode ter **N Products** *(participação parcial)*.  
- **1 Product** pertence **sempre** a **1 SubCategory** *(participação total)*.

---

### Product_ProductLine (N:1)
- Um **Product** “pertence a” uma **ProductLine**.  
- **1 ProductLine** pode ter **N Products** *(participação parcial)*.  
- **1 Product** pode **não ter ProductLine** *(participação parcial)*.

---

### Product_ProductClass (N:1)
- Um **Product** “pertence a” uma **ProductClass**.  
- **1 ProductClass** pode ter **N Products** *(participação parcial)*.  
- **1 Product** pode **não ter ProductClass** *(participação parcial)*.

---

### Product_ProductStyle (N:1)
- Um **Product** “possui” um **ProductStyle**.  
- **1 ProductStyle** pode estar associado a **N Products** *(participação parcial)*.  
- **1 Product** pode **não ter ProductStyle** *(participação parcial)*.

---

### Product_ProductSizeRange (N:1)
- Um **Product** “tem” um **ProductSizeRange**.  
- **1 ProductSizeRange** pode estar associado a **N Products** *(participação parcial)*.  
- **1 Product** pode **não ter SizeRange** *(participação parcial)*.

---

### Product_UnitOfMeasure (N:1)
- Um **Product** “utiliza” unidades de medida (peso e tamanho).  
- **1 UnitOfMeasure** pode ser usada em **N Products** *(participação parcial)*.  
- **1 Product** pode **não ter unidade definida** *(participação parcial)*.

---

#---------------------------------------------------------------------------------
                                    SALES
#---------------------------------------------------------------------------------

### SalesOrder_SalesOrderLine (1:N)
- Um **SalesOrder** “contém” várias **SalesOrderLines**.  
- **1 SalesOrder** tem **N SalesOrderLines** *(participação total)*.  
- **1 SalesOrderLine** pertence **sempre** a **1 SalesOrder** *(participação total)*.

---

### SalesOrderLine_Product (N:1)
- Uma **SalesOrderLine** “refere-se a” um **Product**.  
- **1 Product** pode aparecer em **N SalesOrderLines** *(participação parcial)*.  
- **1 SalesOrderLine** refere-se **sempre** a **1 Product** *(participação total)*.

---

### SalesOrder_Customer (N:1)
- Um **SalesOrder** “é feito por” um **Customer**.  
- **1 Customer** pode ter **N SalesOrders** *(participação parcial)*.  
- **1 SalesOrder** pertence **sempre** a **1 Customer** *(participação total)*.

---

### SalesOrder_SalesTerritory (N:1)
- Um **SalesOrder** “ocorre em” um **SalesTerritory**.  
- **1 SalesTerritory** pode estar associado a **N SalesOrders** *(participação parcial)*.  
- **1 SalesOrder** pertence **sempre** a **1 SalesTerritory** *(participação total)*.

---

### SalesOrderLine_Currency (N:1)
- Uma **SalesOrderLine** “é faturada em” uma **Currency**.  
- **1 Currency** pode estar associada a **N SalesOrderLines** *(participação parcial)*.  
- **1 SalesOrderLine** usa **sempre 1 Currency** *(participação total)*.

---

#---------------------------------------------------------------------------------
                                    CUSTOMER
#---------------------------------------------------------------------------------

### Customer_CustomerAddress (1:N)
- Um **Customer** “pode ter” vários **CustomerAddresses**.  
- **1 Customer** pode ter **N Endereços** *(participação parcial)*.  
- **1 CustomerAddress** pertence **sempre** a **1 Customer** *(participação total)*.

---

### CustomerAddress_StateProvince (N:1)
- Um **CustomerAddress** “pertence a” um **StateProvince**.  
- **1 StateProvince** pode ter **N Endereços** *(participação parcial)*.  
- **1 CustomerAddress** pertence **sempre** a **1 StateProvince** *(participação total)*.

---

### StateProvince_CountryRegion (N:1)
- Um **StateProvince** “pertence a” um **CountryRegion**.  
- **1 CountryRegion** pode conter **N StateProvinces** *(participação parcial)*.  
- **1 StateProvince** pertence **sempre** a **1 CountryRegion** *(participação total)*.

---

### Customer_SalesTerritory (N:1)
- Um **Customer** “está associado a” um **SalesTerritory**.  
- **1 SalesTerritory** pode ter **N Customers** *(participação parcial)*.  
- **1 Customer** pertence **sempre** a **1 SalesTerritory** *(participação total)*.

---

### AppUser_Customer (1:1)
- Um **AppUser** “pode estar associado a” um **Customer**.  
- **1 Customer** pode ter **no máximo 1 AppUser** *(participação parcial)*.  
- **1 AppUser** pode **não ter Customer** *(participação parcial)*.

---

### AppUser_PasswordRecoveryQuestion (1:1)
- Um **AppUser** “tem” uma **PasswordRecoveryQuestion**.  
- **1 AppUser** tem **no máximo 1 questão** *(participação parcial)*.  
- **1 PasswordRecoveryQuestion** pertence **sempre** a **1 AppUser** *(participação total)*.

---

### AppUser_SentEmails (1:N)
- Um **AppUser** “pode enviar” vários **SentEmails**.  
- **1 AppUser** pode ter **N emails enviados** *(participação parcial)*.  
- **1 SentEmail** pertence **sempre** a **1 AppUser** *(participação total)*.


# 5. Modelo relacional

#---------------------------------------------------------------------------------
#                                   PRODUCTS
#---------------------------------------------------------------------------------

`Product`(
    product_id,
    product_name_id,
    model_id,
    color_id,
    category_id,
    subcategory_id,
    product_line_id,
    class_id,
    style_id,
    size,
    size_range_id,
    size_unit_code,
    weight_unit_code,
    weight,
    finished_goods_flag,
    standard_cost,
    list_price,
    dealer_price,
    days_to_manufacture,
    description
)
Chave primaria: {product_id}
Chave estrangeira:
{product_name_id} → product_name {product_name_id}
{model_id} → product_model {model_id}
{color_id} → product_color {color_id}
{category_id} → product_category {category_id}
{subcategory_id} → product_subcategory {subcategory_id}
{product_line_id} → product_line {product_line_id}
{class_id} → product_class {class_id}
{style_id} → product_style {style_id}
{size_range_id} → product_size_range {size_range_id}
{size_unit_code} → unit_of_measure {code}
{weight_unit_code} → unit_of_measure {code}

`ProductName`(
    product_name_id,
    name
)
Chave primaria: {product_name_id}

`ProductModel`(
    model_id,
    name
)
Chave primaria: {model_id}

`ProductColor`(
    color_id,
    name
)
Chave primaria: {color_id}

`ProductCategory`(
    category_id,
    name
)
Chave primaria: {category_id}

`ProductSubcategory`(
    subcategory_id,
    category_id,
    name
)
Chave primaria: {subcategory_id}
Chave estrangeira:
{category_id} → product_category {category_id}

`ProductLine`(
    product_line_id,
    name
)
Chave primaria: {product_line_id}

`ProductClass`(
    class_id,
    name
)
Chave primaria: {class_id}

`ProductStyle`(
    style_id,
    name
)
Chave primaria: {style_id}

`ProductSizeRange`(
    size_range_id,
    name
)
Chave primaria: {size_range_id}

`UnitOfMeasure`(
    code,
    name,
    conversion_to_base
)
Chave primaria: {code}

#---------------------------------------------------------------------------------
#                                   SALES
#---------------------------------------------------------------------------------

`SalesOrder`(
    sales_order_id,
    sales_order_number,
    customer_id,
    sales_territory_id,
    order_date,
    due_date,
    ship_date
)
Chave primaria: {sales_order_id}
Chave estrangeira:
{customer_id} → Customer {customer_id}
{sales_territory_id} → SalesTerritory {sales_territory_id}

`SalesOrderLine`(
    sales_order_line_id,
    sales_order_id,
    line_number,
    product_id,
    currency_id,
    product_standard_cost,
    unit_price,
    quantity,
    total_sales_amount,
    tax_amt,
    freight
)
Chave primaria: {sales_order_line_id}
Chave estrangeira:
{sales_order_id} → SalesOrder {sales_order_id}
{product_id} → Product {product_id}
{currency_id} → Currency {currency_id}

`SalesTerritory`(
    sales_territory_id,
    name,
    region
)
Chave primaria: {sales_territory_id}

`Currency`(
    currency_id,
    code,
    name
)
Chave primaria: {currency_id}

#---------------------------------------------------------------------------------
#                                   CUSTOMERS
#---------------------------------------------------------------------------------

`Customer`(
    customer_id,
    title,
    first_name,
    middle_name,
    last_name,
    birth_date,
    marital_status,
    gender,
    email_address,
    yearly_income,
    education,
    occupation,
    number_cars_owned,
    date_first_purchase,
    password_hash,
    nif
)
Chave primaria: {customer_id}

`CustomerAddress`(
    customer_address_id,
    customer_id,
    address_line1,
    city,
    state_province_id,
    postal_code,
    country_id,
    phone
)
Chave primaria: {customer_address_id}
Chave estrangeira:
{customer_id} → Customer {customer_id}
{state_province_id} → StateProvince {state_province_id}
{country_id} → CountryRegion {country_id}

`StateProvince`(
    state_province_id,
    code,
    name,
    country_id
)
Chave primaria: {state_province_id}
Chave estrangeira:
{country_id} → CountryRegion {country_id}

`CountryRegion`(
    country_id,
    code,
    name
)
Chave primaria: {country_id}

`AppUser`(
    app_user_id,
    customer_id,
    email,
    password_hash,
    is_active,
    created_at,
    last_login
)
Chave primaria: {app_user_id}
Chave estrangeira:
{customer_id} → Customer {customer_id}

`PasswordRecoveryQuestion`(
    question_id,
    app_user_id,
    question_text,
    answer_hash
)
Chave primaria: {question_id}
Chave estrangeira:
{app_user_id} → AppUser {app_user_id}

`SentEmails`(
    sent_email_id,
    recipient_email,
    subject,
    message,
    sent_at
)
Chave primaria: {sent_email_id}