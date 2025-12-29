param (
    [Parameter(Mandatory)]
    [hashtable]$Tool
)

# Skip if no WinGet ID is specified
if (-not $Tool.WinGetId) {
    Write-Log "No WinGet ID specified for $($Tool.Name). Skipping." -Level WARNING
    return $false
}

# Check if tool is already installed
if ($Tool.BinaryCheck -and (Get-Command $Tool.BinaryCheck -ErrorAction SilentlyContinue)) {
    Write-Log "$($Tool.Name) already installed (WinGet)." -Level SUCCESS
    return $true
}

Write-Log "→ Installing $($Tool.Name) via WinGet..." -Level INFO

try {
    # Install the tool via WinGet
    winget install `
        --id $Tool.WinGetId `
        --exact `
        --silent `
        --accept-package-agreements `
        --accept-source-agreements

    # Confirm installation if BinaryCheck exists
    if ($Tool.BinaryCheck -and (Get-Command $Tool.BinaryCheck -ErrorAction SilentlyContinue)) {
        Write-Log "✔ Installed $($Tool.Name) via WinGet." -Level SUCCESS
        return $true
    } else {
        Write-Log "Installed $($Tool.Name) via WinGet, but binary not found: $($Tool.BinaryCheck)." -Level WARNING
        return $false
    }
} catch {
    Write-Log "❌ Failed to install $($Tool.Name) via WinGet." -Level ERROR
    Write-Log $_ -Level ERROR
    return $false
}
