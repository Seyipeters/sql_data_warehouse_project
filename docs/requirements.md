# Project Requirements

## Objective

Build a self-contained SQL Server warehouse demo that shows:

- raw source ingestion into a bronze layer
- standardized cleansing into a silver layer
- star-schema analytics tables in a gold layer
- validation queries that confirm the end-to-end load worked

## Functional Scope

The completed project should:

1. create the `DataWarehouse` database and required schemas
2. load sample CRM and ERP CSV files into bronze tables
3. standardize customer, product, sales, and reference data in silver tables
4. model customer and product dimensions plus a sales fact table in gold
5. provide queries that verify row counts and basic referential integrity

## Non-Functional Scope

- scripts should be idempotent where practical
- the source data path should be configurable
- the repository should be runnable on a local SQL Server instance without hidden files