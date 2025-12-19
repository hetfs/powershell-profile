### PowerShell Profile for HETFS
### Repository: https://github.com/hetfs/powershell-profile
### Version: 2.0 - Modular Refactor with Starship

# Debug mode flag - Set to $true for development
$debug = $false

# Define the path to the file that stores the last execution time
$timeFilePath = Join-Path (Split-Path $PROFILE) "LastExecutionTime.txt"

# Define the update interval in days, set to -1 to always check
$updateInterval = 7

################################################################################
###                             WARNING                                      ###
###        DO NOT MODIFY THIS FILE DIRECTLY - USE OVERRIDE SYSTEM           ###
###          Customizations should be made in HETFScustom.ps1               ###
###   or by creating override functions with _Override suffix in profile.ps1 ###
################################################################################

### Section 1: Core Configuration and Override System ###
#region Core Configuration

# Define repository root - using HETFS repository
if ($repo_root_Override){
    $repo_root = $repo_root_Override
} else {
    $repo_root = "https://github.com/hetfs/powershell-profile"
}

# Debug mode override
if ($debug_Override){
    $debug = $debug_Override
}

# Update interval override
if ($updateInterval_Override){
    $updateInterval = $updateInterval_Override
}

# Time file path override
if ($timeFilePath_Override){
    $timeFilePath = $timeFilePath_Override
}

# Editor configuration override
if ($EDITOR_Override){
    $EDITOR = $EDITOR_Override
} else {
    $EDITOR = if (Test-CommandExists nvim) { 'nvim' }
          elseif (Test-CommandExists vim) { 'vim' }
          elseif (Test-CommandExists code) { 'code' }
          elseif (Test-CommandExists notepad++) { 'notepad++' }
          else { 'notepad' }
}

# Function to test if a command exists
function Test-CommandExists {
    param($command)
    $exists = $null -ne (Get-Command $command -ErrorAction SilentlyContinue)
    return $exists
}

#endregion

### Section 2: Debug and Development Functions ###
#region Debug Functions

function Debug-Message {
    if (Get-Command -Name "Debug-Message_Override" -ErrorAction SilentlyContinue) {
        Debug-Message_Override
    } else {
        Write-Host "=======================================" -ForegroundColor Red
        Write-Host "           Debug mode enabled          " -ForegroundColor Red
        Write-Host "          ONLY FOR DEVELOPMENT         " -ForegroundColor Red
        Write-Host "                                       " -ForegroundColor Red
        Write-Host "     IF YOU ARE NOT DEVELOPING         " -ForegroundColor Red
        Write-Host "     JUST RUN 'Update-Profile'         " -ForegroundColor Red
        Write-Host "      to discard all changes           " -ForegroundColor Red
        Write-Host "   and update to latest profile        " -ForegroundColor Red
        Write-Host "               version                 " -ForegroundColor Red
        Write-Host "=======================================" -ForegroundColor Red
    }
}

if ($debug) {
    Debug-Message
}

#endregion

### Section 3: Automatic Update System ###
#region Update Functions

# Initial GitHub.com connectivity check
$global:canConnectToGitHub = Test-Connection github.com -Count 1 -Quiet -TimeoutSeconds 1

function Update-Profile {
    if (Get-Command -Name "Update-Profile_Override" -ErrorAction SilentlyContinue) {
        Update-Profile_Override
    } else {
        try {
            $url = "$repo_root/raw/main/Microsoft.PowerShell_profile.ps1"
            $oldhash = Get-FileHash $PROFILE
            Invoke-RestMethod $url -OutFile "$env:temp/Microsoft.PowerShell_profile.ps1"
            $newhash = Get-FileHash "$env:temp/Microsoft.PowerShell_profile.ps1"
            
            if ($newhash.Hash -ne $oldhash.Hash) {
                Copy-Item -Path "$env:temp/Microsoft.PowerShell_profile.ps1" -Destination $PROFILE -Force
                Write-Host "✅ Profile has been updated. Please restart your shell to reflect changes" -ForegroundColor Green
            } else {
                Write-Host "✅ Profile is up to date." -ForegroundColor Green
            }
        } catch {
            Write-Error "Unable to check for profile updates: $_"
        } finally {
            Remove-Item "$env:temp/Microsoft.PowerShell_profile.ps1" -ErrorAction SilentlyContinue
        }
    }
}

