<#
.SYNOPSIS
    Unified installer for all registered tools.
.DESCRIPTION
    - Loads tool registries from ToolsRegistr/
    - Installs tools using WinGet, Chocolatey, or GitHub Releases
    - Stops once a tool is successfully installed
    - Idempotent, safe for CI/local bootstrap
#>

param (
    [string[]]$Category,
    [string[]]$ToolName
)

$ErrorActionPreference = "Stop"

$RootDir       = Split-Path -Parent $PSScriptRoot
$RegistryDir   = Join-Path $RootDir "ToolsRegistr"
$InstallersDir = Join-Path $RootDir "Installers"

# ------------------------------------------------------------------
# Load installer backends
# ------------------------------------------------------------------

. "$InstallersDir/WinGet.ps1"
. "$InstallersDir/Chocolatey.ps1"
. "$InstallersDir/GitHubRelease.ps1"

# ------------------------------------------------------------------
# Install single tool
# ------------------------------------------------------------------

function Install-Tool {
    param (
        [Parameter(Mandatory)]
        [hashtable]$Tool
    )

    Write-Host "`n→ Processing tool: $($Tool.Name) [$($Tool.Category)]" -ForegroundColor Cyan

    try {
        if (Install-WithWinGet          -Tool $Tool) { return }
        if (Install-WithChocolatey      -Tool $Tool) { return }
        if (Install-WithGitHubRelease   -Tool $Tool) { return }

        Write-Warning "❌ Failed to install $($Tool.Name)"
    }
    catch {
        Write-Warning "⚠ Exception while installing $($Tool.Name): $_"
    }
}

# ------------------------------------------------------------------
# Load registries and iterate tools
# ------------------------------------------------------------------

$registryFiles = Get-ChildItem $RegistryDir -Filter '*.ps1' | Sort-Object Name

foreach ($file in $registryFiles) {

    Write-Host "`n=== Loading registry: $($file.BaseName) ===" -ForegroundColor Magenta
    $tools = . $file.FullName

    foreach ($tool in $tools) {

        if ($Category -and $tool.Category -notin $Category) {
            continue
        }

        if ($ToolName -and $tool.Name -notin $ToolName) {
            continue
        }

        Install-Tool -Tool $tool
    }
}

Write-Host "`n✔ All requested tools processed successfully" -ForegroundColor Green
