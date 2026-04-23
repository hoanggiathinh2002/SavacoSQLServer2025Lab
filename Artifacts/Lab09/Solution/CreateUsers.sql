USE InternetSales;
GO

-- Create users
CREATE USER Marketing_Application
FOR LOGIN Marketing_Application
WITH DEFAULT_SCHEMA = Customers;

CREATE USER WebApplicationSvc
FOR LOGIN [SQLServerSSMS\WebApplicationSvc]
WITH DEFAULT_SCHEMA = Sales;

CREATE USER InternetSales_Users
FOR LOGIN [SQLServerSSMS\InternetSales_Users]
WITH DEFAULT_SCHEMA = Sales;

CREATE USER InternetSales_Managers
FOR LOGIN [SQLServerSSMS\InternetSales_Managers]
WITH DEFAULT_SCHEMA = Sales;

CREATE USER Database_Managers
FOR LOGIN [SQLServerSSMS\Database_Managers]
WITH DEFAULT_SCHEMA = dbo;

