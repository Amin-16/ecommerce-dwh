--FULL LOADING
CREATE OR ALTER PROCEDURE bronze.load_bronze AS

BEGIN TRY
DECLARE @start_time DATETIME , @end_time DATETIME
	PRINT('====================================')
		PRINT('Loading Bronze Layer')
	PRINT('====================================')
	PRINT('------------------------------------')
		PRINT('Loading CRM Tables')
	PRINT('------------------------------------')
	
	SET @start_time = GETDATE()
	PRINT('Truncating Table: bronze.crm_cust_info ')
	TRUNCATE TABLE bronze.crm_cust_info;
	PRINT('Inserting Table: bronze.crm_cust_info ')
	BULK INSERT bronze.crm_cust_info
	FROM 'C:\Users\MOHAMED\Desktop\college\ecommerce-dwh\datasets\source_crm\cust_info.csv'
	WITH (
	FIRSTROW = 2,
	FIELDTERMINATOR =',',
	TABLOCK
	);


	PRINT('Truncating Table: bronze.crm_prd_info ')
	TRUNCATE TABLE bronze.crm_prd_info
	
	PRINT('Inserting Table: bronze.crm_prd_info ')
	BULK INSERT bronze.crm_prd_info
	FROM 'C:\Users\MOHAMED\Desktop\college\ecommerce-dwh\datasets\source_crm\prd_info.csv'
	WITH(
	FIRSTROW=2,
	FIELDTERMINATOR = ',',
	TABLOCK
	);


	PRINT('Truncating Table: bronze.crm_sales_details')
	TRUNCATE TABLE bronze.crm_sales_details
	PRINT('Inserting Table: bronze.crm_sales_details')
	BULK INSERT bronze.crm_sales_details
	FROM 'C:\Users\MOHAMED\Desktop\college\ecommerce-dwh\datasets\source_crm\sales_details.csv'
	WITH(
	FIRSTROW = 2,
	FIELDTERMINATOR =',',
	TABLOCK
	);

	PRINT('Truncating Table: bronze.erp_cust_az12')
	TRUNCATE TABLE bronze.erp_cust_az12
	PRINT('Inserting Table: bronze.erp_cust_az12')
	BULK INSERT bronze.erp_cust_az12
	FROM 'C:\Users\MOHAMED\Desktop\college\ecommerce-dwh\datasets\source_erp\CUST_AZ12.csv'
	WITH(
	FIRSTROW =2 ,
	FIELDTERMINATOR = ',',
	TABLOCK
	);


	PRINT('Truncating Table: bronze.erp_loc_a101')
	TRUNCATE TABLE bronze.erp_loc_a101
	
	PRINT('Inserting Table: bronze.erp_loc_a101')
	BULK INSERT bronze.erp_loc_a101
	FROM 'C:\Users\MOHAMED\Desktop\college\ecommerce-dwh\datasets\source_erp\loc_a101.csv'
	WITH(
	FIRSTROW =2 ,
	FIELDTERMINATOR = ',',
	TABLOCK
	);


	PRINT('Truncating Table: bronze.erp_px_cat_g1v2')
	TRUNCATE TABLE bronze.erp_px_cat_g1v2
	PRINT('Inserting Table: bronze.erp_px_cat_g1v2')
	BULK INSERT bronze.erp_px_cat_g1v2
	FROM 'C:\Users\MOHAMED\Desktop\college\ecommerce-dwh\datasets\source_erp\px_cat_g1v2.csv'
	WITH(
	FIRSTROW =2 ,
	FIELDTERMINATOR = ',',
	TABLOCK
	);
	
	
	SET @end_time = GETDATE()
	PRINT '>> Load Duration for Bronze Layer: ' + CAST(DATEDIFF(second, @start_time ,@end_time) AS NVARCHAR ) + 'seconds'
	END TRY
	BEGIN CATCH
	PRINT '*** ERROR in Bronze Layer *****' + ERROR_MESSAGE()
	END CATCH
