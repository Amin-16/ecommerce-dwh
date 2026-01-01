USE DataWarehouse

-- Check for Duplicates and NULLs in Primary Key
-- EXPEC : no results
SELECT cst_id , Count(*)
FROM bronze.crm_cust_info
GROUP BY cst_id
HAVING Count(cst_id) > 1 or cst_id is NULL



SELECT prd_id , Count(*)
FROM bronze.crm_prd_info
GROUP BY prd_id
HAVING Count(prd_id) > 1 or prd_id is NULL


-- Check for Extra spaces
-- EXPEC : no results
SELECT cst_firstname 
FROM bronze.crm_cust_info
WHERE cst_firstname ! = TRIM(cst_firstname)

SELECT prd_line
FROM bronze.crm_prd_info
WHERE prd_line != TRIM(prd_line)

--Check for Data inconsistincy and Qualtiy
SELECT 
Distinct cst_gndr
from bronze.crm_cust_info

SELECT 
Distinct cst_marital_status
from bronze.crm_cust_info

SELECT 
Distinct prd_line
from bronze.crm_prd_info

-- Check For NULL and Negative nums
--Expec no results

SELECT *
FROM bronze.crm_prd_info
WHERE prd_cost is NULL OR prd_cost <0

SELECT 
sls_sales ,
sls_quantity ,
sls_price

from bronze.crm_sales_details

WHERE 
sls_sales <= 0 OR sls_sales is NULL OR sls_sales != sls_quantity * sls_price
OR sls_quantity <= 0 OR sls_quantity is NULL 
OR sls_price <= 0 OR sls_price is NULL

--Check For invalid Dates
--Expec no results
SELECT * 
From bronze.crm_prd_info
WHERE prd_start_dt> prd_end_dt

select sls_ship_dt 
from bronze.crm_sales_details
Where sls_ship_dt =0  OR LEN(sls_ship_dt) != 8

select sls_order_dt , sls_due_dt
from bronze.crm_sales_details
Where sls_due_dt < sls_order_dt

select sls_order_dt , sls_ship_dt
from bronze.crm_sales_details
Where sls_ship_dt < sls_order_dt

-----------------------------------------

SELECT * FROM bronze.erp_cust_az12 WHERE cid LIKE '%AW00%'

SELECT * FROM bronze.erp_cust_az12 Where gen is NULL

SELECT DISTINCT gen from bronze.erp_cust_az12

------------------------------------------------------

SELECT DISTINCT cid FROM bronze.erp_loc_a101 WHERE cid NOT LIKE 'AW%'

SELECT DISTINCT LEN(cid )FROM bronze.erp_loc_a101 

SELECT cst_key FROM bronze.crm_cust_info WHERE cst_key NOT IN(SELECT REPLACE(cid,'-','') FROM bronze.erp_loc_a101)

SELECT DISTINCT cntry
FROM(
SELECT 
CASE 
WHEN TRIM(cntry) = 'DE' THEN 'Germany'
WHEN  TRIM(cntry)  IN('US','USA') THEN 'United States'
WHEN  TRIM(cntry)  IS NULL OR  TRIM(cntry) = '' THEN 'n/a'
ELSE  TRIM(cntry) 
END as cntry
FROM bronze.erp_loc_a101)t
---------------------------------------------------------------------------

SELECT 
id ,
cat,
subcat ,
maintenance
FROM bronze.erp_px_cat_g1v2

SELECT * FROM silver.crm_prd_info WHERE cat_id  IN(SELECT id FROM bronze.erp_px_cat_g1v2)

SELECT * FROM bronze.erp_px_cat_g1v2 WHERE TRIM(cat) != cat OR TRIM(subcat) != subcat OR TRIM(maintenance) != maintenance 


SELECT DISTINCT maintenance FROM bronze.erp_px_cat_g1v2

SELECT 
*
FROM silver.erp_px_cat_g1v2

