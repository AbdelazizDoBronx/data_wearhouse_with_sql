/*
=============================================
Create databases and schemas
=============================================

Script purpose:
    This script create a new DATABASE named data_wearhouse after checking if its already exists.
    If DATABASE exists it is dropped and  recreated it.
    Additionally the script sets up three schemas within the DATABASE, "Bronze", "Silver", "Gold"

Warning
    Running this script will DROP the entire data_wearhouse DATABASE if exists
    All data in the database will be permanently deleted. Proceed with caution
    and ensure you have proper backups before running this script.
*/



-- Terminate all the active connections to the database
SELECT pg_terminate_backend(pid) 
FROM pg_stat_activity 
WHERE datname = 'data_wearhouse' 
  AND pid <> pg_backend_pid();

DROP DATABASE IF EXISTS data_wearhouse;


CREATE DATABASE data_wearhouse;


CREATE SCHEMA bronze;

CREATE SCHEMA silver;

CREATE SCHEMA gold;