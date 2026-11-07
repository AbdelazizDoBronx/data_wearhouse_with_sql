/*
=======================================

    DDL script: create SILVER layer tables

=======================================
    Script purpose:
        This script creates tables in SILVER schema, if tables exists alrready this scripts drop them.
        Run this script if you want to re-define the tables.  
        
*/

-- sets default schema to bronze
SET search_path TO 'silver', public;



CREATE OR REPLACE PROCEDURE ddl_silver_tables()
LANGUAGE plpgsql
AS $$

BEGIN
    DROP TABLE IF EXISTS crm_cust_info ; 
    CREATE TABLE crm_cust_info
        (
            cst_id BIGINT,
            cst_key VARCHAR(250),
            cst_firstname VARCHAR(250),
            cst_lastname VARCHAR(250),
            cst_marital_status VARCHAR(50),
            cst_gndr VARCHAR(50),
            cst_create_date DATE,
            dwh_created_at TIMESTAMPTZ DEFAULT NOW()
        )
    ;


    DROP TABLE IF EXISTS crm_prd_info; 
    CREATE TABLE crm_prd_info
        (
            prd_id BIGINT,
            prd_key VARCHAR(250),
            cat_key VARCHAR(250),
            prd_nm VARCHAR(250),
            prd_cost DECIMAL(10, 2),
            prd_line VARCHAR(50),
            prd_start_dt DATE,
            prd_end_dt DATE,
            dwh_created_at TIMESTAMPTZ DEFAULT NOW()
        )
    ;


    DROP TABLE IF EXISTS crm_sales_details; 
    CREATE TABLE crm_sales_details
        (
            sls_ord_num VARCHAR(250),
            sls_prd_key VARCHAR(250),
            sls_cust_id BIGINT,
            sls_order_dt DATE,
            sls_ship_dt DATE,
            sls_due_dt ,
            sls_sales DECIMAL(10, 2),
            sls_quantity INT,
            sls_price DECIMAL(10, 2),
            dwh_created_at TIMESTAMPTZ DEFAULT NOW()
        )
    ;



    DROP TABLE IF EXISTS erp_CUST_AZ12; 
    CREATE TABLE erp_CUST_AZ12
        (
            CID VARCHAR(250),
            BDATE DATE,
            GEN VARCHAR(50),
            dwh_created_at TIMESTAMPTZ DEFAULT NOW()
        )
    ;



    DROP TABLE IF EXISTS erp_LOC_A101; 
    CREATE TABLE erp_LOC_A101
        (
            CID VARCHAR(250),
            CNTRY VARCHAR(250),
            dwh_created_at TIMESTAMPTZ DEFAULT NOW()
        );


    DROP TABLE IF EXISTS erp_PX_CAT_G1V2; 
    CREATE TABLE erp_PX_CAT_G1V2
        (
            ID VARCHAR(50),
            CAT VARCHAR(50),
            SUBCAT VARCHAR(50),
            MAINTENANCE VARCHAR(50),
            dwh_created_at TIMESTAMPTZ DEFAULT NOW()
        );
        
END ;
$$ ;


CALL ddl_silver_tables();


