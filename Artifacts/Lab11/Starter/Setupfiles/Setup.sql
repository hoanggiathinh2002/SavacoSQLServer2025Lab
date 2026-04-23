USE master
GO

-- delete maintenance plans
WHILE EXISTS (SELECT * FROM msdb.dbo.sysmaintplan_plans)
BEGIN
	DECLARE @id NVARCHAR(50);
	SELECT @id = MAX (id) FROM msdb.dbo.sysmaintplan_plans;
	EXECUTE msdb.dbo.sp_maintplan_delete_plan @plan_id = @id;
END

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


-- restore databases
RESTORE DATABASE HumanResources FROM  DISK = N'$(SUBDIR)SetupFiles\HumanResources.bak' 
WITH  
	MOVE N'HumanResources' TO N'C:\Data\HumanResources.mdf', 
	MOVE N'HumanResources_log' TO N'C:\Logs\HumanResources.ldf',  
	REPLACE;
GO

ALTER AUTHORIZATION ON DATABASE::HumanResources TO [SQLSERVERSSMS\Savaco];
GO

EXEC  msdb.dbo.sp_delete_database_backuphistory @database_name = 'HumanResources';
GO

RESTORE DATABASE [InternetSales] FROM  DISK = N'$(SUBDIR)SetupFiles\CorruptDB.bak' WITH  REPLACE,
MOVE 'Northwind' TO N'C:\Data\InternetSales.mdf',
MOVE 'Northwind_Log' TO N'C:\Logs\InternetSales.ldf';

ALTER AUTHORIZATION ON DATABASE::InternetSales TO [SQLSERVERSSMS\Savaco];
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

ALTER AUTHORIZATION ON DATABASE::AWDataWarehouse TO [SQLSERVERSSMS\Savaco];
GO

EXEC  msdb.dbo.sp_delete_database_backuphistory @database_name = 'AWDataWarehouse';
GO


-- Set recovery model for HumanResources
ALTER DATABASE HumanResources SET RECOVERY SIMPLE WITH NO_WAIT;
GO


-- Set the recovery model for AWDataWarehouse
ALTER DATABASE AWDataWarehouse SET RECOVERY SIMPLE WITH NO_WAIT;
GO

-- Create a clustered idnex on HumanResources
CREATE CLUSTERED INDEX idx_Employee_BusinessEntityID
ON HumanResources.Employees.Employee (BusinessEntityID);
GO

-- Modify the data in the table 
SET NOCOUNT ON;
DECLARE @Counter int = (SELECT MIN(BusinessEntityID) FROM HumanResources.Employees.Employee);
DECLARE @maxEmp int = (SELECT MAX(BusinessEntityID) FROM HumanResources.Employees.Employee);
WHILE @Counter <= @maxEmp BEGIN
  UPDATE HumanResources.Employees.Employee SET PhoneNumber = '555-123' + CONVERT(varchar(6),@Counter)
    WHERE BusinessEntityID = @Counter;
  SET @Counter += 1;
END;
GO

SET NOCOUNT ON;
DECLARE @Counter int = (SELECT MIN(BusinessEntityID) FROM HumanResources.Employees.Employee);
DECLARE @maxEmp int = (SELECT MAX(BusinessEntityID) FROM HumanResources.Employees.Employee);
WHILE @Counter <= @maxEmp BEGIN
  UPDATE HumanResources.Employees.Employee SET EmailAddress = REPLACE(EmailAddress, 'SQLSERVERSSMS.com', 'SQLSERVERSSMS.msft')
    WHERE BusinessEntityID = @Counter;
  SET @Counter += 1;
END;
GO