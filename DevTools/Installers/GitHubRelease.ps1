#Requires -Version 7.0
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

<#
.SYNOPSIS
    GitHub Release installer module for DevTools.

.DESCRIPTION
    Downloads and installs tools from GitHub Releases, with automatic asset selection,
    extraction, and binary verification.

.NOTES
    Requires PowerShell 7+, optionally 7-Zip for .7z/.tar.gz assets.
#>

function Install-WithGitHubRelease {
    [CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact='High')]
    param (
        [Parameter(Mandatory=$true)]
        [PSCustomObject]$Tool,

        [Parameter()]
        [string]$OutputPath = (Join-Path $PSScriptRoot '..\Output'),

        [Parameter()]
        [string]$BinPath = (Join-Path $PSScriptRoot '..\bin')
    )

    begin {
        Write-Verbose "[Begin] GitHub Release installer initialization"
        $OutputPath = $PSCmdlet.GetUnresolvedProviderPathFromPSPath($OutputPath)
        $BinPath    = $PSCmdlet.GetUnresolvedProviderPathFromPSPath($BinPath)
        Write-Verbose "Output path: $OutputPath"
        Write-Verbose "Bin path: $BinPath"
    }

    process {
        try {
            # Validate required properties
            foreach ($prop in @('Name','Category','GitHubRepo')) {
                if (-not $Tool.PSObject.Properties[$prop]) {
                    throw "GitHubRelease: missing required property '$prop'"
                }
            }

            $toolName     = if ($Tool.DisplayName) { $Tool.DisplayName.Trim() } else { $Tool.Name.Trim() }
            $categoryDesc = if ($Tool.CategoryDescription) { $Tool.CategoryDescription.Trim() } else { $Tool.Category.Trim() }

            # Skip if binary already exists
            if ($Tool.BinaryCheck -and (Get-Command $Tool.BinaryCheck -ErrorAction SilentlyContinue)) {
                Write-Verbose "'$toolName' already installed [$($Tool.Category): $categoryDesc]"
                return $true
            }

            # Validate GitHub repo format
            $repo = $Tool.GitHubRepo.Trim('/')
            if ($repo -notmatch '^[^/]+/[^/]+$') { throw "Invalid GitHub repository format: '$repo'" }

            # ShouldProcess / WhatIf support
            $opDesc = "Install '$toolName' from GitHub Release"
            if (-not $PSCmdlet.ShouldProcess($opDesc, "Category: $($Tool.Category)")) { return $false }
            if ($PSCmdlet.MyInvocation.BoundParameters.ContainsKey('WhatIf')) {
                Write-Host "[WHATIF] Would install '$toolName' from GitHub ($repo)" -ForegroundColor Cyan
                return $true
            }

            # Ensure 7-Zip is available for .7z/.tar.gz extraction
            $sevenZip = Get-Command '7z' -ErrorAction SilentlyContinue
            if (-not $sevenZip) {
                Write-Verbose "7-Zip not found. Attempting installation via Chocolatey..."
                if (Get-Command 'choco' -ErrorAction SilentlyContinue) {
                    choco install 7zip -y --no-progress --ignore-checksums
                    $sevenZip = Get-Command '7z' -ErrorAction SilentlyContinue
                    if (-not $sevenZip) { Write-Warning "7-Zip installation failed" }
                }
                else { Write-Warning "Chocolatey not available. Extraction of .7z/.tar.gz may fail" }
            }

            # Query latest GitHub release
            $releaseApi = "https://api.github.com/repos/$repo/releases/latest"
            $headers = @{
                "User-Agent" = "DevToolsInstaller/1.0 (PowerShell)"
                "Accept"     = "application/vnd.github+json"
            }
            if ($env:GITHUB_TOKEN) { $headers.Authorization = "token $env:GITHUB_TOKEN" }

            $release = Invoke-RestMethod -Uri $releaseApi -Headers $headers -Method Get -ErrorAction Stop
            if (-not $release.assets -or $release.assets.Count -eq 0) {
                Write-Warning "No assets found for '$toolName'"
                return $false
            }

            # Select asset using GitHubAssetPattern or common defaults
            $assetPatterns = @(
                $Tool.GitHubAssetPattern,
                '.*windows.*x64.*\.zip$', '.*windows.*amd64.*\.zip$', '.*win64.*\.zip$',
                '.*windows.*x64.*\.exe$', '.*windows.*amd64.*\.exe$', '.*win64.*\.exe$',
                '.*\.zip$', '.*\.exe$', '.*\.msi$', '.*\.7z$', '.*\.tar\.gz$'
            ) | Where-Object { $_ }

            $asset = $null
            foreach ($pattern in $assetPatterns) {
                $asset = $release.assets | Where-Object { $_.name -match $pattern } | Select-Object -First 1
                if ($asset) { Write-Verbose "Selected asset: $($asset.name)"; break }
            }
            if (-not $asset) { Write-Warning "No compatible asset found for '$toolName'"; return $false }

            # Prepare directories
            $downloadDir = Join-Path $OutputPath 'downloads' $Tool.Name
            if (-not (Test-Path $downloadDir)) { New-Item -Path $downloadDir -ItemType Directory -Force | Out-Null }
            $archivePath = Join-Path $downloadDir $asset.name

            $installDir = Join-Path $BinPath $Tool.Name
            if (-not (Test-Path $installDir)) { New-Item -Path $installDir -ItemType Directory -Force | Out-Null }

            # Download asset
            Write-Host "Downloading $($asset.name)..." -ForegroundColor Cyan
            Invoke-WebRequest -Uri $asset.browser_download_url -Headers @{ "User-Agent"="DevToolsInstaller/1.0" } `
                -OutFile $archivePath -UseBasicParsing -ErrorAction Stop
            Write-Host "✓ Downloaded: $($asset.name)" -ForegroundColor Green

            # Install / Extract asset
            Write-Host "Installing '$toolName'..." -ForegroundColor Cyan
            switch -Regex ($archivePath) {
                '\.zip$'         { Expand-Archive -Path $archivePath -DestinationPath $installDir -Force }
                '\.exe$|\.msi$'  { Copy-Item -Path $archivePath -Destination $installDir -Force }
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

                    # Add to user PATH if requested
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
        catch { Write-Error "GitHub Release installer error: $_"; return $false }
    }

    end { Write-Verbose "[End] GitHub Release installer completed" }
}
