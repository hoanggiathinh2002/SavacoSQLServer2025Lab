USE master
GO

-- drop encryption keys
WHILE (SELECT COUNT(*) FROM sys.databases WHERE is_encrypted = 1) > 0
BEGIN
	DECLARE @n SYSNAME, @sql NVARCHAR(200);
	SELECT @n = (SELECT MAX(name) FROM sys.databases WHERE is_encrypted = 1);
	SET @sql = 'DROP DATABASE ' + @n;
	EXECUTE sp_executesql  @sql;
END
GO

WHILE (SELECT COUNT(*) FROM sys.symmetric_keys WHERE name NOT LIKE '#%') > 0
BEGIN
	DECLARE @n SYSNAME, @sql NVARCHAR(200);
	SELECT @n = (SELECT MAX(name) FROM sys.symmetric_keys WHERE name NOT LIKE '#%');
	SET @sql = 'DROP SYMMETRIC KEY ' + @n;
	EXECUTE sp_executesql  @sql;
END
GO

WHILE (SELECT COUNT(*) FROM sys.asymmetric_keys WHERE name NOT LIKE '#%') > 0
BEGIN
	DECLARE @n SYSNAME, @sql NVARCHAR(200);
	SELECT @n = (SELECT MAX(name) FROM sys.asymmetric_keys WHERE name NOT LIKE '#%');
	SET @sql = 'DROP ASYMMETRIC KEY ' + @n;
	EXECUTE sp_executesql  @sql;
END
GO

WHILE (SELECT COUNT(*) FROM sys.certificates WHERE name NOT LIKE '#%') > 0
BEGIN
	DECLARE @n SYSNAME, @sql NVARCHAR(200);
	SELECT @n = (SELECT MAX(name) FROM sys.certificates WHERE name NOT LIKE '#%');
	SET @sql = 'DROP CERTIFICATE ' + @n;
	EXECUTE sp_executesql  @sql;
END
GO

DROP MASTER KEY;
GO


-- drop databases
IF EXISTS(SELECT * FROM sys.sysdatabases WHERE name = 'HumanResources')
BEGIN
	DROP DATABASE HumanResources
END
GO


EXEC  msdb.dbo.sp_delete_database_backuphistory @database_name = 'HumanResources';
GO

IF EXISTS(SELECT * FROM sys.sysdatabases WHERE name = 'InternetSales')
BEGIN
	DROP DATABASE InternetSales
END
GO

