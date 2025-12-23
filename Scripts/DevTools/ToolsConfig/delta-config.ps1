# =======================================================
# Auto-install delta (Windows)
# Repository: https://github.com/dandavison/delta
# =======================================================

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Test-Command {
    param ([string]$Name)
    return [bool](Get-Command $Name -ErrorAction SilentlyContinue)
}

if (Test-Command delta) {
    Write-Host "delta already installed. Skipping."
    return
}

Write-Host "delta not found. Installing..."

# Prefer WinGet
if (Test-Command winget) {
    Write-Host "Installing delta via WinGet..."
    winget install --id dandavison.delta --source winget --accept-source-agreements --accept-package-agreements
    return
}

# Fallback to Chocolatey
if (Test-Command choco) {
    Write-Host "Installing delta via Chocolatey..."
    choco install delta -y
    return
}

Write-Warning "No supported package manager found. Install delta manually:"
Write-Warning "https://github.com/dandavison/delta#installation"


