Connect-MgGraph



#EIDSCA.AP01: Default Authorization Settings - Disable Self service password reset for administrators.
Update-MgPolicyAuthorizationPolicy -AllowedToUseSspr:$false