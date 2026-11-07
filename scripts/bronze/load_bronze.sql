
-- SET search_path TO bronze, public;

-- DO $$
-- DECLARE 
--     started_at TIMESTAMP;
--     finished_at TIMESTAMP;
--     excu_started_at TIMESTAMP;
--     excu_finished_at TIMESTAMP;

--     err_code TEXT;
--     err_desc TEXT;
-- BEGIN

--     RAISE NOTICE '=================================================';
--     RAISE NOTICE 'LOADING DATA INTO BRONZE LAYER!';
--     RAISE NOTICE '=================================================';

--     -- 1. CRM: Customer Info
--     RAISE NOTICE 'Loading Data Into crm_cust_info...';

--     excu_started_at := CLOCK_TIMESTAMP();
--     started_at := CLOCK_TIMESTAMP();

--     TRUNCATE TABLE crm_cust_info;

--     COPY crm_cust_info
--     FROM 'C:/tmp/source_crm/cust_info1.csv'
--     WITH (FORMAT csv, HEADER true, DELIMITER ',');

--     finished_at := CLOCK_TIMESTAMP();

--     RAISE NOTICE 'crm_cust_info loaded successfully. Duration: %',
--         finished_at - started_at;


--     -- 2. CRM: Product Info
--     RAISE NOTICE 'Loading Data Into crm_prd_info...';

--     started_at := CLOCK_TIMESTAMP();

--     TRUNCATE TABLE crm_prd_info;

--     COPY crm_prd_info
--     FROM 'C:/tmp/source_crm/prd_info.csv'
--     WITH (FORMAT csv, HEADER true, DELIMITER ',');

--     finished_at := CLOCK_TIMESTAMP();

--     RAISE NOTICE 'crm_prd_info loaded successfully. Duration: %',
--         finished_at - started_at;


--     -- 3. CRM: Sales Details
--     RAISE NOTICE 'Loading Data Into crm_sales_details...';

--     started_at := CLOCK_TIMESTAMP();

--     TRUNCATE TABLE crm_sales_details;

--     COPY crm_sales_details
--     FROM 'C:/tmp/source_crm/sales_details.csv'
--     WITH (FORMAT csv, HEADER true, DELIMITER ',');

--     finished_at := CLOCK_TIMESTAMP();

--     RAISE NOTICE 'crm_sales_details loaded successfully. Duration: %',
--         finished_at - started_at;


--     -- 4. ERP: Customer AZ12
--     RAISE NOTICE 'Loading Data Into erp_CUST_AZ12...';

--     started_at := CLOCK_TIMESTAMP();

--     TRUNCATE TABLE erp_CUST_AZ12;

--     COPY erp_CUST_AZ12
--     FROM 'C:/tmp/source_erp/CUST_AZ12.csv'
--     WITH (FORMAT csv, HEADER true, DELIMITER ',');

--     finished_at := CLOCK_TIMESTAMP();

--     RAISE NOTICE 'erp_CUST_AZ12 loaded successfully. Duration: %',
--         finished_at - started_at;


--     -- 5. ERP: Location A101
--     RAISE NOTICE 'Loading Data Into erp_LOC_A101...';

--     started_at := CLOCK_TIMESTAMP();

--     TRUNCATE TABLE erp_LOC_A101;

--     COPY erp_LOC_A101
--     FROM 'C:/tmp/source_erp/LOC_A101.csv'
--     WITH (FORMAT csv, HEADER true, DELIMITER ',');

--     finished_at := CLOCK_TIMESTAMP();

--     RAISE NOTICE 'erp_LOC_A101 loaded successfully. Duration: %',
--         finished_at - started_at;


--     -- 6. ERP: Product Category G1V2
--     RAISE NOTICE 'Loading Data Into erp_PX_CAT_G1V2...';

--     started_at := CLOCK_TIMESTAMP();

--     TRUNCATE TABLE erp_PX_CAT_G1V2;

--     COPY erp_PX_CAT_G1V2
--     FROM 'C:/tmp/source_erp/PX_CAT_G1V2.csv'
--     WITH (FORMAT csv, HEADER true, DELIMITER ',');

--     finished_at := CLOCK_TIMESTAMP();
--     excu_finished_at := CLOCK_TIMESTAMP();

