param (
    [string]$DBName = "TrainingDB"
)

$ServerInstance = "localhost"
$MaxRetries = 10
$RetryCount = 0
$SQLServiceReady = $false

# --- STEP 1: Wait for SQL Server to be ready ---
Write-Host "Waiting for SQL Server instance to start..."
while (-not $SQLServiceReady -and $RetryCount -lt $MaxRetries) {
    try {
        # Try a simple connection test
        $test = Invoke-Sqlcmd -ServerInstance $ServerInstance -Query "SELECT GETDATE()" -ErrorAction Stop
        $SQLServiceReady = $true
        Write-Host "SQL Server is UP and responding."
    }
    catch {
        $RetryCount++
        Write-Host "SQL Server not ready yet (Attempt $RetryCount of $MaxRetries). Waiting 15 seconds..."
        Start-Sleep -Seconds 15
    }
}

if (-not $SQLServiceReady) {
    throw "SQL Server failed to start within the expected time."
}

# --- STEP 2: Execute with high permissions ---
# We use -ErrorAction SilentlyContinue for the CREATE DB in case it exists
Write-Host "Creating Database: $DBName"
Invoke-Sqlcmd -ServerInstance $ServerInstance -Query "IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = '$DBName') CREATE DATABASE [$DBName];" 

Write-Host "Applying Schema to $DBName..."
Invoke-Sqlcmd -ServerInstance $ServerInstance -Database $DBName -InputFile "./Tables-Schema.sql"

Write-Host "Lesson 1 successfully applied to $DBName"
