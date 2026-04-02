Write-Host "Checking for pending reboots to prepare for SQL Server..."
# We don't need complex logic here because 'rebootBehavior: always' 
# in the JSON will force a reboot as soon as this script exits with 0.
Write-Host "Rebooting machine to clear component-based servicing or file renames..."
exit 0
