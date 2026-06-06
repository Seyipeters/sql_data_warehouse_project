/*
===============================================================================
DDL Script: Create Gold Tables
===============================================================================
Script Purpose:
    This script creates the dimensional model used for analytics.
===============================================================================
*/

IF OBJECT_ID('gold.fact_sales', 'U') IS NOT NULL
    DROP TABLE gold.fact_sales;
GO

IF OBJECT_ID('gold.dim_products', 'U') IS NOT NULL
    DROP TABLE gold.dim_products;
GO

IF OBJECT_ID('gold.dim_customers', 'U') IS NOT NULL
    DROP TABLE gold.dim_customers;
GO

CREATE TABLE gold.dim_customers (
    customer_key      INT IDENTITY(1, 1) PRIMARY KEY,
    customer_id       INT NOT NULL,
    customer_code     NVARCHAR(50) NOT NULL,
    first_name        NVARCHAR(50) NOT NULL,
    last_name         NVARCHAR(50) NOT NULL,
    marital_status    NVARCHAR(50) NOT NULL,
    gender            NVARCHAR(50) NOT NULL,
    birth_date        DATE NULL,
    country           NVARCHAR(50) NOT NULL,
    customer_created  DATE NULL,
    dwh_create_date   DATETIME2 NOT NULL DEFAULT GETDATE()
);
GO

CREATE TABLE gold.dim_products (
    product_key       INT IDENTITY(1, 1) PRIMARY KEY,
    product_id        INT NOT NULL,
    product_code      NVARCHAR(50) NOT NULL,
    product_name      NVARCHAR(50) NOT NULL,
    category_id       NVARCHAR(50) NOT NULL,
    category          NVARCHAR(50) NOT NULL,
    subcategory       NVARCHAR(50) NOT NULL,
    product_line      NVARCHAR(50) NOT NULL,
    maintenance       NVARCHAR(50) NOT NULL,
    product_cost      INT NOT NULL,
    start_date        DATE NULL,
    end_date          DATE NULL,
    dwh_create_date   DATETIME2 NOT NULL DEFAULT GETDATE()
);
GO

CREATE TABLE gold.fact_sales (
    sales_key         INT IDENTITY(1, 1) PRIMARY KEY,
    order_number      NVARCHAR(50) NOT NULL,
    customer_key      INT NOT NULL,
    product_key       INT NOT NULL,
    order_date        DATE NULL,
    ship_date         DATE NULL,
    due_date          DATE NULL,
    sales_amount      INT NOT NULL,
    quantity          INT NOT NULL,
    unit_price        INT NOT NULL,
    dwh_create_date   DATETIME2 NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_fact_sales_customer FOREIGN KEY (customer_key) REFERENCES gold.dim_customers(customer_key),
    CONSTRAINT FK_fact_sales_product FOREIGN KEY (product_key) REFERENCES gold.dim_products(product_key)
);
GO