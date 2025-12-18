Connect-ExchangeOnline


#
Set-ExternalInOutlook -Enabled $true

#MT.1039: Ensure MailTips are enabled for end users
Set-OrganizationConfig -MailTipsExternalRecipientsTipsEnabled $true

#MT.1040: Ensure additional storage providers are restricted in Outlook on the web
Set-OwaMailboxPolicy -Identity "OwaMailboxPolicy-Default" -AdditionalStorageProvidersAvailable $false

#MT.1041: Ensure users installing Outlook add-ins is not allowed
Get-ManagementRoleAssignment -RoleAssignee "Default Role Assignment Policy" | Where-Object { $_.Role -like "My*Apps" } | Remove-ManagementRoleAssignment -Confirm:$false

