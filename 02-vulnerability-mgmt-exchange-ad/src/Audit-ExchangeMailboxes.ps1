<#
.SYNOPSIS
    Pre-Migration Mailbox Assessment Script.
.DESCRIPTION
    Collects mailbox statistics, sizes, and legacy protocol flags prior to hybrid migration.
.NOTES
    Author: Arthur Luiz Laguna Silva
    Sanitized Version for Portfolio
#>

[CmdletBinding()]
Param(
    [string]$ExportPath = "C:\MigrationReports\MailboxAudit.csv"
)

Write-Output "Starting Exchange Mailbox Pre-Migration Audit..."

# Query Exchange mailboxes (Sanitized cmdlet placeholder for local execution)
$Mailboxes = Get-Mailbox -ResultSize Unlimited | Where-Object { $_.RecipientTypeDetails -eq "UserMailbox" }

$Report = foreach ($Mb in $Mailboxes) {
    $Stats = Get-MailboxStatistics -Identity $Mb.UserPrincipalName
    [PSCustomObject]@{
        DisplayName        = $Mb.DisplayName
        UserPrincipalName  = $Mb.UserPrincipalName
        TotalItemSizeMB    = [math]::Round(($Stats.TotalItemSize.Value.ToBytes() / 1MB), 2)
        ItemCount          = $Stats.ItemCount
        MAPIEnabled        = $Mb.MAPIEnabled
        OWAEnabled         = $Mb.OWAEnabled
        LegacyProtocols    = ($Mb.PopEnabled -or $Mb.ImapEnabled)
    }
}

$Report | Export-Csv -Path $ExportPath -NoTypeInformation -Encoding UTF8
Write-Output "Audit completed. Report saved to $ExportPath"
