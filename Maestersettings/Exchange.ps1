Connect-ExchangeOnline


#
Set-ExternalInOutlook -Enabled $true

#MT.1039: Ensure MailTips are enabled for end users
Set-OrganizationConfig -MailTipsExternalRecipientsTipsEnabled $true

#MT.1040: Ensure additional storage providers are restricted in Outlook on the web
Set-OwaMailboxPolicy -Identity "OwaMailboxPolicy-Default" -AdditionalStorageProvidersAvailable $false

#MT.1041: Ensure users installing Outlook add-ins is not allowed
Get-ManagementRoleAssignment -RoleAssignee "Default Role Assignment Policy" | Where-Object { $_.Role -like "My*Apps" } | Remove-ManagementRoleAssignment -Confirm:$false



#CIS.M365.2.1.11: Ensure comprehensive attachment filtering is applied (defender handmatig aanzetten)
$Policy = @{
    Name = "CIS L2 Attachment Policy"
    EnableFileFilter = $true
    ZapEnabled = $true
    EnableInternalSenderAdminNotifications = $true
    InternalSenderAdminAddress = 'complaints@giraffe-it.com' # Change this.
}

$L2Extensions = @(
    "7z", "a3x", "ace", "ade", "adp", "ani", "app", "appinstaller",
    "applescript", "application", "appref-ms", "appx", "appxbundle", "arj",
    "asd", "asx", "bas", "bat", "bgi", "bz2", "cab", "chm", "cmd", "com",
    "cpl", "crt", "cs", "csh", "daa", "dbf", "dcr", "deb",
    "desktopthemepackfile", "dex", "diagcab", "dif", "dir", "dll", "dmg",
    "doc", "docm", "dot", "dotm", "elf", "eml", "exe", "fxp", "gadget", "gz",
    "hlp", "hta", "htc", "htm", "htm", "html", "html", "hwpx", "ics", "img",
    "inf", "ins", "iqy", "iso", "isp", "jar", "jnlp", "js", "jse", "kext",
    "ksh", "lha", "lib", "library-ms", "lnk", "lzh", "macho", "mam", "mda",
    "mdb", "mde", "mdt", "mdw", "mdz", "mht", "mhtml", "mof", "msc", "msi",
    "msix", "msp", "msrcincident", "mst", "ocx", "odt", "ops", "oxps", "pcd",
    "pif", "plg", "pot", "potm", "ppa", "ppam", "ppkg", "pps", "ppsm", "ppt",
    "pptm", "prf", "prg", "ps1", "ps11", "ps11xml", "ps1xml", "ps2",
    "ps2xml", "psc1", "psc2", "pub", "py", "pyc", "pyo", "pyw", "pyz",
    "pyzw", "rar", "reg", "rev", "rtf", "scf", "scpt", "scr", "sct",
    "searchConnector-ms", "service", "settingcontent-ms", "sh", "shb", "shs",
    "shtm", "shtml", "sldm", "slk", "so", "spl", "stm", "svg", "swf", "sys",
    "tar", "theme", "themepack", "timer", "uif", "url", "uue", "vb", "vbe",
    "vbs", "vhd", "vhdx", "vxd", "wbk", "website", "wim", "wiz", "ws", "wsc",
    "wsf", "wsh", "xla", "xlam", "xlc", "xll", "xlm", "xls", "xlsb", "xlsm",
    "xlt", "xltm", "xlw", "xml", "xnk", "xps", "xsl", "xz", "z"
)

# Create the policy
New-MalwareFilterPolicy @Policy -FileTypes $L2Extensions

# Create the rule for all accepted domains
$Rule = @{
    Name = $Policy.Name
    Enabled = $false
    MalwareFilterPolicy = $Policy.Name
    RecipientDomainIs = (Get-AcceptedDomain).Name
    Priority = 0
}

New-MalwareFilterRule @Rule

