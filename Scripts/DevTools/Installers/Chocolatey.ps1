param (
    [Parameter(Mandatory)]
    [hashtable]$Tool
)

# Skip if no Chocolatey ID is defined
if (-not $Tool.ChocoId) {
    Write-Log "No Chocolatey ID defined for $($Tool.Name). Skipping." -Level WARNING
    return $false
}

# Check if binary already exists
if ($Tool.BinaryCheck -and (Get-Command $Tool.BinaryCheck -ErrorAction SilentlyContinue)) {
    Write-Log "$($Tool.Name) already installed (Chocolatey)." -Level SUCCESS
    return $true
}

Write-Log "→ Installing $($Tool.Name) via Chocolatey..." -Level INFO

try {
    # Ensure Chocolatey is available
    if (-not (Get-Command choco.exe -ErrorAction SilentlyContinue)) {
        Write-Log "Chocolatey is not installed. Cannot install $($Tool.Name)." -Level WARNING
        return $false
    }

    # Install the package silently
    $args = @("install", $Tool.ChocoId, "-y", "--no-progress")
    choco @args

    # Verify installation
    if ($Tool.BinaryCheck -and (Get-Command $Tool.BinaryCheck -ErrorAction SilentlyContinue)) {
        Write-Log "$($Tool.Name) installed successfully." -Level SUCCESS
        return $true
    } else {
        Write-Log "$($Tool.Name) installation finished but binary not found." -Level WARNING
        return $false
    }
} catch {
    Write-Log "Failed to install $($Tool.Name) via Chocolatey: $_" -Level ERROR
    return $false
}
