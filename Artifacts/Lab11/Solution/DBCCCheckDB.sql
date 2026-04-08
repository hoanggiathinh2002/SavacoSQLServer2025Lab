
-- Check AWDataWarehouse
DBCC CHECKDB('AWDataWarehouse') WITH NO_INFOMSGS;
GO

-- Check HumanResources
DBCC CHECKDB('HumanResources') WITH NO_INFOMSGS;
GO

-- Check InternetSales
DBCC CHECKDB('InternetSales') WITH NO_INFOMSGS;
GO

-- Repair the database
ALTER DATABASE InternetSales SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
GO
DBCC CHECKDB('InternetSales', REPAIR_ALLOW_DATA_LOSS);
GO
ALTER DATABASE InternetSales SET MULTI_USER WITH ROLLBACK IMMEDIATE;
GO


-- Check the internal database structure
DBCC CHECKDB('InternetSales') WITH NO_INFOMSGS;
GO