--     RAISE NOTICE 'erp_PX_CAT_G1V2 loaded successfully. Duration: %',
--         finished_at - started_at;

--     EXCEPTION
--         WHEN OTHERS THEN
--             err_code := SQLSTATE;
--             err_desc := SQLERRM;

--             RAISE NOTICE 'Caught some errors: error code: %, error message: %', err_code, err_desc;

--     RAISE NOTICE '=================================================';
--     RAISE NOTICE 'LOADING DATA INTO BRONZE LAYER HAS FINISHED';
--     RAISE NOTICE 'Took: %', excu_finished_at - excu_started_at;
--     RAISE NOTICE '=================================================';

-- END $$;





















-- SET search_path TO bronze, public;

-- DO $$
-- DECLARE
--     started_at TIMESTAMPTZ;
--     finished_at TIMESTAMPTZ;

--     table_name TEXT;
--     file_path TEXT;

--     error_message TEXT;

--     success_count INT := 0;
--     failed_count INT := 0;

--     tables TEXT[] := ARRAY[
--         'crm_cust_info',
--         'crm_prd_info',
--         'crm_sales_details',
--         'erp_cust_az12',
--         'erp_loc_a101',
--         'erp_px_cat_g1v2'
--     ];

--     files TEXT[] := ARRAY[
--         'C:/tmp/source_crm/cust_info.csv',
--         'C:/tmp/source_crm/prd_info.csv',
--         'C:/tmp/source_crm/sales_details.csv',
--         'C:/tmp/source_erp/CUST_AZ12.csv',
--         'C:/tmp/source_erp/LOC_A101.csv',
--         'C:/tmp/source_erp/PX_CAT_G1V2.csv'
--     ];

--     i INT;

-- BEGIN

--     RAISE NOTICE '=================================================';
--     RAISE NOTICE 'LOADING DATA INTO BRONZE LAYER';
--     RAISE NOTICE '=================================================';

--     FOR i IN 1..ARRAY_LENGTH(tables, 1)
--     LOOP

--         table_name := tables[i];
--         file_path := files[i];

--         started_at := CLOCK_TIMESTAMP();

--         RAISE NOTICE 'Loading %...', table_name;

--         BEGIN

--             EXECUTE FORMAT('TRUNCATE TABLE bronze.%I', table_name);

--             EXECUTE FORMAT(
--                 'COPY bronze.%I FROM %L
--                  WITH (FORMAT csv, HEADER true, DELIMITER %L)',
--                 table_name,
--                 file_path,
--                 ','
--             );

            -- finished_at := CLOCK_TIMESTAMP();

--             success_count := success_count + 1;

--             RAISE NOTICE '% loaded successfully. Duration: %',
--                 table_name,
--                 finished_at - started_at;

--         EXCEPTION WHEN OTHERS THEN

--             finished_at := CLOCK_TIMESTAMP();

--             failed_count := failed_count + 1;

--             GET STACKED DIAGNOSTICS
--                 error_message = MESSAGE_TEXT;

--             RAISE WARNING 'Failed to load table: %', table_name;
--             RAISE WARNING 'Error: %', error_message;
--             RAISE WARNING 'Duration: %',
--                 finished_at - started_at;

--         END;

--     END LOOP;

--     RAISE NOTICE '=================================================';
--     RAISE NOTICE 'BRONZE LOADING SUMMARY';
--     RAISE NOTICE 'Successfully loaded: %', success_count;
--     RAISE NOTICE 'Failed loads: %', failed_count;
--     RAISE NOTICE '=================================================';

--     IF failed_count > 0 THEN
--         RAISE WARNING 'BRONZE LOADING COMPLETED WITH ERRORS!';
--     ELSE
--         RAISE NOTICE 'BRONZE LOADING COMPLETED SUCCESSFULLY!';
--     END IF;

-- END $$;







/*
  ==============================================================
                  LOAD DATA TO BRONZE LAYER
  ==============================================================
    - Script Purpose
        loading data from csv files to the bronze layer tables after TRUNCATING the tables.
        used a postgres bloc statment approch (DO BEGIN END), i used a loop (DIY)
*/



