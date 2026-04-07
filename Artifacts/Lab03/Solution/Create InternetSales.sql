CREATE DATABASE InternetSales
 ON  PRIMARY 
(NAME = 'InternetSales', FILENAME = 'C:\Data\InternetSales.mdf', SIZE = 5MB, FILEGROWTH = 1MB), 
 FILEGROUP SalesData
(NAME = 'InternetSales_data1', FILENAME = 'C:\Data\InternetSales_data1.ndf', SIZE = 100MB, FILEGROWTH = 10MB ),
(NAME = 'InternetSales_data2', FILENAME = 'C:\Data\InternetSales_data2.ndf', SIZE = 100MB, FILEGROWTH = 10MB )
 LOG ON 
(NAME = 'InternetSales_log', FILENAME = 'C:\Logs\InternetSales.ldf', SIZE = 2MB, FILEGROWTH = 10%);
GO

ALTER DATABASE InternetSales
MODIFY FILEGROUP SalesData DEFAULT;
GO
