CREATE OR ALTER PROCEDURE gold.load_gold
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        PRINT '================================================';
        PRINT 'Loading Gold Layer';
        PRINT '================================================';

        DELETE FROM gold.fact_sales;
        DELETE FROM gold.dim_products;
        DELETE FROM gold.dim_customers;

        INSERT INTO gold.dim_customers (
            customer_id,
            customer_code,
            first_name,
            last_name,
            marital_status,
            gender,
            birth_date,
            country,
            customer_created
        )
        SELECT
            crm.cst_id,
            crm.cst_key,
            crm.cst_firstname,
            crm.cst_lastname,
            crm.cst_marital_status,
            COALESCE(erp.gen, crm.cst_gndr, 'Unknown'),
            erp.bdate,
            COALESCE(loc.cntry, 'UNKNOWN'),
            crm.cst_create_date
        FROM silver.crm_cust_info AS crm
        LEFT JOIN silver.erp_cust_az12 AS erp
            ON erp.cid = crm.cst_key
        LEFT JOIN silver.erp_loc_a101 AS loc
            ON loc.cid = crm.cst_key;

        INSERT INTO gold.dim_products (
            product_id,
            product_code,
            product_name,
            category_id,
            category,
            subcategory,
            product_line,
            maintenance,
            product_cost,
            start_date,
            end_date
        )
        SELECT
            prd.prd_id,
            prd.prd_key,
            prd.prd_nm,
            prd.cat_id,
            COALESCE(cat.cat, 'Unknown'),
            COALESCE(cat.subcat, 'Unknown'),
            prd.prd_line,
            COALESCE(cat.maintenance, 'Unknown'),
            prd.prd_cost,
            prd.prd_start_dt,
            prd.prd_end_dt
        FROM silver.crm_prd_info AS prd
        LEFT JOIN silver.erp_px_cat_g1v2 AS cat
            ON cat.id = prd.cat_id;

        INSERT INTO gold.fact_sales (
            order_number,
            customer_key,
            product_key,
            order_date,
            ship_date,
            due_date,
            sales_amount,
            quantity,
            unit_price
        )
        SELECT
            s.sls_ord_num,
            dc.customer_key,
            dp.product_key,
            s.sls_order_dt,
            s.sls_ship_dt,
            s.sls_due_dt,
            s.sls_sales,
            s.sls_quantity,
            s.sls_price
        FROM silver.crm_sales_details AS s
        INNER JOIN gold.dim_customers AS dc
            ON dc.customer_id = s.sls_cust_id
        INNER JOIN gold.dim_products AS dp
            ON dp.product_code = s.sls_prd_key;

        PRINT 'Gold layer load completed';
    END TRY
    BEGIN CATCH
        PRINT 'Gold layer load failed: ' + ERROR_MESSAGE();
        THROW;
    END CATCH;
END;
GO