SET SEARCH_PATH = 'bronze', PUBLIC;

DO $$
DECLARE 

    path_name TEXT;
    table_name TEXT;

    started_at TIMESTAMP;
    finished_at TIMESTAMP;
    exec_started_at TIMESTAMP;
    exec_finished_at TIMESTAMP;

    success_count INT := 0;
    failed_count INT := 0;

    err_code TEXT;
    err_msg TEXT;
    err_desc TEXT;

    tables_names TEXT[] := ARRAY [
        'crm_cust_info', 
        'crm_prd_info', 
        'crm_sales_details', 
        'erp_cust_az12', 
        'erp_loc_a101', 
        'erp_px_cat_g1v2'
    ];

    files_path TEXT[] := ARRAY [
        'C:/tmp/source_crm/cust_info.csv',
        'C:/tmp/source_crm/prd_info.csv',
        'C:/tmp/source_crm/sales_details.csv',
        'C:/tmp/source_erp/CUST_AZ12.csv',
        'C:/tmp/source_erp/LOC_A101.csv',
        'C:/tmp/source_erp/PX_CAT_G1V2.csv'
    ];
    
    i INT;

BEGIN 

    RAISE NOTICE '===========================================================';
    RAISE NOTICE 'LOADING DATA INTO BRONZE TABLES HAS STARTED';
    RAISE NOTICE '===========================================================';

    
    FOR i IN 1..ARRAY_LENGTH(tables_names, 1) LOOP  

        table_name := tables_names[i];
        path_name := files_path[i];

        BEGIN

            
            exec_started_at := CLOCK_TIMESTAMP();
            started_at := CLOCK_TIMESTAMP();

            RAISE NOTICE '===========================================================';
            RAISE NOTICE 'Loading %...', table_name;        

            RAISE NOTICE 'TRUNCATING TABLE %', table_name;
            EXECUTE FORMAT('TRUNCATE TABLE %I', table_name);
            RAISE NOTICE 'TRUNCATING HAS COMPLITED';

            RAISE NOTICE 'LOADING DATA INTO %L', table_name;
            RAISE NOTICE '%' ,path_name;
            EXECUTE FORMAT('COPY %I FROM %L WITH(FORMAT csv, HEADER TRUE, DELIMITER %L)', table_name ,path_name, ',');
            
            exec_finished_at := CLOCK_TIMESTAMP();
            finished_at := CLOCK_TIMESTAMP();

            success_count := success_count + 1;

            RAISE NOTICE 'LOADING DATA HAS COMPLITED SUCCESFULLY';
            RAISE NOTICE 'LOADING TOOK % ms', finished_at - started_at;

            RAISE NOTICE 'COMPLETE PROCESSUS TOOK %s ms', exec_finished_at - exec_started_at;

            RAISE NOTICE '===========================================================';

            EXCEPTION WHEN OTHERS THEN

                finished_at := CLOCK_TIMESTAMP();
                failed_count := failed_count + 1;

                err_code := SQLSTATE;
                err_msg := SQLERRM;


                GET STACKED DIAGNOSTICS
                    err_desc := MESSAGE_TEXT;
                
                RAISE WARNING 'SOME ERRORS CAUGHT, ERROR CODE: %, ERROR MESSAGE: %', err_code, err_msg;
                RAISE WARNING 'ERROR DESCRIPTION %', err_desc;
                RAISE WARNING 'DURATION: % ms', started_at - finished_at;

        END;
    END LOOP;    

    RAISE NOTICE '----------------------------------------------------------------';
    RAISE NOTICE 'BRONZE LAYER DATA LOADING SUMMARIZE';
    RAISE NOTICE 'SUCCESS INSTRACTIONS COUNT: %', success_count;
    RAISE NOTICE 'FAILED INSTRACTIONS COUNT: %', failed_count;
    RAISE NOTICE '----------------------------------------------------------------';

    IF failed_count > 0 THEN 
        RAISE NOTICE 'DATA LOADING HAS COMPLITED WITH SOME ERRORS';
    ELSE
        RAISE NOTICE 'DATA LOADING HAS COMPLITED WITH SUCCESS';
    END IF;           
END $$;


-- SELECT * FROM pg_tables WHERE schemaname = 'bronze';