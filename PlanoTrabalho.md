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



Encriptar: https://www.geeksforgeeks.org/sql/sql-data-encryption/
Hash: https://blog.sqlauthority.com/2023/10/20/sql-server-best-practices-for-securely-storing-passwords/



# Conjuntos de Entidades

#---------------------------------------------------------------------------------
#                                   PRODUCTS
#---------------------------------------------------------------------------------

### ProductMaster
**Representa o produto base (ex.: “HL Touring Frame”)**
- `product_master_id` (PK)
- `product_name` (ex.: “HL Touring Frame”)
- `model` (ex.: “HL Touring Frame”)
- `category_id` (FK → ProductCategory)
- `subcategory_id` (FK → ProductSubcategory)
- `product_line_id` (FK → ProductLine, opcional)
- `class_id` (FK → ProductClass, opcional)
- `description` (ex.: “The HL aluminum frame is custom-shaped for strength and durability.”)

---

### ProductVariant
**Representa uma variação específica de um produto (cor, tamanho, peso, preço).**
- `product_variant_id` (PK)
- `product_master_id` (FK → ProductMaster)
- `variant_name` (ex.: “HL Touring Frame – Red”)
- `color_id` (FK → ProductColor, opcional)
- `style_id` (FK → ProductStyle, opcional)
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
- `safety_stock_level` (INT)

---

### ProductColor
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

---

#---------------------------------------------------------------------------------
#                                   CUSTOMERS
#---------------------------------------------------------------------------------

### Customer
**Representa um cliente.**
- `customer_id` (PK)
- `title` (ex.: “Mr.”)
- `first_name` (ex.: “Jon”)
- `middle_name` (ex.: “V”)
- `last_name` (ex.: “Yang”)
- `birth_date` (DATE)
- `marital_status` (CHAR(1))
- `gender` (CHAR(1), opcional)
- `email_address` (NVARCHAR(100))
- `yearly_income` (DECIMAL(10,2))
- `education` (NVARCHAR(50))
- `occupation` (NVARCHAR(50))
- `number_cars_owned` (INT)
- `date_first_purchase` (DATE)
- `nif` (NVARCHAR(20), armazenado **encriptado**)

---

### CustomerAddress
**Representa o endereço de um cliente.**
- `customer_address_id` (PK)
- `customer_id` (FK → Customer)
- `address_line1` (NVARCHAR(255))
- `city` (NVARCHAR(100))
- `state_province_id` (FK → StateProvince)
- `postal_code` (NVARCHAR(20))
- `country_id` (FK → CountryRegion)
- `phone` (NVARCHAR(50))

---

### StateProvince
**Representa um estado ou província.**
- `state_province_id` (PK)
- `code` (NVARCHAR(10))
- `name` (NVARCHAR(100))
- `country_id` (FK → CountryRegion)

---

### CountryRegion
**Representa um país ou região.**
- `country_id` (PK)
- `code` (NVARCHAR(10))
- `name` (NVARCHAR(100))

---

#---------------------------------------------------------------------------------
#                                   SALES
#---------------------------------------------------------------------------------

### SalesOrder
**Representa uma venda (pedido principal).**
- `sales_order_id` (PK)
- `sales_order_number` (NVARCHAR(50))
- `customer_id` (FK → Customer)
- `sales_territory_id` (FK → SalesTerritory)
- `order_date` (DATE)
- `currency_id` (FK → Currency)
- `due_date` (DATE)
- `ship_date` (DATE)

---

### SalesOrderLine
**Representa uma variação de produto vendida dentro de um pedido.**
- `sales_order_line_id` (PK)
- `sales_order_id` (FK → SalesOrder)
- `line_number` (INT)
- `product_variant_id` (FK → ProductVariant)
- `product_standard_cost` (DECIMAL(10,2))
- `unit_price` (DECIMAL(10,2))
- `quantity` (INT)
- `tax_amt` (DECIMAL(10,2))
- `freight` (DECIMAL(10,2))

---

### SalesTerritory
**Representa uma região ou território de vendas.**
- `sales_territory_id` (PK)
- `region` (NVARCHAR(100))
- `country_region_id` (FK → CountryRegion)
- `territory_group` (NVARCHAR(100), opcional)

---

### Currency
**Representa a moeda usada nas transações.**
- `currency_id` (PK)
- `code` (NVARCHAR(10))
- `name` (NVARCHAR(50))

