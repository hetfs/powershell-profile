#region Tool Detection & Path Helpers with Winget Source Pinning

function Test-CommandExists {
    param([string]$Command)
    try {
        return [bool](Get-Command $Command -ErrorAction SilentlyContinue)
    } catch {
        return $false
    }
}

function Add-ToPath {
    param([string]$Directory)

    if (-not (Test-Path $Directory)) {
        Write-Log "Directory not found: $Directory" -Level WARN
        return $false
    }

    $currentPath = [Environment]::GetEnvironmentVariable('PATH', 'User')
    if ($currentPath -split ';' -notcontains $Directory) {
        if ($PSCmdlet.ShouldProcess($Directory, 'Add to PATH')) {
            $newPath = if ($currentPath) { "$currentPath;$Directory" } else { $Directory }
            [Environment]::SetEnvironmentVariable('PATH', $newPath, 'User')
            Write-Log "Added to PATH: $Directory" -Level INFO
            return $true
        }
    }
    return $false
}

function Test-ToolInstalled {
    param(
        [string]$Tool,
        [scriptblock|string]$TestCommand
    )

    if ($TestCommand -is [scriptblock]) {
        try {
            if (& $TestCommand) {
                Write-Log "✓ $Tool is already installed (script block check)" -Level INFO
                return $true
            }
        } catch { return $false }
    } elseif ($TestCommand -is [string]) {
        try {
            $output = Invoke-Expression $TestCommand 2>&1
            if ($LASTEXITCODE -eq 0 -or -not $LASTEXITCODE) {
                if ($output -and $output.ToString().Trim().Length -gt 0) {
                    Write-Log "✓ $Tool is already installed: $($output[0])" -Level INFO
                    return $true
                }
            }
        } catch { return $false }
    }

    return $false
}

function Get-ToolsToInstall {
    param(
        [hashtable]$ToolRegistry,
        [string[]]$Categories,
        [string[]]$Tools
    )

    $flattenedTools = @{}
    foreach ($category in $ToolRegistry.Keys) {
        foreach ($tool in $ToolRegistry[$category].Keys) {
            $flattenedTools[$tool] = $ToolRegistry[$category][$tool]
            $flattenedTools[$tool].Category = $category
        }
    }

    if ($Tools) {
        $toolsToInstall = @{}
        foreach ($tool in $Tools) {
            if ($flattenedTools.ContainsKey($tool)) {
                $toolsToInstall[$tool] = $flattenedTools[$tool]
            } else {
                Write-Log "Tool '$tool' not found in registry" -Level WARN
            }
        }

        if ($toolsToInstall.Count -eq 0) {
            Write-Log "No valid tools specified for installation." -Level ERROR
            exit 1
        }
        return $toolsToInstall
    }

    return $flattenedTools
}

function Get-AvailableMethodsForTool {
    param(
        [hashtable]$ToolInfo,
        [hashtable]$AvailableMethods
    )

    $methods = @()

    if ($ToolInfo.SkipIf -and (& $ToolInfo.SkipIf)) {
        Write-Log "Skipping $($ToolInfo.DisplayName) due to SkipIf condition" -Level SKIP
        return @()
    }

    if ($ToolInfo.WinGetId -and $AvailableMethods.WinGet) {
        # Pin the WinGet source to Microsoft.Store
        try {
            $sources = winget source list | ForEach-Object { ($_ -split '\s+')[0] }
            if ('winget' -notin $sources) {
                Write-Log "Pinning WinGet source 'winget'" -Level INFO
                winget source add --name winget --arg "https://winget.azureedge.net/cache" --force
            } else {
                Write-Log "WinGet source 'winget' already pinned" -Level DEBUG
            }
        } catch {
            Write-Log "Failed to pin WinGet source: $_" -Level WARN
        }

        $methods += 'WinGet'
    }

    if ($ToolInfo.GitHubRelease) { $methods += 'GitHub' }

    if ($ToolInfo.ChocolateyId -and $AvailableMethods.Chocolatey) {
        if ($ToolInfo.ChocolateyId -notmatch '\.powershell$') { $methods += 'Chocolatey' }
    }

    if ($ToolInfo.WinGetId -eq $null -and $ToolInfo.ChocolateyId -ne $null -and
        $ToolInfo.ChocolateyId -match '\.powershell$') { $methods += 'PowerShellGet' }

    return $methods
}

#endregion
