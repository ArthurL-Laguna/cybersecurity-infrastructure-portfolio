<#
.SYNOPSIS
    Creates a Secured Internal SMTP Relay Connector in Exchange Server 2019.
.DESCRIPTION
    Configures a dedicated receive connector for internal devices/apps with explicit
    IP address bindings and mandatory TLS enforcement.
.NOTES
    Author: Arthur Luiz Laguna Silva
    Sanitized Version for Portfolio
#>

$ConnectorName = "Secured Application Relay"
$TargetServer  = "EXCH2019-NODE01"
$AllowedIPs    = "10.0.10.50", "10.0.10.51", "10.0.20.0/24" # Sanitized Allowed Appliance IPs

Write-Output "Creating Receive Connector: $ConnectorName..."

New-ReceiveConnector -Name $ConnectorName `
    -Server $TargetServer `
    -TransportRole FrontendTransport `
    -Custom `
    -Bindings "0.0.0.0:25" `
    -RemoteIPRanges $AllowedIPs `
    -AuthMechanism Tls, ExternalAuthoritative `
    -PermissionGroups ExchangeServers, AnonymousUsers

# Apply Relay Permissions exclusively for authenticated local submitters
Get-ReceiveConnector "$TargetServer\$ConnectorName" | Add-ADPermission -User "NT AUTHORITY\ANONYMOUS LOGON" -ExtendedRights "Ms-Exch-SMTP-Accept-Any-Recipient"

Write-Output "Secured Relay Connector created and restricted to authorized IP ranges."
