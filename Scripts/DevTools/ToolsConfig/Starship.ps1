# =======================================================
# PowerShell Starship Config
# Author: Fredaw Lomdo
# Repository: https://github.com/hetfs/powershell-profile
# =======================================================

$ErrorActionPreference = 'Stop'

# Paths
$ConfigDir = Join-Path $HOME '.config\starship'
$ConfigFile = Join-Path $ConfigDir 'starship.toml'

# Ensure Starship exists
if (-not (Get-Command starship -ErrorAction SilentlyContinue)) {
    Write-Host "Starship not found. Please install via:" -ForegroundColor Yellow
    Write-Host "  • WinGet: winget install starship" -ForegroundColor Cyan
    Write-Host "  • Chocolatey: choco install starship" -ForegroundColor Cyan
    Write-Host "  • Or manually: https://starship.rs/guide/#%F0%9F%9A%80-installation" -ForegroundColor Cyan
    return
}

# Create config directory
if (-not (Test-Path $ConfigDir)) {
    New-Item -ItemType Directory -Path $ConfigDir -Force | Out-Null
}

# Create default starship.toml if missing
if (-not (Test-Path $ConfigFile)) {
    @'
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

[palettes.gruvbox_dark]
color_fg0 = '#fbf1c7'
color_bg1 = '#3c3836'
color_bg3 = '#665c54'
color_blue = '#458588'
color_aqua = '#689d6a'
color_green = '#98971a'
color_orange = '#d65d0e'
color_purple = '#b16286'
color_red = '#cc241d'
color_yellow = '#d79921'

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
Ubuntu = "󰕈"
SUSE = ""
Raspbian = "󰐿"
Mint = "󰣭"
Macos = ""
Manjaro = ""
Linux = "󰌽"
Gentoo = "󰣨"
Fedora = "󰣛"
Alpine = ""
Amazon = ""
Android = ""
Arch = "󰣇"
Artix = "󰣇"
CentOS = ""
Debian = "󰣚"
Redhat = "󱄛"
RedHatEnterprise = "󱄛"

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

[directory.substitutions]
"Documents" = "󰈙 "
"Downloads" = " "
"Music" = "󰝚 "
"Pictures" = " "
"Developer" = "󰲋 "

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

[c]
symbol = " "
style = "bg:teal"
format = '[[ $symbol( $version) ](fg:base bg:teal)]($style)'

[rust]
symbol = ""
style = "bg:teal"
format = '[[ $symbol( $version) ](fg:base bg:teal)]($style)'

[golang]
symbol = ""
style = "bg:teal"
format = '[[ $symbol( $version) ](fg:base bg:teal)]($style)'

[php]
symbol = ""
style = "bg:teal"
format = '[[ $symbol( $version) ](fg:base bg:teal)]($style)'

[java]
symbol = " "
style = "bg:teal"
format = '[[ $symbol( $version) ](fg:base bg:teal)]($style)'

[kotlin]
symbol = ""
style = "bg:teal"
format = '[[ $symbol( $version) ](fg:base bg:teal)]($style)'

[haskell]
symbol = ""
style = "bg:teal"
format = '[[ $symbol( $version) ](fg:base bg:teal)]($style)'

[python]
symbol = ""
style = "bg:teal"
format = '[[ $symbol( $version) ](fg:base bg:teal)]($style)'

[docker_context]
symbol = ""
style = "bg:mantle"
format = '[[ $symbol( $context) ](fg:#83a598 bg:color_bg3)]($style)'

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
vimcmd_symbol = '[](bold fg:creen)'
vimcmd_replace_one_symbol = '[](bold fg:purple)'
vimcmd_replace_symbol = '[](bold fg:purple)'
vimcmd_visual_symbol = '[](bold fg:lavender)'
'@ | Set-Content -Path $ConfigFile -Encoding UTF8
}

# Set STARSHIP_CONFIG (user-level)
[Environment]::SetEnvironmentVariable(
    'STARSHIP_CONFIG',
    $ConfigFile,
    [EnvironmentVariableTarget]::User
)

# -------------------------------
# PowerShell initialization
# -------------------------------
$ProfileContent = @'
# ====== Starship configuration =======

if (Get-Command starship -ErrorAction SilentlyContinue) {
    $env:STARSHIP_CONFIG = "$HOME\.config\starship\starship.toml"
    Invoke-Expression (& starship init powershell)
}
# ===== End Starship =================
'@

# Ensure profile file exists
if (-not (Test-Path $PROFILE)) {
    New-Item -ItemType File -Path $PROFILE -Force | Out-Null
}

# Check if starship config already exists in profile
$existingContent = Get-Content -Path $PROFILE -Raw -ErrorAction SilentlyContinue
$starshipPattern = 'starship init powershell'

if (-not $existingContent -or $existingContent -notmatch $starshipPattern) {
    # Add starship configuration to profile
    Add-Content -Path $PROFILE -Value "`n$ProfileContent"
    Write-Host "Starship configuration added to PowerShell profile." -ForegroundColor Green
} else {
    Write-Host "Starship configuration already exists in PowerShell profile." -ForegroundColor Yellow
}

Write-Host "Starship setup complete!" -ForegroundColor Green
Write-Host "Configuration file: $ConfigFile" -ForegroundColor Cyan
Write-Host "Restart PowerShell or run: . `$PROFILE" -ForegroundColor Cyan
