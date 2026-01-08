# ------------------------------------------------------------
# DevTools bootstrap (supports inline execution)
# ------------------------------------------------------------
function Resolve-DevToolsRoot {
    if ($PSScriptRoot -and (Test-Path -LiteralPath $PSScriptRoot)) {
        return $PSScriptRoot
    }

    $Root = Join-Path $env:TEMP 'powershell-profile\DevTools'

    if (-not (Test-Path -LiteralPath $Root)) {
        Write-Host '→ Bootstrapping DevTools (inline execution)…' -ForegroundColor Cyan

        $ZipUrl  = 'https://github.com/hetfs/powershell-profile/archive/refs/heads/main.zip'
        $ZipPath = Join-Path $env:TEMP 'powershell-profile.zip'

        Invoke-WebRequest -Uri $ZipUrl -OutFile $ZipPath
        Expand-Archive -Path $ZipPath -DestinationPath $env:TEMP -Force
        Remove-Item $ZipPath -Force
    }

    return $Root
}

$Script:DevToolsRoot = Resolve-DevToolsRoot

# Re-exec locally when invoked via irm | iex
if (-not $PSScriptRoot) {
    & "$Script:DevToolsRoot\DevTools.ps1" @PSBoundParameters
    return
}

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

    if ($null -eq $InputObject) { @() }
    elseif ($InputObject -is [System.Collections.IEnumerable] -and $InputObject -isnot [string]) {
        @($InputObject)
    }
    else { @($InputObject) }
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

            $LogConfig = Initialize-DevToolsLogging `
                -LogPath $LogPath `
                -MinimumLevel 'DEBUG'

            Start-LoggingSession -Config $LogConfig

            Write-Log -Config $LogConfig -Level INFO `
                -Message "DevTools started (PowerShell $($PSVersionTable.PSVersion))"

            $EnvContext = Initialize-DevToolsEnvironment `
                -RootPath $RootPath `
                -InstallersPath $InstallersPath `
                -ConfigPath $ConfigPath `
                -OutputPath $OutputPath `
                -ToolsRegistryPath $ToolsRegistry

            $CategoriesFile = Join-Path $ConfigPath 'categories.ps1'
            if (-not (Test-Path -LiteralPath $CategoriesFile)) {
                throw 'categories.ps1 not found'
            }

            $Categories = & $CategoriesFile
            if ($Categories -isnot [PSCustomObject]) {
                throw 'categories.ps1 must return a PSCustomObject'
            }

            $ResolvedTools = @()
            Get-ChildItem -Path $ToolsRegistry -Filter '*.ps1' | Sort-Object Name | ForEach-Object {
                $ResolvedTools += As-Array (& $_.FullName)
            }

            if ($Category) {
                $ResolvedTools = $ResolvedTools | Where-Object Category -eq $Category
            }

            if ($Tools) {
                $ResolvedTools = $ResolvedTools | Where-Object Name -in $Tools
            }

            if ($Plan) {
                $ResolvedTools | Sort-Object Category, Name |
                    Format-Table Name, Category, ToolType -AutoSize
                return
            }

            . (Join-Path $InstallersPath 'Install-Tools.ps1')

            if ($PSCmdlet.ShouldProcess('DevTools', 'Install tools')) {
                Install-Tools `
                    -Tools $ResolvedTools `
                    -EnvContext $EnvContext `
                    -WinGetOnly:$WinGetOnly `
                    -ExportWinGetList:$ExportWinGetList
            }

            Write-Log -Config $LogConfig -Level SUCCESS `
                -Message 'DevTools completed successfully'
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
