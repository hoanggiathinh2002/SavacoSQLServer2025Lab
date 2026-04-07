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


-- Set recovery model for HumanResources
ALTER DATABASE HumanResources SET RECOVERY SIMPLE WITH NO_WAIT;
GO

-- back up the database
BACKUP DATABASE HumanResources
TO  DISK = 'C:\Backups\HumanResources.bak'
WITH FORMAT, INIT,  MEDIANAME = 'HumanResources Backup',  NAME = 'HumanResources-Full Database Backup', COMPRESSION;
GO

-- Modify the data
UPDATE HumanResources.dbo.Employee
SET PhoneNumber = '151-555-1234'
WHERE BusinessEntityID = 259;

-- Back up the database again
BACKUP DATABASE HumanResources
TO  DISK = 'C:\Backups\HumanResources.bak'
WITH NOFORMAT, NOINIT,  NAME = 'HumanResources-Full Database Backup 2', COMPRESSION;
GO

-- Set the recovery model for InternetSales
ALTER DATABASE InternetSales SET RECOVERY FULL WITH NO_WAIT;
GO

-- Back up the database
BACKUP DATABASE InternetSales TO  DISK = 'C:\Backups\InternetSales.bak'
WITH FORMAT, INIT,  MEDIANAME = 'Internet Sales Backup',  NAME = 'InternetSales-Full Database Backup', COMPRESSION;
GO

-- Modify the database
UPDATE InternetSales.dbo.Product
SET ListPrice = ListPrice * 1.1
WHERE ProductSubcategoryID = 1;

-- Back up the transaction log
BACKUP LOG InternetSales TO  DISK = 'C:\Backups\InternetSales.bak'
WITH NOFORMAT, NOINIT,  NAME = 'InternetSales-Transaction Log Backup', COMPRESSION;
GO

-- Modify the database
UPDATE InternetSales.dbo.Product
SET ListPrice = ListPrice * 1.1
WHERE ProductSubcategoryID = 2;

-- Perform a differential backup
BACKUP DATABASE InternetSales TO  DISK = 'C:\Backups\InternetSales.bak'
WITH  DIFFERENTIAL, NOFORMAT, NOINIT,  NAME = 'InternetSales-Differential Backup',COMPRESSION;
GO

-- Modify the database
UPDATE InternetSales.dbo.Product
SET ListPrice = ListPrice * 1.1
WHERE ProductSubcategoryID = 3;

-- Backup the transaction log
BACKUP LOG InternetSales TO  DISK = 'C:\Backups\InternetSales.bak'
WITH NOFORMAT, NOINIT,  NAME = 'InternetSales-Transaction Log Backup 2', COMPRESSION;
GO

-- Remove backup history
EXEC  msdb.dbo.sp_delete_database_backuphistory @database_name = 'InternetSales';

-- Set the recovery model for AWDataWarehouse
ALTER DATABASE AWDataWarehouse SET RECOVERY SIMPLE WITH NO_WAIT;
GO

-- Back up the read-only filegroup
BACKUP DATABASE AWDataWarehouse
FILEGROUP = 'Archive'
TO DISK = 'C:\Backups\AWDataWarehouse_Read-Only.bak'
WITH FORMAT, INIT,  NAME = 'AWDataWarehouse-Archive', COMPRESSION;
GO

-- Perform a partial backup
BACKUP DATABASE AWDataWarehouse
READ_WRITE_FILEGROUPS
TO DISK = 'C:\Backups\AWDataWarehouse_Read-Write.bak'
WITH FORMAT, INIT, NAME = 'AWDataWarehouse-Active Data', COMPRESSION;
GO

-- Modify the database
INSERT INTO AWDataWarehouse.dbo.FactInternetSales
VALUES
(1, 20080801, 11000, 5.99, 2.49);
GO

-- Perform a differential partial backup
BACKUP DATABASE AWDataWarehouse
READ_WRITE_FILEGROUPS
TO DISK = 'C:\Backups\AWDataWarehouse_Read-Write.bak'
WITH DIFFERENTIAL, NOFORMAT, NOINIT, NAME = 'AWDataWarehouse-Active Data',  COMPRESSION;
GO

-- Drop the AWDataWarehouse database
DROP DATABASE AWDataWarehouse;
GO