function Update-PowerShell {
    if (Get-Command -Name "Update-PowerShell_Override" -ErrorAction SilentlyContinue) {
        Update-PowerShell_Override
    } else {
        try {
            Write-Host "🔍 Checking for PowerShell updates..." -ForegroundColor Cyan
            $currentVersion = $PSVersionTable.PSVersion.ToString()
            $gitHubApiUrl = "https://api.github.com/repos/PowerShell/PowerShell/releases/latest"
            $latestReleaseInfo = Invoke-RestMethod -Uri $gitHubApiUrl
            $latestVersion = $latestReleaseInfo.tag_name.Trim('v')
            
            if ([version]$currentVersion -lt [version]$latestVersion) {
                Write-Host "🔄 Updating PowerShell from v$currentVersion to v$latestVersion..." -ForegroundColor Yellow
                winget upgrade Microsoft.PowerShell --accept-source-agreements --accept-package-agreements
                Write-Host "✅ PowerShell has been updated. Please restart your shell." -ForegroundColor Green
            } else {
                Write-Host "✅ Your PowerShell is up to date (v$currentVersion)." -ForegroundColor Green
            }
        } catch {
            Write-Error "Failed to update PowerShell. Error: $_"
        }
    }
}

# Check for updates if not in debug mode
if (-not $debug -and `
    ($updateInterval -eq -1 -or `
     -not (Test-Path $timeFilePath) -or `
     ((Get-Date) - (Get-Content -Path $timeFilePath | Get-Date)).TotalDays -gt $updateInterval)) {
    
    Update-Profile
    Update-PowerShell
    
    # Update last execution time
    Get-Date -Format 'yyyy-MM-dd' | Out-File -FilePath $timeFilePath
} elseif ($debug) {
    Write-Warning "Debug mode enabled - skipping automatic updates"
}

#endregion

### Section 4: Module Imports ###
#region Module Imports

# Import Terminal-Icons module
if (-not (Get-Module -ListAvailable -Name Terminal-Icons)) {
    Write-Host "📦 Installing Terminal-Icons module..." -ForegroundColor Yellow
    Install-Module -Name Terminal-Icons -Scope CurrentUser -Force -SkipPublisherCheck
}
Import-Module -Name Terminal-Icons

# Import Chocolatey profile if available
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
    Import-Module "$ChocolateyProfile"
}

#endregion

### Section 5: Starship Prompt Configuration ###
#region Starship Prompt

function Initialize-Starship {
    if (Get-Command -Name "Get-Theme_Override" -ErrorAction SilentlyContinue) {
        Get-Theme_Override
    } else {
        # Check if Starship is installed
        if (Get-Command starship -ErrorAction SilentlyContinue) {
            # Initialize Starship
            Invoke-Expression (&starship init powershell)
            Write-Host "✅ Starship prompt initialized" -ForegroundColor Green
        } else {
            Write-Warning "Starship not found. Please install it from https://starship.rs/"
            Write-Host "You can install it using: winget install Starship.Starship" -ForegroundColor Yellow
        }
    }
}

# Initialize Starship
Initialize-Starship

#endregion

### Section 6: Utility Functions ###
#region Utility Functions

# Clear system cache
function Clear-Cache {
    if (Get-Command -Name "Clear-Cache_Override" -ErrorAction SilentlyContinue) {
        Clear-Cache_Override
    } else {
        Write-Host "🧹 Clearing cache..." -ForegroundColor Cyan
        
        $pathsToClear = @(
            "$env:SystemRoot\Prefetch\*",
            "$env:SystemRoot\Temp\*",
            "$env:TEMP\*",
            "$env:LOCALAPPDATA\Microsoft\Windows\INetCache\*"
        )
        
        foreach ($path in $pathsToClear) {
            if (Test-Path $path) {
                Remove-Item -Path $path -Recurse -Force -ErrorAction SilentlyContinue
            }
        }
        
        Write-Host "✅ Cache clearing completed." -ForegroundColor Green
    }
}

# Admin check and prompt customization
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
function prompt {
    if ($isAdmin) { "[" + (Get-Location) + "] # " } else { "[" + (Get-Location) + "] $ " }
}

# Set window title
$adminSuffix = if ($isAdmin) { " [ADMIN]" } else { "" }
$Host.UI.RawUI.WindowTitle = "PowerShell {0}$adminSuffix" -f $PSVersionTable.PSVersion.ToString()

# Quick access to editing the profile
function Edit-Profile {
    & $EDITOR $PROFILE.CurrentUserAllHosts
}
Set-Alias -Name ep -Value Edit-Profile

# Reload profile
function reload-profile {
    & $profile
}

#endregion

### Section 7: File and Directory Operations ###
#region File Operations

function touch($file) { 
    if (-not (Test-Path $file)) {
        New-Item -ItemType File -Path $file
    } else {
        (Get-Item $file).LastWriteTime = Get-Date
    }
}

function ff($name) {
    Get-ChildItem -Recurse -Filter "*${name}*" -ErrorAction SilentlyContinue | ForEach-Object {
        Write-Output "$($_.FullName)"
    }
}

function unzip($file) {
    Write-Host "📦 Extracting $file to current directory..." -ForegroundColor Cyan
    $fullFile = Get-ChildItem -Path $pwd -Filter $file | ForEach-Object { $_.FullName }
    Expand-Archive -Path $fullFile -DestinationPath $pwd
}

function nf { 
    param($name) 
    New-Item -ItemType "file" -Path . -Name $name 
}

function mkcd { 
    param($dir) 
    New-Item -ItemType Directory -Path $dir -Force | Out-Null
    Set-Location $dir
}

function trash($path) {
    $fullPath = Resolve-Path -Path $path -ErrorAction SilentlyContinue
    
    if ($fullPath) {
        $shell = New-Object -ComObject 'Shell.Application'
        $item = Get-Item $fullPath.Path
        $parentPath = if ($item.PSIsContainer) { $item.Parent.FullName } else { $item.DirectoryName }
        
        $shellItem = $shell.NameSpace($parentPath).ParseName($item.Name)
        if ($shellItem) {
            $shellItem.InvokeVerb('delete')
            Write-Host "🗑️  '$fullPath' moved to Recycle Bin." -ForegroundColor Green
        }
    } else {
        Write-Error "Item '$path' does not exist."
    }
}

# Navigation shortcuts
function docs { 
    Set-Location -Path ([Environment]::GetFolderPath("MyDocuments"))
}

function dtop { 
    Set-Location -Path ([Environment]::GetFolderPath("Desktop"))
}

#endregion

### Section 8: Git Operations ###
#region Git Functions

function gs { git status }

function ga { git add . }

function gc { 
    param($m) 
    git commit -m "$m" 
}

function gpush { git push }

function gpull { git pull }

function gcl { git clone "$args" }

function gcom {
    git add .
    git commit -m "$args"
}

function lazyg {
    git add .
    git commit -m "$args"
    git push
}

#endregion

### Section 9: System Information ###
#region System Info

function uptime {
    try {
        if ($PSVersionTable.PSVersion.Major -ge 6) {
            $bootTime = Get-Uptime -Since
        } else {
            $os = Get-WmiObject win32_operatingsystem
            $bootTime = [System.Management.ManagementDateTimeConverter]::ToDateTime($os.LastBootUpTime)
        }
        
        $uptime = (Get-Date) - $bootTime
        Write-Host "⏱️  System started: $($bootTime.ToString('dddd, MMMM dd, yyyy HH:mm:ss'))" -ForegroundColor Cyan
        Write-Host "⏱️  Uptime: $($uptime.Days) days, $($uptime.Hours) hours, $($uptime.Minutes) minutes, $($uptime.Seconds) seconds" -ForegroundColor Green
    } catch {
        Write-Error "Failed to get uptime: $_"
    }
}

function sysinfo { 
    Get-ComputerInfo | Select-Object -Property @(
        'WindowsProductName',
        'WindowsVersion',
        'OsHardwareAbstractionLayer',
        'CsNumberOfProcessors',
        'CsProcessors',
        'CsTotalPhysicalMemory',
        'OsTotalVisibleMemorySize'
    )
}

function Get-PubIP { 
    (Invoke-WebRequest http://ifconfig.me/ip -TimeoutSec 5).Content 
}

# WinUtil functions
function winutil {
    irm https://christitus.com/win | iex
}

function winutildev {
    if (Get-Command -Name "WinUtilDev_Override" -ErrorAction SilentlyContinue) {
        WinUtilDev_Override
    } else {
        irm https://christitus.com/windev | iex
    }
}

#endregion

### Section 10: Process Management ###
#region Process Management

function admin {
    if ($args.Count -gt 0) {
        $argList = $args -join ' '
        Start-Process wt -Verb runAs -ArgumentList "pwsh.exe -NoExit -Command $argList"
    } else {
        Start-Process wt -Verb runAs
    }
}
Set-Alias -Name su -Value admin

function k9 { 
    param($name)
    Get-Process $name -ErrorAction SilentlyContinue | Stop-Process -Force
}

function pgrep($name) {
    Get-Process $name
}

function pkill($name) {
    Get-Process $name -ErrorAction SilentlyContinue | Stop-Process
}

#endregion

### Section 11: Network Utilities ###
#region Network

function flushdns {
    Clear-DnsClientCache
    Write-Host "✅ DNS cache flushed" -ForegroundColor Green
}

function hb {
    if ($args.Length -eq 0) {
        Write-Error "No file path specified."
        return
    }
    
    $FilePath = $args[0]
    if (Test-Path $FilePath) {
        $Content = Get-Content $FilePath -Raw
        $uri = "http://bin.christitus.com/documents"
        
        try {
            $response = Invoke-RestMethod -Uri $uri -Method Post -Body $Content -ErrorAction Stop
            $url = "http://bin.christitus.com/$($response.key)"
            Set-Clipboard $url
            Write-Host "✅ URL copied to clipboard: $url" -ForegroundColor Green
        } catch {
            Write-Error "Failed to upload document: $_"
        }
    } else {
        Write-Error "File does not exist: $FilePath"
    }
}

#endregion

### Section 12: Text Processing ###
#region Text Processing

function grep($regex, $dir) {
    if ($dir) {
        Get-ChildItem $dir | Select-String $regex
    } else {
        $input | Select-String $regex
    }
}

function sed($file, $find, $replace) {
    (Get-Content $file).replace("$find", $replace) | Set-Content $file
}

function head {
    param($Path, $n = 10)
    Get-Content $Path -Head $n
}

function tail {
    param($Path, $n = 10, [switch]$f = $false)
    Get-Content $Path -Tail $n -Wait:$f
}

#endregion

### Section 13: Enhanced Command Line ###
#region Enhanced CLI

# PSReadLine Configuration
$PSReadLineOptions = @{
    EditMode = 'Windows'
    HistoryNoDuplicates = $true
    HistorySearchCursorMovesToEnd = $true
    Colors = @{
        Command = '#87CEEB'
        Parameter = '#98FB98'
        Operator = '#FFB6C1'
        Variable = '#DDA0DD'
        String = '#FFDAB9'
        Number = '#B0E0E6'
        Type = '#F0E68C'
        Comment = '#D3D3D3'
        Keyword = '#8367c7'
        Error = '#FF6347'
    }
    PredictionSource = 'History'
    PredictionViewStyle = 'ListView'
    BellStyle = 'None'
    MaximumHistoryCount = 10000
}
Set-PSReadLineOption @PSReadLineOptions

# Key handlers
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
Set-PSReadLineKeyHandler -Chord 'Ctrl+d' -Function DeleteChar
Set-PSReadLineKeyHandler -Chord 'Ctrl+w' -Function BackwardDeleteWord
Set-PSReadLineKeyHandler -Chord 'Alt+d' -Function DeleteWord
Set-PSReadLineKeyHandler -Chord 'Ctrl+LeftArrow' -Function BackwardWord
Set-PSReadLineKeyHandler -Chord 'Ctrl+RightArrow' -Function ForwardWord
Set-PSReadLineKeyHandler -Chord 'Ctrl+z' -Function Undo
Set-PSReadLineKeyHandler -Chord 'Ctrl+y' -Function Redo

# Filter sensitive commands from history
Set-PSReadLineOption -AddToHistoryHandler {
    param($line)
    $sensitive = @('password', 'secret', 'token', 'apikey', 'connectionstring')
    $hasSensitive = $sensitive | Where-Object { $line -match $_ }
    return ($null -eq $hasSensitive)
}

# Custom completions
$scriptblock = {
    param($wordToComplete, $commandAst, $cursorPosition)
    $customCompletions = @{
        'git' = @('status', 'add', 'commit', 'push', 'pull', 'clone', 'checkout', 'branch', 'merge', 'rebase')
        'npm' = @('install', 'start', 'run', 'test', 'build', 'publish')
        'deno' = @('run', 'compile', 'bundle', 'test', 'lint', 'fmt', 'cache', 'info', 'doc', 'upgrade')
    }
    
    $command = $commandAst.CommandElements[0].Value
    if ($customCompletions.ContainsKey($command)) {
        $customCompletions[$command] | Where-Object { $_ -like "$wordToComplete*" } | ForEach-Object {
            [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
        }
    }
}
Register-ArgumentCompleter -Native -CommandName git, npm, deno -ScriptBlock $scriptblock

#endregion

### Section 14: zoxide Configuration ###
#region zoxide

if (Get-Command zoxide -ErrorAction SilentlyContinue) {
    Invoke-Expression (& { (zoxide init --cmd z powershell | Out-String) })
} else {
    Write-Host "⚠️  zoxide not found. You can install it with:" -ForegroundColor Yellow
    Write-Host "   winget install ajeetdsouza.zoxide" -ForegroundColor Cyan
}

# Define git directory shortcut using zoxide
function g { z github }

#endregion

### Section 15: Help System ###
#region Help

function Show-Help {
    $helpText = @"
✨ PowerShell Profile Help ✨
============================

📋 Core Commands:
  ep              - Edit your PowerShell profile
  reload-profile  - Reload the current profile
  Update-Profile  - Update profile from repository
  Update-PowerShell - Update PowerShell to latest version
  Clear-Cache     - Clear system cache

📁 File Operations:
  touch <file>    - Create or update file timestamp
  nf <name>       - Create new file
  mkcd <dir>      - Create and change to directory
  trash <path>    - Move item to Recycle Bin
  unzip <file>    - Extract zip file
  ff <name>       - Find files by name
  docs            - Go to Documents folder
  dtop            - Go to Desktop folder

🐙 Git Shortcuts:
  gs              - git status
  ga              - git add .
  gc <msg>        - git commit -m
  gpush           - git push
  gpull           - git pull
  gcl <url>       - git clone
  gcom <msg>      - git add . && git commit -m
  lazyg <msg>     - git add . && git commit -m && git push

🖥️  System:
  admin           - Open new admin window
  uptime          - Show system uptime
  sysinfo         - Show system information
  flushdns        - Clear DNS cache
  Get-PubIP       - Get public IP address
  winutil         - Run WinUtil (Chris Titus)
  winutildev      - Run WinUtil dev version

🔍 Process Management:
  k9 <name>       - Kill process by name
  pgrep <name>    - Find processes by name
  pkill <name>    - Kill processes by name

📝 Text Processing:
  grep <regex> [dir] - Search for pattern
  sed <file> <find> <replace> - Replace text
  head <file> [n] - Show first n lines
  tail <file> [n] - Show last n lines

📊 Miscellaneous:
  hb <file>       - Upload file to hastebin
  g               - Go to git directory (zoxide)
  z <dir>         - Smart directory jump (zoxide)

🌐 Repository: https://github.com/hetfs/powershell-profile
🚀 Prompt: Starship (https://starship.rs/)

Type 'Get-Help <command>' for detailed help.
"@
    Write-Host $helpText
}

# Display help hint on first run
if (-not (Test-Path $timeFilePath)) {
    Write-Host "✨ Welcome to HETFS PowerShell Profile!" -ForegroundColor Cyan
    Write-Host "📚 Type 'Show-Help' to see available commands" -ForegroundColor Green
}

#endregion

### Section 16: Custom Configuration Loading ###
#region Custom Configuration

# Load HETFScustom.ps1 if it exists
$customConfigPath = Join-Path (Split-Path $PROFILE) "HETFScustom.ps1"
if (Test-Path $customConfigPath) {
    Write-Host "📁 Loading custom configuration from HETFScustom.ps1..." -ForegroundColor Cyan
    . $customConfigPath
}

# Load user's profile.ps1 if it exists
$userProfilePath = Join-Path (Split-Path $PROFILE) "profile.ps1"
if (Test-Path $userProfilePath) {
    Write-Host "📁 Loading user profile overrides..." -ForegroundColor Cyan
    . $userProfilePath
}

#endregion

### Section 17: Final Initialization ###
#region Final Initialization

# Set editor alias
Set-Alias -Name vim -Value $EDITOR

# Enhanced listing
function la { Get-ChildItem -Force | Format-Table -AutoSize }
function ll { Get-ChildItem -Force -File | Format-List }

# Clipboard utilities
function cpy { Set-Clipboard $args[0] }
function pst { Get-Clipboard }

# Other utilities
function which($name) {
    Get-Command $name | Select-Object -ExpandProperty Definition
}

function export($name, $value) {
    Set-Item -Force -Path "env:$name" -Value $value
}

function df { Get-Volume }

# Telemetry opt-out for admin sessions
if ($isAdmin) {
    [System.Environment]::SetEnvironmentVariable('POWERSHELL_TELEMETRY_OPTOUT', 'true', [System.EnvironmentVariableTarget]::Machine)
}

# Display completion message
if (-not $debug) {
    Write-Host "✅ HETFS PowerShell Profile loaded successfully" -ForegroundColor Green
    Write-Host "📚 Type 'Show-Help' for available commands" -ForegroundColor Cyan
}

#endregion
