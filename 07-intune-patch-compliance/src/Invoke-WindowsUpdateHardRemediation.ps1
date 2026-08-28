# Invoke-WindowsUpdateHardRemediation.ps1
# Hard remediation script for cache purging (SoftwareDistribution/catroot2) and deep repair[cite: 7]
# Sanitized for production deployment

$logFolder = "C:\Windows\Temp\Scripts_and_remediations"
$logFile   = "WindowsUpdate_HardRemediation.log"
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
    Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired"
}

$Services = @("wuauserv", "bits", "cryptsvc", "UsoSvc", "WaaSMedicSvc")

Write-Log "=================================================="
Write-Log "STARTING HARD REMEDIATION V2"
Write-Log "=================================================="

try {
    $backupTimestamp = Get-Date -Format "yyyyMMdd_HHmmss"

    foreach ($svc in $Services) {
        $service = Get-Service -Name $svc -ErrorAction SilentlyContinue
        if ($service -and $service.Status -eq "Running") {
            Stop-Service -Name $svc -Force -ErrorAction SilentlyContinue
            Write-Log "Stopped service: $svc"
        }
    }

    Start-Sleep 10

    # Purge BITS jobs
    Get-BitsTransfer -AllUsers -ErrorAction SilentlyContinue | Remove-BitsTransfer -Confirm:$false -ErrorAction SilentlyContinue

    # Reset SoftwareDistribution
    $sd = Join-Path $env:SystemRoot "SoftwareDistribution"
    if (Test-Path $sd) {
        $backupName = "SoftwareDistribution_$backupTimestamp.old"
        Rename-Item -Path $sd -NewName $backupName -ErrorAction Stop
        Write-Log "Renamed SoftwareDistribution to $backupName"
    }

    # Reset Catroot2
    $catroot = "$env:SystemRoot\System32\catroot2"
    if (Test-Path $catroot) {
        $backupName = "catroot2_$backupTimestamp.old"
        Rename-Item -Path $catroot -NewName $backupName -ErrorAction Stop
        Write-Log "Renamed Catroot2 to $backupName"
    }

    # Restart services
    foreach ($svc in $Services) {
        Start-Service -Name $svc -ErrorAction SilentlyContinue
    }
    Start-Sleep 15

    Start-Process -FilePath "usoclient.exe" -ArgumentList "RefreshSettings" -NoNewWindow -WindowStyle Hidden -ErrorAction SilentlyContinue
    Start-Sleep 10
    Start-Process -FilePath "usoclient.exe" -ArgumentList "StartScan" -NoNewWindow -ErrorAction SilentlyContinue

    if (Check-RebootRequired) {
        Write-Log "[CAUSE=REBOOT] Pending reboot required post-remediation"
    }

    Write-Log "=================================================="
    Write-Log "END HARD REMEDIATION V2"
    Write-Log "=================================================="
    exit 0
}
catch {
    Write-Log "[CAUSE=CRITICAL] $($_.Exception.Message)"
    exit 1
}
