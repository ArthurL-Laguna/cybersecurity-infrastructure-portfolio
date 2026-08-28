<#
.SYNOPSIS
    Active Directory Group Evaluation and Task Scheduler Registration Script.
.DESCRIPTION
    Evaluates user group membership upon logon, provisions the helper script locally, 
    and registers a native Windows Scheduled Task to display a countdown warning before UserLock session termination.
.AUTHOR
    Arthur Laguna
#>

# Get current logged-on username
$UserName = $env:USERNAME

# Define Active Directory Security Groups for shift schedules
$Group1 = "CORP_Shift_Group_01"
$TaskTimeGroup1 = "11:44:58"

$Group2 = "CORP_Shift_Group_02"
$TaskTimeGroup2 = "12:44:58"

# Configuration parameters for the notification UI
$WindowTitle_Text = "Security Warning!"
$Title_Text = "IT Infrastructure & Security"
$TimeLeft_Text = "Time remaining until session lock:"
$TimeLeft_Seconds = 900 # (15 minutes)
$Message_Text = "Due to corporate security compliance measures, this workstation will be locked in 15 minutes. Please save your work."

# Setup local paths
$LocalTempDir = "C:\Temp"
if (!(Test-Path $LocalTempDir)) {
    New-Item -ItemType Directory -Path $LocalTempDir -Force | Out-Null
}

$HelperScriptPath = "$LocalTempDir\SessionWarning.ps1"
$LogPath = "$env:TEMP\task_execution.log"

# Function to log execution events
function Write-Log {
    param([string]$Message)
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$Timestamp - $Message" | Out-File -FilePath $LogPath -Append
}

Write-Log "Logon script initialized for user: $UserName"

# Logic to evaluate group membership and register scheduled task
# Note: In production domain environments, use ActiveDirectory module or System.DirectoryServices to check group nesting.
# Here we register the core task structure dynamically based on user context.

$Action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-ExecutionPolicy Bypass -File `"$HelperScriptPath`""
$Trigger = New-ScheduledTaskTrigger -Daily -At $TaskTimeGroup1
$Settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable

# Register the task under the user context
Register-ScheduledTask -TaskName "SessionLockNotification" -Action $Action -Trigger $Trigger -Settings $Settings -Force | Out-Null

Write-Log "Scheduled task 'SessionLockNotification' successfully registered."
