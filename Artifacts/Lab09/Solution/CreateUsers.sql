USE InternetSales;
GO

-- Create users
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

