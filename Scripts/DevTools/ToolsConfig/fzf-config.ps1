# =======================================================
# Silent One-Click PowerShell Dev Tools Installer
# Auto Windows Terminal reload & Catppuccin theme
# =======================================================

$ErrorActionPreference = 'Stop'

# ----------------------
# Helpers
# ----------------------
function Test-Command {
    param([string]$Name)
    try { [bool](Get-Command $Name -ErrorAction SilentlyContinue) }
    catch { $false }
}

function Write-Status {
    param([string]$Message, [ConsoleColor]$Color = 'Gray')
    Write-Host $Message -ForegroundColor $Color
}

# ----------------------
# Tools installation (silent)
# ----------------------
$tools = @{
    'fzf' = @{Id = 'Junegunn.Fzf'}
    'bat' = @{Id = 'SharkDP.Bat'}
    'fd' = @{Id = 'sharkdp.fd'}
    'rg' = @{Id = 'BurntSushi.ripgrep.MSVC'}
}

foreach ($tool in $tools.Keys) {
    if (-not (Test-Command $tool)) {
        try {
            Write-Status "Installing $tool..." Cyan
            winget install --id $($tools[$tool].Id) -e --silent --accept-package-agreements --accept-source-agreements
            Write-Status "Installed $tool" Green
        }
        catch {
            Write-Status "Failed to install $tool. You may need to run as admin." Red
        }
    }
    else {
        Write-Status "$tool already installed" Gray
    }
}

# ----------------------
# JetBrains Mono Nerd Font
# ----------------------
$fontsPath = "$env:LOCALAPPDATA\Microsoft\Windows\Fonts"
$nerdFontDir = Join-Path $fontsPath 'JetBrainsMono Nerd Font'
if (-not (Test-Path $nerdFontDir)) {
    try {
        $zipUrl = 'https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/JetBrainsMono.zip'
        $zipFile = Join-Path $env:TEMP 'JetBrainsMono.zip'

        Write-Status "Downloading JetBrains Mono Nerd Font..." Cyan
        Invoke-WebRequest -Uri $zipUrl -OutFile $zipFile -UseBasicParsing

        Write-Status "Extracting font..." Cyan
        Expand-Archive -Path $zipFile -DestinationPath $nerdFontDir -Force

        # Clean up
        Remove-Item $zipFile -ErrorAction SilentlyContinue
        Write-Status "Font installed successfully" Green
    }
    catch {
        Write-Status "Failed to install font: $_" Red
    }
}

# ----------------------
# Windows Terminal Catppuccin + font
# ----------------------
$wtSettings = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
if (Test-Path $wtSettings) {
    try {
        $settings = Get-Content $wtSettings -Raw -ErrorAction Stop | ConvertFrom-Json -ErrorAction Stop

        $modified = $false

        # Apply font to PowerShell profiles - handle different Windows Terminal versions
        if ($settings.profiles -and $settings.profiles.list) {
            foreach ($profile in $settings.profiles.list) {
                # Check if it's a PowerShell profile
                $isPowerShell = $false
                if ($profile.name -match 'PowerShell' -or $profile.source -match 'PowerShell' -or
                    $profile.commandline -match 'powershell' -or $profile.commandline -match 'pwsh') {
                    $isPowerShell = $true
                }

                # PowerShell Core 7+ might be under different names
                if (-not $isPowerShell -and $profile.guid) {
                    # Common PowerShell profile GUIDs
                    $psGuids = @(
                        '{61c54bbd-c2c6-5271-96e7-009a87ff44bf}', # Windows PowerShell
                        '{574e775e-4f2a-5b96-ac1e-a2962a402336}'  # PowerShell Core
                    )
                    if ($psGuids -contains $profile.guid) {
                        $isPowerShell = $true
                    }
                }

                if ($isPowerShell) {
                    # Add fontFace property if it doesn't exist
                    if (-not $profile.fontFace) {
                        $profile | Add-Member -MemberType NoteProperty -Name 'fontFace' -Value 'JetBrains Mono Nerd Font' -Force
                        $modified = $true
                    }
                    elseif ($profile.fontFace -ne 'JetBrains Mono Nerd Font') {
                        $profile.fontFace = 'JetBrains Mono Nerd Font'
                        $modified = $true
                    }

                    # Add colorScheme property if it doesn't exist
                    if (-not $profile.colorScheme) {
                        $profile | Add-Member -MemberType NoteProperty -Name 'colorScheme' -Value 'Catppuccin Mocha' -Force
                        $modified = $true
                    }
                    elseif ($profile.colorScheme -ne 'Catppuccin Mocha') {
                        $profile.colorScheme = 'Catppuccin Mocha'
                        $modified = $true
                    }
                }
            }
        }

        # Add color scheme if not present
        if (-not ($settings.schemes | Where-Object { $_.name -eq 'Catppuccin Mocha' })) {
            if (-not $settings.schemes) {
                $settings | Add-Member -MemberType NoteProperty -Name 'schemes' -Value @() -Force
            }

            $catppuccinScheme = [PSCustomObject]@{
                name = 'Catppuccin Mocha'
                background = '#1e1e2e'
                foreground = '#cdd6f4'
                black = '#313244'
                red = '#f38ba8'
                green = '#a6e3a1'
                yellow = '#f9e2af'
                blue = '#89b4fa'
                purple = '#cba6f7'
                cyan = '#94e2d5'
                white = '#f5e0dc'
                brightBlack = '#585b70'
                brightRed = '#f38ba8'
                brightGreen = '#a6e3a1'
                brightYellow = '#f9e2af'
                brightBlue = '#89b4fa'
                brightPurple = '#cba6f7'
                brightCyan = '#94e2d5'
                brightWhite = '#f5e0dc'
            }

            $settings.schemes += $catppuccinScheme
            $modified = $true
        }

        if ($modified) {
            # Convert to JSON with proper formatting
            $jsonSettings = $settings | ConvertTo-Json -Depth 10
            Set-Content -Path $wtSettings -Value $jsonSettings -Encoding UTF8
            Write-Status "Updated Windows Terminal settings" Green
        }
        else {
            Write-Status "Windows Terminal settings already configured" Gray
        }

        # Detect running Windows Terminal process
        $wtRunning = Get-Process -Name WindowsTerminal -ErrorAction SilentlyContinue
        if ($wtRunning) {
            Write-Status 'Windows Terminal is running. Changes will apply in new tabs.' Cyan
        }
        else {
            Write-Status 'Windows Terminal not running. Changes will apply next launch.' Cyan
        }
    }
    catch {
        Write-Status "Failed to update Windows Terminal settings: $_" Red
    }
}
else {
    Write-Status "Windows Terminal settings not found at $wtSettings" Yellow
}

