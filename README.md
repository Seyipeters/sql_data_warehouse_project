# Data Warehouse and Analytics Project

An end-to-end SQL Server data warehouse portfolio project built around a medallion architecture and a star-schema analytics model.

## What this project demonstrates

- bronze ingestion from raw CRM and ERP CSV files
- silver-layer data cleansing and standardization
- gold-layer dimensional modeling for analytics
- validation queries for row counts, date quality, and referential integrity

This repository is designed to be runnable on a local SQL Server instance with the sample data included in the repo.

## Architecture

The warehouse follows a three-layer pattern:

1. `bronze`: raw source ingestion into SQL Server tables
2. `silver`: cleaned and standardized operational tables
3. `gold`: analytics-ready star schema with customer and product dimensions plus a sales fact table

## Tech stack

- SQL Server
- T-SQL stored procedures
- `sqlcmd` for orchestration and validation

## Repository structure

```text
sql_data_warehouse_project/
├── datasets/
│   ├── source_crm/
│   │   ├── cust_info.csv
│   │   ├── prd_info.csv
│   │   └── sales_details.csv
│   └── source_erp/
│       ├── cust_az12.csv
│       ├── loc_a101.csv
│       └── px_cat_g1v2.csv
├── docs/
│   └── requirements.md
├── scripts/
│   ├── bronze/
│   │   ├── ddl_bronze.sql
│   │   └── proc_load_bronze.sql
│   ├── silver/
│   │   ├── ddl_silver.sql
│   │   └── proc_load_silver.sql
│   ├── gold/
│   │   ├── ddl_gold.sql
│   │   └── proc_load_gold.sql
│   ├── init_database.sql
│   └── run_pipeline.sql
├── tests/
│   └── validation_queries.sql
├── LICENSE
└── README.md
```

## Data model

The gold layer contains:

- `gold.dim_customers`
- `gold.dim_products`
- `gold.fact_sales`

The model supports basic sales analysis by customer geography and product category.

## How to run

### Prerequisites

- a reachable local SQL Server instance
- `sqlcmd` installed and on your path

### Option 1: run the full pipeline with one command

1. Open [scripts/run_pipeline.sql](/Users/Omole Peter/sql_data_warehouse_project/scripts/run_pipeline.sql)
2. Update the `DataPath` variable so it points to your local `datasets` directory
3. Run:

```powershell
sqlcmd -i .\scripts\run_pipeline.sql
```

### Option 2: run the scripts step by step

```powershell
sqlcmd -i .\scripts\init_database.sql
sqlcmd -d DataWarehouse -i .\scripts\bronze\ddl_bronze.sql
sqlcmd -d DataWarehouse -i .\scripts\silver\ddl_silver.sql
sqlcmd -d DataWarehouse -i .\scripts\gold\ddl_gold.sql
sqlcmd -d DataWarehouse -i .\scripts\bronze\proc_load_bronze.sql
sqlcmd -d DataWarehouse -Q "EXEC bronze.load_bronze @base_data_path = 'C:\path\to\sql_data_warehouse_project\datasets';"
sqlcmd -d DataWarehouse -i .\scripts\silver\proc_load_silver.sql
sqlcmd -d DataWarehouse -Q "EXEC silver.load_silver;"
sqlcmd -d DataWarehouse -i .\scripts\gold\proc_load_gold.sql
sqlcmd -d DataWarehouse -Q "EXEC gold.load_gold;"
sqlcmd -d DataWarehouse -i .\tests\validation_queries.sql
```

## Sample validation output

After a successful run, the included sample data should produce:

- 5 customer rows in `gold.dim_customers`
- 4 product rows in `gold.dim_products`
- 6 sales rows in `gold.fact_sales`
- 0 invalid sales dates in silver
- 0 orphan fact rows in gold

## Why this is a strong portfolio project

- It shows layered warehouse design rather than a single flat script.
- It includes both ingestion and transformation logic.
- It uses reusable stored procedures and validation queries.
- It is self-contained, so a reviewer can run it without hidden local files.

## License

This project is licensed under the [MIT License](LICENSE).


