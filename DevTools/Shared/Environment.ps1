#Requires -Version 7.0
<#
.SYNOPSIS
    DevTools environment initialization and context management.

.DESCRIPTION
    - Provides session/run IDs
    - Normalizes paths safely
    - Detects system info, CI, elevation, and package managers
    - Returns a PSCustomObject context for the current DevTools run
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

#region ===== Session & Run Identity =====

function Get-DevToolsSessionId {
    [CmdletBinding()]
    param ()

    if (Get-Variable -Name PSSessionId -Scope Global -ErrorAction SilentlyContinue) {
        return $Global:PSSessionId
    }

    return $PID
}

function New-DevToolsRunId {
    [CmdletBinding()]
    param ()

    return [Guid]::NewGuid().ToString()
}

#endregion

#region ===== Environment Initialization =====

function Initialize-DevToolsEnvironment {
    [CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact='Low')]
    param(
        [Parameter(Mandatory)]
        [string]$RootPath,

        [Parameter(Mandatory)]
        [string]$InstallersPath,

        [Parameter(Mandatory)]
        [string]$ConfigPath,

        [Parameter(Mandatory)]
        [string]$OutputPath,

        [Parameter(Mandatory)]
        [string]$ToolsRegistryPath,

        [switch]$SkipValidation
    )

    begin {
        Write-Verbose '[Begin] DevTools environment initialization'
    }

    process {
        try {
            # --------------------------------
            # Normalize paths safely
            # --------------------------------
            $normalized = @{}
            $pathMap = @{
                RootPath          = $RootPath
                InstallersPath    = $InstallersPath
                ConfigPath        = $ConfigPath
                OutputPath        = $OutputPath
                ToolsRegistryPath = $ToolsRegistryPath
            }

            foreach ($key in $pathMap.Keys) {
                if (-not $pathMap[$key] -or [string]::IsNullOrWhiteSpace($pathMap[$key])) {
                    throw "Path parameter '$key' is null or empty"
                }
                $normalized[$key] = [System.IO.Path]::GetFullPath($pathMap[$key])
            }

            # --------------------------------
            # Validate directories exist
            # --------------------------------
            if (-not $SkipValidation) {
                foreach ($path in $normalized.Values) {
                    if (-not (Test-Path -LiteralPath $path)) {
                        throw "Required path not found: $path"
                    }
                }
            }

            # Ensure OutputPath exists
            if (-not (Test-Path -LiteralPath $normalized.OutputPath)) {
                New-Item -ItemType Directory -Path $normalized.OutputPath -Force | Out-Null
            }

            # --------------------------------
            # Identity
            # --------------------------------
            $sessionId = Get-DevToolsSessionId
            $runId     = New-DevToolsRunId

            # --------------------------------
            # System info
            # --------------------------------
            $system = Get-SystemInformation
            $isElevated = Test-Administrator

            # --------------------------------
            # Package managers
            # --------------------------------
            $packageManagers = [PSCustomObject]@{
                WinGet        = Test-WinGetAvailable
                Chocolatey    = Test-ChocolateyAvailable
                PowerShellGet = Test-PowerShellGetAvailable
                Scoop         = Test-ScoopAvailable
            }

            # --------------------------------
            # Compose environment context
            # --------------------------------
            $context = [PSCustomObject]@{
                # Identity
                SessionId         = $sessionId
                RunId             = $runId
                ProcessId         = $PID

                # Paths
                RootPath          = $normalized.RootPath
                InstallersPath    = $normalized.InstallersPath
                ConfigPath        = $normalized.ConfigPath
                OutputPath        = $normalized.OutputPath
                ToolsRegistryPath = $normalized.ToolsRegistryPath

                # Runtime
                PSVersion         = $PSVersionTable.PSVersion
                PSEdition         = $PSVersionTable.PSEdition
                ExecutionPolicy   = Get-ExecutionPolicy -Scope Process

                # System
                OS                = $system.OS
                Architecture      = $system.Architecture
                Is64Bit           = $system.Is64Bit
                IsElevated        = $isElevated

                # CI
                IsCI              = Test-IsCI
                CIProvider        = Get-CIProvider

                # Package managers
                PackageManagers   = $packageManagers

                # Timing
                StartTimeUtc      = [DateTime]::UtcNow
                StartTimeLocal    = Get-Date
            }

            Write-Verbose 'Environment context created successfully'
            return $context
        }
        catch {
            throw "DevTools environment initialization failed: $($_.Exception.Message)"
        }
    }

    end {
        Write-Verbose '[End] DevTools environment initialization completed'
    }
}

#endregion

#region ===== Helpers =====

function Test-IsCI {
    [CmdletBinding()]
    param()
    return [bool](
        $env:CI -or
        $env:GITHUB_ACTIONS -or
        $env:TF_BUILD -or
        $env:JENKINS_URL -or
        $env:TEAMCITY_VERSION
    )
}

function Get-CIProvider {
    [CmdletBinding()]
    param()
    if ($env:GITHUB_ACTIONS) { return 'GitHubActions' }
    if ($env:TF_BUILD)        { return 'AzureDevOps' }
    if ($env:JENKINS_URL)     { return 'Jenkins' }
    if ($env:TEAMCITY_VERSION){ return 'TeamCity' }
    if ($env:CI)              { return 'GenericCI' }
    return $null
}

function Test-WinGetAvailable {
    [CmdletBinding()]
    param()
    try { Get-Command winget -ErrorAction Stop | Out-Null; return $true } catch { return $false }
}

function Test-ChocolateyAvailable {
    [CmdletBinding()]
    param()
    try { Get-Command choco -ErrorAction Stop | Out-Null; return $true } catch { return $false }
}

function Test-PowerShellGetAvailable {
    [CmdletBinding()]
    param()
    try { Get-Module PowerShellGet -ListAvailable | Out-Null; return $true } catch { return $false }
}

function Test-ScoopAvailable {
    [CmdletBinding()]
    param()
    try { Get-Command scoop -ErrorAction Stop | Out-Null; return $true } catch { return $false }
}

function Test-Administrator {
    [CmdletBinding()]
    param()
    $id = [Security.Principal.WindowsIdentity]::GetCurrent()
    $p  = [Security.Principal.WindowsPrincipal]::new($id)
    return $p.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Get-SystemInformation {
    [CmdletBinding()]
    param()
    return [PSCustomObject]@{
        OS           = [Environment]::OSVersion.VersionString
        Architecture = if ([Environment]::Is64BitOperatingSystem) { 'x64' } else { 'x86' }
        Is64Bit      = [Environment]::Is64BitOperatingSystem
    }
}

#endregion
