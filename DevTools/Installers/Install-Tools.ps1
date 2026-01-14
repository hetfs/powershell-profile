#Requires -Version 7.0
<#
.SYNOPSIS
    Universal DevTools installer module.
.DESCRIPTION
    Installs and validates tools using WinGet, Chocolatey, GitHub Releases, or custom scripts.
    Supports CI environments, WhatIf/Confirm, and safe property access.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# ------------------------------------------------------------
# Generic post-install validation
# ------------------------------------------------------------
function Invoke-PostInstallValidation {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [PSCustomObject]$Tool
    )

    if (-not $Tool.Validation) { return }

    $type  = $Tool.Validation.Type
    $value = $Tool.Validation.Value

    switch ($type) {
        'Command' {
            if (-not (Get-Command $value -ErrorAction SilentlyContinue)) {
                throw "Post-install validation failed: command '$value' not found"
            }
        }
        'Path' {
            if (-not (Test-Path -LiteralPath $value)) {
                throw "Post-install validation failed: path '$value' does not exist"
            }
        }
        'Script' {
            if (-not (Test-Path -LiteralPath $value)) {
                throw "Validation script '$value' not found"
            }
            & $value
        }
        default {
            throw "Unknown validation type '$type' for tool '$($Tool.Name)'"
        }
    }
}

# ------------------------------------------------------------
# Determine installer type safely
# ------------------------------------------------------------
function Get-PreferredInstaller {
    param([PSCustomObject]$Tool, [switch]$WinGetOnly)

    if ($WinGetOnly -and $Tool.WinGetId) { return 'WinGet' }

    if ($Tool.PSObject.Properties['PreferredInstaller'] -and $Tool.PreferredInstaller) {
        return $Tool.PreferredInstaller
    }

    if ($Tool.WinGetId)        { return 'WinGet' }
    if ($Tool.ChocoId)         { return 'Chocolatey' }
    if ($Tool.GitHubRepo)      { return 'GitHubRelease' }
    if ($Tool.InstallerScript) { return 'Script' }

    return 'None'
}

# ------------------------------------------------------------
# Main installer
# ------------------------------------------------------------
function Install-Tools {
    [CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact='Medium')]
    param(
        [Parameter(Mandatory)]
        [PSCustomObject[]] $Tools,

        [Parameter(Mandatory)]
        [PSCustomObject] $EnvContext,

        [switch] $WinGetOnly,
        [switch] $ExportWinGetList
    )

    # ------------------------------------------------------------
    # Ensure $Tools is always an array (fix .Count issue)
    # ------------------------------------------------------------
    if ($Tools -isnot [System.Array]) { $Tools = @($Tools) }

    # ------------------------------------------------------------
    # Initialize summary
    # ------------------------------------------------------------
    $summary = [System.Collections.Generic.List[PSCustomObject]]::new()

    # ------------------------------------------------------------
    # Export WinGet list if requested
    # ------------------------------------------------------------
    if ($ExportWinGetList) {
        $wingetPath = Join-Path $EnvContext.OutputPath 'winget-tools.txt'

        $Tools |
            Where-Object { $_.WinGetId } |
            Select-Object Name, WinGetId |
            Sort-Object Name |
            Set-Content -Path $wingetPath

        Write-Information "✔ WinGet list exported to $wingetPath"
    }

    # ------------------------------------------------------------
    # Install loop
    # ------------------------------------------------------------
    foreach ($Tool in $Tools) {
        $name = $Tool.Name
        $status = 'Skipped'

        # Skip if validation already passes
        try {
            Invoke-PostInstallValidation -Tool $Tool
            Write-Information "✔ $name already installed and validated"
            $status = 'AlreadyInstalled'
            $summary.Add([PSCustomObject]@{ Tool=$name; Status=$status })
            continue
        }
        catch {
            # Tool not installed or validation failed
        }

        $installerType = Get-PreferredInstaller -Tool $Tool -WinGetOnly:$WinGetOnly

        if ($installerType -eq 'None') {
            Write-Warning "No installer defined for '$name', skipping"
            $summary.Add([PSCustomObject]@{ Tool=$name; Status='NoInstaller' })
            continue
        }

        if (-not $PSCmdlet.ShouldProcess($name, "Install via $installerType")) {
            $summary.Add([PSCustomObject]@{ Tool=$name; Status='Skipped' })
            continue
        }

        # ------------------------------------------------------------
        # Install the tool
        # ------------------------------------------------------------
        try {
            switch ($installerType) {
                'WinGet' {
                    Install-WithWinGet -Tool $Tool -EnvContext $EnvContext
                }
                'Chocolatey' {
                    Install-WithChocolatey -Tool $Tool
                }
                'GitHubRelease' {
                    Install-WithGitHubRelease -Tool $Tool -EnvContext $EnvContext
                }
                'Script' {
                    & $Tool.InstallerScript -Tool $Tool -EnvContext $EnvContext
                }
            }

            # Post-install validation
            Invoke-PostInstallValidation -Tool $Tool
            Write-Information "✔ Installed and validated '$name' successfully"
            $status = 'Installed'
        }
        catch {
            Write-Error ("Installation failed for {0}: {1}" -f $name, $_.Exception.Message)
            if (Test-IsCI) { throw }
            $status = 'Failed'
        }
        finally {
            $summary.Add([PSCustomObject]@{ Tool=$name; Status=$status })
        }
    }

    # ------------------------------------------------------------
    # Detailed summary function
    # ------------------------------------------------------------
    function Show-InstallationSummary {
        Write-Host "`n🔹 DevTools Installation Summary" -ForegroundColor Cyan
        Write-Host "----------------------------------------"
        foreach ($item in $summary) {
            switch ($item.Status) {
                'Installed'        { Write-Host "✅ $($item.Tool) installed successfully" -ForegroundColor Green }
                'AlreadyInstalled' { Write-Host "ℹ️  $($item.Tool) already installed" -ForegroundColor Yellow }
                'Skipped'          { Write-Host "⚠️  $($item.Tool) skipped" -ForegroundColor DarkYellow }
                'Failed'           { Write-Host "❌ $($item.Tool) installation failed" -ForegroundColor Red }
                'NoInstaller'      { Write-Host "❌ $($item.Tool) has no installer defined" -ForegroundColor Red }
            }
        }
        Write-Host "----------------------------------------`n"
    }

    # Show summary
    Show-InstallationSummary
}
