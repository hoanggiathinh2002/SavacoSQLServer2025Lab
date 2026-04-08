USE master;
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

