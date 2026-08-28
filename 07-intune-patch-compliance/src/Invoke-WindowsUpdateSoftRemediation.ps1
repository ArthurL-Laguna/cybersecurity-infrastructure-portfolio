# Invoke-WindowsUpdateSoftRemediation.ps1
# Soft remediation script for service resets and USOClient orchestration[cite: 8]
# Sanitized for production deployment

$logFolder = "C:\Windows\Temp\Scripts_and_remediations"
$logFile   = "WindowsUpdate_SoftRemediation.log"
$logPath   = Join-Path $logFolder $logFile

if (!(Test-Path $logFolder)) {
    New-Item -Path $logFolder -ItemType Directory -Force | Out-Null
}

function Write-Log {
    param([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp [$env:COMPUTERNAME] - $Message" | Out-File -FilePath $logPath -Append -Encoding utf8
}

function Check-RebootRequired {
    return (Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired")
}

Write-Log "=================================================="
Write-Log "STARTING SOFT REMEDIATION V3"
Write-Log "=================================================="

try {
    foreach ($svc in @("wuauserv", "bits", "cryptsvc")) {
        $service = Get-Service $svc -ErrorAction SilentlyContinue
        if ($service) {
            if ($service.Status -ne "Running") {
                Start-Service $svc -ErrorAction SilentlyContinue
                Write-Log "Service started: $svc"
            } else {
                Write-Log "Service OK: $svc"
            }
        }
    }

    Write-Log "Restarting update components..."
    Restart-Service wuauserv -Force -ErrorAction SilentlyContinue
    Restart-Service bits -Force -ErrorAction SilentlyContinue
    Start-Sleep 10

    Write-Log "Executing RefreshSettings"
    Start-Process -FilePath "usoclient.exe" -ArgumentList "RefreshSettings" -NoNewWindow -ErrorAction SilentlyContinue
    Start-Sleep 5

    Write-Log "Executing StartScan"
    Start-Process -FilePath "usoclient.exe" -ArgumentList "StartScan" -NoNewWindow -ErrorAction SilentlyContinue
    Start-Sleep 10

    Write-Log "Executing StartDownload"
    Start-Process -FilePath "usoclient.exe" -ArgumentList "StartDownload" -NoNewWindow -ErrorAction SilentlyContinue
    Start-Sleep 10

    Write-Log "Executing StartInstall"
    Start-Process -FilePath "usoclient.exe" -ArgumentList "StartInstall" -NoNewWindow -ErrorAction SilentlyContinue
    Start-Sleep 10

    if (Check-RebootRequired) {
        Write-Log "[CAUSE=REBOOT] Pending reboot detected"
    }

    Write-Log "=================================================="
    Write-Log "END SOFT REMEDIATION V3"
    Write-Log "=================================================="
    exit 0
}
catch {
    Write-Log "[CAUSE=CRITICAL] $($_.Exception.Message)"
    exit 1
}
