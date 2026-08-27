<#
.SYNOPSIS
    Event Log Auditor for Local Administrator Lifecycle.
.DESCRIPTION
    Queries local Event Viewer logs to verify successful discovery and remediation runs.
.NOTES
    Author: Arthur Luiz Laguna Silva
    Sanitized Version for Portfolio
#>

[CmdletBinding()]
Param(
    [int]$DaysBack = 7
)

$StartDate = (Get-Date).AddDays(-$DaysBack)
Write-Output "Auditing Local Administrator compliance events for the last $DaysBack days..."

Get-WinEvent -FilterHashtable @{
    LogName = 'Application'
    ProviderName = @('SCCM-SetLocalAdminPassword-Discovery', 'SCCM-SetLocalAdminPassword-Remediation')
    StartTime = $StartDate
} -ErrorAction SilentlyContinue | Select-Object TimeCreated, Id, ProviderName, Message | Format-Table -AutoSize
