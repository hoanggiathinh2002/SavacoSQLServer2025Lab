USE master
GO

-- drop encryption keys
WHILE (SELECT COUNT(*) FROM sys.databases WHERE is_encrypted = 1) > 0
BEGIN
	DECLARE @n SYSNAME, @sql NVARCHAR(200);
	SELECT @n = (SELECT MAX(name) FROM sys.databases WHERE is_encrypted = 1);
	SET @sql = 'DROP DATABASE ' + @n;
	EXECUTE sp_executesql  @sql;
END
GO

WHILE (SELECT COUNT(*) FROM sys.symmetric_keys WHERE name NOT LIKE '#%') > 0
BEGIN
	DECLARE @n SYSNAME, @sql NVARCHAR(200);
	SELECT @n = (SELECT MAX(name) FROM sys.symmetric_keys WHERE name NOT LIKE '#%');
	SET @sql = 'DROP SYMMETRIC KEY ' + @n;
	EXECUTE sp_executesql  @sql;
END
GO

WHILE (SELECT COUNT(*) FROM sys.asymmetric_keys WHERE name NOT LIKE '#%') > 0
BEGIN
	DECLARE @n SYSNAME, @sql NVARCHAR(200);
	SELECT @n = (SELECT MAX(name) FROM sys.asymmetric_keys WHERE name NOT LIKE '#%');
	SET @sql = 'DROP ASYMMETRIC KEY ' + @n;
	EXECUTE sp_executesql  @sql;
END
GO

WHILE (SELECT COUNT(*) FROM sys.certificates WHERE name NOT LIKE '#%') > 0
BEGIN
	DECLARE @n SYSNAME, @sql NVARCHAR(200);
	SELECT @n = (SELECT MAX(name) FROM sys.certificates WHERE name NOT LIKE '#%');
	SET @sql = 'DROP CERTIFICATE ' + @n;
	EXECUTE sp_executesql  @sql;
END
GO

DROP MASTER KEY;
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

IF EXISTS (SELECT * FROM sys.server_principals WHERE name = 'ADVENTUREWORKS\WebApplicationSvc')
BEGIN
	DROP LOGIN [ADVENTUREWORKS\WebApplicationSvc];
END
GO

IF EXISTS (SELECT * FROM sys.server_principals WHERE name = 'ADVENTUREWORKS\InternetSales_Users')
BEGIN
	DROP LOGIN [ADVENTUREWORKS\InternetSales_Users];
END
GO

IF EXISTS (SELECT * FROM sys.server_principals WHERE name = 'ADVENTUREWORKS\InternetSales_Managers')
BEGIN
	DROP LOGIN [ADVENTUREWORKS\InternetSales_Managers];
END
GO

IF EXISTS (SELECT * FROM sys.server_principals WHERE name = 'ADVENTUREWORKS\Database_Managers')
BEGIN
	DROP LOGIN [ADVENTUREWORKS\Database_Managers];
END
GO

IF EXISTS (SELECT * FROM sys.server_principals WHERE name = 'application_admin')
BEGIN
	DROP SERVER ROLE application_admin;
END
GO

ALTER SERVER AUDIT SPECIFICATION [AW_ServerAuditSpec]
WITH (STATE = OFF);
GO

DROP SERVER AUDIT SPECIFICATION [AW_ServerAuditSpec];
GO

ALTER SERVER AUDIT [AW_Audit]
WITH (STATE = OFF);
GO

DROP SERVER AUDIT [AW_Audit];
GO

-- restore databases
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


-- Set the recovery model for InternetSales
ALTER DATABASE InternetSales SET RECOVERY FULL WITH NO_WAIT;
GO


-- Set the recovery model for AWDataWarehouse
ALTER DATABASE AWDataWarehouse SET RECOVERY SIMPLE WITH NO_WAIT;
GO


-- Windows login for application DBAs group
CREATE LOGIN [ADVENTUREWORKS\Database_Managers]
FROM WINDOWS 
WITH DEFAULT_DATABASE = InternetSales;
GO

-- Windows login for e-commerce site service account
CREATE LOGIN [ADVENTUREWORKS\WebApplicationSvc]
FROM WINDOWS 
WITH DEFAULT_DATABASE = InternetSales;
GO

