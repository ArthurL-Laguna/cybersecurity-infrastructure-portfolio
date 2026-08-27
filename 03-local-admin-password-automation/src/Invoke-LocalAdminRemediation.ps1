<#
.SYNOPSIS
    Remediation Script - Automated Local Administrator Password Correction.
.DESCRIPTION
    Triggered automatically by SCCM when a workstation is evaluated as NonCompliant.
    Updates the local administrator password via ADSI and logs the event.
.NOTES
    Author: Arthur Luiz Laguna Silva
    Context: Enterprise SCCM Configuration Item (CI) Remediation
#>

param($Out)

If ($Out -eq "NonCompliant") {
    $Computer = $env:COMPUTERNAME
    $Username = 'Tiger'
    $Password = 'P@ssw0rd'

    $adminObj = [adsi]("WinNT://$Computer/$Username,user")
    $adminObj.psbase.invoke("SetPassword", $Password)
    $adminObj.psbase.CommitChanges()

    Add-Type -AssemblyName System.DirectoryServices.AccountManagement
    $obj = New-Object System.DirectoryServices.AccountManagement.PrincipalContext('machine', $computer)
    $OutResult = $obj.ValidateCredentials($Username, $password)

    $LogName = "Application"
    $SourceRem = "SCCM-SetLocalAdminPassword-Remediation"

    if (-not [System.Diagnostics.EventLog]::SourceExists($SourceRem)) {
        [System.Diagnostics.EventLog]::CreateEventSource($SourceRem, $LogName)
    }

    If ($OutResult -eq $True) {
        Write-EventLog -LogName $LogName -Source $SourceRem -EventId 501 -EntryType Information -Message "Local Admin Password was corrected by Auto-Remediation successfully."
    } Else {
        Write-EventLog -LogName $LogName -Source $SourceRem -EventId 502 -EntryType Error -Message "Auto-Remediation failed to validate the updated local password."
    }
}