# ----------------------
# Ensure PowerShell profile exists
# ----------------------
# Get profile path safely
try {
    # Try to get the profile path
    if ($PROFILE -and $PROFILE.ToString().Trim() -notlike '@{*' -and $PROFILE.ToString().Trim() -ne '') {
        $profilePath = $PROFILE.ToString().Trim()
    }
    else {
        # Use default paths
        $profilePath = "$env:USERPROFILE\Documents\PowerShell\Microsoft.PowerShell_profile.ps1"
        if (-not (Test-Path $profilePath)) {
            $profilePath = "$env:USERPROFILE\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1"
        }
    }

    $profileDir = Split-Path $profilePath -Parent
    if (-not (Test-Path $profileDir)) {
        New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
    }

    if (-not (Test-Path $profilePath)) {
        New-Item -ItemType File -Path $profilePath -Force | Out-Null
        Write-Status "Created PowerShell profile at $profilePath" Green
    }

    $ProfileContent = Get-Content -Path $profilePath -Raw -ErrorAction SilentlyContinue
    if ([string]::IsNullOrWhiteSpace($ProfileContent)) {
        $ProfileContent = ''
    }
}
catch {
    # Use a guaranteed path
    $profilePath = "$env:USERPROFILE\Documents\PowerShell\Microsoft.PowerShell_profile.ps1"
    $profileDir = Split-Path $profilePath -Parent

    if (-not (Test-Path $profileDir)) {
        New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
    }

    if (-not (Test-Path $profilePath)) {
        New-Item -ItemType File -Path $profilePath -Force | Out-Null
    }

    $ProfileContent = ''
}

