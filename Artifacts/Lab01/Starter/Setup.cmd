@Echo Off
ECHO Preparing the lab environment...

REM - Get current directory
SET SUBDIR=%~dp0

REM - Restart SQL Server Service to force closure of any open connections
NET STOP SQLSERVERAGENT
NET STOP MSSQLSERVER
NET START MSSQLSERVER
NET START SQLSERVERAGENT


REM - Run SQL Script to prepare the database environment
ECHO Preparing Databases...
SQLCMD -E -i "%SUBDIR%SetupFiles\Setup.sql" -C > NUL 

ECHO Delete lab files (ignore errors if they don't exist!!!!!!)...
DEL %SUBDIR%*.ps1 /Q /S
DEL %SUBDIR%*.txt /Q /S
DEL %SUBDIR%*.ssmssln /Q /S
DEL %SUBDIR%*.sql /Q
RMDIR %SUBDIR%AWProject /S /Q

PAUSE



