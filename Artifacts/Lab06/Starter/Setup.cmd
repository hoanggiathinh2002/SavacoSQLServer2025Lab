@Echo Off
ECHO Preparing the lab environment...

REM - Get current directory
SET SUBDIR=%~dp0

REM - Restart SQL Server Service
ECHO Restarting SQL Server services...
NET STOP SQLSERVERAGENT
NET STOP MSSQLSERVER
NET START MSSQLSERVER
NET START SQLSERVERAGENT

REM Create folders for database files
ECHO Creating folders for database files...
IF NOT EXIST "C:\Logs" MD C:\Logs
IF NOT EXIST "C:\Data" MD C:\Data
IF NOT EXIST "C:\Backups" MD C:\Backups

ECHO Cleaning up old files (Keeping files from today)...
/D -1 targets files modified before today. 
REM Adjust -1 to -7 if you want to keep a week's worth.

FORFILES /P "C:\Backups" /M *.bak /D -1 /C "cmd /c del @path" 2>NUL
FORFILES /P "%SUBDIR%." /M *.xl* /D -1 /C "cmd /c del @path" 2>NUL
FORFILES /P "%SUBDIR%." /M *.xml /D -1 /C "cmd /c del @path" 2>NUL
FORFILES /P "%SUBDIR%." /M *.bacpac /D -1 /C "cmd /c del @path" 2>NUL

COPY "%SUBDIR%SetupFiles\CurrencyRates.csv" "C:\CurrencyRates.csv" /Y

REM - Run SQL Script to prepare the database environment
ECHO Configuring databases...
SQLCMD -S localhost -E -i "%SUBDIR%SetupFiles\Setup2.sql" -C > NUL 
SQLCMD -E -i "%SUBDIR%SetupFiles\Setup.sql" -C > NUL 

ECHO Setup Complete.