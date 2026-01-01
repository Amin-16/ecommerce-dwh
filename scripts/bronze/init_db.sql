USE master
GO
IF EXISTS (SELECT 1 FROM sys.databases WHERE name ='DataWarehouse')
BEGIN
ALTER DATABASE Datawarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
DROP DATABASE DataWarehouse

END;
GO


CREATE DATABASE DataWarehouse

Create schema bronze;
GO
Create schema silver;
GO
Create schema gold;
GO

