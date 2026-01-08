#Requires -Version 7.0
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Write-Host 'Loading Windows Terminal settings...' -ForegroundColor Cyan

# ------------------------------------------------------------
# User preferences
# ------------------------------------------------------------

$FontName   = 'JetBrains Mono Nerd Font'
$SchemeName = 'Catppuccin Mocha'

# ------------------------------------------------------------
# Resolve Windows Terminal settings paths (Stable + Preview)
# ------------------------------------------------------------

$TerminalPackages = @(
    'Microsoft.WindowsTerminal_8wekyb3d8bbwe',
    'Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe'
)

$SettingsPaths = foreach ($Pkg in $TerminalPackages) {
    $Path = Join-Path $env:LOCALAPPDATA "Packages\$Pkg\LocalState\settings.json"
    if (Test-Path $Path) { $Path }
}

if (-not $SettingsPaths) {
    throw 'Windows Terminal settings.json not found (Stable or Preview).'
}

# ------------------------------------------------------------
# Utility: Load JSON safely
# ------------------------------------------------------------

function Read-TerminalJson {
    param ([string]$Path)

    $Raw = Get-Content $Path -Raw -Encoding UTF8
    if (-not $Raw.Trim()) {
        throw "settings.json is empty: $Path"
    }

    try {
        return $Raw | ConvertFrom-Json -Depth 100
    } catch {
        throw "Invalid JSON in $Path"
    }
}

# ------------------------------------------------------------
# Utility: Write JSON without formatting churn
# ------------------------------------------------------------

function Write-TerminalJson {
    param (
        [Parameter(Mandatory)] [string] $Path,
        [Parameter(Mandatory)] [object] $Object
    )

    $Json = $Object | ConvertTo-Json -Depth 100
    $Json = $Json -replace "`r`n", "`n"
    Set-Content -Path $Path -Value $Json -Encoding UTF8
}

# ------------------------------------------------------------
# Schema validation (minimal + forward compatible)
# ------------------------------------------------------------

function Test-TerminalSchema {
    param ([object]$Settings)

    if (-not $Settings.PSObject.Properties['profiles']) {
        throw 'Invalid schema: missing profiles'
    }

    if (-not $Settings.profiles.PSObject.Properties['list']) {
        throw 'Invalid schema: profiles.list missing'
    }

    if (-not ($Settings.profiles.list -is [System.Collections.IEnumerable])) {
        throw 'Invalid schema: profiles.list must be an array'
    }
}

# ------------------------------------------------------------
# Profile detection (StrictMode-safe)
# ------------------------------------------------------------

function Test-IsPowerShellProfile {
    param ([object]$Profile)

    if ($Profile.PSObject.Properties['name'] -and
        $Profile.name -match 'PowerShell') {
        return $true
    }

    if ($Profile.PSObject.Properties['commandline'] -and
        $Profile.commandline -match 'pwsh|powershell') {
        return $true
    }

    if ($Profile.PSObject.Properties['source'] -and
        $Profile.source -match 'PowerShell') {
        return $true
    }

    if ($Profile.PSObject.Properties['guid']) {
        $KnownGuids = @(
            '{61c54bbd-c2c6-5271-96e7-009a87ff44bf}',
            '{574e775e-4f2a-5b96-ac1e-a2962a402336}'
        )
        return $KnownGuids -contains $Profile.guid
    }

    return $false
}

# ------------------------------------------------------------
# Desired PowerShell profile defaults
# ------------------------------------------------------------

$DesiredProfileSettings = @{
    fontFace    = $FontName
    fontSize    = 11
    padding     = '8,8,8,8'
    colorScheme = $SchemeName
    snapOnInput = $true
    useAcrylic  = $true
    opacity     = 90
}

# ------------------------------------------------------------
# Catppuccin Mocha scheme (added only if missing)
# ------------------------------------------------------------

$CatppuccinMochaScheme = @{
    name                = 'Catppuccin Mocha'
    foreground          = '#CDD6F4'
    background          = '#1E1E2E'
    cursorColor         = '#F5E0DC'
    selectionBackground = '#585B70'
    black               = '#45475A'
    red                 = '#F38BA8'
    green               = '#A6E3A1'
    yellow              = '#F9E2AF'
    blue                = '#89B4FA'
    purple              = '#CBA6F7'
    cyan                = '#94E2D5'
    white               = '#BAC2DE'
    brightBlack         = '#585B70'
    brightRed           = '#F38BA8'
    brightGreen         = '#A6E3A1'
    brightYellow        = '#F9E2AF'
    brightBlue          = '#89B4FA'
    brightPurple        = '#CBA6F7'
    brightCyan          = '#94E2D5'
    brightWhite         = '#A6ADC8'
}

# ------------------------------------------------------------
# Apply configuration
# ------------------------------------------------------------

foreach ($SettingsPath in $SettingsPaths) {

    Write-Host "Processing $SettingsPath" -ForegroundColor Yellow

    $Settings = Read-TerminalJson -Path $SettingsPath
    Test-TerminalSchema -Settings $Settings

    # Ensure schemes array exists
    if (-not $Settings.PSObject.Properties['schemes']) {
        $Settings | Add-Member -MemberType NoteProperty -Name schemes -Value @()
    }

    # Add Catppuccin Mocha if missing
    if (-not ($Settings.schemes | Where-Object name -eq $SchemeName)) {
        $Settings.schemes += [pscustomobject]$CatppuccinMochaScheme
    }

    foreach ($Profile in $Settings.profiles.list) {

        if (-not (Test-IsPowerShellProfile -Profile $Profile)) {
            continue
        }

        foreach ($Key in $DesiredProfileSettings.Keys) {

            if ($Profile.PSObject.Properties[$Key]) {
                continue
            }

            $Profile | Add-Member `
                -MemberType NoteProperty `
                -Name $Key `
                -Value $DesiredProfileSettings[$Key]
        }
    }

    Write-TerminalJson -Path $SettingsPath -Object $Settings
}

Write-Host 'Windows Terminal font and theme configured successfully.' -ForegroundColor Green
