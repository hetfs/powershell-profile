$categoryTools = @{
    'ffmpeg' = @{
        DisplayName = 'FFmpeg'
        WinGetId = 'Gyan.FFmpeg'
        ChocolateyId = 'ffmpeg'
        GitHubRelease = $null
        TestCommand = 'ffmpeg -version'
    }
    'imagemagick' = @{
        DisplayName = 'ImageMagick'
        WinGetId = 'ImageMagick.ImageMagick'
        ChocolateyId = 'imagemagick'
        GitHubRelease = $null
        TestCommand = 'magick --version'
    }
    'yt-dlp' = @{
        DisplayName = 'yt-dlp'
        WinGetId = 'yt-dlp.yt-dlp'
        ChocolateyId = 'yt-dlp'
        GitHubRelease = @{
            Owner = 'yt-dlp'
            Repo = 'yt-dlp'
            AssetPattern = '^yt-dlp\.exe$'
            IsZip = $false
            InstallPath = "$InstallPath\yt-dlp.exe"
            AddToPath = $InstallPath
        }
        TestCommand = 'yt-dlp --version'
    }
    'poppler' = @{
        DisplayName = 'Poppler'
        WinGetId = 'oschwartz10612.Poppler'
        ChocolateyId = $null
        GitHubRelease = $null
        TestCommand = 'pdftotext -v'
    }
    'chafa' = @{
        DisplayName = 'Chafa'
        WinGetId = 'hpjansson.Chafa'
        ChocolateyId = $null
        GitHubRelease = @{
            Owner = 'hpjansson'
            Repo = 'chafa'
            AssetPattern = '^chafa-.+-win64\.zip$'
            IsZip = $true
            ExtractPath = "$InstallPath\chafa"
            AddToPath = "$InstallPath\chafa\bin"
        }
        TestCommand = 'chafa --version'
    }
    'editly' = @{
        DisplayName = 'Editly'
        WinGetId = $null
        ChocolateyId = 'editly'
        GitHubRelease = $null
        TestCommand = 'editly --version'
        PostInstall = {
            Write-Log "Editly requires Node.js and npm. Checking availability..." -Level INFO
            if (Test-CommandExists 'npm') {
                try {
                    Write-Log "Installing Editly via npm..." -Level INFO
                    npm install -g editly
                    Write-Log "✓ Editly installed via npm" -Level SUCCESS
                } catch {
                    Write-Log "Failed to install Editly via npm: $_" -Level WARN
                }
            } else {
                Write-Log "npm not found. Please install Node.js first." -Level WARN
            }
        }
    }
    'auto-editor' = @{
        DisplayName = 'Auto-Editor'
        WinGetId = $null
        ChocolateyId = 'auto-editor'
        GitHubRelease = $null
        TestCommand = 'auto-editor --version'
        PostInstall = {
            Write-Log "Auto-Editor requires Python and pip. Checking availability..." -Level INFO
            if (Test-CommandExists 'pip') {
                try {
                    Write-Log "Installing Auto-Editor via pip..." -Level INFO
                    pip install auto-editor
                    Write-Log "✓ Auto-Editor installed via pip" -Level SUCCESS
                } catch {
                    Write-Log "Failed to install Auto-Editor via pip: $_" -Level WARN
                }
            } else {
                Write-Log "pip not found. Please install Python first." -Level WARN
            }
        }
    }
    'signet' = @{
        DisplayName = 'Signet'
        WinGetId = $null
        ChocolateyId = 'signet'
        GitHubRelease = $null
        TestCommand = 'signet --version'
    }
}
