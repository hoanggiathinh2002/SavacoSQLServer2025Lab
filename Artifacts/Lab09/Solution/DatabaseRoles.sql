USE InternetSales;
GO

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