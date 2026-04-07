USE master
GO

-- drop encryption keys
DROP CERTIFICATE BackupCert;
GO
DROP MASTER KEY;
GO


IF EXISTS(SELECT * FROM sys.sysdatabases WHERE name = 'HumanResources')
BEGIN
	DROP DATABASE HumanResources
END
GO

RESTORE DATABASE HumanResources FROM  DISK = N'$(SUBDIR)SetupFiles\HumanResources.bak' 
WITH  
	MOVE N'HumanResources' TO N'C:\Data\HumanResources.mdf', 
	MOVE N'HumanResources_log' TO N'C:\Logs\HumanResources.ldf',  
	REPLACE;
GO

ALTER AUTHORIZATION ON DATABASE::HumanResources TO [AdventureWorks\u2uadmin];
GO

EXEC  msdb.dbo.sp_delete_database_backuphistory @database_name = 'HumanResources';
GO

IF EXISTS(SELECT * FROM sys.sysdatabases WHERE name = 'InternetSales')
BEGIN
	DROP DATABASE InternetSales
END
GO

RESTORE DATABASE InternetSales FROM  DISK = N'$(SUBDIR)SetupFiles\InternetSales.bak'
WITH 
	MOVE N'InternetSales' TO N'C:\Data\InternetSales.mdf',  
	MOVE N'InternetSales_data1' TO N'C:\Data\InternetSales_data1.ndf',  
	MOVE N'InternetSales_data2' TO N'C:\Data\InternetSales_data2.ndf',  
	MOVE N'InternetSales_log' TO N'C:\Logs\InternetSales.ldf',  
	REPLACE;
GO

ALTER AUTHORIZATION ON DATABASE::InternetSales TO [AdventureWorks\u2uadmin];
GO

EXEC  msdb.dbo.sp_delete_database_backuphistory @database_name = 'InternetSales';
GO

IF EXISTS(SELECT * FROM sys.sysdatabases WHERE name = 'AWDataWarehouse')
BEGIN
	DROP DATABASE AWDataWarehouse
END
GO

RESTORE DATABASE AWDataWarehouse FROM  DISK = N'$(SUBDIR)SetupFiles\AWDataWarehouse.bak'
WITH 
	MOVE N'AWDataWarehouse' TO N'C:\Data\AWDataWarehouse.mdf',  
	MOVE N'AWDataWarehouse_archive' TO N'C:\Data\AWDataWarehouse_archive.ndf',  
	MOVE N'AWDataWarehouse_current' TO N'C:\Data\AWDataWarehouse_current.ndf',  
	MOVE N'AWDataWarehouse_log' TO N'C:\Logs\AWDataWarehouse.ldf',  
	REPLACE;
GO

ALTER AUTHORIZATION ON DATABASE::AWDataWarehouse TO [AdventureWorks\u2uadmin];
GO

EXEC  msdb.dbo.sp_delete_database_backuphistory @database_name = 'AWDataWarehouse';
GO