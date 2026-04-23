# 1. Define the list of usernames based on your SQL script
$userList = @(
    "Database_Managers",
    "WebApplicationSvc",
    "InternetSales_Users",
    "IntSales_Managers"
)

# 2. Set a secure password for the new accounts
# Replace 'Admin1234567' with your desired default password
$password = ConvertTo-SecureString "Admin1234567" -AsPlainText -Force

foreach ($username in $userList) {
    # Check if the user already exists to avoid errors
    if (-not (Get-LocalUser -Name $username -ErrorAction SilentlyContinue)) {
        
        New-LocalUser -Name $username -Password $password -Description "Account for SQL Server SSMS Access" -PasswordNeverExpires
        
        Write-Host "Successfully created user: $username" -ForegroundColor Green
    } 
    else {
        Write-Host "User $username already exists. Skipping..." -ForegroundColor Yellow
    }
}

# 3. Quick Verification
Write-Host "`nSummary of Local Users:" -ForegroundColor White
Get-LocalUser | Where-Object { $userList -contains $_.Name } | Select-Object Name, Enabled, LastLogon