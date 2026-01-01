USE DataWarehouse

-- Check for Duplicates and NULLs in Primary Key
-- EXPEC : no results
SELECT cst_id , Count(*)
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING Count(cst_id) > 1 or cst_id is NULL

-- Check for Extra spaces
-- EXPEC : no results
SELECT cst_firstname 
FROM silver.crm_cust_info
WHERE cst_firstname ! = TRIM(cst_firstname)

SELECT cst_lastname 
FROM silver.crm_cust_info
WHERE cst_lastname! = TRIM(cst_lastname)
--Check for Data inconsistincy and Qualtiy
SELECT 
Distinct cst_gndr
from silver.crm_cust_info

SELECT 
Distinct cst_marital_status
from silver.crm_cust_info

Select * from silver.crm_cust_info