-- Windows login for users group
CREATE LOGIN [ADVENTUREWORKS\InternetSales_Users]
FROM WINDOWS 
WITH DEFAULT_DATABASE = InternetSales;
GO

-- Windows login for managers group
CREATE LOGIN [ADVENTUREWORKS\InternetSales_Managers]
FROM WINDOWS 
WITH DEFAULT_DATABASE = InternetSales;
GO

--  SQL Server login for marketing application
CREATE LOGIN Marketing_Application
WITH PASSWORD = 'Pa$$w0rd',
CHECK_POLICY = ON, CHECK_EXPIRATION = OFF,
DEFAULT_DATABASE = InternetSales;
GO

-- Create a user-defined server role
CREATE SERVER ROLE application_admin;
GO

-- Add a login to the role
ALTER SERVER ROLE application_admin
ADD MEMBER [ADVENTUREWORKS\Database_Managers];
GO

-- Grant permission to manage application logins
GRANT ALTER ANY LOGIN TO application_admin;
GRANT VIEW ANY DATABASE TO application_admin;

-- Create users
USE InternetSales;
GO

CREATE USER Marketing_Application
FOR LOGIN Marketing_Application
WITH DEFAULT_SCHEMA = Customers;

CREATE USER WebApplicationSvc
FOR LOGIN [ADVENTUREWORKS\WebApplicationSvc]
WITH DEFAULT_SCHEMA = Sales;

CREATE USER InternetSales_Users
FOR LOGIN [ADVENTUREWORKS\InternetSales_Users]
WITH DEFAULT_SCHEMA = Sales;

CREATE USER InternetSales_Managers
FOR LOGIN [ADVENTUREWORKS\InternetSales_Managers]
WITH DEFAULT_SCHEMA = Sales;

CREATE USER Database_Managers
FOR LOGIN [ADVENTUREWORKS\Database_Managers]
WITH DEFAULT_SCHEMA = dbo;

-- Create user-defined database roles
CREATE ROLE sales_reader;
CREATE ROLE sales_writer;
CREATE ROLE customers_reader;
CREATE ROLE products_reader;
CREATE ROLE web_application;

-- Add members
ALTER ROLE db_securityadmin
ADD MEMBER Database_Managers;

ALTER ROLE sales_reader
ADD MEMBER InternetSales_Users;

ALTER ROLE sales_reader
ADD MEMBER InternetSales_Managers;

ALTER ROLE sales_writer
ADD MEMBER InternetSales_Managers;

ALTER ROLE customers_reader
ADD MEMBER InternetSales_Users;

ALTER ROLE customers_reader
ADD MEMBER InternetSales_Managers;

ALTER ROLE customers_reader
ADD MEMBER Marketing_Application;

ALTER ROLE products_reader
ADD MEMBER InternetSales_Managers;

ALTER ROLE products_reader
ADD MEMBER Marketing_Application;

ALTER ROLE web_application
ADD MEMBER WebApplicationSvc;

-- Create application role
CREATE APPLICATION ROLE sales_admin
WITH DEFAULT_SCHEMA = Sales, PASSWORD = 'Pa$$w0rd';

-- Grant permissions
GRANT SELECT ON SCHEMA::Sales TO sales_reader;
GRANT INSERT, UPDATE, EXECUTE ON SCHEMA::Sales TO sales_writer;
GRANT SELECT, INSERT, UPDATE, DELETE, EXECUTE ON Schema::Sales TO sales_admin;
GRANT SELECT, INSERT, UPDATE, DELETE, EXECUTE ON Schema::Customers TO sales_admin;
GRANT SELECT ON SCHEMA::Customers TO customers_reader;
GRANT SELECT ON SCHEMA::Products TO products_reader;
GRANT EXECUTE ON SCHEMA::Products TO InternetSales_Managers;
GRANT INSERT ON Sales.SalesOrderHeader TO web_application;
GRANT INSERT ON Sales.SalesOrderDetail TO web_application;
GRANT SELECT ON Products.vProductCatalog TO web_customer;