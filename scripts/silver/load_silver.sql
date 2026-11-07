

SET SEARCH_PATH = 'silver', PUBLIC;

-- Finding duplicates in pk cst_id
-- SELECT cst_id, count(cst_id) AS cnt 
-- FROM bronze.crm_cust_info
-- GROUP BY cst_id
-- ORDER BY cnt DESC
-- ;


CREATE OR REPLACE PROCEDURE load_silver_tables()
LANGUAGE plpgsql
AS $$
BEGIN


-- Fixing crm_cust_info table
WITH base_cte AS
    (
    SELECT cst_id, cst_key, cst_firstname, cst_lastname, cst_marital_status, cst_gndr, cst_create_date,
    ROW_NUMBER() OVER(PARTITION BY cst_id ORDER BY cst_create_date DESC) AS rnk
    FROM bronze.crm_cust_info
    )

    INSERT INTO crm_cust_info (
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
        cst_key, 
        TRIM(cst_firstname) AS cst_firstname, 
        TRIM(cst_lastname) AS cst_lastname, 
        CASE 
            WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
            WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
            ELSE 'N/A'
        END AS cst_marital_status, 
        CASE
            WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
            WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
            ELSE 'N/A'
        END AS cst_gndr,
        cst_create_date 
    FROM base_cte
    -- WHERE cst_id IN (29433, 29449, 29466, 29466, 29473, 29483)
    WHERE rnk = 1
;




-- fixing crm_prd_info table
INSERT INTO crm_prd_info (prd_id, prd_key, cat_key, prd_nm, prd_cost, prd_line, prd_start_dt, prd_end_dt)
SELECT 
    prd_id, 
    TRIM(SUBSTRING(prd_key, 5, LENGTH(prd_key))) AS prd_key,
    TRIM(REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_')) AS cat_key, 
    TRIM(prd_nm) AS prd_nm, 
    CASE
        WHEN prd_cost IS NULL THEN 0
        ELSE prd_cost
    END AS prd_cost, 
    CASE
        WHEN UPPER(TRIM(prd_line)) = 'M' THEN 'Mountain'
        WHEN UPPER(TRIM(prd_line)) = 'R' THEN 'Road'
        WHEN UPPER(TRIM(prd_line)) = 'S' THEN 'Other Sales'
        WHEN UPPER(TRIM(prd_line)) = 'T' THEN 'Touring'
        ELSE 'N/A'
    END AS prd_line,
    -- for time travelling problem i could consider prd_start_dt as clean and TRUE value then add an intreval over it to get prd_end_dt
    prd_start_dt, 
    (LEAD(prd_start_dt) OVER(PARTITION BY prd_key ORDER BY prd_start_dt) - 1) AS prd_end_dt -- Method 1
    -- (prd_start_dt + INTERVAL '1 YEAR 5 DAYS') AS prd_end_dt -- Method 2
FROM bronze.crm_prd_info 
;





INSERT INTO crm_sales_details (sls_ord_num, sls_prd_key, sls_cust_id, sls_order_dt, sls_ship_dt, sls_due_dt, sls_sales, sls_quantity, sls_price)
SELECT 
    sls_ord_num, 
    sls_prd_key, 
    sls_cust_id,
    CASE
        WHEN LENGTH(sls_order_dt::VARCHAR) != 8 OR sls_order_dt = 0 THEN NULL
        ELSE sls_order_dt::VARCHAR::DATE
    END AS sls_order_dt,
    CASE
        WHEN sls_ship_dt = 0 OR LENGTH(sls_ship_dt::VARCHAR) != 8 THEN NULL
        ELSE sls_ship_dt::VARCHAR::DATE
    END AS sls_ship_dt,  
    CASE
        WHEN LENGTH(sls_due_dt::VARCHAR) != 8 OR sls_due_dt = 0 THEN NULL
        ELSE sls_due_dt::VARCHAR::DATE
    END AS sls_due_dt,
     COALESCE(NULLIF(ABS(sls_sales), 0), sls_price::NUMERIC / NULLIF(sls_quantity, 0)) AS sls_sales, 
    ABS(sls_quantity) AS sls_quantity, 
    CASE 
        WHEN sls_sales > 0 AND sls_sales IS NOT NULL THEN ABS(sls_sales) * sls_quantity
        ELSE sls_price
    END AS sls_price
FROM bronze.crm_sales_details 
;





INSERT INTO erp_CUST_AZ12 
    (
        cid,
        bdate,
        gen
    )
SELECT 
    CASE 
        WHEN cid LIKE 'NAS%' THEN SUBSTRING(TRIM(cid), 4, LENGTH(cid))
        ELSE cid
    END AS cid,
    CASE 
        WHEN CURRENT_DATE < bdate THEN NULL
        ELSE bdate
    END AS bdate,
    CASE
        WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'
        WHEN UPPER(TRIM(gen)) IN ('F', 'Female') THEN 'Female'
        ELSE 'N/A'
    END AS gen
FROM bronze.erp_cust_az12 
;









INSERT INTO erp_LOC_A101 
    (
        cid,
        cntry
    )
SELECT 
    REPLACE(TRIM(cid), '-', '') AS cid,
    CASE
        WHEN UPPER(TRIM(cntry)) IN ('US', 'UNITED STATES', 'USA') THEN 'United States'
        WHEN UPPER(TRIM(cntry)) IN ('GERMANY', 'DE') THEN 'Germany'
        WHEN UPPER(TRIM(cntry)) IN ('FRANCE') THEN 'France'
        WHEN UPPER(TRIM(cntry)) IN ('UNITED KINGDOM') THEN 'United Kingdom'
        WHEN UPPER(TRIM(cntry)) IN ('AUSTRALIA') THEN 'Australia'
        WHEN UPPER(TRIM(cntry)) IN ('CANADA') THEN 'Canada'
        ELSE 'N/A'
    END AS cntry
FROM bronze.erp_LOC_A101
;





INSERT INTO erp_PX_CAT_G1V2
SELECT 
        ID,
        CAT,
        SUBCAT,
        MAINTENANCE,
FROM bronze.erp_px_cat_g1v2
;



END ;
$$ ;

CALL load_silver_tables();