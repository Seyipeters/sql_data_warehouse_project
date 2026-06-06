CREATE OR ALTER PROCEDURE bronze.load_bronze
	@base_data_path NVARCHAR(4000)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @start_time DATETIME2;
	DECLARE @end_time DATETIME2;
	DECLARE @batch_start_time DATETIME2;
	DECLARE @batch_end_time DATETIME2;
	DECLARE @sql NVARCHAR(MAX);

	IF @base_data_path IS NULL OR LTRIM(RTRIM(@base_data_path)) = ''
	BEGIN
		THROW 50001, 'A base data path is required. Example: C:\repo\sql_data_warehouse_project\datasets', 1;
	END;

	SET @base_data_path = REPLACE(@base_data_path, '/', '\\');
	IF RIGHT(@base_data_path, 1) = '\\'
	BEGIN
		SET @base_data_path = LEFT(@base_data_path, LEN(@base_data_path) - 1);
	END;

	BEGIN TRY
		SET @batch_start_time = GETDATE();
		PRINT '================================================';
		PRINT 'Loading Bronze Layer';
		PRINT '================================================';

		PRINT '------------------------------------------------';
		PRINT 'Loading CRM Tables';
		PRINT '------------------------------------------------';

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.crm_cust_info';
		TRUNCATE TABLE bronze.crm_cust_info;
		SET @sql = N'BULK INSERT bronze.crm_cust_info FROM '''
			+ REPLACE(@base_data_path + '\source_crm\cust_info.csv', '''', '''''')
			+ N''' WITH (FIRSTROW = 2, FIELDTERMINATOR = '','', ROWTERMINATOR = ''0x0a'', TABLOCK, CODEPAGE = ''65001'');';
		EXEC sp_executesql @sql;
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(20)) + ' seconds';
		PRINT '>> -------------';

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.crm_prd_info';
		TRUNCATE TABLE bronze.crm_prd_info;
		SET @sql = N'BULK INSERT bronze.crm_prd_info FROM '''
			+ REPLACE(@base_data_path + '\source_crm\prd_info.csv', '''', '''''')
			+ N''' WITH (FIRSTROW = 2, FIELDTERMINATOR = '','', ROWTERMINATOR = ''0x0a'', TABLOCK, CODEPAGE = ''65001'');';
		EXEC sp_executesql @sql;
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(20)) + ' seconds';
		PRINT '>> -------------';

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.crm_sales_details';
		TRUNCATE TABLE bronze.crm_sales_details;
		SET @sql = N'BULK INSERT bronze.crm_sales_details FROM '''
			+ REPLACE(@base_data_path + '\source_crm\sales_details.csv', '''', '''''')
			+ N''' WITH (FIRSTROW = 2, FIELDTERMINATOR = '','', ROWTERMINATOR = ''0x0a'', TABLOCK, CODEPAGE = ''65001'');';
		EXEC sp_executesql @sql;
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(20)) + ' seconds';
		PRINT '>> -------------';

		PRINT '------------------------------------------------';
		PRINT 'Loading ERP Tables';
		PRINT '------------------------------------------------';

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.erp_loc_a101';
		TRUNCATE TABLE bronze.erp_loc_a101;
		SET @sql = N'BULK INSERT bronze.erp_loc_a101 FROM '''
			+ REPLACE(@base_data_path + '\source_erp\loc_a101.csv', '''', '''''')
			+ N''' WITH (FIRSTROW = 2, FIELDTERMINATOR = '','', ROWTERMINATOR = ''0x0a'', TABLOCK, CODEPAGE = ''65001'');';
		EXEC sp_executesql @sql;
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(20)) + ' seconds';
		PRINT '>> -------------';

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.erp_cust_az12';
		TRUNCATE TABLE bronze.erp_cust_az12;
		SET @sql = N'BULK INSERT bronze.erp_cust_az12 FROM '''
			+ REPLACE(@base_data_path + '\source_erp\cust_az12.csv', '''', '''''')
			+ N''' WITH (FIRSTROW = 2, FIELDTERMINATOR = '','', ROWTERMINATOR = ''0x0a'', TABLOCK, CODEPAGE = ''65001'');';
		EXEC sp_executesql @sql;
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(20)) + ' seconds';
		PRINT '>> -------------';

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.erp_px_cat_g1v2';
		TRUNCATE TABLE bronze.erp_px_cat_g1v2;
		SET @sql = N'BULK INSERT bronze.erp_px_cat_g1v2 FROM '''
			+ REPLACE(@base_data_path + '\source_erp\px_cat_g1v2.csv', '''', '''''')
			+ N''' WITH (FIRSTROW = 2, FIELDTERMINATOR = '','', ROWTERMINATOR = ''0x0a'', TABLOCK, CODEPAGE = ''65001'');';
		EXEC sp_executesql @sql;
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(20)) + ' seconds';
		PRINT '>> -------------';

		SET @batch_end_time = GETDATE();
		PRINT '==========================================';
		PRINT 'Loading Bronze Layer is Completed';
		PRINT '   - Total Load Duration: ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR(20)) + ' seconds';
		PRINT '==========================================';
	END TRY
	BEGIN CATCH
		PRINT '==========================================';
		PRINT 'ERROR OCCURRED DURING LOADING BRONZE LAYER';
		PRINT 'Error Message: ' + ERROR_MESSAGE();
		PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS NVARCHAR(20));
		PRINT 'Error State: ' + CAST(ERROR_STATE() AS NVARCHAR(20));
		PRINT '==========================================';
		THROW;
	END CATCH;
END;
GO
