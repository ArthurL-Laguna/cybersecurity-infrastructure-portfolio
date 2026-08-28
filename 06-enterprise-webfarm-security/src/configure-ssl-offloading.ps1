<#
.SYNOPSIS
    Automated script for centralizing TLS certificates, SSL Offloading, and URL Rewrite HTTP-to-HTTPS redirect rules.
.DESCRIPTION
    Configures SSL Offloading on the ARR Reverse Proxy, binds TLS certificates to IIS bindings,
    adds X-Forwarded-For / X-Forwarded-Proto headers, and creates mandatory HTTP to HTTPS rewrite rules.
.NOTES
    Sanitized Enterprise Baseline Script - Case 06 (Web Farm Edge Security & Offloading)
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$SiteName = "Default Web Site",

    [Parameter(Mandatory = $false)]
    [string]$CertThumbprint = "1234567890ABCDEF1234567890ABCDEF12345678",

    [Parameter(Mandatory = $false)]
    [string]$DomainHeader = "app.enterprise-domain.local"
)

# Ensure Execution as Admin
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Error "This script must be run as Administrator."
    exit 1
}

Import-Module WebAdministration -ErrorAction Stop

Write-Host "[+] Initializing SSL Offloading & Perimeter Binding Setup..." -ForegroundColor Green

# 1. Bind Certificate to HTTPS Port 443
$binding = Get-WebBinding -Name $SiteName -Protocol "https" -Port 443
if (-not $binding) {
    Write-Host "   -> Creating HTTPS Binding for $SiteName on port 443..." -ForegroundColor Yellow
    New-WebBinding -Name $SiteName -IPAddress "*" -Port 443 -Protocol "https"
}

Write-Host "   -> Binding SSL Certificate Thumbprint [$CertThumbprint]..." -ForegroundColor Yellow
$certPath = "Cert:\LocalMachine\My\$CertThumbprint"
if (Test-Path $certPath) {
    Get-Item $certPath | New-Item -Path "IIS:\SslBindings\0.0.0.0!443" -Force | Out-Null
} else {
    Write-Warning "Certificate with thumbprint $CertThumbprint not found in LocalMachine\My store. Please verify."
}

# 2. Configure HTTP to HTTPS Automatic Redirect Rule via URL Rewrite
Write-Host "[+] Provisioning Global HTTP to HTTPS Redirect Rule..." -ForegroundColor Green

$rewritePath = "system.webServer/rewrite/rules"
$ruleName = "Redirect-HTTP-to-HTTPS"

$existingRule = Get-WebConfigurationProperty -pspath "IIS:\sites\$SiteName" -filter $rewritePath -name "collection" |
    Where-Object { $_.name -eq $ruleName }

if (-not $existingRule) {
    $ruleXml = @{
        name = $ruleName
        stopProcessing = $true
    }
    
    Add-WebConfigurationProperty -pspath "IIS:\sites\$SiteName" -filter $rewritePath -name "." -value $ruleXml
    Set-WebConfigurationProperty -pspath "IIS:\sites\$SiteName" -filter "$rewritePath/rule[@name='$ruleName']/match" -name "url" -value "(.*)"
    
    $conditionXml = @{
        input = "{HTTPS}"
        pattern = "^OFF$"
    }
    Add-WebConfigurationProperty -pspath "IIS:\sites\$SiteName" -filter "$rewritePath/rule[@name='$ruleName']/conditions" -name "." -value $conditionXml
    
    Set-WebConfigurationProperty -pspath "IIS:\sites\$SiteName" -filter "$rewritePath/rule[@name='$ruleName']/action" -name "type" -value "Redirect"
    Set-WebConfigurationProperty -pspath "IIS:\sites\$SiteName" -filter "$rewritePath/rule[@name='$ruleName']/action" -name "url" -value "https://{HTTP_HOST}/{R:1}"
    Set-WebConfigurationProperty -pspath "IIS:\sites\$SiteName" -filter "$rewritePath/rule[@name='$ruleName']/action" -name "redirectType" -value "Permanent"
    
    Write-Host "   -> HTTP to HTTPS Redirect Rule Created Successfully." -ForegroundColor Yellow
}

# 3. Configure SSL Offloading Header Propagation
Write-Host "[+] Enforcing Reverse Proxy SSL Headers (X-Forwarded-Proto / X-Forwarded-For)..." -ForegroundColor Green
$proxySection = 'system.webServer/proxy'
Set-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST' -section $proxySection -name 'setResponseHeader' -value $true

$allowedServerVars = "system.webServer/rewrite/allowedServerVariables"
$headersToAdd = @("HTTP_X_FORWARDED_FOR", "HTTP_X_FORWARDED_PROTO", "HTTP_X_ARR_SSL")

foreach ($header in $headersToAdd) {
    $varCheck = Get-WebConfigurationProperty -pspath "IIS:\sites\$SiteName" -filter $allowedServerVars -name "collection" |
        Where-Object { $_.name -eq $header }
    if (-not $varCheck) {
        Add-WebConfigurationProperty -pspath "IIS:\sites\$SiteName" -filter $allowedServerVars -name "." -value @{name=$header}
    }
}

Write-Host "[SUCCESS] SSL Offloading & Edge Routing Rules Configured Successfully!" -ForegroundColor Green
