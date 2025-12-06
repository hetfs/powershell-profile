### Update Module

function Update-Profile {
    if (Test-Path function:Update-Profile_Override) {
        Update-Profile_Override
        return
    }
    
    try {
        $url = "$global:repo_root/powershell-profile/main/Microsoft.PowerShell_profile.ps1"
        $oldhash = Get-FileHash $PROFILE
        Invoke-RestMethod $url -OutFile "$env:temp/Microsoft.PowerShell_profile.ps1"
        $newhash = Get-FileHash "$env:temp/Microsoft.PowerShell_profile.ps1"
        if ($newhash.Hash -ne $oldhash.Hash) {
            Copy-Item -Path "$env:temp/Microsoft.PowerShell_profile.ps1" -Destination $PROFILE -Force
            Write-Host "Profile has been updated. Please restart your shell to reflect changes" -ForegroundColor Magenta
        } else {
            Write-Host "Profile is up to date." -ForegroundColor Green
        }
    } catch {
        Write-Error "Unable to check for `$profile updates: $_"
    } finally {
        Remove-Item "$env:temp/Microsoft.PowerShell_profile.ps1" -ErrorAction SilentlyContinue
    }
}

function Update-PowerShell {
    if (Test-Path function:Update-PowerShell_Override) {
        Update-PowerShell_Override
        return
    }
    
    try {
        Write-Host "Checking for PowerShell updates..." -ForegroundColor Cyan
        $updateNeeded = $false
        $currentVersion = $PSVersionTable.PSVersion.ToString()
        $gitHubApiUrl = "https://api.github.com/repos/PowerShell/PowerShell/releases/latest"
        $latestReleaseInfo = Invoke-RestMethod -Uri $gitHubApiUrl
        $latestVersion = $latestReleaseInfo.tag_name.Trim('v')
        if ($currentVersion -lt $latestVersion) {
            $updateNeeded = $true
        }

        if ($updateNeeded) {
            Write-Host "Updating PowerShell..." -ForegroundColor Yellow
            Start-Process powershell.exe -ArgumentList "-NoProfile -Command winget upgrade Microsoft.PowerShell --accept-source-agreements --accept-package-agreements" -Wait -NoNewWindow
            Write-Host "PowerShell has been updated. Please restart your shell to reflect changes" -ForegroundColor Magenta
        } else {
            Write-Host "Your PowerShell is up to date." -ForegroundColor Green
        }
    } catch {
        Write-Error "Failed to update PowerShell. Error: $_"
    }
}

# Check for updates
if (-not $global:debug) {
    $shouldUpdate = $false
    
    if ($global:updateInterval -eq -1) {
        $shouldUpdate = $true
    } elseif (-not (Test-Path $global:timeFilePath)) {
        $shouldUpdate = $true
    } else {
        $lastUpdate = Get-Content -Path $global:timeFilePath -ErrorAction SilentlyContinue
        if ($lastUpdate) {
            $daysSinceUpdate = ((Get-Date) - [datetime]::ParseExact($lastUpdate, 'yyyy-MM-dd', $null)).TotalDays
            if ($daysSinceUpdate -gt $global:updateInterval) {
                $shouldUpdate = $true
            }
        }
    }
    
    if ($shouldUpdate) {
        Update-Profile
        Update-PowerShell
        $currentTime = Get-Date -Format 'yyyy-MM-dd'
        $currentTime | Out-File -FilePath $global:timeFilePath
    }
}

Export-ModuleMember -Function Update-Profile, Update-PowerShell
