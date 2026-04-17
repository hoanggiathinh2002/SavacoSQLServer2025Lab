USE [master];
GO
-- Drop Databases (Common across Labs 01-13)
IF EXISTS (SELECT name FROM sys.databases WHERE name = 'HumanResources') DROP DATABASE [HumanResources];
IF EXISTS (SELECT name FROM sys.databases WHERE name = 'InternetSales') DROP DATABASE [InternetSales];
IF EXISTS (SELECT name FROM sys.databases WHERE name = 'AWDataWarehouse') DROP DATABASE [AWDataWarehouse];
IF EXISTS (SELECT name FROM sys.databases WHERE name = 'AWDatabase') DROP DATABASE [AWDatabase];
GO

-- Remove SQL Agent Artifacts (Labs 12 & 13)
EXEC msdb.dbo.sp_delete_alert @name = N'InternetSales Log Full Alert';
EXEC msdb.dbo.sp_delete_job @job_name = N'Back Up Log - InternetSales';
GO

-- Remove Security Artifacts (Lab 09 & 10)
IF EXISTS (SELECT name FROM sys.server_principals WHERE name = 'Marketing_Application') DROP LOGIN [Marketing_Application];
IF EXISTS (SELECT name FROM sys.server_principals WHERE name = 'Sales_Manager') DROP LOGIN [Sales_Manager];
IF EXISTS (SELECT name FROM sys.server_audits WHERE name = 'DataChangeAudit') DROP SERVER AUDIT [DataChangeAudit];
GO

-- Reset Configurations (Lab 03 & 09)
EXEC sp_configure 'show advanced options', 1; RECONFIGURE;
EXEC sp_configure 'Database Mail XPs', 0; RECONFIGURE;