USE master
GO

-- drop databases
IF EXISTS(SELECT * FROM sys.sysdatabases WHERE name = 'HumanResources')
BEGIN
	DROP DATABASE HumanResources
END
GO

IF EXISTS(SELECT * FROM sys.sysdatabases WHERE name = 'InternetSales')
BEGIN
	DROP DATABASE InternetSales
END
GO

IF EXISTS(SELECT * FROM sys.sysdatabases WHERE name = 'AWDataWarehouse')
BEGIN
	DROP DATABASE AWDataWarehouse
END
GO

-- Drop server roles and logins
IF EXISTS (SELECT * FROM sys.server_principals WHERE name = 'Marketing_Application')
BEGIN
	DROP LOGIN [Marketing_Application];
END
GO

IF EXISTS (SELECT * FROM sys.server_principals WHERE name = 'SQLSERVERSSMS\WebApplicationSvc')
BEGIN
	DROP LOGIN [SQLSERVERSSMS\WebApplicationSvc];
END
GO

IF EXISTS (SELECT * FROM sys.server_principals WHERE name = 'SQLSERVERSSMS\InternetSales_Users')
BEGIN
	DROP LOGIN [SQLSERVERSSMS\InternetSales_Users];
END
GO

IF EXISTS (SELECT * FROM sys.server_principals WHERE name = 'SQLSERVERSSMS\IntSales_Managers')
BEGIN
	DROP LOGIN [SQLSERVERSSMS\IntSales_Managers];
END
GO

IF EXISTS (SELECT * FROM sys.server_principals WHERE name = 'SQLSERVERSSMS\Database_Managers')
BEGIN
	DROP LOGIN [SQLSERVERSSMS\Database_Managers];
END
GO

IF EXISTS (SELECT * FROM sys.server_principals WHERE name = 'application_admin')
BEGIN
	DROP SERVER ROLE application_admin;
END
GO

-- restore databases
RESTORE DATABASE HumanResources FROM  DISK = N'$(SUBDIR)SetupFiles\HumanResources.bak' 
WITH  
	MOVE N'HumanResources' TO N'C:\Data\HumanResources.mdf', 
	MOVE N'HumanResources_log' TO N'C:\Logs\HumanResources.ldf',  
	REPLACE;
GO

ALTER AUTHORIZATION ON DATABASE::HumanResources TO [SQLServerSSMS\Savaco];
GO

EXEC  msdb.dbo.sp_delete_database_backuphistory @database_name = 'HumanResources';
GO


RESTORE DATABASE InternetSales FROM  DISK = N'$(SUBDIR)SetupFiles\InternetSales.bak'
WITH 
	MOVE N'InternetSales' TO N'C:\Data\InternetSales.mdf',  
	MOVE N'InternetSales_data1' TO N'C:\Data\InternetSales_data1.ndf',  
	MOVE N'InternetSales_data2' TO N'C:\Data\InternetSales_data2.ndf',  
	MOVE N'InternetSales_log' TO N'C:\Logs\InternetSales.ldf',  
	REPLACE;
GO

ALTER AUTHORIZATION ON DATABASE::InternetSales TO [SQLServerSSMS\Savaco];
GO

EXEC  msdb.dbo.sp_delete_database_backuphistory @database_name = 'InternetSales';
GO

RESTORE DATABASE AWDataWarehouse FROM  DISK = N'$(SUBDIR)SetupFiles\AWDataWarehouse.bak'
WITH 
	MOVE N'AWDataWarehouse' TO N'C:\Data\AWDataWarehouse.mdf',  
	MOVE N'AWDataWarehouse_archive' TO N'C:\Data\AWDataWarehouse_archive.ndf',  
	MOVE N'AWDataWarehouse_current' TO N'C:\Data\AWDataWarehouse_current.ndf',  
	MOVE N'AWDataWarehouse_log' TO N'C:\Logs\AWDataWarehouse.ldf',  
	REPLACE;
GO

ALTER AUTHORIZATION ON DATABASE::AWDataWarehouse TO [SQLServerSSMS\Savaco];
GO

EXEC  msdb.dbo.sp_delete_database_backuphistory @database_name = 'AWDataWarehouse';
GO


-- Set recovery model for HumanResources
ALTER DATABASE HumanResources SET RECOVERY SIMPLE WITH NO_WAIT;
GO


-- Set the recovery model for InternetSales
ALTER DATABASE InternetSales SET RECOVERY FULL WITH NO_WAIT;
GO


-- Set the recovery model for AWDataWarehouse
ALTER DATABASE AWDataWarehouse SET RECOVERY SIMPLE WITH NO_WAIT;
GO


