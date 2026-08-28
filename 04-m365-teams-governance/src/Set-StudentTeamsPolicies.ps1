# Connect to Microsoft Teams Online
Import-Module MicrosoftTeams
Connect-MicrosoftTeams

$Institution = "[Institution-Name]"
$DepartmentPrefix = "108" # Example numeric unit prefix

$Classes = @("EF-1", "EF-2", "EF-3", "EF-4", "EF-5", "EF-6", "EF-7", "EF-8", "EF-9", "EI-1", "EI-2", "EI-M", "EM-1", "EM-2", "EM-3")

foreach ($Class in $Classes) {
    $Filter = "$DepartmentPrefix-$Class*"
    Write-Output "STARTING POLICY APPLICATION FOR CLASS GROUP: $Filter"
    
    $Users = Get-CsOnlineUser -ResultSize unlimited -Filter "Department -like '$Filter'"
    
    if ($Users) {
        $Users.DisplayName | Measure-Object
        
        $Users | Grant-CsTeamsMeetingPolicy -PolicyName "Meeting Policy - Students - $Institution"
        $Users | Grant-CsTeamsMessagingPolicy -PolicyName "Messaging Policy - Students - $Institution"
        $Users | Grant-CsTeamsAppSetupPolicy -PolicyName "App Setup Policy - Students - $Institution"
        $Users | Grant-CsTeamsCallingPolicy -PolicyName "Calling Policy - Students - $Institution"
    } else {
        Write-Warning "No users found for department filter: $Filter"
    }
}
