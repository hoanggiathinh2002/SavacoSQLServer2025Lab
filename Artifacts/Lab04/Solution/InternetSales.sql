-- Set the recovery model
USE master;
GO
ALTER DATABASE InternetSales SET RECOVERY FULL WITH NO_WAIT;
GO

-- Back up the database
BACKUP DATABASE InternetSales TO  DISK = 'C:\Backups\InternetSales.bak'
WITH FORMAT, INIT,  MEDIANAME = 'Internet Sales Backup',  NAME = 'InternetSales-Full Database Backup', COMPRESSION;
GO

-- Modify the database
UPDATE InternetSales.dbo.Product
SET ListPrice = ListPrice * 1.1
WHERE ProductSubcategoryID = 1;

-- Back up the transaction log
BACKUP LOG InternetSales TO  DISK = 'C:\Backups\InternetSales.bak'
WITH NOFORMAT, NOINIT,  NAME = 'InternetSales-Transaction Log Backup', COMPRESSION;
GO

-- Modify the database
UPDATE InternetSales.dbo.Product
SET ListPrice = ListPrice * 1.1
WHERE ProductSubcategoryID = 2;

-- Perform a differential backup
BACKUP DATABASE InternetSales TO  DISK = 'C:\Backups\InternetSales.bak'
WITH  DIFFERENTIAL, NOFORMAT, NOINIT,  NAME = 'InternetSales-Differential Backup',COMPRESSION;
GO

-- Modify the database
UPDATE InternetSales.dbo.Product
SET ListPrice = ListPrice * 1.1
WHERE ProductSubcategoryID = 3;

-- Backup the transaction log
BACKUP LOG InternetSales TO  DISK = 'C:\Backups\InternetSales.bak'
WITH NOFORMAT, NOINIT,  NAME = 'InternetSales-Transaction Log Backup 2', COMPRESSION;
GO

-- Verify backup media
RESTORE HEADERONLY 
FROM DISK = 'C:\Backups\InternetSales.bak';
GO

RESTORE FILELISTONLY 
FROM DISK = 'C:\Backups\InternetSales.bak';
GO

RESTORE VERIFYONLY 
FROM DISK = 'C:\Backups\InternetSales.bak';
GO
