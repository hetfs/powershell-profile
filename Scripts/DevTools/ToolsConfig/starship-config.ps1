# =======================================================
# PowerShell Starship Config with Safe Update
# Author: Fredaw Lomdo
# Repository: https://github.com/hetfs/powershell-profile
# =======================================================

$ErrorActionPreference = 'Stop'

# -------------------------------------------------------
# Paths
# -------------------------------------------------------
$ConfigDir  = Join-Path $HOME '.config\starship'
$ConfigFile = Join-Path $ConfigDir 'starship.toml'
$BackupDir  = Join-Path $ConfigDir 'backups'

# -------------------------------------------------------
# Default TOML template
# -------------------------------------------------------
$DefaultTOML = @'
"$schema" = 'https://starship.rs/config-schema.json'

format = """
[](surface0)\
$os\
$username\
[](bg:peach fg:surface0)\
$directory\
[](fg:peach bg:green)\
$git_branch\
$git_status\
[](fg:green bg:teal)\
$c\
$rust\
$golang\
$nodejs\
$php\
$java\
$kotlin\
$haskell\
$python\
[](fg:teal bg:blue)\
$docker_context\
[](fg:blue bg:purple)\
$time\
[ ](fg:purple)\
$line_break$character"""

palette = 'catppuccin_mocha'

[palettes.catppuccin_mocha]
rosewater = "#f5e0dc"
flamingo = "#f2cdcd"
pink = "#f5c2e7"
orange = "#cba6f7"
red = "#f38ba8"
maroon = "#eba0ac"
peach = "#fab387"
yellow = "#f9e2af"
green = "#a6e3a1"
teal = "#94e2d5"
sky = "#89dceb"
sapphire = "#74c7ec"
blue = "#89b4fa"
lavender = "#b4befe"
text = "#cdd6f4"
subtext1 = "#bac2de"
subtext0 = "#a6adc8"
overlay2 = "#9399b2"
overlay1 = "#7f849c"
overlay0 = "#6c7086"
surface2 = "#585b70"
surface1 = "#45475a"
surface0 = "#313244"
base = "#1e1e2e"
mantle = "#181825"
crust = "#11111b"

[os]
disabled = false
style = "bg:surface0 fg:text"

[os.symbols]
Windows = "󰍲"
Linux = "󰌽"
Macos = ""

[username]
show_always = true
style_user = "bg:surface0 fg:text"
style_root = "bg:surface0 fg:text"
format = '[ $user ]($style)'

[directory]
style = "fg:mantle bg:peach"
format = "[ $path ]($style)"
truncation_length = 3
truncation_symbol = "…/"

[git_branch]
symbol = ""
style = "bg:teal"
format = '[[ $symbol $branch ](fg:base bg:green)]($style)'

[git_status]
style = "bg:teal"
format = '[[($all_status$ahead_behind )](fg:base bg:green)]($style)'

[nodejs]
symbol = ""
style = "bg:teal"
format = '[[ $symbol( $version) ](fg:base bg:teal)]($style)'

[time]
disabled = false
time_format = "%R"
style = "bg:peach"
format = '[[  $time ](fg:mantle bg:purple)]($style)'

[line_break]
disabled = false

[character]
disabled = false
success_symbol = '[](bold fg:green)'
error_symbol = '[](bold fg:red)'
'@

# -------------------------------------------------------
# Ensure directories exist
# -------------------------------------------------------
foreach ($dir in @($ConfigDir, $BackupDir)) {
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
}

# -------------------------------------------------------
# Write or safely update starship.toml
# -------------------------------------------------------
$DefaultHash = [System.BitConverter]::ToString((New-Object System.Security.Cryptography.SHA256Managed).ComputeHash([System.Text.Encoding]::UTF8.GetBytes($DefaultTOML)))
$WriteFile = $false

if (-not (Test-Path $ConfigFile)) {
    Write-Host "Creating new Starship config..." -ForegroundColor Green
    $WriteFile = $true
} else {
    $ExistingContent = Get-Content -Path $ConfigFile -Raw -ErrorAction SilentlyContinue
    $ExistingHash = [System.BitConverter]::ToString((New-Object System.Security.Cryptography.SHA256Managed).ComputeHash([System.Text.Encoding]::UTF8.GetBytes($ExistingContent)))

    if ($ExistingHash -ne $DefaultHash) {
        # Backup existing config
        $timestamp = Get-Date -Format 'yyyyMMdd_HHmmss'
        $backupFile = Join-Path $BackupDir "starship.toml.$timestamp.bak"
        Copy-Item -Path $ConfigFile -Destination $backupFile
        Write-Host "Existing config backed up to $backupFile" -ForegroundColor Yellow
        $WriteFile = $true
    } else {
        Write-Host "Starship config is up-to-date." -ForegroundColor Cyan
    }
}

if ($WriteFile) {
    $DefaultTOML | Set-Content -Path $ConfigFile -Encoding UTF8
    Write-Host "Starship config written to $ConfigFile" -ForegroundColor Green
}

# -------------------------------------------------------
# Set STARSHIP_CONFIG environment variable
# -------------------------------------------------------
[Environment]::SetEnvironmentVariable('STARSHIP_CONFIG', $ConfigFile, [EnvironmentVariableTarget]::User)

# -------------------------------------------------------
# PowerShell profile initialization (idempotent)
# -------------------------------------------------------
$ProfileContent = @'
# ===== BEGIN STARSHIP CONFIGURATION =====
if (Get-Command starship -ErrorAction SilentlyContinue) {
    $env:STARSHIP_CONFIG = "$HOME\.config\starship\starship.toml"
    Invoke-Expression (& starship init powershell)
}
# ===== END STARSHIP CONFIGURATION =====
'@

if (-not (Test-Path $PROFILE)) { New-Item -ItemType File -Path $PROFILE -Force | Out-Null }
$existingProfile = Get-Content -Path $PROFILE -Raw -ErrorAction SilentlyContinue
if (-not $existingProfile -or $existingProfile -notmatch 'starship init powershell') {
    Add-Content -Path $PROFILE -Value "`n$ProfileContent"
    Write-Host "Starship configuration added to PowerShell profile." -ForegroundColor Green
} else {
    Write-Host "Starship configuration already exists in PowerShell profile." -ForegroundColor Yellow
}

# -------------------------------------------------------
# Completion
# -------------------------------------------------------
Write-Host "Starship setup complete!" -ForegroundColor Green
Write-Host "Configuration file: $ConfigFile" -ForegroundColor Cyan
Write-Host "Backups (if updated) are in: $BackupDir" -ForegroundColor Cyan
Write-Host "Restart PowerShell or run: . `$PROFILE" -ForegroundColor Cyan
