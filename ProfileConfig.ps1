### Profile Configuration
### Version 2.0

# Configuration Variables
$global:debug = $false
$global:repo_root = "https://raw.githubusercontent.com/hetfs"
$global:timeFilePath = "$env:USERPROFILE\Documents\PowerShell\LastExecutionTime.txt"
$global:updateInterval = 7
$global:canConnectToGitHub = $false

# Check for overrides
if (Test-Path variable:debug_Override) { $global:debug = $debug_Override }
if (Test-Path variable:repo_root_Override) { $global:repo_root = $repo_root_Override }
if (Test-Path variable:timeFilePath_Override) { $global:timeFilePath = $timeFilePath_Override }
if (Test-Path variable:updateInterval_Override) { $global:updateInterval = $updateInterval_Override }

# Initial GitHub connectivity check
try {
    $global:canConnectToGitHub = Test-Connection github.com -Count 1 -Quiet -TimeoutSeconds 1
}
catch {
    $global:canConnectToGitHub = $false
}

# Opt-out of telemetry if running as admin
if ([bool]([System.Security.Principal.WindowsIdentity]::GetCurrent()).IsSystem) {
    [System.Environment]::SetEnvironmentVariable('POWERSHELL_TELEMETRY_OPTOUT', 'true', [System.EnvironmentVariableTarget]::Machine)
}

# Import required modules
if (-not (Get-Module -ListAvailable -Name Terminal-Icons)) {
    Install-Module -Name Terminal-Icons -Scope CurrentUser -Force -SkipPublisherCheck
}
Import-Module -Name Terminal-Icons

# Chocolatey Profile
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path $ChocolateyProfile) {
    Import-Module $ChocolateyProfile
}
