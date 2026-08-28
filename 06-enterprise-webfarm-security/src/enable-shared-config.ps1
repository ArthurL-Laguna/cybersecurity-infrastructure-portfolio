# enable-shared-config.ps1
# Script to export and configure IIS Shared Configuration across farm nodes
# Sanitized for production deployment

Import-Module WebAdministration

$sharePath = "\\LB-Node-01\IIS$\Shared Configuration"
$localPath = "$env:windir\System32\inetsrv\config"
$userName = "Domain\IISAdmin"
$password = "SecurePasswordHere"

Write-Host "Exporting local IIS configuration to central share: $sharePath..." -ForegroundColor Cyan

# Export configuration files
Publish-WebConfiguration -local -physicalPath $sharePath -computerName "localhost"

Write-Host "Configuring physical path credentials and enabling Shared Configuration..." -ForegroundColor Cyan
Set-WebConfigurationProperty -Filter "/system.applicationHost/configHistory" -Name "enabled" -Value $true

# Enable shared configuration mode pointing to the SMB repository
Enable-SharedConfiguration -path $sharePath -userName $userName -password $password

Write-Host "IIS Shared Configuration enabled successfully. Zero configuration drift enforced." -ForegroundColor Green