# ----------------------
# FZF configuration - Fixed: No nested here-string issues
# ----------------------
$FzfConfigBlock = @'
# ===== BEGIN FZF CONFIGURATION =====
if (Get-Module -ListAvailable -Name PSFzf) {
    Import-Module PSFzf
    Set-PsFzfOption `
        -PSReadlineChordProvider 'Ctrl+t' `
        -PSReadlineChordReverseHistory 'Ctrl+r' `
        -GitKeyBindings
}

if (Get-Command git -ErrorAction SilentlyContinue) {
    $env:FZF_DEFAULT_COMMAND = 'git ls-files --exclude-standard --cached --others'
}
elseif (Get-Command rg -ErrorAction SilentlyContinue) {
    $env:FZF_DEFAULT_COMMAND = 'rg --files --hidden --glob "!.git/*"'
}
elseif (Get-Command fd -ErrorAction SilentlyContinue) {
    $env:FZF_DEFAULT_COMMAND = 'fd --type f --hidden --follow --exclude .git'
}

$env:FZF_CTRL_T_COMMAND = $env:FZF_DEFAULT_COMMAND
$env:FZF_ALT_C_COMMAND = 'fd --type d --hidden --follow --exclude .git'

# Set FZF options using string concatenation to avoid nested here-string issues
$env:FZF_DEFAULT_OPTS = "--height=40% " +
    "--layout=reverse " +
    "--border=rounded " +
    "--info=inline " +
    "--margin=1 " +
    "--padding=1 " +
    "--multi " +
    "--prompt='❯ ' " +
    "--pointer='▶' " +
    "--marker='✓' " +
    "--separator='─' " +
    "--scrollbar='│' " +
    "--walker-skip=.git,node_modules,target " +
    "--bind=enter:become(nvim {+}) " +
    "--bind=ctrl-j:down,ctrl-k:up " +
    "--bind=ctrl-d:preview-page-down,ctrl-u:preview-page-up " +
    "--bind=ctrl-/:toggle-preview " +
    "--preview='if (Get-Command bat -ErrorAction SilentlyContinue) {bat --style=numbers,changes --color=always {}} else {type {}}' " +
    "--preview-window='right:60%:wrap' " +
    "--ansi " +
    "--color=bg:#1e1e2e,fg:#cdd6f4,hl:#f38ba8 " +
    "--color=bg+:#313244,fg+:#f5e0dc,hl:#f38ba8 " +
    "--color=info:#89b4fa,prompt:#94e2d5,pointer:#f38ba8 " +
    "--color=marker:#a6e3a1,spinner:#f5e0dc,header:#89b4fa"

function Search-Files {
    param(
        [string]$Dir = '.',
        [string]$Pattern = ''
    )

    if (-not (Get-Command rg -ErrorAction SilentlyContinue)) {
        Write-Warning 'ripgrep (rg) is not installed. Install it first.'
        return
    }

    $result = rg --color=always --line-number --no-heading --hidden --glob '!.git/*' $Pattern $Dir |
        fzf --ansi --multi --preview='bat --style=numbers,changes --color=always {1} --highlight-line {2}' --bind='ctrl-j:down,ctrl-k:up,enter:execute(nvim {1} +{2})' --height=50% --layout=reverse --border=rounded --prompt='🔍 RG> ' --color=bg:#1e1e2e,fg:#cdd6f4,hl:#f38ba8,fg+:#f5e0dc,pointer:#f38ba8,marker:#a6e3a1

    if ($result) {
        $file, $line = $result -split ':'
        if (Test-Path $file) {
            nvim $file "+$line"
        }
    }
}

Set-Alias rgf Search-Files
# ===== END FZF CONFIGURATION =====
'@

# ----------------------
# Idempotent profile update
# ----------------------
$beginMarker = '# ===== BEGIN FZF CONFIGURATION ====='
$endMarker = '# ===== END FZF CONFIGURATION ====='

# Check if markers already exist
$markersExist = $false
if ($ProfileContent -and $ProfileContent.Contains($beginMarker) -and $ProfileContent.Contains($endMarker)) {
    $markersExist = $true
}

if ($markersExist) {
    try {
        # Extract content between markers
        $startIndex = $ProfileContent.IndexOf($beginMarker)
        $endIndex = $ProfileContent.IndexOf($endMarker) + $endMarker.Length

        if ($startIndex -ge 0 -and $endIndex -gt $startIndex) {
            $before = $ProfileContent.Substring(0, $startIndex)
            $after = $ProfileContent.Substring($endIndex)
            $Updated = $before + $FzfConfigBlock + $after
            Set-Content -Path $profilePath -Value $Updated -Encoding UTF8
            Write-Status "Updated existing FZF configuration in profile" Green
        }
        else {
            # If markers exist but extraction failed, append new config
            Add-Content -Path $profilePath -Value "`n$FzfConfigBlock" -Encoding UTF8
            Write-Status "Added FZF configuration to profile" Green
        }
    }
    catch {
        # If update fails, append new config
        Add-Content -Path $profilePath -Value "`n$FzfConfigBlock" -Encoding UTF8
        Write-Status "Added FZF configuration to profile" Green
    }
}
else {
    Add-Content -Path $profilePath -Value "`n$FzfConfigBlock" -Encoding UTF8
    Write-Status "Added FZF configuration to profile" Green
}

# ----------------------
# Install PSFzf module if not present
# ----------------------
if (-not (Get-Module -ListAvailable -Name PSFzf -ErrorAction SilentlyContinue)) {
    try {
        Write-Status "Installing PSFzf module..." Cyan
        Install-Module -Name PSFzf -Scope CurrentUser -Force -AllowClobber
        Write-Status "Installed PSFzf module" Green
    }
    catch {
        Write-Status "Note: PSFzf module not installed. Run: Install-Module PSFzf" Yellow
    }
}

# ----------------------
# Reload profile silently
# ----------------------
try {
    if (Test-Path $profilePath) {
        # Clear the error first
        $Error.Clear()
        . $profilePath
        Write-Status "Profile reloaded successfully" Green
    }
}
catch {
    Write-Status "Note: Could not reload profile. Restart PowerShell to apply changes." Yellow
}

# ----------------------
# Done
# ----------------------
Write-Status 'FULL INSTALL COMPLETE' -Color Green
Write-Status 'Use "rgf" for live fuzzy grep with bat previews' -Color Magenta
Write-Status 'Restart Windows Terminal to apply Nerd Font + Catppuccin theme in all tabs' -Color Cyan
Write-Status 'Note: You may need to restart your shell for all changes to take full effect' -Color Cyan
