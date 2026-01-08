# ================================
# Usage
# .\DevTools.ps1
# .\DevTools.ps1 -WhatIf
# .\DevTools.ps1 -Plan
# .\DevTools.ps1 -Category terminal
# .\DevTools.ps1 -Tools git,neovim
# =================================
#Requires -Version 7.0
[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [string[]] $Tools,
    [string]   $Category,
    [switch]   $WinGetOnly,
    [switch]   $ExportWinGetList,
    [switch]   $Plan
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# ------------------------------------------------------------
# Helper: normalize to array
# ------------------------------------------------------------
function As-Array {
    param([object]$InputObject)

    if ($null -eq $InputObject) {
        @()
    }
    elseif ($InputObject -is [System.Collections.IEnumerable] -and
            $InputObject -isnot [string]) {
        @($InputObject)
    }
    else {
        @($InputObject)
    }
}

# ------------------------------------------------------------
# Main
# ------------------------------------------------------------
function Invoke-DevTools {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
    param(
        [string[]] $Tools,
        [string]   $Category,
        [switch]   $WinGetOnly,
        [switch]   $ExportWinGetList,
        [switch]   $Plan
    )

    begin {
        if ($env:CI -or $env:GITHUB_ACTIONS -or $env:TF_BUILD) {
            $ConfirmPreference = 'None'
        }

        $RootPath       = $PSScriptRoot
        $SharedPath     = Join-Path $RootPath 'Shared'
        $ConfigPath     = Join-Path $RootPath 'Config'
        $InstallersPath = Join-Path $RootPath 'Installers'
        $ToolsRegistry  = Join-Path $RootPath 'ToolsRegistry'
        $OutputPath     = Join-Path $RootPath 'Output'

        foreach ($dir in @($SharedPath, $ConfigPath, $InstallersPath, $ToolsRegistry)) {
            if (-not (Test-Path -LiteralPath $dir)) {
                throw "Required directory missing: $dir"
            }
        }

        if (-not (Test-Path -LiteralPath $OutputPath)) {
            New-Item -ItemType Directory -Path $OutputPath -Force | Out-Null
        }

        $LogPath = Join-Path $OutputPath 'DevToolsInstall.log'
    }

    process {
        $LogConfig = $null

        try {
            # ------------------------------------------------------------
            # Load shared modules
            # ------------------------------------------------------------
            foreach ($module in @(
                'Helpers.ps1',
                'Logging.ps1',
                'Environment.ps1',
                'DependencyResolver.ps1',
                'ToolValidator.ps1',
                'DocsGenerator.ps1'
            )) {
                $modulePath = Join-Path $SharedPath $module
                if (-not (Test-Path -LiteralPath $modulePath)) {
                    throw "Shared module missing: $modulePath"
                }
                . $modulePath
            }

            # ------------------------------------------------------------
            # Logging
            # ------------------------------------------------------------
            $LogConfig = Initialize-DevToolsLogging `
                -LogPath $LogPath `
                -MinimumLevel 'DEBUG'

            Start-LoggingSession -Config $LogConfig

            Write-Log `
                -Config $LogConfig `
                -Level INFO `
                -Message "DevTools started (PowerShell $($PSVersionTable.PSVersion))"

            # ------------------------------------------------------------
            # Environment
            # ------------------------------------------------------------
            $EnvContext = Initialize-DevToolsEnvironment `
                -RootPath $RootPath `
                -InstallersPath $InstallersPath `
                -ConfigPath $ConfigPath `
                -OutputPath $OutputPath `
                -ToolsRegistryPath $ToolsRegistry

            Write-Log -Config $LogConfig -Level INFO -Message "Environment initialized"

            # ------------------------------------------------------------
            # Categories
            # ------------------------------------------------------------
            $CategoriesFile = Join-Path $ConfigPath 'categories.ps1'
            if (-not (Test-Path -LiteralPath $CategoriesFile)) {
                throw "categories.ps1 not found"
            }

            $Categories = & $CategoriesFile
            if ($Categories -isnot [PSCustomObject]) {
                throw "categories.ps1 must return a PSCustomObject"
            }

            Write-Log `
                -Config $LogConfig `
                -Level SUCCESS `
                -Message ("Loaded categories: " + ($Categories.PSObject.Properties.Name -join ', '))

            # ------------------------------------------------------------
            # Load tools
            # ------------------------------------------------------------
            $ResolvedTools = @()
            $ToolFiles = Get-ChildItem -Path $ToolsRegistry -Filter '*.ps1' | Sort-Object Name

            foreach ($file in $ToolFiles) {
                try {
                    $toolsFromFile = As-Array (& $file.FullName)

                    $valid = $toolsFromFile | Where-Object {
                        $_ -is [PSCustomObject] -and
                        $_.PSObject.Properties['Name'] -and
                        $_.PSObject.Properties['Category'] -and
                        $_.PSObject.Properties['ToolType']
                    }

                    if ($valid.Count -gt 0) {
                        $ResolvedTools += $valid
                        Write-Log -Config $LogConfig -Level DEBUG `
                            -Message "Loaded $($valid.Count) tools from $($file.Name)"
                    }
                    else {
                        Write-Log -Config $LogConfig -Level WARNING `
                            -Message "No valid tools in $($file.Name)"
                    }
                }
                catch {
                    Write-Log -Config $LogConfig -Level ERROR `
                        -Message "Failed loading $($file.Name): $($_.Exception.Message)"
                }
            }

            if ($ResolvedTools.Count -eq 0) {
                Write-Log -Config $LogConfig -Level WARNING -Message "No tools loaded"
                return
            }

            Write-Log -Config $LogConfig -Level SUCCESS `
                -Message "Total tools loaded: $($ResolvedTools.Count)"

            # ------------------------------------------------------------
            # Filters
            # ------------------------------------------------------------
            if ($Category) {
                $ResolvedTools = $ResolvedTools | Where-Object Category -eq $Category
            }

            if ($Tools) {
                $ResolvedTools = $ResolvedTools | Where-Object Name -in $Tools
            }

            if ($ResolvedTools.Count -eq 0) {
                Write-Log -Config $LogConfig -Level WARNING -Message "No matching tools found"
                return
            }

            Write-Log -Config $LogConfig -Level INFO `
                -Message "Filtered tools count: $($ResolvedTools.Count)"

            # ------------------------------------------------------------
            # Plan mode
            # ------------------------------------------------------------
            if ($Plan) {
                Write-Log -Config $LogConfig -Level INFO -Message "Plan-only mode enabled"
                $ResolvedTools | Sort-Object Category, Name |
                    Format-Table Name, Category, ToolType -AutoSize
                return
            }

            # ------------------------------------------------------------
            # Install
            # ------------------------------------------------------------
            $InstallerPath = Join-Path $InstallersPath 'Install-Tools.ps1'
            if (-not (Test-Path -LiteralPath $InstallerPath)) {
                throw "Install-Tools.ps1 not found"
            }

            . $InstallerPath

            if ($PSCmdlet.ShouldProcess('DevTools', 'Install tools')) {
                Install-Tools `
                    -Tools $ResolvedTools `
                    -EnvContext $EnvContext `
                    -WinGetOnly:$WinGetOnly `
                    -ExportWinGetList:$ExportWinGetList
            }

            Write-Log -Config $LogConfig -Level SUCCESS -Message "DevTools completed successfully"
        }
        finally {
            if ($LogConfig) {
                Stop-LoggingSession -Config $LogConfig
            }
        }
    }
}

Invoke-DevTools `
    -Tools $Tools `
    -Category $Category `
    -WinGetOnly:$WinGetOnly `
    -ExportWinGetList:$ExportWinGetList `
    -Plan:$Plan `
    -WhatIf:$WhatIfPreference
