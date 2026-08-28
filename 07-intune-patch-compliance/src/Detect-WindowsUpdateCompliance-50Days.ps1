# Detect-WindowsUpdateCompliance-50Days.ps1
# Compliance detection script utilizing 50-day threshold logic[cite: 5]
# Sanitized for production deployment

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

function Get-LatestCUDate {
    try {
        $session = New-Object -ComObject Microsoft.Update.Session
        $searcher = $session.CreateUpdateSearcher()
        $history = $searcher.QueryHistory(0, 200)

        $updates = $history | Where-Object {
            ($_.Title -match "Cumulative Update" -or $_.Title -match "Security Update" -or $_.Title -match "Hotpatch") -and
            ($_.Title -notmatch "\.NET" -and $_.Title -notmatch "Defender" -and $_.Title -notmatch "Malicious" -and $_.Title -notmatch "Removal")
        }

        if ($updates) {
            return ($updates | Sort-Object Date -Descending | Select-Object -First 1).Date
        }
    }
    catch {}

    try {
        $pkg = Get-WindowsPackage -Online | Where-Object { $_.PackageName -like "*RollupFix*" } | Sort-Object InstallTime -Descending | Select-Object -First 1
        if ($pkg) { return $pkg.InstallTime }
    }
    catch {}

    return $null
}

function Test-PendingLCU {
    try {
        $session = New-Object -ComObject Microsoft.Update.Session
        $searcher = $session.CreateUpdateSearcher()
        $result = $searcher.Search("IsInstalled=0 and Type='Software'")
        $updates = @($result.Updates)

        $relevant = $updates | Where-Object {
            ($_.Title -match "Cumulative Update|Security Update|Hotpatch") -and
            ($_.Title -notmatch "\.NET|Defender|Malicious|Removal")
        }

        return ($relevant.Count -gt 0)
    }
    catch {
        return $false
    }
}

try {
    $today = Get-Date
    $updateDate = Get-LatestCUDate
    if (-not $updateDate) { exit 1 }

    $patchMonth = Get-Date -Year $updateDate.Year -Month $updateDate.Month -Day 1
    $patchTuesday = Get-SecondTuesday $patchMonth
    $deferral = Get-QualityDeferral
    $effectiveDate = $patchTuesday.AddDays($deferral)

    $days = (New-TimeSpan -Start $effectiveDate -End $today).Days
    $pendingLCU = Test-PendingLCU

    if (($days -gt 50) -and $pendingLCU) {
        exit 1
    }

    exit 0
}
catch {
    exit 1
}
