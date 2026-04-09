@Echo Off
ECHO Preparing the lab environment...

REM - Get current directory
SET SUBDIR=%~dp0

REM - Restart SQL Server Service
NET STOP SQLSERVERAGENT
NET STOP MSSQLSERVER
NET STOP SQLAGENT$SQL2
NET STOP MSSQL$SQL2
NET START MSSQLSERVER
NET START MSSQL$SQL2
NET START SQLSERVERAGENT
NET START SQLAGENT$SQL2

REM - Run SQL Script to prepare the database environment
ECHO Configuring databases...
SQLCMD -S local\SQL2 -E -i %SUBDIR%SetupFiles\Setup2.sql > NUL
SQLCMD -E -i %SUBDIR%SetupFiles\Setup.sql > NUL

REM Create folders for database files
ECHO Creating folders for database files
MD C:\Logs > NUL
MD C:\Data > NUL

XCOPY %SUBDIR%SetupFiles\AWData*.* %SUBDIR% /Q /Y

PAUSE


