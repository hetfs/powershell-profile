#Requires -Version 7.0
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

<#
.SYNOPSIS
    Chocolatey installer module for DevTools.

.DESCRIPTION
    Installs and manages tools using Chocolatey silently, with full CmdletBinding support.
    No interactive prompts; supports -WhatIf and -Confirm.
#>

# ------------------------------------------------------------
#region ===== Chocolatey Detection =====

function Test-ChocolateyAvailable {
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    $choco = Get-Command 'choco' -ErrorAction SilentlyContinue
    if ($choco) { Write-Verbose "Chocolatey available at: $($choco.Source)"; return $true }

    Write-Verbose "Chocolatey not available"
    return $false
}

function Get-ChocolateyVersion {
    [CmdletBinding()]
    [OutputType([System.Version])]
    param()

    if (-not (Test-ChocolateyAvailable)) { return $null }

    try {
        $versionOutput = (& choco --version 2>$null).Trim()
        return [System.Version]::Parse($versionOutput)
    }
    catch { Write-Verbose "Failed to get Chocolatey version: $_"; return $null }
}

function Update-ChocolateySelf {
    [CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact='High')]
    param()

    if (-not (Test-ChocolateyAvailable)) { return $false }
    if (-not $PSCmdlet.ShouldProcess("Chocolatey", "Upgrade Chocolatey to latest version")) { return $false }
    if ($PSCmdlet.MyInvocation.BoundParameters.ContainsKey('WhatIf')) {
        Write-Host "[WHATIF] Would upgrade Chocolatey itself" -ForegroundColor Cyan
        return $true
    }

    Write-Host "[Action] Upgrading Chocolatey..." -ForegroundColor Cyan
    try {
        & choco upgrade chocolatey -y --no-progress --ignore-checksums
        Write-Host "✓ Chocolatey upgraded successfully" -ForegroundColor Green
        return $true
    }
    catch { Write-Error "Failed to upgrade Chocolatey: $_"; return $false }
}

#endregion
# ------------------------------------------------------------
#region ===== Tool Installation =====

function Install-WithChocolatey {
    [CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact='High')]
    param (
        [Parameter(Mandatory, Position=0)]
        [PSCustomObject]$Tool
    )

    begin { Write-Verbose "[Begin] Chocolatey installer initialization" }

    process {
        if (-not $Tool.Name) { throw "Chocolatey: missing 'Name' property" }
        if (-not $Tool.ChocoId) {
            Write-Verbose "Skipping '$($Tool.Name)': no ChocoId defined [$($Tool.Category)]"
            return $false
        }

        $toolName     = ($Tool.DisplayName ?? $Tool.Name).Trim()
        $categoryDesc = ($Tool.CategoryDescription ?? $Tool.Category).Trim()

        # Skip if binary already exists
        if ($Tool.BinaryCheck -and (Get-Command $Tool.BinaryCheck -ErrorAction SilentlyContinue)) {
            Write-Verbose "'$toolName' already installed [$($Tool.Category): $categoryDesc]"
            return $true
        }

        # Verify Chocolatey availability
        if (-not (Test-ChocolateyAvailable)) {
            Write-Warning "Chocolatey not available. Cannot install '$toolName'"
            return $false
        }

        # ShouldProcess / WhatIf support
        if (-not $PSCmdlet.ShouldProcess("Install '$toolName' via Chocolatey")) { return $false }
        if ($PSCmdlet.MyInvocation.BoundParameters.ContainsKey('WhatIf')) {
            Write-Host "[WHATIF] Would install '$toolName' via Chocolatey (ID: $($Tool.ChocoId))" -ForegroundColor Cyan
            return $true
        }

        # Build silent install arguments
        $args = @('install', $Tool.ChocoId, '-y', '--no-progress', '--accept-license', '--ignore-checksums')
        if ($Tool.ChocoParams) { $args += $Tool.ChocoParams }

        Write-Host "Installing '$toolName' via Chocolatey..." -ForegroundColor Cyan
        Write-Debug "Chocolatey arguments: $($args -join ' ')"

        try {
            $process = Start-Process 'choco' -ArgumentList $args -Wait -NoNewWindow -PassThru -ErrorAction Stop
            if ($process.ExitCode -ne 0) {
                Write-Warning "Chocolatey failed for '$toolName' (exit code: $($process.ExitCode))"
                return $false
            }

            # Binary validation
            if ($Tool.BinaryCheck) {
                Start-Sleep 2
                if (Get-Command $Tool.BinaryCheck -ErrorAction SilentlyContinue) {
                    Write-Host "✓ '$toolName' installed successfully via Chocolatey" -ForegroundColor Green
                    return $true
                }

                if ($Tool.AltCheck) {
                    try {
                        $altResult = Invoke-Expression $Tool.AltCheck -ErrorAction SilentlyContinue
                        if ($altResult) {
                            Write-Host "✓ '$toolName' verified via alternative method" -ForegroundColor Green
                            return $true
                        }
                    }
                    catch { Write-Warning "Alternative check failed for '$toolName': $_" }
                }

                Write-Warning "Chocolatey reported success but binary '$($Tool.BinaryCheck)' not found for '$toolName'"
                return $false
            }

            Write-Host "✓ '$toolName' installed via Chocolatey (no binary check)" -ForegroundColor Green
            return $true
        }
        catch { Write-Error "Chocolatey installation failed for '$toolName': $_"; return $false }
    }

    end { Write-Verbose "[End] Chocolatey installer completed" }
}

#endregion
# ----------------------------------------
