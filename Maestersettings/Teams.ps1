
# CIS.M365.8.4.1: Ensure all or a majority of third-party and custom apps are blocked
Set-CsTeamsAppPermissionPolicy -Identity Global -DefaultCatalogAppsType BlockedAppList -DefaultCatalogApps @() -GlobalCatalogAppsType AllowedAppList -GlobalCatalogApps @() -PrivateCatalogAppsType AllowedAppList -PrivateCatalogApps @()