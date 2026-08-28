# Detect-WindowsUpdateCompliance-IntuneJSON.ps1
# Advanced compliance evaluation script outputting JSON structures for Intune Custom Compliance[cite: 9]
# Sanitized for production deployment

try {
    function Get-SecondTuesday {
        param([datetime]$ReferenceDate)

        $firstDay = Get-Date -Year $ReferenceDate.Year -Month $ReferenceDate.Month -Day 1

        for ($i = 0; $i -lt 15; $i++) {
            $day = $firstDay.AddDays($i)
            if ($day.DayOfWeek -eq 'Tuesday') {
                return $day.AddDays(7)
            }
        }
    }

    function Get-QualityDeferral {
        try {
            return (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\current\device\Update" -ErrorAction Stop).DeferQualityUpdatesPeriodInDays
        }
        catch {
            return 0
        }
    }

    $session = New-Object -ComObject Microsoft.Update.Session
    $searcher = $session.CreateUpdateSearcher()
    $history = $searcher.QueryHistory(0, 200)

    $updates = $history | Where-Object {
        ($_.Title -match "Cumulative Update" -or $_.Title -match "Security Update" -or $_.Title -match "Hotpatch") -and
        ($_.Title -notmatch "\.NET" -and $_.Title -notmatch "Defender" -and $_.Title -notmatch "Malicious" -and $_.Title -notmatch "Removal")
    }

    $latest = $updates | Sort-Object Date -Descending | Select-Object -First 1
    $updateDate = $latest.Date

    if (-not $updateDate) {
        try {
            $pkg = Get-WindowsPackage -Online | Where-Object { $_.PackageName -like "*RollupFix*" } | Sort-Object InstallTime -Descending | Select-Object -First 1
            if ($pkg) { $updateDate = $pkg.InstallTime }
        }
        catch {}
    }

    if (-not $updateDate) {
        throw "No valid update found"
    }

    $patchMonth = Get-Date -Year $updateDate.Year -Month $updateDate.Month -Day 1
    $patchTuesday = Get-SecondTuesday $patchMonth
    $deferral = Get-QualityDeferral
    $effectiveDate = $patchTuesday.AddDays($deferral)

    $days = (New-TimeSpan -Start $effectiveDate -End (Get-Date)).Days

    if ($days -gt 60) {
        $status = "NonCompliant"
    }
    else {
        $status = "Compliant"
    }

    @{
        WindowsUpdateComplianceVerification = $status
    } | ConvertTo-Json -Compress

    exit 0
}
catch {
    @{
        WindowsUpdateComplianceVerification = "NonCompliant"
    } | ConvertTo-Json -Compress

    exit 0
}
