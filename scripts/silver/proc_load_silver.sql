CREATE OR ALTER PROCEDURE silver.load_silver  AS

BEGIN TRY
		DECLARE 
			@start_time DATETIME,
			@end_time   DATETIME;

        SET @start_time = GETDATE();
		
		PRINT CONVERT(VARCHAR(23), @start_time, 121) + ' >> LOADING SILVER LAYER';
		-------------------------------------------------
		PRINT '>> Loading crm_cust_info'
		-------------------------------------------------
		TRUNCATE TABLE silver.crm_cust_info;

		INSERT INTO  silver.crm_cust_info(
		cst_id  ,
		cst_key ,
		cst_firstname ,
		cst_lastname ,
		cst_marital_status ,
		cst_gndr ,
		cst_create_date
		)

		SELECT 
		cst_id ,
		cst_key ,
		TRIM(cst_firstname) as cst_firstname,
		TRIM(cst_lastname) as cst_lastname  ,
		CASE
		WHEN TRIM(UPPER(cst_marital_status))= 'S' THEN 'Single'
		WHEN TRIM(UPPER(cst_marital_status))= 'M' THEN 'Married'
		ELSE 'n/a'
		END  as cst_marital_status,

		CASE
		WHEN TRIM(UPPER(cst_gndr)) = 'M' THEN 'Male'
		WHEN TRIM(UPPER(cst_gndr))= 'F' THEN 'Female'
		ELSE 'n/a'
		END  as cst_gndr,

		cst_create_date 
		FROM
		(
		SELECT 
		*,
		ROW_NUMBER() OVER(PARTITION BY cst_id ORDER BY cst_create_date DESC) as flag_last
		from bronze.crm_cust_info)t

		WHERE flag_last = 1 and cst_id is not null

		--------------------------------------
		PRINT '>> loading crm_prd_info'
		----------------------------------------
		TRUNCATE TABLE silver.crm_prd_info

		INSERT INTO silver.crm_prd_info
		(
		prd_id ,
		cat_id ,
		prd_key ,
		prd_nm ,
		prd_cost ,
		prd_line ,
		prd_start_dt ,
		prd_end_dt 
		)
		SELECT 
		 prd_id,
		 REPLACE(SUBSTRING(prd_key,1,5),'-','_') as cat_id,
		 SUBSTRING(prd_key, 7 , LEN(prd_key)) as prd_key,
		 prd_nm,
		 ISNULL(prd_cost,0) as prd_cost,
		 CASE TRIM(UPPER(prd_line ))
		 WHEN 'M' then 'Mountain'
		 WHEN 'R' then 'Road'
		 WHEN 'S' then 'Other Sales'
		 WHEN 'T' then 'Touring'
		 ELSE 'n/a'
		 END AS prd_line
		 ,
		 CAST(prd_start_dt AS DATE) AS prd_start_dt ,
		 CAST(LEAD(prd_start_dt) OVER(PARTITION BY prd_key ORDER BY prd_start_dt) - 1  AS DATE)as prd_end_dt
		FROM bronze.crm_prd_info
		---------------------------------------
		PRINT'>> crm_sales_details'
		----------------------------------------


		TRUNCATE TABLE silver.crm_sales_details 


		INSERT INTO silver.crm_sales_details (
		sls_ord_num ,
		sls_prd_key ,
		sls_cust_id ,
		sls_order_dt,
		sls_ship_dt ,
		sls_due_dt,
		sls_sales ,
		sls_quantity ,
		sls_price
		)
		SELECT 
		sls_ord_num ,
		sls_prd_key ,
		sls_cust_id ,

		CASE WHEN sls_order_dt= 0 OR LEN(sls_order_dt) ! = 8 THEN NULL
		ELSE CAST(CAST(sls_order_dt AS VARCHAR ) AS DATE)
		END AS sls_order_dt ,

		CASE WHEN sls_ship_dt= 0 OR LEN(sls_ship_dt) ! = 8 THEN NULL
		ELSE CAST(CAST(sls_ship_dt AS VARCHAR ) AS DATE)
		END AS sls_ship_dt
		,
		CASE WHEN sls_due_dt= 0 OR LEN(sls_due_dt) ! = 8 THEN NULL
		ELSE CAST(CAST(sls_due_dt AS VARCHAR ) AS DATE)
		END AS sls_order_dt,

		CASE WHEN sls_sales <=0 or sls_sales is NULL  or sls_sales != sls_quantity * ABS(sls_price)
		THEN sls_quantity * ABS(sls_price)
		ELSE sls_sales
		END AS sls_sales ,

		sls_quantity ,

		CASE WHEN sls_price =0 OR sls_price is NULL THEN sls_sales/NULLIF(sls_quantity,0)
		WHEN sls_price < 0 THEN sls_price * -1
		ELSE sls_price
		END AS sls_price 
		FROM bronze.crm_sales_details 


		------------------------------------------
		PRINT '>> Loading erp_cust_az12'
		-----------------------------------------

		TRUNCATE TABLE silver.erp_cust_az12
		INSERT INTO silver.erp_cust_az12(cid,bdate,gen)
		SELECT 

		CASE  
		WHEN cid LIKE 'NASA%' THEN SUBSTRING(cid ,4,LEN(cid))
		ELSE cid
		END AS cid ,
		CASE WHEN bdate >= GETDATE() THEN NULL
		ELSE bdate
		END AS bdate,

		CASE 
		WHEN UPPER(TRIM(gen)) IN  ('MALE','M') THEN 'M'
		WHEN UPPER(TRIM(gen)) IN  ('FEMALE','F')  THEN 'F'
		ELSE 'n/a'
		END AS gen

		FROM 
		bronze.erp_cust_az12

		--------------------------------------
		PRINT '>> Loading erp_loc_a101'
		--------------------------------------

		TRUNCATE TABLE silver.erp_loc_a101

		INSERT INTO silver.erp_loc_a101(cid, cntry)
		SELECT 
		REPLACE(cid,'-','') AS cid ,
		CASE 
		WHEN TRIM(cntry) = 'DE' THEN 'Germany'
		WHEN  TRIM(cntry)  IN('US','USA') THEN 'United States'
		WHEN  TRIM(cntry)  IS NULL OR  TRIM(cntry) = '' THEN 'n/a'
		ELSE  TRIM(cntry) 
		END as cntry
		FROM bronze.erp_loc_a101
		--------------------------------------
		PRINT '>> loading erp_px_cat_g1v2'
		---------------------------------------

		TRUNCATE TABLE silver.erp_px_cat_g1v2 
		INSERT INTO silver.erp_px_cat_g1v2 (id ,cat,subcat,maintenance)
		SELECT 
		id ,
		cat,
		subcat ,
		maintenance
		FROM bronze.erp_px_cat_g1v2
		
		SET @end_time = GETDATE();
        PRINT CONVERT(VARCHAR(23), @end_time, 121) + ' >> LOADING DONE SUCCESSFULY';
END TRY
BEGIN CATCH
	PRINT '*** ERROR in Silver Layer *****' + ERROR_MESSAGE()
END CATCH
