:setvar DataPath "C:\path\to\sql_data_warehouse_project\datasets"

:r .\scripts\init_database.sql
GO

USE DataWarehouse;
GO

:r .\scripts\bronze\ddl_bronze.sql
:r .\scripts\silver\ddl_silver.sql
:r .\scripts\gold\ddl_gold.sql
:r .\scripts\bronze\proc_load_bronze.sql
:r .\scripts\silver\proc_load_silver.sql
:r .\scripts\gold\proc_load_gold.sql
GO

EXEC bronze.load_bronze @base_data_path = '$(DataPath)';
GO
EXEC silver.load_silver;
GO
EXEC gold.load_gold;
GO

:r .\tests\validation_queries.sql