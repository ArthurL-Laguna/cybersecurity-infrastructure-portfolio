<#
.SYNOPSIS
    Discovery Script - Local Administrator Password Compliance Check.
.DESCRIPTION
    Validates local administrator credentials using System.DirectoryServices.AccountManagement 
    and logs status to the Windows Event Viewer for SCCM Configuration Baseline tracking.
.NOTES
    Author: Arthur Luiz Laguna Silva
    Context: Enterprise SCCM Configuration Item (CI) Discovery
#>

$Computer = $env:COMPUTERNAME
$Username = 'Tiger'
$Password = 'P@ssw0rd' # Standardized enterprise managed local password

$OutResult = $(
    Add-Type -AssemblyName System.DirectoryServices.AccountManagement
    $obj = New-Object System.DirectoryServices.AccountManagement.PrincipalContext('machine', $computer)
    $obj.ValidateCredentials($Username, $password)
)

$LogName = "Application"
$SourceDisc = "SCCM-SetLocalAdminPassword-Discovery"

if (-not [System.Diagnostics.EventLog]::SourceExists($SourceDisc)) {
    [System.Diagnostics.EventLog]::CreateEventSource($SourceDisc, $LogName)
}

if ($OutResult -eq $True) {
    Write-EventLog -LogName $LogName -Source $SourceDisc -EventId 501 -EntryType Information -Message "Local Admin Password already correct and compliant."
    Write-Output "Compliant"
} else {
    Write-EventLog -LogName $LogName -Source $SourceDisc -EventId 502 -EntryType Warning -Message "Local Admin Password non-compliant or mismatched."
    Write-Output "NonCompliant"
}
