# Optioneel
$ErrorActionPreference = 'Stop'

$modules = @(
    "Az.Accounts",
    "ExchangeOnlineManagement",
    "MicrosoftTeams"
)

foreach ($module in $modules) {
    Write-Host "`n--- Checking $module ---"

    if ($module -eq "ExchangeOnlineManagement") {
        $desiredVersion = [version]"3.6.0"

        # Eerst loaded module uit de sessie halen (anders kun je niet uninstallen)
        $loadedExo = Get-Module -Name $module -ErrorAction SilentlyContinue
        if ($loadedExo) {
            Write-Host "ExchangeOnlineManagement is currently loaded in this session. Removing module from session..."
            Remove-Module -Name $module -Force -ErrorAction SilentlyContinue
        }

        # Alle geïnstalleerde versies ophalen
        $installedExo = Get-InstalledModule -Name $module -AllVersions -ErrorAction SilentlyContinue

        if ($null -eq $installedExo) {
            Write-Host "$module is not installed. Installing version $desiredVersion..."
            Install-Module -Name $module -RequiredVersion $desiredVersion -Force -Scope AllUsers
        }
        else {
            $hasDesired = $installedExo.Version -contains $desiredVersion

            if (-not $hasDesired) {
                Write-Host "$module is installed, but not version $desiredVersion. Reinstalling..."
                Uninstall-Module -Name $module -AllVersions -Force
                Install-Module -Name $module -RequiredVersion $desiredVersion -Force -Scope AllUsers
            }
            else {
                $otherVersions = $installedExo | Where-Object { $_.Version -ne $desiredVersion }
                if ($otherVersions) {
                    Write-Host "$module $desiredVersion is installed, removing other versions..."
                    Uninstall-Module -Name $module -AllVersions -Force
                    Install-Module -Name $module -RequiredVersion $desiredVersion -Force -Scope AllUsers
                }
                else {
                    Write-Host "$module is pinned at version $desiredVersion."
                }
            }
        }

        continue
    }

    # Standaard pad voor de overige modules
    $installed = Get-InstalledModule -Name $module -ErrorAction SilentlyContinue

    if ($null -eq $installed) {
        Write-Host "$module is not installed. Installing latest version..."
        Install-Module -Name $module -Force -Scope AllUsers
        continue
    }

    $gallery = Find-Module -Name $module

    if ($gallery.Version -gt $installed.Version) {
        Write-Host "A newer version is available ($($gallery.Version)). Updating $module..."
        Update-Module -Name $module -Force
    }
    else {
        Write-Host "$module is up-to-date ($($installed.Version))."
    }
}

Write-Host "`n--- Installing test tooling (Pester & Maester) ---"

Install-Module Pester -SkipPublisherCheck -Force -Scope CurrentUser
Install-Module Maester -Scope CurrentUser -Force

if (-not (Test-Path -Path ".\maester-tests")) {
    md maester-tests | Out-Null
}

Set-Location maester-tests
Install-MaesterTests

Write-Host "`n--- Connecting Maester ---"
Connect-Maester -Service All

Invoke-Maester
