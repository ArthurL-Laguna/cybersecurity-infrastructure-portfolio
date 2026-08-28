# setup-arr-farm.ps1
# Script to configure IIS Application Request Routing (ARR) Farm and Load Balancing
# Sanitized for production deployment

Import-Module WebAdministration

$farmName = "WebFarmCluster"
$primaryServer = "FARM-Node-01"
$secondaryServer = "FARM-Node-02"

Write-Host "Creating Web Farm: $farmName..." -ForegroundColor Cyan
New-WebFarm -Name $farmName

Write-Host "Adding servers to the farm..." -ForegroundColor Cyan
Add-WebFarmServer -FarmName $farmName -Address $primaryServer
Add-WebFarmServer -FarmName $farmName -Address $secondaryServer

Write-Host "Configuring routing properties and weighted round-robin..." -ForegroundColor Cyan
Set-WebConfigurationProperty -Filter "/system.webServer/webFarms/webFarm[@name='$farmName']/loadMetric" -Name "type" -Value "httpPercent"

Write-Host "Enabling client affinity (ARRAffinity)..." -ForegroundColor Cyan
Set-WebConfigurationProperty -Filter "/system.webServer/webFarms/webFarm[@name='$farmName']/routing" -Name "affinityEnabled" -Value $true

Write-Host "ARR Farm setup completed successfully." -ForegroundColor Green
