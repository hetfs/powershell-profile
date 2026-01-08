# ----------------------------------------
# Helpers.ps1 - DevTools helper functions
# ----------------------------------------
# Windows-only, PowerShell 7+
# Supports -WhatIf / -Confirm
# CI-safe, logging-friendly
# ----------------------------------------

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# ------------------------------------------------------------
#region ===== Tool Normalization =====

function ConvertTo-NormalizedTool {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [PSCustomObject]$Tool
    )

    foreach ($prop in @('Name','Category')) {
        if (-not $Tool.PSObject.Properties[$prop] -or
            [string]::IsNullOrWhiteSpace($Tool.$prop)) {
            throw "Tool object missing required property '$prop'"
        }
    }

    if (-not $Tool.PSObject.Properties['DisplayName']) {
        $Tool | Add-Member -NotePropertyName DisplayName -NotePropertyValue $Tool.Name -Force
    }

    if (-not $Tool.PSObject.Properties['CategoryDescription']) {
        $Tool | Add-Member -NotePropertyName CategoryDescription -NotePropertyValue '' -Force
    }

    return $Tool
}

function Validate-ToolInstaller {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [PSCustomObject]$Tool
    )

    if ($Tool.WinGetId -or $Tool.ChocoId -or $Tool.GitHubRepo -or $Tool.InstallerScript) {
        return $true
    }

    Write-Warning "No installer defined for tool '$($Tool.Name)'"
    return $false
}

#endregion
# ------------------------------------------------------------
#region ===== CI Detection =====

function Test-IsCI {
    return [bool](
        $env:CI -or
        $env:GITHUB_ACTIONS -or
        $env:TF_BUILD -or
        $env:JENKINS_URL -or
        $env:TEAMCITY_VERSION
    )
}

#endregion
# ------------------------------------------------------------
#region ===== Path & Directory Helpers =====

function Resolve-DevToolsPath {
    param([Parameter(Mandatory)][string]$Path)
    try {
        return [System.IO.Path]::GetFullPath((Resolve-Path -LiteralPath $Path).Path)
    } catch {
        return $Path
    }
}

function Ensure-Directory {
    param([Parameter(Mandatory)][string]$Path)
    if (-not (Test-Path -LiteralPath $Path)) {
        New-Item -ItemType Directory -Path $Path -Force | Out-Null
    }
    return $Path
}

#endregion
# ------------------------------------------------------------
#region ===== Process Helpers =====

function Invoke-Process {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory)][string]$FilePath,
        [string[]]$Arguments = @(),
        [switch]$NoNewWindow
    )

    $argString = ($Arguments -join ' ')
    if (-not $PSCmdlet.ShouldProcess($FilePath, "Run: $argString")) {
        return
    }

    if ($PSCmdlet.MyInvocation.BoundParameters.ContainsKey('WhatIf')) {
        Write-Host "[WHATIF] Would run: $FilePath $argString" -ForegroundColor Cyan
        return $true
    }

    $processInfo = @{
        FilePath     = $FilePath
        ArgumentList = $Arguments
        Wait         = $true
        PassThru     = $true
        ErrorAction  = 'Stop'
    }

    if ($NoNewWindow) {
        $processInfo.NoNewWindow = $true
    }

    return Start-Process @processInfo
}

function Invoke-Script {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory)][string]$ScriptPath,
        [hashtable]$Parameters = @{}
    )

    if (-not $PSCmdlet.ShouldProcess($ScriptPath, 'Invoke script')) {
        return $false
    }

    if ($PSCmdlet.MyInvocation.BoundParameters.ContainsKey('WhatIf')) {
        Write-Host "[WHATIF] Would invoke $ScriptPath" -ForegroundColor Cyan
        return $true
    }

    & $ScriptPath @Parameters
}

#endregion
# ------------------------------------------------------------
#region ===== Installer Helpers =====

