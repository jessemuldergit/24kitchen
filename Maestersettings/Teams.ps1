
# CIS.M365.8.4.1: Ensure all or a majority of third-party and custom apps are blocked
Set-CsTeamsAppPermissionPolicy -Identity Global -DefaultCatalogAppsType BlockedAppList -DefaultCatalogApps @() -GlobalCatalogAppsType AllowedAppList -GlobalCatalogApps @() -PrivateCatalogAppsType AllowedAppList -PrivateCatalogApps @()


# MT.1046: Restrict anonymous users from joining meetings
Set-CsTeamsMeetingPolicy -Identity GLobal -AllowAnonymousUsersToJoinMeeting $false

#MT.1045: Only invited users should be automatically admitted to Teams meetings
Set-CsTeamsMeetingPolicy -Identity Global -AutoAdmittedUsers "InvitedUsers"

#CIS.M365.8.5.3: Ensure only people in my org can bypass the lobby
Set-CsTeamsMeetingPolicy -Identity Global -AutoAdmittedUsers "EveryoneInCompanyExcludingGuests"