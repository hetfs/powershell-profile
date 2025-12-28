function Install-PowerShellModule {
    param(
        [string]$ModuleName,
        [string]$ToolName
    )

    if (-not $ModuleName) {
        Write-Log "Module name not specified for $ToolName, skipping." -Level WARN
        return $false
    }

    if ($PSCmdlet.ShouldProcess($ToolName, "Install PowerShell module")) {
        try {
            Write-Log "Installing PowerShell module '$ModuleName' for $ToolName..." -Level INFO

            $moduleNameClean = $ModuleName -replace '\.powershell$', ''

            # Check if already installed
            $existing = Get-InstalledModule -Name $moduleNameClean -ErrorAction SilentlyContinue
            if (-not $existing) {
                Install-Module -Name $moduleNameClean -Scope CurrentUser -Force -AllowClobber -ErrorAction Stop
                Write-Log "✓ Module '$moduleNameClean' installed successfully." -Level SUCCESS
            } else {
                Write-Log "Module '$moduleNameClean' already installed." -Level INFO
            }

            # Import if not loaded
            if (-not (Get-Module -Name $moduleNameClean)) {
                Import-Module -Name $moduleNameClean -Force -ErrorAction Stop
                Write-Log "Module '$moduleNameClean' imported successfully." -Level INFO
            } else {
                Write-Log "Module '$moduleNameClean' already loaded." -Level INFO
            }

            return $true
        } catch {
            Write-Log "❌ PowerShell module installation failed for $ToolName: $_" -Level ERROR
            return $false
        }
    }

    Write-Log "Skipped PowerShell module installation for $ToolName." -Level SKIP
    return $false
}
