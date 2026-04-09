@Echo Off
ECHO Preparing the lab environment...

REM - Get current directory
SET SUBDIR=%~dp0

REM - Restart SQL Server Service
NET STOP SQLSERVERAGENT
NET STOP MSSQLSERVER
REM NET STOP SQLAGENT$SQL2
REM NET STOP MSSQL$SQL2
NET START MSSQLSERVER
REM NET START MSSQL$SQL2
NET START SQLSERVERAGENT
REM NET START SQLAGENT$SQL2

REM Create folders for database files
ECHO Creating folders for database files (ignore errors if they already exist!)...
MD C:\Logs > NUL
MD C:\Data > NUL
MD C:\Backups > NUL
ECHO Deleting backup files (ignore errors if they don't exist!)...
DEL C:\Backups\*.bak /Q > NUL

REM - Run SQL Script to prepare the database environment
ECHO Configuring databases...
SQLCMD -S localhost -E -i %SUBDIR%SetupFiles\Setup2.sql -C > NUL
SQLCMD -E -i %SUBDIR%SetupFiles\Setup.sql -C > NUL

ECHO Setup Complete.
