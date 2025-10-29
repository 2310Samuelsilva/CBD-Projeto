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
#                                   PRODUCTS
#---------------------------------------------------------------------------------

### ProductMaster
**Representa o produto base (ex.: “HL Touring Frame”)**
- `product_master_id` (PK)
- `product_name` (ex.: “HL Touring Frame”)  ← stored directly
- `model` (ex.: “HL Touring Frame”)         ← stored directly
- `category_id` (FK → ProductCategory)
- `subcategory_id` (FK → ProductSubcategory)
- `product_line_id` (FK → ProductLine, opcional)
- `class_id` (FK → ProductClass, opcional)
- `style_id` (FK → ProductStyle, opcional)
- `description` (ex.: “The HL aluminum frame is custom-shaped for strength and durability.”)

---

### ProductVariant
**Representa uma variação específica de um produto (cor, tamanho, peso, preço).**
- `product_variant_id` (PK)
- `product_master_id` (FK → ProductMaster)
- `color_id` (FK → ProductColors, opcional)
- `size` (ex.: 'S', 'L', '60')
- `size_range_id` (FK → ProductSizeRange, opcional)
- `size_unit_measure_code` (FK → UnitOfMeasure, opcional)
- `weight` (DECIMAL, ex.: 3.08, opcional)
- `weight_unit_measure_code` (FK → UnitOfMeasure, opcional)
- `finished_goods_flag` (BIT)
- `standard_cost` (DECIMAL(10,2))
- `list_price` (DECIMAL(10,2))
- `dealer_price` (DECIMAL(10,2))
- `days_to_manufacture` (INT)

---

### ProductColors
**Representa a cor de um produto.**
- `color_id` (PK)
- `name` (ex.: “Blue”, “Yellow”)

---

### ProductCategory
**Representa a categoria do produto.**
- `category_id` (PK)
- `name` (ex.: “Components”)

---

### ProductSubcategory
**Representa a subcategoria de um produto.**
- `subcategory_id` (PK)
- `category_id` (FK → ProductCategory)
- `name` (ex.: “Frames”)

---

### ProductLine
**Representa a linha do produto.**
- `product_line_id` (PK)
- `name` (ex.: “T”)

---

### ProductClass
**Representa a classe do produto.**
- `class_id` (PK)
- `name` (ex.: “H”)

---

### ProductStyle
**Representa o estilo do produto.**
- `style_id` (PK)
- `name` (ex.: “U”)

---

### ProductSizeRange
**Representa a gama de tamanhos de um produto.**
- `size_range_id` (PK)
- `name` (ex.: “60-62 CM”)

---

### UnitOfMeasure
**Representa as unidades de medida.**
- `unit_measure_code` (PK)
- `name` (ex.: “Pounds”, “Centimeters”)
- `conversion_to_base` (DECIMAL(10,6), ex.: 0.453592 para LB → KG)



#---------------------------------------------------------------------------------
#                                   SALES
#---------------------------------------------------------------------------------

### SalesOrder
**Representa uma venda (pedido principal).**
- `sales_order_id` (PK, surrogate key)
- `sales_order_number` (ex.: 'SO43697')
- `customer_id` (FK → Customer)
- `sales_territory_id` (FK → SalesTerritory)
- `order_date` (DATE, ex.: 2010-12-29)
- `due_date` (DATE, ex.: 2011-01-10)
- `ship_date` (DATE, ex.: 2011-01-05)

---

### SalesOrderLine
**Representa uma variação de produto vendida dentro de um pedido.**
- `sales_order_line_id` (PK, surrogate key)
- `sales_order_id` (FK → SalesOrder)
- `line_number` (INT, ex.: 1)
- `product_variant_id` (FK → ProductVariant)
- `currency_id` (FK → Currency)
- `product_standard_cost` (DECIMAL(10,2), ex.: 2171.29)
- `unit_price` (DECIMAL(10,2), ex.: 3578.27)
- `quantity` (INT, ex.: 1)
- `tax_amt` (DECIMAL(10,2), ex.: 286.26)
- `freight` (DECIMAL(10,2), ex.: 89.46)

> 💡 `total_sales_amount` foi removido — pode ser calculado dinamicamente como `(unit_price * quantity)`.

---

### SalesTerritory
**Representa uma região ou território de vendas.**
- `sales_territory_id` (PK)
- `name` (NVARCHAR(100), ex.: “Northwest”)
- `region` (NVARCHAR(100), opcional)