---

#---------------------------------------------------------------------------------
#                                   APP USERS
#---------------------------------------------------------------------------------

### AppUser
**Representa um utilizador da aplicação (cliente ou administrativo).**
- `app_user_id` (PK)
- `customer_id` (FK → Customer, opcional)
- `email` (NVARCHAR(100))
- `password_hash` (NVARCHAR(255))
- `is_active` (BIT DEFAULT 1)
- `created_at` (DATETIME DEFAULT GETDATE())
- `last_login` (DATETIME)

---

### PasswordRecoveryQuestion
**Pergunta de segurança para recuperação de password.**
- `question_id` (PK)
- `app_user_id` (FK → AppUser)
- `question_text` (NVARCHAR(255))
- `answer_hash` (NVARCHAR(255))

---

### SentEmails
**Simula envio de emails.**
- `sent_email_id` (PK)
- `recipient_email` (NVARCHAR(100))
- `subject` (NVARCHAR(255))
- `message` (NVARCHAR(MAX))
- `sent_at` (DATETIME DEFAULT GETDATE())


# Conjuntos de Relacionamentos & Restrições

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

### ProductMaster_ProductSubcategory (N:1)
- Um **ProductMaster** “pertence a” uma **ProductSubcategory**.  
- **1 ProductSubcategory** pode ter **N ProductMasters** *(participação parcial)*.  
- **1 ProductMaster** pertence **sempre** a **1 ProductSubcategory** *(participação total)*.

---

### ProductVariant_ProductColor (N:1)
- Um **ProductVariant** “tem” uma **ProductColor**.  
- **1 ProductColor** pode ser usada por **N ProductVariants** *(participação parcial)*.  
- **1 ProductVariant** pode **não ter cor** *(participação parcial)*.

---

### ProductVariant_ProductStyle (N:1)
- Um **ProductVariant** “tem” um **ProductStyle**.  
- **1 ProductStyle** pode estar associado a **N ProductVariants** *(participação parcial)*.  
- **1 ProductVariant** pode **não ter estilo** *(participação parcial)*.

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
#                                   CUSTOMERS
#---------------------------------------------------------------------------------

### Customer_CustomerAddress (1:N)
- Um **Customer** “pode ter” vários **CustomerAddresses**.  
- **1 Customer** pode ter **N endereços** *(participação parcial)*.  
- **1 CustomerAddress** pertence **sempre** a **1 Customer** *(participação total)*.

---

### CustomerAddress_StateProvince (N:1)
- Um **CustomerAddress** “pertence a” um **StateProvince**.  
- **1 StateProvince** pode ter **N CustomerAddresses** *(participação parcial)*.  
- **1 CustomerAddress** pertence **sempre** a **1 StateProvince** *(participação total)*.

---

### CustomerAddress_CountryRegion (N:1)
- Um **CustomerAddress** “pertence a” um **CountryRegion**.  
- **1 CountryRegion** pode ter **N CustomerAddresses** *(participação parcial)*.  
- **1 CustomerAddress** pertence **sempre** a **1 CountryRegion** *(participação total)*.

---

### StateProvince_CountryRegion (N:1)
- Um **StateProvince** “pertence a” um **CountryRegion**.  
- **1 CountryRegion** pode ter **N StateProvinces** *(participação parcial)*.  
- **1 StateProvince** pertence **sempre** a **1 CountryRegion** *(participação total)*.

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

# 5. Modelo Relacional (Atualizado ao Create DB)

##---------------------------------------------------------------------------------
#                                   PRODUCTS
##---------------------------------------------------------------------------------

`ProductColor`(
    color_id,
    name
)
- Chave primária: {color_id}

---

`ProductCategory`(
    category_id,
    name
)
- Chave primária: {category_id}

---

`ProductSubcategory`(
    subcategory_id,
    name
)
- Chave primária: {subcategory_id}

---

`ProductLine`(
    product_line_id,
    name
)
- Chave primária: {product_line_id}

---

`ProductClass`(
    class_id,
    name
)
- Chave primária: {class_id}

---

`ProductStyle`(
    style_id,
    name
)
- Chave primária: {style_id}

---

`ProductSizeRange`(
    size_range_id,
    name
)
- Chave primária: {size_range_id}

---

`UnitOfMeasure`(
    unit_measure_code,
    name,
    conversion_to_base
)
- Chave primária: {unit_measure_code}

