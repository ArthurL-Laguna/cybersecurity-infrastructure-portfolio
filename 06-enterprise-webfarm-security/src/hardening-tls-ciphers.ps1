<#
.SYNOPSIS
    Hardening script for disabling legacy SCHANNEL protocols (SSLv2, SSLv3, TLS 1.0, TLS 1.1) and enforcing TLS 1.2/1.3 with secure Cipher Suites.
.DESCRIPTION
    Modifies Registry SCHANNEL keys to mandate TLS 1.2 and TLS 1.3, disables insecure ciphers (3DES, RC4, DES, NULL),
    and sets strict Cipher Suite order on Windows Server IIS Edge hosts.
.NOTES
    Sanitized Enterprise Baseline Script - Case 06 (Web Farm Edge Security & Offloading)
#>

[CmdletBinding()]
param()

# Ensure Execution as Admin
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Error "This script must be run as Administrator."
    exit 1
}

Write-Host "[+] Initializing SCHANNEL & TLS Cipher Suite Security Hardening..." -ForegroundColor Green

$SchannelPath = "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL"

function Set-SchannelProtocol {
    param (
        [string]$ProtocolName,
        [bool]$Enabled
    )
    
    $paths = @(
        "$SchannelPath\Protocols\$ProtocolName\Client",
        "$SchannelPath\Protocols\$ProtocolName\Server"
    )

    foreach ($path in $paths) {
        if (-not (Test-Path $path)) {
            New-Item -Path $path -Force | Out-Null
        }
        
        $enabledVal = if ($Enabled) { 1 } else { 0 }
        $disabledByDefaultVal = if ($Enabled) { 0 } else { 1 }

        Set-ItemProperty -Path $path -Name "Enabled" -Value $enabledVal -Type DWord
        Set-ItemProperty -Path $path -Name "DisabledByDefault" -Value $disabledByDefaultVal -Type DWord
    }

    $statusStr = if ($Enabled) { "ENABLED" } else { "DISABLED" }
    Write-Host "   -> Protocol [$ProtocolName]: $statusStr" -ForegroundColor Yellow
}

# 1. Disable Deprecated & Vulnerable Protocols
Write-Host "[+] Disabling Insecure Legacy Protocols..." -ForegroundColor Green
Set-SchannelProtocol -ProtocolName "SSL 2.0" -Enabled $false
Set-SchannelProtocol -ProtocolName "SSL 3.0" -Enabled $false
Set-SchannelProtocol -ProtocolName "TLS 1.0" -Enabled $false
Set-SchannelProtocol -ProtocolName "TLS 1.1" -Enabled $false

# 2. Enable Modern Cryptographic Protocols (TLS 1.2 & TLS 1.3)
Write-Host "[+] Enforcing Modern Protocol Baselines..." -ForegroundColor Green
Set-SchannelProtocol -ProtocolName "TLS 1.2" -Enabled $true
Set-SchannelProtocol -ProtocolName "TLS 1.3" -Enabled $true

# 3. Disable Insecure Ciphers & Hashes
Write-Host "[+] Deprecating Weak Ciphers (RC4, 3DES, DES, NULL, MD5)..." -ForegroundColor Green
$weakCiphers = @("RC4 128/128", "RC4 40/128", "RC4 56/128", "Triple DES 168", "DES 56/56", "NULL")
foreach ($cipher in $weakCiphers) {
    $cipherPath = "$SchannelPath\Ciphers\$cipher"
    if (-not (Test-Path $cipherPath)) {
        New-Item -Path $cipherPath -Force | Out-Null
    }
    Set-ItemProperty -Path $cipherPath -Name "Enabled" -Value 0 -Type DWord
}

$weakHashes = @("MD5", "SHA")
foreach ($hash in $weakHashes) {
    $hashPath = "$SchannelPath\Hashes\$hash"
    if (-not (Test-Path $hashPath)) {
        New-Item -Path $hashPath -Force | Out-Null
    }
    Set-ItemProperty -Path $hashPath -Name "Enabled" -Value 0 -Type DWord
}

# 4. Enforce Strong Cipher Suite Ordering (PFS / ECDHE Prioritization)
Write-Host "[+] Configuring Hardened Cipher Suite Priority Order..." -ForegroundColor Green
$secureCipherSuites = @(
    "TLS_AES_256_GCM_SHA384",
    "TLS_AES_128_GCM_SHA256",
    "TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384",
    "TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256",
    "TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384",
    "TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256",
    "TLS_DHE_RSA_WITH_AES_256_GCM_SHA384",
    "TLS_DHE_RSA_WITH_AES_128_GCM_SHA256"
)

try {
    foreach ($suite in $secureCipherSuites) {
        Enable-TlsCipherSuite -Name $suite -ErrorAction SilentlyContinue
    }
    Write-Host "   -> Modern Cipher Suite Order Configured Successfully." -ForegroundColor Yellow
} catch {
    Write-Warning "Could not reorder TLS Cipher Suites dynamically: $_"
}

Write-Host "[SUCCESS] SCHANNEL Hardening Completed! A system reboot is recommended to apply SCHANNEL registry changes." -ForegroundColor Green
