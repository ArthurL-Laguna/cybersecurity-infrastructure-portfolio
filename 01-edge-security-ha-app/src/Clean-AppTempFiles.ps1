<#
.SYNOPSIS
    Automated Maintenance & Temporary File Sanitization Script for Web Nodes.
.DESCRIPTION
    Purges temporary application files, cached assets, and old session logs 
    to prevent disk saturation and mitigate potential data leakage risks.
.NOTES
    Author: Arthur Luiz Laguna Silva
    Sanitized Version for Portfolio
#>

# Define target temp directories and retention thresholds
$TempFolderPath = "C:\AppTempStorage\SessionData"
$LogFolderPath  = "C:\AppLogs\SyncService"
$DaysToRetain   = 7
$CutoffDate     = (Get-Date).AddDays(-$DaysToRetain)

Write-Output "Starting maintenance routine - $(Get-Date)"

# Purge old session/temp files
if (Test-Path -Path $TempFolderPath) {
    Get-ChildItem -Path $TempFolderPath -Recurse -File | Where-Object {
        $_.LastWriteTime -lt $CutoffDate
    } | Remove-Item -Force -ErrorAction SilentlyContinue
    
    Write-Output "Temp files older than $DaysToRetain days purged successfully."
} else {
    Write-Warning "Target path $TempFolderPath does not exist."
}

# Purge old application logs
if (Test-Path -Path $LogFolderPath) {
    Get-ChildItem -Path $LogFolderPath -Filter "*.log" | Where-Object {
        $_.LastWriteTime -lt $CutoffDate
    } | Remove-Item -Force -ErrorAction SilentlyContinue
    
    Write-Output "Application logs purged successfully."
}

Write-Output "Maintenance routine completed - $(Get-Date)"
