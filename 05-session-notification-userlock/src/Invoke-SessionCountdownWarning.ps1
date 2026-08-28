<#
.SYNOPSIS
    Interactive PowerShell WPF Session Countdown Warning UI.
.DESCRIPTION
    Generates a corporate-styled dialog window with a real-time countdown timer 
    to prevent abrupt data loss resulting from aggressive session lockouts.
.AUTHOR
    Arthur Laguna
#>

param(
    [string]$WindowTitle = "Security Warning!",
    [string]$HeaderTitle = "IT Infrastructure & Security",
    [string]$WarningLabel = "Time remaining until session lock:",
    [int]$CountdownSeconds = 900,
    [string]$WarningMessage = "Due to corporate security compliance measures, this workstation will be locked in 15 minutes. Please save your work."
)

# Load required .NET assemblies
[void][Reflection.Assembly]::Load('System.Windows.Forms, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089')
[void][Reflection.Assembly]::Load('System.Drawing, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a')

[System.Windows.Forms.Application]::EnableVisualStyles()

# Create Main Form
$MainForm = New-Object 'System.Windows.Forms.Form'
$PanelHeader = New-Object 'System.Windows.Forms.Panel'
$PanelBottom = New-Object 'System.Windows.Forms.Panel'
$LabelHeaderTitle = New-Object 'System.Windows.Forms.Label'
$LabelTimePrompt = New-Object 'System.Windows.Forms.Label'
$LabelCountdownTimer = New-Object 'System.Windows.Forms.Label'
$LabelBodyMessage = New-Object 'System.Windows.Forms.Label'

# Timer configuration
$Script:StartTime = (Get-Date).AddSeconds($CountdownSeconds)
$TimerUpdate = New-Object 'System.Windows.Forms.Timer'
$TimerUpdate.Interval = 1000 # 1 second tick

$TimerUpdate_Tick = {
    [TimeSpan]$Span = $script:StartTime - (Get-Date)
    if ($Span.TotalSeconds -le 0) {
        $TimerUpdate.Stop()
        $MainForm.Close()
    } else {
        $LabelCountdownTimer.Text = "{0:N0}" -f $Span.TotalSeconds
    }
}
$TimerUpdate.add_Tick($TimerUpdate_Tick)

# Form Layout Settings
$MainForm.SuspendLayout()
$MainForm.ClientSize = '373, 279'
$MainForm.BackColor = 'White'
$MainForm.MaximizeBox = $False
$MainForm.MinimizeBox = $False
$MainForm.ControlBox = $False
$MainForm.ShowIcon = $False
$MainForm.ShowInTaskbar = $False
$MainForm.StartPosition = 'CenterScreen'
$MainForm.Text = $WindowTitle
$MainForm.TopMost = $True

# Header Panel (Corporate Blue Theme: #0072C6)
$PanelHeader.BackColor = [System.Drawing.Color]::FromArgb(0, 114, 198)
$PanelHeader.Location = '0, 0'
$PanelHeader.Size = '375, 67'

$LabelHeaderTitle.Font = 'Microsoft Sans Serif, 14.25pt, style=Bold'
$LabelHeaderTitle.ForeColor = 'White'
$LabelHeaderTitle.Location = '11, 18'
$LabelHeaderTitle.Size = '350, 30'
$LabelHeaderTitle.Text = $HeaderTitle
$LabelHeaderTitle.TextAlign = 'MiddleLeft'
$PanelHeader.Controls.Add($LabelHeaderTitle)

# Body Message Label
$LabelBodyMessage.Font = 'Microsoft Sans Serif, 9pt'
$LabelBodyMessage.Location = '12, 84'
$LabelBodyMessage.Size = '350, 83'
$LabelBodyMessage.Text = $WarningMessage

# Countdown Prompt Label
$LabelTimePrompt.AutoSize = $True
$LabelTimePrompt.Font = 'Microsoft Sans Serif, 9pt, style=Bold'
$LabelTimePrompt.Location = '30, 176'
$LabelTimePrompt.Size = '200, 15'
$LabelTimePrompt.Text = $WarningLabel

# Countdown Ticker Label (Red Warning Accent)
$LabelCountdownTimer.AutoSize = $True
$LabelCountdownTimer.Font = 'Microsoft Sans Serif, 11pt, style=Bold'
$LabelCountdownTimer.ForeColor = [System.Drawing.Color]::FromArgb(192, 0, 0)
$LabelCountdownTimer.Location = '260, 174'
$LabelCountdownTimer.Size = '50, 20'
$LabelCountdownTimer.Text = $CountdownSeconds.ToString()
$LabelCountdownTimer.TextAlign = 'MiddleCenter'

# Bottom Panel
$PanelBottom.Location = '0, 205'
$PanelBottom.Size = '378, 80'

# Add Controls to Form
$MainForm.Controls.Add($PanelHeader)
$MainForm.Controls.Add($PanelBodyMessage)
$MainForm.Controls.Add($LabelTimePrompt)
$MainForm.Controls.Add($LabelCountdownTimer)
$MainForm.Controls.Add($PanelBottom)

$MainForm.ResumeLayout()

# Start Timer on Form Load
$MainForm.add_Load({
    $TimerUpdate.Start()
})

# Show Dialog
[void]$MainForm.ShowDialog()
