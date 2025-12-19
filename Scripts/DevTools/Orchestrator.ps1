function Install-Tools {
    param(
        [hashtable]$ToolsToInstall,
        [string[]]$MethodsOrder,
        [hashtable]$AvailableMethods,
        [switch]$Force,
        [int]$MaxRetries,
        [string]$InstallPath
    )
    
    $installationResults = @{}
    $totalTools = $ToolsToInstall.Count
    $processedTools = 0
    
    Write-Log "Total tools to process: $totalTools" -Level INFO
    
    # Group tools by category for organized output
    $toolsByCategory = @{}
    foreach ($tool in $ToolsToInstall.Keys) {
        $category = $ToolsToInstall[$tool].Category
        if (-not $toolsByCategory.ContainsKey($category)) {
            $toolsByCategory[$category] = @()
        }
        $toolsByCategory[$category] += $tool
    }
    
    foreach ($category in $toolsByCategory.Keys | Sort-Object) {
        Write-Log "`n" + "="*60 -Level INFO
        Write-Log "CATEGORY: $category".ToUpper() -Level INFO
        Write-Log "="*60 -Level INFO
        
        $categoryTools = $toolsByCategory[$category]
        
        foreach ($toolName in ($categoryTools | Sort-Object)) {
            $processedTools++
            $toolInfo = $ToolsToInstall[$toolName]
            $displayName = $toolInfo.DisplayName
            
            # Update progress bar
            $percentComplete = [math]::Round(($processedTools / $totalTools) * 100)
            Write-Progress -Activity "Installing Development Tools" `
                -Status "Installing $displayName ($processedTools/$totalTools)" `
                -PercentComplete $percentComplete `
                -CurrentOperation "Category: $category"
            
            Write-Log "`nProcessing: $displayName" -Level INFO
            
            # Skip if already installed and not forced
            if (-not $Force) {
                $installed = Test-ToolInstalled -Tool $displayName -TestCommand $toolInfo.TestCommand
                if ($installed) {
                    $installationResults[$toolName] = 'AlreadyInstalled'
                    Write-Log "Tool already installed, skipping (use -Force to reinstall)" -Level SKIP
                    continue
                }
            }
            
            # Get available methods for this tool
            $availableToolMethods = Get-AvailableMethodsForTool -ToolInfo $toolInfo -AvailableMethods $AvailableMethods
            if ($availableToolMethods.Count -eq 0) {
                Write-Log "✗ No installation methods available for $displayName" -Level WARN
                $installationResults[$toolName] = 'NoMethods'
                continue
            }
            
            $installed = $false
            $methodUsed = $null
            $retryCount = 0
            
            # Try each method in order
            while (-not $installed -and $retryCount -lt $MaxRetries) {
                foreach ($method in $MethodsOrder) {
                    if ($method -notin $availableToolMethods) {
                        Write-Log "Skipping $method for $displayName (method not available)" -Level SKIP
                        continue
                    }
                    
                    Write-Log "Attempting installation via $method..." -Level DEBUG
                    
                    switch ($method) {
                        'WinGet' {
                            if ($toolInfo.WinGetId) {
                                $installed = Install-ViaWinGet -PackageId $toolInfo.WinGetId `
                                    -ToolName $displayName `
                                    -AvailableMethods $AvailableMethods `
                                    -IsAdmin $script:isAdmin
                                if ($installed) { $methodUsed = 'WinGet' }
                            }
                        }
                        'GitHub' {
                            if ($toolInfo.GitHubRelease) {
                                $installed = Install-ViaGitHub -ReleaseInfo $toolInfo.GitHubRelease `
                                    -ToolName $displayName `
                                    -InstallPath $InstallPath
                                if ($installed) { $methodUsed = 'GitHub' }
                            }
                        }
                        'Chocolatey' {
                            if ($toolInfo.ChocolateyId -and $toolInfo.ChocolateyId -notmatch '\.powershell$') {
                                $installed = Install-ViaChocolatey -PackageId $toolInfo.ChocolateyId `
                                    -ToolName $displayName `
                                    -AvailableMethods $AvailableMethods `
                                    -IsAdmin $script:isAdmin
                                if ($installed) { $methodUsed = 'Chocolatey' }
                            }
                        }
                        'PowerShellGet' {
                            if ($toolInfo.WinGetId -eq $null -and $toolInfo.ChocolateyId -ne $null -and 
                                $toolInfo.ChocolateyId -match '\.powershell$') {
                                $installed = Install-PowerShellModule -ModuleName $toolInfo.ChocolateyId `
                                    -ToolName $displayName
                                if ($installed) { $methodUsed = 'PowerShellGet' }
                            }
                        }
                    }
                    
                    if ($installed) {
                        break
                    }
                }
                
                if (-not $installed) {
                    $retryCount++
                    if ($retryCount -lt $MaxRetries) {
                        Write-Log "Retrying installation of $displayName (attempt $retryCount of $MaxRetries)..." -Level WARN
                        Start-Sleep -Seconds (2 * $retryCount)
                    }
                }
            }
            
            if ($installed) {
                $installationResults[$toolName] = $methodUsed
                
                # Run post-install steps
                if ($toolInfo.PostInstall) {
                    try {
                        Write-Log "Running post-install steps for $displayName..." -Level DEBUG
                        & $toolInfo.PostInstall
                        Write-Log "Post-install completed for $displayName" -Level DEBUG
                    } catch {
                        Write-Log "Post-install failed: $_" -Level WARN
                    }
                }
            } else {
                Write-Log "✗ Failed to install $displayName with any available method" -Level ERROR
                $installationResults[$toolName] = 'Failed'
            }
        }
    }
    
    Write-Progress -Activity "Installing Development Tools" -Completed
    return $installationResults
}
