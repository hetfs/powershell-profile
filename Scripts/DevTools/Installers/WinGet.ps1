function Install-ViaWinGet {
    param(
        [string]$PackageId,
        [string]$ToolName,
        [hashtable]$AvailableMethods,
        [bool]$IsAdmin
    )
    
    if (-not $AvailableMethods.WinGet) {
        Write-Log "WinGet method skipped - WinGet not available" -Level SKIP
        return $false
    }
    
    if ($PSCmdlet.ShouldProcess($ToolName, "Install via WinGet")) {
        try {
            Write-Log "Installing $ToolName via WinGet..." -Level INFO
            
            $scopeArg = if (-not $IsAdmin) { "--scope user" } else { "" }
            $command = "winget install --id '$PackageId' --silent --accept-package-agreements --accept-source-agreements $scopeArg"
            Write-Log "Running: $command" -Level DEBUG
            
            $result = Invoke-Expression $command 2>&1
            $exitCode = $LASTEXITCODE
            
            switch ($exitCode) {
                0 { 
                    Write-Log "✓ Successfully installed $ToolName via WinGet" -Level SUCCESS
                    return $true 
                }
                -1978335189 {
                    Write-Log "WinGet: Package may already be installed or requires elevation" -Level INFO
                    return $false
                }
                -1978335212 {
                    Write-Log "WinGet: Another installation in progress, skipping" -Level WARN
                    return $false
                }
                default {
                    Write-Log "WinGet installation failed with exit code: $exitCode" -Level WARN
                    if ($result) {
                        Write-Log "WinGet output: $result" -Level DEBUG
                    }
                    return $false
                }
            }
        } catch {
            Write-Log "WinGet installation failed: $_" -Level ERROR
            return $false
        }
    }
    return $false
}
