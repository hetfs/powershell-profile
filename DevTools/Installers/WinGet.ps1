#Requires -Version 7.0
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

<#
.SYNOPSIS
    WinGet installer module for DevTools.

.DESCRIPTION
    Installs, queries, and manages tools via Windows Package Manager (WinGet)
    with full PowerShell CmdletBinding support.

.LINK
    https://learn.microsoft.com/en-us/windows/package-manager/winget/
#>

# ------------------------------------------------------------
# Test WinGet availability
# ------------------------------------------------------------
function Test-WinGetAvailable {
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    $cmd = Get-Command 'winget' -ErrorAction SilentlyContinue
    if ($cmd) { Write-Verbose "WinGet available at $($cmd.Source)"; return $true }
    Write-Verbose "WinGet not available"
    return $false
}

# ------------------------------------------------------------
# Get WinGet version
# ------------------------------------------------------------
function Get-WinGetVersion {
    [CmdletBinding()]
    [OutputType([System.Version])]
    param()

    if (-not (Test-WinGetAvailable)) { return $null }

    try {
        $ver = (& winget --version).Trim() -replace '^v',''
        return [System.Version]::Parse($ver)
    }
    catch { Write-Verbose "Failed to get WinGet version: $_"; return $null }
}

# ------------------------------------------------------------
# Install a tool via WinGet
# ------------------------------------------------------------
function Install-WithWinGet {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    param (
        [Parameter(Mandatory)]
        [PSCustomObject]$Tool
    )

    begin { Write-Verbose "[Begin] WinGet installer initialization" }

    process {
        try {
            # Validate required properties
            foreach ($prop in @('Name','Category','WinGetId')) {
                if (-not $Tool.PSObject.Properties[$prop]) {
                    throw "WinGet: Missing required property '$prop'"
                }
            }

            $toolName = if ($Tool.DisplayName) { $Tool.DisplayName.Trim() } else { $Tool.Name.Trim() }
            $category = if ($Tool.CategoryDescription) { $Tool.CategoryDescription.Trim() } else { $Tool.Category.Trim() }

            # Skip if binary already exists
            if ($Tool.BinaryCheck -and (Get-Command $Tool.BinaryCheck -ErrorAction SilentlyContinue)) {
                Write-Verbose "'$toolName' already installed [$category]"
                return $true
            }

            # Verify WinGet is available
            if (-not (Test-WinGetAvailable)) {
                Write-Warning "WinGet is not available. Cannot install '$toolName'"
                return $false
            }

            # ShouldProcess / WhatIf support
            $opDesc = "Install '$toolName' via WinGet"
            if (-not $PSCmdlet.ShouldProcess($opDesc, "Category: $category")) { return $false }
            if ($PSCmdlet.MyInvocation.BoundParameters.ContainsKey('WhatIf')) {
                Write-Host "[WHATIF] Would install '$toolName' via WinGet (ID: $($Tool.WinGetId))" -ForegroundColor Cyan
                return $true
            }

            # Build WinGet arguments
            $args = @('install','--id',$Tool.WinGetId,'--exact','--silent','--accept-package-agreements','--accept-source-agreements')
            if ($Tool.WinGetSource)  { $args += @('--source', $Tool.WinGetSource) }
            if ($Tool.WinGetScope)   { $args += @('--scope', $Tool.WinGetScope) } else { $args += @('--scope','user') }
            if ($Tool.WinGetVersion) { $args += @('--version', $Tool.WinGetVersion) }
            if ($Tool.WinGetParams)  { $args += $Tool.WinGetParams }

            Write-Verbose "WinGet arguments: $($args -join ' ')"
            Write-Host "Installing '$toolName' via WinGet..." -ForegroundColor Cyan

            # Execute WinGet
            $process = Start-Process -FilePath 'winget' -ArgumentList $args -Wait -PassThru -NoNewWindow -ErrorAction Stop

            # Check exit code
            $successExitCodes = if ($Tool.WinGetSuccessCodes) { $Tool.WinGetSuccessCodes } else { @(0) }
            if ($process.ExitCode -notin $successExitCodes) {
                Write-Warning "WinGet failed for '$toolName' (exit code: $($process.ExitCode))"
                return $process.ExitCode -eq -1978335189  # ERROR_PACKAGE_ALREADY_INSTALLED
            }

            # Verify binary if defined
            if ($Tool.BinaryCheck) {
                Start-Sleep 2
                if (Get-Command $Tool.BinaryCheck -ErrorAction SilentlyContinue) {
                    Write-Host "✓ '$toolName' installed successfully via WinGet" -ForegroundColor Green

                    # Add to user PATH if required
                    if ($Tool.AddToPath) {
                        $userPath = [Environment]::GetEnvironmentVariable('PATH','User')
                        if ($Tool.BinaryCheck -notin ($userPath -split ';')) {
                            [Environment]::SetEnvironmentVariable('PATH', "$userPath;$($Tool.BinaryCheck)", 'User')
                            Write-Verbose "Added '$($Tool.BinaryCheck)' to user PATH"
                        }
                    }
                    return $true
                }
                Write-Warning "Binary '$($Tool.BinaryCheck)' not found after installation"
                return $false
            }

            Write-Host "✓ '$toolName' installed via WinGet (no binary check)" -ForegroundColor Green
            return $true
        }
        catch { Write-Error "WinGet installer error: $_"; return $false }
    }

    end { Write-Verbose "[End] WinGet installation completed" }
}

