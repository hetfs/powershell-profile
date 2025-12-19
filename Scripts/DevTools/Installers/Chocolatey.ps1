function Install-ViaChocolatey {
    param(
        [string]$PackageId,
        [string]$ToolName,
        [hashtable]$AvailableMethods,
        [bool]$IsAdmin
    )
    
    if (-not $AvailableMethods.Chocolatey) {
        Write-Log "Chocolatey method skipped - Chocolatey not available" -Level SKIP
        return $false
    }
    
    if ($PSCmdlet.ShouldProcess($ToolName, "Install via Chocolatey")) {
        try {
            Write-Log "Installing $ToolName via Chocolatey..." -Level INFO
            
            $userArg = if (-not $IsAdmin) { "--allow-unofficial --allow-empty-checksums" } else { "" }
            choco install $PackageId -y --no-progress $userArg
            $exitCode = $LASTEXITCODE
            
            if ($exitCode -eq 0) {
                Write-Log "✓ Successfully installed $ToolName via Chocolatey" -Level SUCCESS
                return $true
            } elseif ($exitCode -eq 1603 -or $exitCode -eq 3010) {
                Write-Log "Chocolatey installation may require admin privileges or reboot (exit code: $exitCode)" -Level WARN
                return $false
            } else {
                Write-Log "Chocolatey installation failed with exit code: $exitCode" -Level WARN
                return $false
            }
        } catch {
            Write-Log "Chocolatey installation failed: $_" -Level ERROR
            return $false
        }
    }
    return $false
}
