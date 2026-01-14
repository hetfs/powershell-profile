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
        if (-not $Tool.PSObject.Properties[$prop] -or [string]::IsNullOrWhiteSpace($Tool.$prop)) {
            throw "Tool object missing required property '$prop'"
        }
    }

    # Ensure optional properties
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
    try { return [System.IO.Path]::GetFullPath((Resolve-Path -LiteralPath $Path).Path) }
    catch { return $Path }
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

    $argString = ($Arguments | ForEach-Object { "`"$_`"" }) -join ' '
    if (-not $PSCmdlet.ShouldProcess($FilePath, "Run: $argString")) { return }

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

    if ($NoNewWindow) { $processInfo.NoNewWindow = $true }
    return Start-Process @processInfo
}

function Invoke-Script {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory)][string]$ScriptPath,
        [hashtable]$Parameters = @{}
    )

    if (-not $PSCmdlet.ShouldProcess($ScriptPath, 'Invoke script')) { return $false }
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
        [Parameter(Mandatory)][PSCustomObject]$Tool,
        [Parameter(Mandatory)][PSCustomObject]$EnvContext
    )

    if (-not $Tool.WinGetId) { throw "WinGetId missing for tool '$($Tool.Name)'" }

    $args = @('install','--id',$Tool.WinGetId,'--exact','--silent','--accept-source-agreements','--accept-package-agreements')

    if (-not $PSCmdlet.ShouldProcess($Tool.Name, 'Install via WinGet')) { return }
    if ($PSCmdlet.MyInvocation.BoundParameters.ContainsKey('WhatIf')) {
        Write-Host "[WHATIF] Would install $($Tool.Name) via WinGet" -ForegroundColor Cyan
        return
    }

    $process = Start-Process -FilePath 'winget' -ArgumentList $args -Wait -PassThru -NoNewWindow -ErrorAction Stop
    switch ($process.ExitCode) {
        0              { return }
        -1978335212    { return } # already installed
        -1978335189    { return } # no upgrade available
        default        { throw "WinGet failed with exit code $($process.ExitCode)" }
    }
}

function Install-WithChocolatey {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param([Parameter(Mandatory)][PSCustomObject]$Tool)

    if (-not $Tool.ChocoId) { throw "ChocoId missing for $($Tool.Name)" }
    if (-not $PSCmdlet.ShouldProcess($Tool.Name, 'Install via Chocolatey')) { return }
    if ($PSCmdlet.MyInvocation.BoundParameters.ContainsKey('WhatIf')) {
        Write-Host "[WHATIF] Would install $($Tool.Name) via Chocolatey" -ForegroundColor Cyan
        return
    }

    choco install $Tool.ChocoId -y
}

function Install-WithGitHubRelease {
    [CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact='High')]
    param(
        [Parameter(Mandatory)][PSCustomObject]$Tool,
        [Parameter(Mandatory)][PSCustomObject]$EnvContext
    )

    # Validate required
    foreach ($prop in @('Name','Category','GitHubRepo')) {
        if (-not $Tool.PSObject.Properties[$prop]) { throw "GitHubRelease: missing required property '$prop'" }
    }

    $toolName     = ($Tool.DisplayName ?? $Tool.Name).Trim()
    $categoryDesc = ($Tool.CategoryDescription ?? $Tool.Category).Trim()

    # Skip if binary exists
    if ($Tool.BinaryCheck -and (Get-Command $Tool.BinaryCheck -ErrorAction SilentlyContinue)) {
        Write-Verbose "'$toolName' already installed [$($Tool.Category): $categoryDesc]"
        return $true
    }

    $repo = $Tool.GitHubRepo.Trim('/')
    if ($repo -notmatch '^[^/]+/[^/]+$') { throw "Invalid GitHub repository format: '$repo'" }

    if (-not $PSCmdlet.ShouldProcess("Install '$toolName' from GitHub Release")) { return $false }
    if ($PSCmdlet.MyInvocation.BoundParameters.ContainsKey('WhatIf')) {
        Write-Host "[WHATIF] Would install '$toolName' from GitHub ($repo)" -ForegroundColor Cyan
        return $true
    }

    # 7-Zip check
    $sevenZip = Get-Command '7z' -ErrorAction SilentlyContinue
    if (-not $sevenZip -and (Get-Command 'choco' -ErrorAction SilentlyContinue)) {
        choco install 7zip -y --no-progress --ignore-checksums
        $sevenZip = Get-Command '7z' -ErrorAction SilentlyContinue
    }

    # Query latest release
    $headers = @{ "User-Agent" = "DevToolsInstaller/1.0"; "Accept" = "application/vnd.github+json" }
    if ($env:GITHUB_TOKEN) { $headers.Authorization = "token $env:GITHUB_TOKEN" }
    $release = Invoke-RestMethod -Uri "https://api.github.com/repos/$repo/releases/latest" -Headers $headers -Method Get -ErrorAction Stop

    if (-not $release.assets -or $release.assets.Count -eq 0) {
        Write-Warning "No assets found for '$toolName'"
        return $false
    }

    # Asset selection
    $assetPatterns = @($Tool.GitHubAssetPattern,'*.zip','*.exe','*.msi','*.7z','*.tar.gz') | Where-Object { $_ }
    $asset = $null
    foreach ($pattern in $assetPatterns) {
        $asset = $release.assets | Where-Object { $_.name -match $pattern } | Select-Object -First 1
        if ($asset) { break }
    }
    if (-not $asset) { Write-Warning "No compatible asset found for '$toolName'"; return $false }

    # Prepare directories
    $downloadDir = Join-Path $EnvContext.TempPath $Tool.Name
    Ensure-Directory $downloadDir
    $archivePath = Join-Path $downloadDir $asset.name
    $installDir  = Join-Path $EnvContext.ToolsPath $Tool.Name
    Ensure-Directory $installDir

    # Download & extract
    Write-Host "Downloading $($asset.name)..." -ForegroundColor Cyan
    Invoke-WebRequest -Uri $asset.browser_download_url -OutFile $archivePath -Headers @{ "User-Agent"="DevToolsInstaller/1.0" } -UseBasicParsing
    Write-Host "✓ Downloaded $($asset.name)" -ForegroundColor Green

    Write-Host "Installing '$toolName'..." -ForegroundColor Cyan
    switch -Regex ($archivePath) {
        '\.zip$'        { Expand-Archive -Path $archivePath -DestinationPath $installDir -Force }
        '\.exe$|\.msi$' { Copy-Item -Path $archivePath -Destination $installDir -Force }
        '\.7z$|\.tar\.gz$' {
            if ($sevenZip) { & $sevenZip -y x $archivePath "-o$installDir" | Out-Null }
            else { Write-Warning "7-Zip not available. Cannot extract $($asset.name)"; return $false }
        }
        default { Write-Warning "Unsupported file type: $($asset.name)"; return $false }
    }

    # Verify binary
    if ($Tool.BinaryCheck) {
        $env:Path += ";$installDir"
        Start-Sleep 2
        if (Get-Command $Tool.BinaryCheck -ErrorAction SilentlyContinue) {
            Write-Host "✓ '$toolName' installed successfully" -ForegroundColor Green
            if ($Tool.AddToPath) {
                $userPath = [Environment]::GetEnvironmentVariable("PATH","User")
                if ($installDir -notin ($userPath -split ';')) {
                    [Environment]::SetEnvironmentVariable("PATH","$userPath;$installDir","User")
                    Write-Verbose "Added $installDir to user PATH"
                }
            }
            return $true
        }
        Write-Warning "Binary '$($Tool.BinaryCheck)' not found after installation"
        return $false
    }

    Write-Host "✓ '$toolName' installed (no binary verification)" -ForegroundColor Green
    return $true
}

#endregion
# ------------------------------------------------------------
#region ===== Utility =====

function Wait-DevTools { param([int]$Seconds); Start-Sleep -Seconds $Seconds }

function Get-NormalizedTools {
    param([string]$RegistryPath)

    $tools = [System.Collections.Generic.List[PSCustomObject]]::new()
    foreach ($file in Get-ChildItem -LiteralPath $RegistryPath -Filter '*.ps1' -File | Sort-Object Name) {
        try {
            $toolObj = & $file.FullName
            if ($toolObj -is [PSCustomObject]) { $tools.Add((ConvertTo-NormalizedTool -Tool $toolObj)) }
        } catch { Write-Warning "Skipping invalid tool file: $($file.Name)" }
    }
    return $tools
}

#endregion
# ----------------------------------------
