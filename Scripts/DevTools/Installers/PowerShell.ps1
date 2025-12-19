function Install-PowerShellModule {
    param(
        [string]$ModuleName,
        [string]$ToolName
    )
    
    if ($PSCmdlet.ShouldProcess($ToolName, "Install PowerShell module")) {
        try {
            Write-Log "Installing $ToolName PowerShell module..." -Level INFO
            $moduleNameClean = $ModuleName -replace '\.powershell$', ''
            Install-Module -Name $moduleNameClean -Force -Scope CurrentUser -AllowClobber -ErrorAction Stop
            Import-Module -Name $moduleNameClean -Force -ErrorAction SilentlyContinue
            Write-Log "✓ Successfully installed $ToolName PowerShell module" -Level SUCCESS
            return $true
        } catch {
            Write-Log "PowerShell module installation failed: $_" -Level ERROR
            return $false
        }
    }
    return $false
}
