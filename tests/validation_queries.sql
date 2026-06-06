SELECT 'bronze.crm_cust_info' AS table_name, COUNT(*) AS row_count FROM bronze.crm_cust_info
UNION ALL
SELECT 'bronze.crm_prd_info', COUNT(*) FROM bronze.crm_prd_info
UNION ALL
SELECT 'bronze.crm_sales_details', COUNT(*) FROM bronze.crm_sales_details
UNION ALL
SELECT 'bronze.erp_loc_a101', COUNT(*) FROM bronze.erp_loc_a101
UNION ALL
SELECT 'bronze.erp_cust_az12', COUNT(*) FROM bronze.erp_cust_az12
UNION ALL
SELECT 'bronze.erp_px_cat_g1v2', COUNT(*) FROM bronze.erp_px_cat_g1v2
UNION ALL
SELECT 'gold.dim_customers', COUNT(*) FROM gold.dim_customers
UNION ALL
SELECT 'gold.dim_products', COUNT(*) FROM gold.dim_products
UNION ALL
SELECT 'gold.fact_sales', COUNT(*) FROM gold.fact_sales;
GO

SELECT 'silver.crm_sales_details invalid dates' AS check_name, COUNT(*) AS issue_count
FROM silver.crm_sales_details
WHERE sls_order_dt IS NULL OR sls_ship_dt IS NULL OR sls_due_dt IS NULL;
GO

SELECT 'gold.fact_sales orphan rows' AS check_name, COUNT(*) AS issue_count
FROM gold.fact_sales AS fs
LEFT JOIN gold.dim_customers AS dc ON dc.customer_key = fs.customer_key
LEFT JOIN gold.dim_products AS dp ON dp.product_key = fs.product_key
WHERE dc.customer_key IS NULL OR dp.product_key IS NULL;
GO

SELECT TOP (10)
    dc.country,
    dp.category,
    SUM(fs.sales_amount) AS total_sales,
    SUM(fs.quantity) AS total_quantity
FROM gold.fact_sales AS fs
INNER JOIN gold.dim_customers AS dc ON dc.customer_key = fs.customer_key
INNER JOIN gold.dim_products AS dp ON dp.product_key = fs.product_key
GROUP BY dc.country, dp.category
ORDER BY total_sales DESC;
GO