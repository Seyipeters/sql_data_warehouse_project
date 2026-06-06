CREATE OR ALTER PROCEDURE silver.load_silver
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        PRINT '================================================';
        PRINT 'Loading Silver Layer';
        PRINT '================================================';

        TRUNCATE TABLE silver.crm_cust_info;
        INSERT INTO silver.crm_cust_info (
            cst_id,
            cst_key,
            cst_firstname,
            cst_lastname,
            cst_marital_status,
            cst_gndr,
            cst_create_date
        )
        SELECT
            cst_id,
            LTRIM(RTRIM(cst_key)),
            LTRIM(RTRIM(cst_firstname)),
            LTRIM(RTRIM(cst_lastname)),
            CASE UPPER(LTRIM(RTRIM(cst_marital_status)))
                WHEN 'S' THEN 'Single'
                WHEN 'M' THEN 'Married'
                ELSE 'Unknown'
            END,
            CASE UPPER(LTRIM(RTRIM(cst_gndr)))
                WHEN 'F' THEN 'Female'
                WHEN 'M' THEN 'Male'
                ELSE 'Unknown'
            END,
            cst_create_date
        FROM bronze.crm_cust_info;

        TRUNCATE TABLE silver.crm_prd_info;
        INSERT INTO silver.crm_prd_info (
            prd_id,
            cat_id,
            prd_key,
            prd_nm,
            prd_cost,
            prd_line,
            prd_start_dt,
            prd_end_dt
        )
        SELECT
            prd_id,
            LEFT(LTRIM(RTRIM(prd_key)), CHARINDEX('-', LTRIM(RTRIM(prd_key)) + '-') - 1),
            LTRIM(RTRIM(prd_key)),
            LTRIM(RTRIM(prd_nm)),
            prd_cost,
            UPPER(LTRIM(RTRIM(prd_line))),
            CAST(prd_start_dt AS DATE),
            CAST(prd_end_dt AS DATE)
        FROM bronze.crm_prd_info;

        TRUNCATE TABLE silver.crm_sales_details;
        INSERT INTO silver.crm_sales_details (
            sls_ord_num,
            sls_prd_key,
            sls_cust_id,
            sls_order_dt,
            sls_ship_dt,
            sls_due_dt,
            sls_sales,
            sls_quantity,
            sls_price
        )
        SELECT
            LTRIM(RTRIM(sls_ord_num)),
            LTRIM(RTRIM(sls_prd_key)),
            sls_cust_id,
            TRY_CONVERT(DATE, CONVERT(CHAR(8), sls_order_dt)),
            TRY_CONVERT(DATE, CONVERT(CHAR(8), sls_ship_dt)),
            TRY_CONVERT(DATE, CONVERT(CHAR(8), sls_due_dt)),
            sls_sales,
            sls_quantity,
            sls_price
        FROM bronze.crm_sales_details;

        TRUNCATE TABLE silver.erp_loc_a101;
        INSERT INTO silver.erp_loc_a101 (cid, cntry)
        SELECT
            LTRIM(RTRIM(cid)),
            CASE
                WHEN NULLIF(LTRIM(RTRIM(cntry)), '') IS NULL THEN 'UNKNOWN'
                ELSE UPPER(LTRIM(RTRIM(cntry)))
            END
        FROM bronze.erp_loc_a101;

        TRUNCATE TABLE silver.erp_cust_az12;
        INSERT INTO silver.erp_cust_az12 (cid, bdate, gen)
        SELECT
            LTRIM(RTRIM(cid)),
            bdate,
            CASE UPPER(LTRIM(RTRIM(gen)))
                WHEN 'F' THEN 'Female'
                WHEN 'M' THEN 'Male'
                ELSE 'Unknown'
            END
        FROM bronze.erp_cust_az12;

        TRUNCATE TABLE silver.erp_px_cat_g1v2;
        INSERT INTO silver.erp_px_cat_g1v2 (id, cat, subcat, maintenance)
        SELECT
            LTRIM(RTRIM(id)),
            LTRIM(RTRIM(cat)),
            LTRIM(RTRIM(subcat)),
            LTRIM(RTRIM(maintenance))
        FROM bronze.erp_px_cat_g1v2;

        PRINT 'Silver layer load completed';
    END TRY
    BEGIN CATCH
        PRINT 'Silver layer load failed: ' + ERROR_MESSAGE();
        THROW;
    END CATCH;
END;
GO