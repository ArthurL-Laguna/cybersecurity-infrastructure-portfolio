<#
.SYNOPSIS
    Automated deployment script for configuring IIS Application Request Routing (ARR 3.0) Reverse Proxy and Server Farm.
.DESCRIPTION
    Installs required IIS features, initializes Web Farm Framework / ARR, configures Server Farm routing,
    enforces Weighted Round Robin, configures health checks, response buffer limits, and custom HTTP/HTTPS rules.
.NOTES
    Sanitized Enterprise Baseline Script - Case 06 (Web Farm Edge Security & Offloading)
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$FarmName = "WebFarm-Enterprise-Prod",

    [Parameter(Mandatory = $false)]
    [string[]]$BackendNodes = @("10.0.10.21", "10.0.10.22"),

    [Parameter(Mandatory = $false)]
    [int]$ResponseBufferThresholdKB = 1024,

    [Parameter(Mandatory = $false)]
    [int]$ConnectionTimeoutSeconds = 120
)

# Ensure execution with Administrator privileges
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Error "This script must be run as Administrator."
    exit 1
}

Write-Host "[+] Initializing IIS ARR Server Farm Setup: $FarmName" -ForegroundColor Green

# 1. Ensure Required IIS Features & WebAdministration Module
$requiredFeatures = @("Web-Server", "Web-WebServer", "Web-Common-Http", "Web-Url-Rewrite", "Web-AppInit")
foreach ($feature in $requiredFeatures) {
    if ((Get-WindowsFeature -Name $feature).InstallState -ne "Installed") {
        Write-Host "   -> Installing feature: $feature" -ForegroundColor Yellow
        Install-WindowsFeature -Name $feature -IncludeManagementTools | Out-Null
    }
}

Import-Module WebAdministration -ErrorAction Stop

# 2. Configure Global ARR Settings (Response Buffer Threshold & Timeouts)
Write-Host "[+] Configuring ARR Global Proxy Settings..." -ForegroundColor Green
Set-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST' -section 'system.webServer/proxy' -name 'enabled' -value $true
Set-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST' -section 'system.webServer/proxy' -name 'responseBufferThreshold' -value ($ResponseBufferThresholdKB * 1024)
Set-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST' -section 'system.webServer/proxy' -name 'timeout' -value (New-TimeSpan -Seconds $ConnectionTimeoutSeconds)
Set-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST' -section 'system.webServer/proxy' -name 'reverseRewriteHostInResponseHeaders' -value $false

# 3. Create Web Farm Configuration
Write-Host "[+] Setting up Web Farm Config: $FarmName" -ForegroundColor Green
$farmPath = "system.webServer/webFarms/webFarm[@name='$FarmName']"

if (-not (Get-WebConfiguration -xpath $farmPath)) {
    Add-WebConfiguration -pspath 'MACHINE/WEBROOT/APPHOST' -filter 'system.webServer/webFarms' -value @{name=$FarmName}
}

# Add Backend Server Nodes
foreach ($node in $BackendNodes) {
    $serverPath = "$farmPath/server[@address='$node']"
    if (-not (Get-WebConfiguration -xpath $serverPath)) {
        Write-Host "   -> Adding Node: $node" -ForegroundColor Yellow
        Add-WebConfiguration -pspath 'MACHINE/WEBROOT/APPHOST' -filter "$farmPath" -value @{address=$node; enabled=$true}
        
        # Configure Port and HTTP/HTTPS Endpoints
        Set-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST' -filter "$farmPath/server[@address='$node']/applicationRequestRouting/protocol[@name='HTTP']" -name 'port' -value 80
    }
}

# 4. Load Balancing & Health Check Settings
Write-Host "[+] Enforcing Weighted Round-Robin & Health Monitoring Probes..." -ForegroundColor Green
Set-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST' -filter "$farmPath/applicationRequestRouting/loadBalancing" -name 'algorithm' -value 'WeightedRoundRobin'

# Health Check Probe Configuration
Set-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST' -filter "$farmPath/applicationRequestRouting/healthCheck" -name 'url' -value "http://$FarmName/healthcheck.html"
Set-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST' -filter "$farmPath/applicationRequestRouting/healthCheck" -name 'interval' -value (New-TimeSpan -Seconds 15)
Set-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST' -filter "$farmPath/applicationRequestRouting/healthCheck" -name 'timeout' -value (New-TimeSpan -Seconds 5)
Set-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST' -filter "$farmPath/applicationRequestRouting/healthCheck" -name 'statusCodeMatch' -value "200-399"

# 5. Session Affinity (Stickiness via ARRAffinity Cookie)
Write-Host "[+] Configuring Session Affinity (ARRAffinity Cookie)..." -ForegroundColor Green
Set-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST' -filter "$farmPath/applicationRequestRouting/affinity" -name 'useCookie' -value $true
Set-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST' -filter "$farmPath/applicationRequestRouting/affinity" -name 'cookieName' -value "ARRAffinity"

Write-Host "[SUCCESS] ARR Server Farm [$FarmName] successfully configured!" -ForegroundColor Green