---

### Currency
**Representa a moeda usada nas transações.**
- `currency_id` (PK)
- `code` (NVARCHAR(10), ex.: “USD”, “EUR”)
- `name` (NVARCHAR(50), ex.: “United States Dollar”)

---



#---------------------------------------------------------------------------------
#                                   CUSTOMER
#---------------------------------------------------------------------------------

### Customer
**Representa um cliente.**
- `customer_id` (PK, surrogate key)
- `title` (NVARCHAR(20), ex.: “Mr.”)
- `first_name` (NVARCHAR(50), ex.: “Jon”)
- `middle_name` (NVARCHAR(50), ex.: “V”)
- `last_name` (NVARCHAR(50), ex.: “Yang”)
- `birth_date` (DATE, ex.: 1966-04-08)
- `marital_status` (CHAR(1), ex.: M, S)
- `gender` (CHAR(1), NULL – opcional conforme regra do grupo)
- `email_address` (NVARCHAR(100), ex.: jon24@adventure-works.com)
- `yearly_income` (DECIMAL(10,2), ex.: 90000)
- `education` (NVARCHAR(50), ex.: “Bachelors”)
- `occupation` (NVARCHAR(50), ex.: “Professional”)
- `number_cars_owned` (INT, ex.: 0)
- `date_first_purchase` (DATE, ex.: 2005-07-22)
- `nif` (NVARCHAR(20), armazenado **encriptado**)

> 🔒 **Campos sensíveis:**  
> - `nif` → armazenado encriptado (AES, Chave simétrica).  

---

### CustomerAddress
**Representa o endereço de um cliente.**
- `customer_address_id` (PK, surrogate key)
- `customer_id` (FK → Customer)
- `address_line1` (NVARCHAR(255), ex.: 3761 N. 14th St)
- `city` (NVARCHAR(100), ex.: Rockhampton)
- `state_province_id` (FK → StateProvince)
- `postal_code` (NVARCHAR(20), ex.: 4700)
- `country_id` (FK → CountryRegion)
- `phone` (NVARCHAR(50), ex.: 1 (11) 500 555-0162)

---

### StateProvince
**Representa um estado ou província.**
- `state_province_id` (PK)
- `code` (NVARCHAR(10), ex.: QLD)
- `name` (NVARCHAR(100), ex.: Queensland)
- `country_id` (FK → CountryRegion)

---

### CountryRegion
**Representa um país ou região.**
- `country_id` (PK)
- `code` (NVARCHAR(10), ex.: AU)
- `name` (NVARCHAR(100), ex.: Australia)

---

#---------------------------------------------------------------------------------
#                                   APP USERS
#---------------------------------------------------------------------------------

### AppUser
**Representa um utilizador da aplicação (cliente ou administrativo).**
- `app_user_id` (PK)
- `customer_id` (FK → Customer, opcional)
- `email` (NVARCHAR(100), único)
- `password_hash` (NVARCHAR(255), **hash irreversível**)
- `is_active` (BIT DEFAULT 1)
- `created_at` (DATETIME DEFAULT GETDATE())
- `last_login` (DATETIME)

> 🔒 **Campos sensíveis:**  
> - `password_hash` → armazenado com hash (ex.: PBKDF2, bcrypt). 

---

### PasswordRecoveryQuestion
**Pergunta de segurança para recuperação de password.**
- `question_id` (PK)
- `app_user_id` (FK → AppUser)
- `question_text` (NVARCHAR(255), ex.: “Qual é o nome da sua primeira escola?”)
- `answer_hash` (NVARCHAR(255), armazenada com **hash ou ofuscação reversível**)

> 🔒 **Segurança:**  
> - `answer_hash` deve ser **ofuscado** (pode ser revertido em texto claro se necessário).  
> - `password_hash` nunca deve ser recuperável (apenas comparável via hash).

---

### SentEmails
**Simula envio de emails.**
- `sent_email_id` (PK)
- `recipient_email` (NVARCHAR(100), ex.: jon24@adventure-works.com)
- `subject` (NVARCHAR(255), ex.: “Nova password gerada”)
- `message` (NVARCHAR(MAX), ex.: “Sua nova password é …”)
- `sent_at` (DATETIME DEFAULT GETDATE())

---


## Conjuntos de Relacionamentos & Restrições - FIXED

#---------------------------------------------------------------------------------
#                                   PRODUCTS
#---------------------------------------------------------------------------------

