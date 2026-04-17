@echo off
SET "LAB_NUM=%1"

:: Check for input immediately to avoid errors in variable logic
if "%1"=="" echo Usage: SwitchLab [LabNumber] (e.g., SwitchLab 7) & exit /b

:: Add a leading zero for labs 1-9 to match folder naming conventions
IF %LAB_NUM% LSS 10 SET "LAB_NUM=0%LAB_NUM%"

SET "LAB_PATH=C:\SQLServerAdminLabs\Labfiles\Lab%LAB_NUM%\Starter"
SET "BG_DIR=C:\SQLServerAdminLabs\Tools\BGInfo"

echo [INFO] Preparing Environment for Lab %LAB_NUM%...

:: 1. Update BGInfo Text
echo Lab %LAB_NUM% > "%BG_DIR%\CurrentLab.txt"

:: 2. Stop Services to Clear Locks
echo [INFO] Stopping SQL Services...
net stop SQLSERVERAGENT /y >nul 2>&1
net stop MSSQLSERVER /y >nul 2>&1

:: 3. File System Cleanup
echo [INFO] Cleaning Files...
del C:\Backups\*.bak /Q >nul 2>&1
if exist "%LAB_PATH%\*.trc" del "%LAB_PATH%\*.trc" /Q >nul 2>&1

:: 4. Start Services & Run Deep Clean
echo [INFO] Starting SQL Services and running Deep Clean...
net start MSSQLSERVER >nul
sqlcmd -S localhost -E -i "C:\SQLServerAdminLabs\Tools\DeepClean.sql" >nul 2>&1

:: 5. Run the Specific Lab Setup AS ADMINISTRATOR
echo [INFO] Requesting Admin privileges for Lab %LAB_NUM% Setup...
if exist "%LAB_PATH%\Setup.cmd" (
    pushd "%LAB_PATH%"
    :: Use PowerShell to start Setup.cmd with 'runas' verb
    powershell -Command "Start-Process 'Setup.cmd' -Verb RunAs -Wait"
    popd
) else (
    echo [WARNING] No Setup.cmd found for Lab %LAB_NUM%.
)

:: 6. Refresh BGInfo Background
start "" "%BG_DIR%\bginfo64.exe" "%BG_DIR%\LabSetup.bgi" /timer:0 /nolicprompt /silent

echo [SUCCESS] VM is now completely reset and ready for Lab %LAB_NUM%.