# ------------------------------------------------------------
# Search WinGet packages
# ------------------------------------------------------------
function Search-WinGetPackage {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Query,
        [string]$Source = 'winget',
        [switch]$Exact
    )

    if (-not (Test-WinGetAvailable)) { Write-Warning "WinGet not available"; return @() }

    $args = @('search', $Query, '--source', $Source)
    if ($Exact) { $args += '--exact' }

    try { return & winget @args 2>$null }
    catch { Write-Verbose "WinGet search failed: $_"; return @() }
}

# ------------------------------------------------------------
# Get installed WinGet package info
# ------------------------------------------------------------
function Get-WinGetPackage {
    [CmdletBinding()]
    param([Parameter(Mandatory)][string]$Id)

    if (-not (Test-WinGetAvailable)) { Write-Warning "WinGet not available"; return $null }

    try {
        $output = & winget list --id $Id --exact 2>$null
        if ($output.Count -gt 1) {
            $fields = ($output | Select-Object -Skip 1)[0] -split '\s+'
            if ($fields.Count -ge 3) {
                return [PSCustomObject]@{
                    Id      = $Id
                    Name    = $fields[0]
                    Version = $fields[1]
                    Source  = $fields[2]
                }
            }
        }
    }
    catch { Write-Verbose "Failed to get WinGet package info: $_" }
    return $null
}

# ------------------------------------------------------------
# Upgrade WinGet packages
# ------------------------------------------------------------
function Update-WinGetPackages {
    [CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact='High')]
    param(
        [Parameter(ParameterSetName='ById')][string]$Id,
        [Parameter(ParameterSetName='All')][switch]$All
    )

    if (-not (Test-WinGetAvailable)) { Write-Warning "WinGet not available"; return $false }

    $desc = if ($Id) { "Upgrade WinGet package: $Id" } else { "Upgrade all WinGet packages" }
    if (-not $PSCmdlet.ShouldProcess($desc, "Confirm WinGet Upgrade")) { return $false }
    if ($PSCmdlet.MyInvocation.BoundParameters.ContainsKey('WhatIf')) {
        Write-Host "[WHATIF] Would upgrade WinGet package(s)" -ForegroundColor Cyan
        return $true
    }

    try {
        $args = @('upgrade','--silent','--accept-package-agreements','--accept-source-agreements')
        if ($Id) { $args += @('--id', $Id, '--exact') } elseif ($All) { $args += '--all' }

        Write-Host "Upgrading WinGet packages..." -ForegroundColor Cyan
        & winget @args
        Write-Host "✓ WinGet packages upgraded successfully" -ForegroundColor Green
        return $true
    }
    catch { Write-Error "Failed to upgrade WinGet packages: $_"; return $false }
}
