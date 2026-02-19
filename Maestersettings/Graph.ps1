Connect-MgGraph



#EIDSCA.AP01: Default Authorization Settings - Disable Self service password reset for administrators.
Update-MgPolicyAuthorizationPolicy -AllowedToUseSspr:$false


# EIDSCA.ST08: Default Settings - Classification and M365 Groups - M365 groups - Allow Guests to become Group Owner. 
# EIDSCA.ST08: Deze komt pas als onderstaande is uitgevoerd.
# MT.1055: Microsoft 365 Group (and Team) creation should be restricted to approved users
# voor het controleren van de huidige instellingen:
$settingsObjectID = (Get-MgBetaDirectorySetting | Where-object -Property Displayname -Value "Group.Unified" -EQ).id

(Get-MgBetaDirectorySetting -DirectorySettingId $settingsObjectID).Values

# Voer onderste script uit als je niks vind. Pas wel de groep aan.
Import-Module Microsoft.Graph.Beta.Identity.DirectoryManagement
Import-Module Microsoft.Graph.Beta.Groups

Connect-MgGraph -Scopes "Directory.ReadWrite.All", "Group.Read.All"

$GroupName = "sg-create-teams"
$AllowGroupCreation = "False"

$settingsObjectID = (Get-MgBetaDirectorySetting | Where-object -Property Displayname -Value "Group.Unified" -EQ).id

if(!$settingsObjectID)
{
    $params = @{
      templateId = "62375ab9-6b52-47ed-826b-58e47e0e304b"
      values = @(
            @{
                   name = "EnableMSStandardBlockedWords"
                   value = $true
             }
              )
         }
    
    New-MgBetaDirectorySetting -BodyParameter $params
    
    $settingsObjectID = (Get-MgBetaDirectorySetting | Where-object -Property Displayname -Value "Group.Unified" -EQ).Id
}

 
$groupId = (Get-MgBetaGroup -all | Where-object {$_.displayname -eq $GroupName}).Id

$params = @{
    templateId = "62375ab9-6b52-47ed-826b-58e47e0e304b"
    values = @(
        @{
            name = "EnableGroupCreation"
            value = $AllowGroupCreation
        }
        @{
            name = "GroupCreationAllowedGroupId"
            value = $groupId
        }
    )
}

Update-MgBetaDirectorySetting -DirectorySettingId $settingsObjectID -BodyParameter $params

(Get-MgBetaDirectorySetting -DirectorySettingId $settingsObjectID).Values