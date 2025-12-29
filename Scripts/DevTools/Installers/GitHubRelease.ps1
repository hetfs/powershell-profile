param (
    [Parameter(Mandatory)]
    [hashtable]$Tool
)

# Skip if no GitHub repository is defined
if (-not $Tool.GitHubRepo) {
    Write-Log "No GitHub repository defined for $($Tool.Name). Skipping." -Level WARNING
    return $false
}

# Check if binary already exists
if ($Tool.BinaryCheck -and (Get-Command $Tool.BinaryCheck -ErrorAction SilentlyContinue)) {
    Write-Log "$($Tool.Name) already installed (GitHub Release)." -Level SUCCESS
    return $true
}

Write-Log "→ Installing $($Tool.Name) from GitHub Releases..." -Level INFO

try {
    $api = "https://api.github.com/repos/$($Tool.GitHubRepo)/releases/latest"
    $release = Invoke-RestMethod -Uri $api -Headers @{ Accept = "application/vnd.github+json" }

    # Pick the first suitable Windows asset
    $asset = $release.assets |
        Where-Object { $_.name -match 'windows|win64|amd64|\.exe|\.zip' } |
        Select-Object -First 1

    if (-not $asset) {
        throw "No suitable release asset found for $($Tool.Name)"
    }

    $installDir = Join-Path $env:LOCALAPPDATA "Tools\$($Tool.Name)"
    New-Item -ItemType Directory -Force -Path $installDir | Out-Null

    $archive = Join-Path $installDir $asset.name

    Write-Log "Downloading $($asset.name)..." -Level INFO
    Invoke-WebRequest -Uri $asset.browser_download_url -OutFile $archive

    # Extract if zip, otherwise leave executable as-is
    if ($archive -match '\.zip$') {
        Write-Log "Extracting $($asset.name)..." -Level INFO
        Expand-Archive -Path $archive -DestinationPath $installDir -Force
        Remove-Item $archive -Force
    }

    # Verify installation
    if ($Tool.BinaryCheck -and (Get-Command $Tool.BinaryCheck -ErrorAction SilentlyContinue)) {
        Write-Log "$($Tool.Name) installed successfully from GitHub." -Level SUCCESS
        return $true
    } else {
        Write-Log "$($Tool.Name) installed but binary not found." -Level WARNING
        return $false
    }
} catch {
    Write-Log "❌ Failed to install $($Tool.Name) from GitHub: $_" -Level ERROR
    return $false
}
