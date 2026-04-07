param (
    [string]$DBName = "TrainingDB"
)

# Use the local SQL instance (assuming it's installed on the VM)
$ServerInstance = "localhost"

# Execute the T-SQL script
Invoke-Sqlcmd -ServerInstance $ServerInstance -Database "master" -Query "IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = '$DBName') CREATE DATABASE [$DBName];"
Invoke-Sqlcmd -ServerInstance $ServerInstance -Database $DBName -InputFile "./Tables-Schema.sql"

Write-Host "Lesson 1 successfully applied to $DBName"