### ProductMaster_ProductVariant (1:N)
- Um **ProductMaster** “possui” várias **ProductVariants**.  
- **1 ProductMaster** pode ter **N ProductVariants** *(participação total)*.  
- **1 ProductVariant** pertence **sempre** a **1 ProductMaster** *(participação total)*.

---

### ProductMaster_ProductCategory (N:1)
- Um **ProductMaster** “pertence a” uma **ProductCategory**.  
- **1 ProductCategory** pode conter **N ProductMasters** *(participação parcial)*.  
- **1 ProductMaster** pertence **sempre** a **1 ProductCategory** *(participação total)*.

---

### ProductCategory_SubCategory (1:N)
- Uma **ProductCategory** “possui” várias **ProductSubcategories**.  
- **1 ProductCategory** pode ter **N ProductSubcategories** *(participação total)*.  
- **1 ProductSubcategory** pertence **sempre** a **1 ProductCategory** *(participação total)*.

---

### ProductSubcategory_ProductMaster (1:N)
- Uma **ProductSubcategory** “contém” vários **ProductMasters**.  
- **1 ProductSubcategory** pode ter **N ProductMasters** *(participação parcial)*.  
- **1 ProductMaster** pertence **sempre** a **1 ProductSubcategory** *(participação total)*.

---

### ProductVariant_ProductColor (N:1)
- Um **ProductVariant** “tem” uma **ProductColor**.  
- **1 ProductColor** pode ser usada por **N ProductVariants** *(participação parcial)*.  
- **1 ProductVariant** pode **não ter cor** *(participação parcial)*.

---

### ProductVariant_ProductLine (N:1)
- Um **ProductVariant** “pertence a” uma **ProductLine**.  
- **1 ProductLine** pode ter **N ProductVariants** *(participação parcial)*.  
- **1 ProductVariant** pode **não ter ProductLine** *(participação parcial)*.

---

### ProductVariant_ProductClass (N:1)
- Um **ProductVariant** “pertence a” uma **ProductClass**.  
- **1 ProductClass** pode ter **N ProductVariants** *(participação parcial)*.  
- **1 ProductVariant** pode **não ter ProductClass** *(participação parcial)*.

---

### ProductVariant_ProductStyle (N:1)
- Um **ProductVariant** “possui” um **ProductStyle**.  
- **1 ProductStyle** pode estar associado a **N ProductVariants** *(participação parcial)*.  
- **1 ProductVariant** pode **não ter ProductStyle** *(participação parcial)*.

---

### ProductVariant_ProductSizeRange (N:1)
- Um **ProductVariant** “tem” um **ProductSizeRange**.  
- **1 ProductSizeRange** pode estar associado a **N ProductVariants** *(participação parcial)*.  
- **1 ProductVariant** pode **não ter SizeRange** *(participação parcial)*.

---

### ProductVariant_UnitOfMeasure (N:1)
- Um **ProductVariant** “utiliza” unidades de medida (peso e tamanho).  
- **1 UnitOfMeasure** pode ser usada em **N ProductVariants** *(participação parcial)*.  
- **1 ProductVariant** pode **não ter unidade definida** *(participação parcial)*.

---

#---------------------------------------------------------------------------------
#                                   SALES
#---------------------------------------------------------------------------------

### SalesOrder_SalesOrderLine (1:N)
- Um **SalesOrder** “contém” várias **SalesOrderLines**.  
- **1 SalesOrder** tem **N SalesOrderLines** *(participação total)*.  
- **1 SalesOrderLine** pertence **sempre** a **1 SalesOrder** *(participação total)*.

---

### SalesOrderLine_ProductVariant (N:1)
- Uma **SalesOrderLine** “refere-se a” um **ProductVariant**.  
- **1 ProductVariant** pode aparecer em **N SalesOrderLines** *(participação parcial)*.  
- **1 SalesOrderLine** refere-se **sempre** a **1 ProductVariant** *(participação total)*.

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
#                                   CUSTOMER
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

#---------------------------------------------------------------------------------
#                                   APP USERS
#---------------------------------------------------------------------------------

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


# 5. Modelo Relacional

##---------------------------------------------------------------------------------
#                                   PRODUCTS
##---------------------------------------------------------------------------------

