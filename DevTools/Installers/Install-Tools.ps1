#Requires -Version 7.0
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# ------------------------------------------------------------
# Generic post-install validation
# ------------------------------------------------------------
function Invoke-PostInstallValidation {
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
            # Execute the custom validation script
            . $value
        }
        default {
            throw "Unknown validation type '$type' for tool '$($Tool.Name)'"
        }
    }
}

# ------------------------------------------------------------
# Main installer
# ------------------------------------------------------------
function Install-Tools {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
    param(
        [Parameter(Mandatory)]
        [PSCustomObject[]] $Tools,

        [Parameter(Mandatory)]
        [PSCustomObject] $EnvContext,

        [switch] $WinGetOnly,
        [switch] $ExportWinGetList
    )

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
        $name   = $Tool.Name

        # Skip if validation already passes (tool already installed)
        try {
            Invoke-PostInstallValidation -Tool $Tool
            Write-Information "✔ $name already installed and validated"
            continue
        }
        catch {
            # Tool not installed or validation failed, proceed to install
        }

        # Determine installer type
        $installerType = if ($WinGetOnly -and $Tool.WinGetId) {
            'WinGet'
        } elseif ($Tool.WinGetId) {
            'WinGet'
        } elseif ($Tool.ChocoId) {
            'Chocolatey'
        } elseif ($Tool.GitHubRepo) {
            'GitHubRelease'
        } elseif ($Tool.InstallerScript) {
            'Script'
        } else {
            'None'
        }

        if (-not $PSCmdlet.ShouldProcess($name, "Install via $installerType")) {
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
                default {
                    Write-Warning "No installer defined for $name"
                    continue
                }
            }

            # ------------------------------------------------------------
            # Post-install validation
            # ------------------------------------------------------------
            Invoke-PostInstallValidation -Tool $Tool

            Write-Information "✔ Installed and validated $name successfully"
        }
        catch {
            Write-Error ("Installation failed for {0}: {1}" -f $name, $_.Exception.Message)
            if (Test-IsCI) { throw }
        }
    }
}