---

`ProductMaster`(
    product_master_id,
    product_name,
    model,
    category_id,
    subcategory_id,
    product_line_id,
    class_id,
    description
)
- Chave primária: {product_master_id}
- Chaves estrangeiras:
  - {category_id} → ProductCategory {category_id}
  - {subcategory_id} → ProductSubcategory {subcategory_id}
  - {product_line_id} → ProductLine {product_line_id}
  - {class_id} → ProductClass {class_id}

---

`ProductVariant`(
    product_variant_id,
    product_master_id,
    variant_name,
    color_id,
    style_id,
    size,
    size_range_id,
    size_unit_measure_code,
    weight,
    weight_unit_measure_code,
    finished_goods_flag,
    standard_cost,
    list_price,
    dealer_price,
    days_to_manufacture,
    safety_stock_level
)
- Chave primária: {product_variant_id}
- Chaves estrangeiras:
  - {product_master_id} → ProductMaster {product_master_id}
  - {color_id} → ProductColor {color_id}
  - {style_id} → ProductStyle {style_id}
  - {size_range_id} → ProductSizeRange {size_range_id}
  - {size_unit_measure_code} → UnitOfMeasure {unit_measure_code}
  - {weight_unit_measure_code} → UnitOfMeasure {unit_measure_code}


##---------------------------------------------------------------------------------
#                                   CUSTOMERS
##---------------------------------------------------------------------------------

`CountryRegion`(
    country_id,
    code,
    name
)
- Chave primária: {country_id}

---

`StateProvince`(
    state_province_id,
    code,
    name,
    country_id
)
- Chave primária: {state_province_id}
- Chave estrangeira:
  - {country_id} → CountryRegion {country_id}

---

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
- Chave primária: {customer_id}

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
- Chave primária: {customer_address_id}
- Chaves estrangeiras:
  - {customer_id} → Customer {customer_id}
  - {state_province_id} → StateProvince {state_province_id}
  - {country_id} → CountryRegion {country_id}


##---------------------------------------------------------------------------------
#                                   SALES
##---------------------------------------------------------------------------------

`SalesTerritory`(
    sales_territory_id,
    region,
    country_region_id,
    territory_group
)
- Chave primária: {sales_territory_id}
- Chave estrangeira:
  - {country_region_id} → CountryRegion {country_id}

---

`Currency`(
    currency_id,
    code,
    name
)
- Chave primária: {currency_id}

---

`SalesOrder`(
    sales_order_id,
    sales_order_number,
    customer_id,
    sales_territory_id,
    currency_id,
    order_date,
    due_date,
    ship_date
)
- Chave primária: {sales_order_id}
- Chaves estrangeiras:
  - {customer_id} → Customer {customer_id}
  - {sales_territory_id} → SalesTerritory {sales_territory_id}
  - {currency_id} → Currency {currency_id}

---

`SalesOrderLine`(
    sales_order_line_id,
    sales_order_id,
    line_number,
    product_variant_id,
    product_standard_cost,
    unit_price,
    quantity,
    tax_amt,
    freight
)
- Chave primária: {sales_order_line_id}
- Chaves estrangeiras:
  - {sales_order_id} → SalesOrder {sales_order_id}
  - {product_variant_id} → ProductVariant {product_variant_id}


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
- Chave primária: {app_user_id}
- Chave estrangeira:
  - {customer_id} → Customer {customer_id}

---

`PasswordRecoveryQuestion`(
    question_id,
    app_user_id,
    question_text,
    answer_hash
)
- Chave primária: {question_id}
- Chave estrangeira:
  - {app_user_id} → AppUser {app_user_id}

---

`SentEmails`(
    sent_email_id,
    recipient_email,
    subject,
    message,
    sent_at
)
- Chave primária: {sent_email_id}



## Migration 

Notes: Removed category_id from product sub category




Migração currency:
- Estava completamente errada pois estava a ir buscar apenas o "ID" à tabela das Sales e não a meter as currencies vindo da tabela legacy.

Migração SalesTerritory:
- Fiz o country referenciar o CountryRegion

Migração Sales:
- Ligação com SaleTerritory não ligava via o novo ID

SALES ORDER LINES
- Falha.. Estava a inserir 800k+ records (apenas existem 60k linhas de vendas).. isto porque o query nao faz mapeamento entre novo id e antigo variante do producto.
- temos de rever


