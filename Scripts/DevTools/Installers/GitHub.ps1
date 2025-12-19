function Install-ViaGitHub {
    param(
        [hashtable]$ReleaseInfo,
        [string]$ToolName,
        [string]$InstallPath
    )
    
    if (-not $ReleaseInfo) {
        Write-Log "GitHub method skipped - No release info provided for $ToolName" -Level SKIP
        return $false
    }
    
    try {
        Write-Log "Fetching GitHub release info for $ToolName..." -Level INFO
        
        $apiUrl = "https://api.github.com/repos/$($ReleaseInfo.Owner)/$($ReleaseInfo.Repo)/releases/latest"
        $headers = @{
            'Accept' = 'application/vnd.github.v3+json'
            'User-Agent' = 'DeveTools-Installer'
        }
        
        $release = Invoke-RestMethod -Uri $apiUrl -Headers $headers -ErrorAction Stop
        
        $asset = $release.assets | Where-Object { $_.name -match $ReleaseInfo.AssetPattern } | Select-Object -First 1
        
        if (-not $asset) {
            Write-Log "No matching asset found for pattern: $($ReleaseInfo.AssetPattern)" -Level WARN
            return $false
        }
        
        $downloadUrl = $asset.browser_download_url
        $fileName = Split-Path $downloadUrl -Leaf
        $tempDir = Join-Path $env:TEMP "DeveTools"
        $downloadPath = Join-Path $tempDir $fileName
        
        if (-not (Test-Path $tempDir)) {
            New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
        }
        
        Write-Log "Downloading $fileName from GitHub..." -Level INFO
        
        # Show download progress
        $ProgressPreference = 'SilentlyContinue'
        Invoke-WebRequest -Uri $downloadUrl -OutFile $downloadPath -ErrorAction Stop
        
        if ($ReleaseInfo.IsZip) {
            $extractPath = $ReleaseInfo.ExtractPath
            Write-Log "Extracting to $extractPath..." -Level INFO
            
            if (Test-Path $extractPath) {
                Remove-Item $extractPath -Recurse -Force -ErrorAction SilentlyContinue
            }
            
            Expand-Archive -Path $downloadPath -DestinationPath $extractPath -Force -ErrorAction Stop
            
            if ($ReleaseInfo.AddToPath) {
                Add-ToPath -Directory $ReleaseInfo.AddToPath
            }
            
            Write-Log "✓ Successfully installed $ToolName from GitHub" -Level SUCCESS
            return $true
        } else {
            if ($ReleaseInfo.InstallPath) {
                $installDir = Split-Path $ReleaseInfo.InstallPath -Parent
                if (-not (Test-Path $installDir)) {
                    New-Item -ItemType Directory -Path $installDir -Force | Out-Null
                }
                
                Move-Item -Path $downloadPath -Destination $ReleaseInfo.InstallPath -Force -ErrorAction SilentlyContinue
                
                if ($ReleaseInfo.AddToPath) {
                    Add-ToPath -Directory (Split-Path $ReleaseInfo.InstallPath -Parent)
                }
            } elseif ($ReleaseInfo.InstallerArgs) {
                Write-Log "Running installer..." -Level INFO
                $installArgs = $ReleaseInfo.InstallerArgs
                Start-Process -FilePath $downloadPath -ArgumentList $installArgs -Wait -NoNewWindow -ErrorAction Stop
            } else {
                $defaultPath = Join-Path $InstallPath "$ToolName.exe"
                Move-Item -Path $downloadPath -Destination $defaultPath -Force -ErrorAction SilentlyContinue
                Add-ToPath -Directory (Split-Path $defaultPath -Parent)
            }
            
            Write-Log "✓ Successfully installed $ToolName from GitHub" -Level SUCCESS
            return $true
        }
    } catch {
        Write-Log "GitHub installation failed: $_" -Level ERROR
        return $false
    }
}
