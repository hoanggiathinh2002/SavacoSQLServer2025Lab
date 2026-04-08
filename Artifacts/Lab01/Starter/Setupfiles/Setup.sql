USE master
GO

-- Drop and restore Databases
IF EXISTS(SELECT * FROM sys.sysdatabases WHERE name = 'AWDatabase')
BEGIN
	DROP DATABASE AWDatabase
END
GO
