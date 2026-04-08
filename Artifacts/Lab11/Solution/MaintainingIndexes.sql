-- Check fragmentation
USE HumanResources;
SELECT * 
FROM sys.dm_db_index_physical_stats(DB_ID(),
                                    OBJECT_ID('Employees.Employee'),
                                    NULL,
                                    NULL,
                                    'DETAILED');
GO



-- Rebuild the indexes
ALTER INDEX ALL ON Employees.Employee REBUILD;
GO

-- Check the fragmentation again
SELECT * 
FROM sys.dm_db_index_physical_stats(DB_ID(),
                                    OBJECT_ID('Employees.Employee'),
                                    NULL,
                                    NULL,
                                    'DETAILED');
GO


