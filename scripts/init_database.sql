
USE master;
GO
-- create the 'DataWarehouse' database
CREATE DATABASE DataWarehouse;
USE DataWarehouse;

-- Create the three layers
CREATE schema bronze;
CREATE schema silver;
create schema gold;
