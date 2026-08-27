<#
.SYNOPSIS
    Active Directory Hardening - Legacy Authentication Audit & Remediation.
.DESCRIPTION
    Audits and enforces registry keys to disable SMBv1 and restrict NTLMv1,
    forcing Kerberos and NTLMv2 usage across member servers.
.NOTES
    Author: Arthur Luiz Laguna Silva
    Sanitized Version for Portfolio
#>

# Enforce SMBv1 Disable
Write-Output "Auditing SMBv1 Server configuration..."
if (Get-Service -Name LanmanServer -ErrorAction SilentlyContinue) {
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" -Name "SMB1" -Type DWORD -Value 0 -Force
    Write-Output "SMBv1 has been permanently disabled in HKLM registry."
}

# Restrict NTLMv1 (Send NTLMv2 response only / refuse LM & NTLM)
Write-Output "Configuring LSA authentication level..."
$LsaPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa"
Set-ItemProperty -Path $LsaPath -Name "LmCompatibilityLevel" -Type DWORD -Value 5 -Force

Write-Output "Authentication hardening completed. NTLMv2 and Kerberos mandated."
