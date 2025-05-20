<#
.SYNOPSIS
    Configures language, region, and time zone settings for all users.

.DESCRIPTION
    - Time zone: Amsterdam
    - Display language: English (US)
    - Regional formatting: Dutch (Netherlands)
    - Applies to:
        - System
        - New users
        - Existing users (logged-in and offline)

.NOTES
    Run as Administrator. A reboot is recommended after running.
#>

Write-Host "`n▶ Starting language and region configuration..." -ForegroundColor Cyan

# ---- Step 1: Set Time Zone to Amsterdam ----
Write-Host "⏱ Setting time zone to Amsterdam..." -ForegroundColor Yellow
Get-TimeZone -ListAvailable | Where-Object { $_.DisplayName -like "*Amsterdam*" } | Set-TimeZone

# ---- Step 2: Set Culture and Regional Format ----
$displayLanguage = "en-US"
$regionalFormat = "nl-NL"

Write-Host "🌐 Setting system culture and region to Dutch (Netherlands)..." -ForegroundColor Yellow
Set-Culture $regionalFormat
Set-WinSystemLocale $regionalFormat
Set-WinHomeLocation 19  # 19 = Netherlands

# ---- Step 3: Configure Display Language with Dutch Format ----
Write-Host "🗣 Setting display language to English (US) with Dutch formatting..." -ForegroundColor Yellow
$languageList = New-WinUserLanguageList -Language $displayLanguage
$languageList[0].Handwriting = $false
$languageList[0].InputMethodTips.Clear()
$languageList[0].InputMethodTips.Add("0409:00000409")  # US Keyboard

# Handle possible error with RegionalFormat property
try {
    $languageList[0].RegionalFormat = $regionalFormat
} catch {
    Write-Warning "⚠ Could not set RegionalFormat on language list: $_"
}

Set-WinUserLanguageList $languageList -Force -WarningAction SilentlyContinue

# ---- Step 4: Apply to Welcome screen and new users ----
Write-Host "👥 Copying settings to Welcome screen and new users..." -ForegroundColor Yellow
Copy-UserInternationalSettingsToSystem -WelcomeScreen $true -NewUser $true

# ---- Step 5: Define Dutch Regional Format Settings ----
$regionSettings = @{
    "LocaleName"        = "nl-NL"
    "sShortDate"        = "dd-MM-yyyy"
    "sLongDate"         = "dddd d MMMM yyyy"
    "sShortTime"        = "HH:mm"
    "sTimeFormat"       = "HH:mm:ss"
    "sDecimal"          = ","
    "sThousand"         = "."
    "sCurrency"         = "€"
    "sMonDecimalSep"    = ","
    "sMonThousandSep"   = "."
}

# ---- Step 6: Apply to all user profiles (logged in and offline) ----
Write-Host "👤 Applying settings to all existing user profiles..." -ForegroundColor Yellow
$profiles = Get-WmiObject Win32_UserProfile | Where-Object { -not $_.Special }

foreach ($profile in $profiles) {
    $sid = $profile.SID
    $userHivePath = "$($profile.LocalPath)\NTUSER.DAT"
    $regPath = "Registry::HKEY_USERS\$sid\Control Panel\International"

    $hiveLoaded = Test-Path "Registry::HKEY_USERS\$sid"

    if (-not $hiveLoaded) {
        Write-Host "  🔄 Loading hive for offline user: $sid" -ForegroundColor DarkGray
        reg load "HKU\$sid" "$userHivePath" 2>$null
    }

    if (Test-Path $regPath) {
        Write-Host "  ✅ Applying to profile: $sid" -ForegroundColor Green
        foreach ($key in $regionSettings.Keys) {
            New-ItemProperty -Path $regPath -Name $key -Value $regionSettings[$key] -PropertyType String -Force | Out-Null
        }
    } else {
        Write-Warning "  ⚠ Could not access registry path for SID: $sid"
    }

    if (-not $hiveLoaded) {
        reg unload "HKU\$sid" 2>$null
    }
}

# ---- Step 7: Apply to currently logged-on user via HKCU ----
Write-Host "🧑 Applying regional settings to current user session (including 24-hour format)..." -ForegroundColor Yellow
$currentUserPath = "HKCU:\Control Panel\International"

foreach ($key in $regionSettings.Keys) {
    try {
        Set-ItemProperty -Path $currentUserPath -Name $key -Value $regionSettings[$key] -Force
    } catch {
        Write-Warning "Failed to set $key for current user: $_"
    }
}

# Optional: Refresh settings without reboot
Start-Process "RUNDLL32.EXE" -ArgumentList "user32.dll,UpdatePerUserSystemParameters ,1 ,True" -NoNewWindow -Wait

Write-Host "`n✅ All settings applied successfully." -ForegroundColor Cyan
Write-Host "🔁 Please restart the computer for all changes to take full effect." -ForegroundColor White