`ProductMaster`(
    product_master_id,
    product_name,
    model,
    category_id,
    subcategory_id,
    product_line_id,
    class_id,
    style_id,
    description
)
Chave primária: {product_master_id}
Chaves estrangeiras:
{category_id} → ProductCategory {category_id}
{subcategory_id} → ProductSubcategory {subcategory_id}
{product_line_id} → ProductLine {product_line_id}
{class_id} → ProductClass {class_id}
{style_id} → ProductStyle {style_id}

---

`ProductVariant`(
    product_variant_id,
    product_master_id,
    color_id,
    size,
    size_range_id,
    size_unit_measure_code,
    weight,
    weight_unit_measure_code,
    finished_goods_flag,
    standard_cost,
    list_price,
    dealer_price,
    days_to_manufacture
)
Chave primária: {product_variant_id}
Chaves estrangeiras:
{product_master_id} → ProductMaster {product_master_id}
{color_id} → ProductColors {color_id}
{size_range_id} → ProductSizeRange {size_range_id}
{size_unit_measure_code} → UnitOfMeasure {unit_measure_code}
{weight_unit_measure_code} → UnitOfMeasure {unit_measure_code}

---

`ProductColors`(
    color_id,
    name
)
Chave primária: {color_id}

---

`ProductCategory`(
    category_id,
    name
)
Chave primária: {category_id}

---

`ProductSubcategory`(
    subcategory_id,
    category_id,
    name
)
Chave primária: {subcategory_id}
Chave estrangeira:
{category_id} → ProductCategory {category_id}

---

`ProductLine`(
    product_line_id,
    name
)
Chave primária: {product_line_id}

---

`ProductClass`(
    class_id,
    name
)
Chave primária: {class_id}

---

`ProductStyle`(
    style_id,
    name
)
Chave primária: {style_id}

---

`ProductSizeRange`(
    size_range_id,
    name
)
Chave primária: {size_range_id}

---

`UnitOfMeasure`(
    unit_measure_code,
    name,
    conversion_to_base
)
Chave primária: {unit_measure_code}

---

##---------------------------------------------------------------------------------
#                                   SALES
##---------------------------------------------------------------------------------

`SalesOrder`(
    sales_order_id,
    sales_order_number,
    customer_id,
    sales_territory_id,
    order_date,
    due_date,
    ship_date
)
Chave primária: {sales_order_id}
Chaves estrangeiras:
{customer_id} → Customer {customer_id}
{sales_territory_id} → SalesTerritory {sales_territory_id}

---

`SalesOrderLine`(
    sales_order_line_id,
    sales_order_id,
    line_number,
    product_variant_id,
    currency_id,
    product_standard_cost,
    unit_price,
    quantity,
    tax_amt,
    freight
)
Chave primária: {sales_order_line_id}
Chaves estrangeiras:
{sales_order_id} → SalesOrder {sales_order_id}
{product_variant_id} → ProductVariant {product_variant_id}
{currency_id} → Currency {currency_id}

---

`SalesTerritory`(
    sales_territory_id,
    name,
    region
)
Chave primária: {sales_territory_id}

---

`Currency`(
    currency_id,
    code,
    name
)
Chave primária: {currency_id}

---

##---------------------------------------------------------------------------------
#                                   CUSTOMERS
##---------------------------------------------------------------------------------

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
    nif
)
Chave primária: {customer_id}

---

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
Chave primária: {customer_address_id}
Chaves estrangeiras:
{customer_id} → Customer {customer_id}
{state_province_id} → StateProvince {state_province_id}
{country_id} → CountryRegion {country_id}

---

`StateProvince`(
    state_province_id,
    code,
    name,
    country_id
)
Chave primária: {state_province_id}
Chave estrangeira:
{country_id} → CountryRegion {country_id}

---

`CountryRegion`(
    country_id,
    code,
    name
)
Chave primária: {country_id}

---

##---------------------------------------------------------------------------------
#                                   APP USERS
##---------------------------------------------------------------------------------

`AppUser`(
    app_user_id,
    customer_id,
    email,
    password_hash,
    is_active,
    created_at,
    last_login
)
Chave primária: {app_user_id}
Chave estrangeira:
{customer_id} → Customer {customer_id}

---

`PasswordRecoveryQuestion`(
    question_id,
    app_user_id,
    question_text,
    answer_hash
)
Chave primária: {question_id}
Chave estrangeira:
{app_user_id} → AppUser {app_user_id}

---

`SentEmails`(
    sent_email_id,
    recipient_email,
    subject,
    message,
    sent_at
)
Chave primária: {sent_email_id}



## Migration 

Notes: Removed category_id from product sub category