function Install-WithWinGet {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory)]
        [PSCustomObject]$Tool,

        [Parameter(Mandatory)]
        [PSCustomObject]$EnvContext
    )

    if (-not $Tool.WinGetId) {
        throw "WinGetId missing for tool '$($Tool.Name)'"
    }

    $args = @(
        'install'
        '--id', $Tool.WinGetId
        '--exact'
        '--silent'
        '--accept-source-agreements'
        '--accept-package-agreements'
    )

    if (-not $PSCmdlet.ShouldProcess($Tool.Name, 'Install via WinGet')) {
        return
    }

    if ($PSCmdlet.MyInvocation.BoundParameters.ContainsKey('WhatIf')) {
        Write-Host "[WHATIF] Would install $($Tool.Name) via WinGet" -ForegroundColor Cyan
        return
    }

    $process = Start-Process `
        -FilePath 'winget' `
        -ArgumentList $args `
        -Wait `
        -PassThru `
        -NoNewWindow `
        -ErrorAction Stop

    switch ($process.ExitCode) {
        0              { return } # success
        -1978335212    { return } # already installed
        -1978335189    { return } # no upgrade available
        default {
            throw "WinGet failed with exit code $($process.ExitCode)"
        }
    }
}

function Install-WithChocolatey {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory)]
        [PSCustomObject]$Tool
    )

    if (-not $Tool.ChocoId) {
        throw "ChocoId missing for $($Tool.Name)"
    }

    if (-not $PSCmdlet.ShouldProcess($Tool.Name, 'Install via Chocolatey')) {
        return
    }

    if ($PSCmdlet.MyInvocation.BoundParameters.ContainsKey('WhatIf')) {
        Write-Host "[WHATIF] Would install $($Tool.Name) via Chocolatey" -ForegroundColor Cyan
        return
    }

    choco install $Tool.ChocoId -y
}

function Install-WithGitHubRelease {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory)][PSCustomObject]$Tool,
        [Parameter(Mandatory)][PSCustomObject]$EnvContext
    )

    if (-not $Tool.GitHubRepo -or -not $Tool.GitHubAssetPattern) {
        throw "GitHubRepo or GitHubAssetPattern missing for $($Tool.Name)"
    }

    if (-not $PSCmdlet.ShouldProcess($Tool.Name, 'Install from GitHub Release')) {
        return
    }

    if ($PSCmdlet.MyInvocation.BoundParameters.ContainsKey('WhatIf')) {
        Write-Host "[WHATIF] Would install $($Tool.Name) from GitHub Release" -ForegroundColor Cyan
        return
    }

    $url = "https://github.com/$($Tool.GitHubRepo)/releases/latest/download/$($Tool.GitHubAssetPattern)"
    $zip = Join-Path $EnvContext.TempPath "$($Tool.Name).zip"
    $dest = Join-Path $EnvContext.ToolsPath $Tool.Name

    Invoke-WebRequest -Uri $url -OutFile $zip -UseBasicParsing
    Ensure-Directory $dest
    Expand-Archive -Path $zip -DestinationPath $dest -Force
}

#endregion
# ------------------------------------------------------------
#region ===== Utility =====

function Wait-DevTools {
    param([int]$Seconds)
    Start-Sleep -Seconds $Seconds
}

function Get-NormalizedTools {
    param([string]$RegistryPath)

    $tools = [System.Collections.Generic.List[PSCustomObject]]::new()

    foreach ($file in Get-ChildItem -LiteralPath $RegistryPath -Filter '*.ps1' -File | Sort-Object Name) {
        try {
            $toolObj = & $file.FullName
            if ($toolObj -is [PSCustomObject]) {
                $tools.Add((ConvertTo-NormalizedTool -Tool $toolObj))
            }
        } catch {
            Write-Warning "Skipping invalid tool file: $($file.Name)"
        }
    }

    return $tools
}

#endregion
# ----------------------------------------
