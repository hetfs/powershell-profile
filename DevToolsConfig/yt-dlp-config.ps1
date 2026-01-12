# ============================================================
# Enhanced yt-dlp Download Manager v2.7.0
# All-in-one Windows-ready configuration + cookies + HDR-first
# ============================================================

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

$ScriptVersion = "2.7.0"
$ColorSuccess = "Green"
$ColorWarning = "Yellow"
$ColorError   = "Red"
$ColorInfo    = "Cyan"
$ColorDebug   = "Gray"

Write-Host "`n" -NoNewline
Write-Host "=" * 70 -ForegroundColor $ColorInfo
Write-Host "Enhanced yt-dlp Download Manager v$ScriptVersion" -ForegroundColor $ColorInfo
Write-Host "=" * 70 -ForegroundColor $ColorInfo
Write-Host "`n"

#region Directory Setup
$configDir = Join-Path $env:APPDATA 'yt-dlp'
$directories = @(
    @{ Name = "Configuration"; Path = $configDir },
    @{ Name = "Archives"; Path = Join-Path $configDir 'archives' },
    @{ Name = "Channel Cache"; Path = Join-Path $configDir 'channel_cache' },
    @{ Name = "Failed Downloads"; Path = Join-Path $configDir 'failed' },
    @{ Name = "Logs"; Path = Join-Path $configDir 'logs' }
)

Write-Host "Setting up directories..." -ForegroundColor $ColorInfo
foreach ($dir in $directories) {
    if (-not (Test-Path $dir.Path)) {
        try { New-Item -ItemType Directory -Path $dir.Path -Force | Out-Null
              Write-Host "  ✓ Created: $($dir.Name)" -ForegroundColor $ColorSuccess }
        catch { Write-Warning "Failed to create $($dir.Name) directory: $_" }
    }
}
#endregion

#region Remove Old Global Config
$configPath = Join-Path $configDir 'config.txt'
if (Test-Path $configPath) {
    try { Remove-Item $configPath -Force
          Write-Host "  ✓ Removed old global configuration" -ForegroundColor $ColorInfo }
    catch { Write-Warning "Failed to remove old global config: $_" }
}
#endregion

#region Create Fresh Global Config
Write-Host "`nCreating fresh yt-dlp configuration..." -ForegroundColor $ColorInfo

# Check for cookies.txt in Downloads
$cookieFile = Join-Path $env:USERPROFILE "Downloads\cookies.txt"
$cookieOption = ""
if (Test-Path $cookieFile) {
    $cookieOption = "--cookies `"$cookieFile`""
    Write-Host "  ✓ Using cookies file: $cookieFile" -ForegroundColor $ColorSuccess
} else {
    Write-Host "  ⚠ No cookies file found. Some videos may require cookies." -ForegroundColor $ColorWarning
}

$globalConfig = @"
--no-warnings
--console-title
--progress
--newline
--js-runtimes node
$cookieOption
--embed-metadata
--embed-thumbnail
--embed-chapters
--recode-video mp4
--retries 10
--fragment-retries 10
--concurrent-fragments 4
--throttled-rate 100K
--no-playlist-reverse
--restrict-filenames
--windows-filenames
--no-overwrites
--continue

# Archive settings (Windows-safe)
--download-archive "$($directories[1].Path -Replace '\\','/')/%(channel)s-%(playlist)s.txt"

# Throttling
--limit-rate 5M
--sleep-requests 1
--sleep-interval 5
"@
Set-Content -Path $configPath -Value $globalConfig -Encoding UTF8 -Force
Write-Host "  ✓ Fresh configuration saved to: $configPath" -ForegroundColor $ColorSuccess
#endregion

#region Dependency & Auto-Update
function Initialize-Dependencies {
    Write-Host "`nChecking dependencies..." -ForegroundColor $ColorInfo
    $dependencies = @(
        @{ Id = 'yt-dlp.yt-dlp'; Name = 'yt-dlp'; InstallMessage = 'Installing yt-dlp...' },
        @{ Id = 'Gyan.FFmpeg'; Name = 'ffmpeg'; InstallMessage = 'Installing FFmpeg...' }
    )
    foreach ($dep in $dependencies) {
        try {
            $installed = Get-Command $dep.Name -ErrorAction SilentlyContinue
            if (-not $installed) {
                Write-Host $dep.InstallMessage -ForegroundColor $ColorWarning
                winget install --id $dep.Id --exact --source winget `
                    --accept-package-agreements --accept-source-agreements --silent
                Write-Host "  ✓ $($dep.Name) installed successfully" -ForegroundColor $ColorSuccess
            } else {
                Write-Host "  ✓ $($dep.Name) found: $($installed.Version)" -ForegroundColor $ColorSuccess
            }
        } catch {
            Write-Warning "Failed to install $($dep.Name): $_"
        }
    }
}

function Update-Tools {
    Write-Host "`nAuto-Updating tools..." -ForegroundColor $ColorInfo
    $tools = @(
        @{ Id = 'yt-dlp.yt-dlp'; Name = 'yt-dlp' },
        @{ Id = 'Gyan.FFmpeg'; Name = 'FFmpeg' }
    )
    foreach ($tool in $tools) {
        try {
            Write-Host "  Updating $($tool.Name)..." -NoNewline
            winget upgrade --id $tool.Id --exact --silent --accept-package-agreements | Out-Null
            Write-Host " ✓" -ForegroundColor $ColorSuccess
        } catch { Write-Host " ✗ (No update or error)" -ForegroundColor $ColorWarning }
    }
}
Initialize-Dependencies
Update-Tools
#endregion

#region Preflight Analysis
function Invoke-PreflightAnalysis {
    param(
        [Parameter(Mandatory)][string]$Url,
        [Parameter()][ValidateRange(1,200)][int]$SampleSize = 50
    )
    Write-Host "`nRunning preflight analysis..." -ForegroundColor $ColorInfo
    try {
        $cacheFile = Join-Path $directories[2].Path "$($Url.GetHashCode()).json"
        if (Test-Path $cacheFile) {
            $cache = Get-Content $cacheFile | ConvertFrom-Json
            if ((Get-Date) -lt ([DateTime]$cache.Timestamp).AddDays(7)) {
                Write-Host "  Using cached analysis from $($cache.Timestamp)" -ForegroundColor $ColorDebug
                return $cache
            }
        }

        Write-Host "  Sampling $SampleSize videos..." -NoNewline
        $jsonData = yt-dlp --dump-json --playlist-items "1-$SampleSize" --quiet $Url 2>$null | ConvertFrom-Json
        foreach ($video in $jsonData) {
            $video | Add-Member -MemberType NoteProperty -Name "OutputFolder" `
                -Value ($(if ($video.duration -le 60) { "Shorts" } else { "Videos" }))
            $video | Add-Member -MemberType NoteProperty -Name "AudioOnly" `
                -Value ($video.categories -contains 'Music')
        }

        $analysis = @{
            Timestamp       = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            TotalVideos     = ($jsonData | Measure-Object).Count
            HDRVideos       = ($jsonData | Where-Object { $_.dynamic_range -ne 'SDR' -and $_.dynamic_range }).Count
            AvailableVideos = ($jsonData | Where-Object { $_.availability -eq 'public' }).Count
            Shorts          = ($jsonData | Where-Object { $_.duration -le 60 }).Count
            LongVideos      = ($jsonData | Where-Object { $_.duration -gt 60 }).Count
            AverageDuration = [math]::Round(($jsonData | Measure-Object -Property duration -Average).Average, 2)
            Channel         = $jsonData[0].channel
            Videos          = $jsonData
        }

        $analysis | ConvertTo-Json | Set-Content -Path $cacheFile -Encoding UTF8
        Write-Host " ✓" -ForegroundColor $ColorSuccess
        return $analysis
    } catch {
        Write-Host " ✗" -ForegroundColor $ColorError
        Write-Warning "Preflight analysis failed: $_"
        return $null
    }
}
#endregion

#region Download Function
function Start-Download {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory,Position=0)][Alias("Link","Playlist","Channel")][string]$Url,
        [switch]$FailFastHDR,
        [Parameter()][ValidateRange(1,10)][int]$MaxRetries = 3
    )

    Write-Host "`n" + "="*70 -ForegroundColor $ColorInfo
    Write-Host "Starting Download Session" -ForegroundColor $ColorInfo
    Write-Host "="*70 -ForegroundColor $ColorInfo

    Update-Tools

    if ($Url -notmatch '^(https?://)?(www\.)?(youtube\.com|youtu\.be)/') {
        Write-Warning "URL doesn't appear to be a valid YouTube URL. Continuing anyway..."
    }

    $analysis = Invoke-PreflightAnalysis -Url $Url
    if ($FailFastHDR -and $analysis.HDRVideos -eq 0) {
        Write-Host "`n❌ HDR Fail-Fast enabled, but no HDR videos found!" -ForegroundColor $ColorError
        return
    }

    $logFile = Join-Path $directories[4].Path "$(Get-Date -Format 'yyyy-MM-dd-HHmmss').log"

    foreach ($video in $analysis.Videos) {

        $format = if ($video.AudioOnly) {
            "-f `"bestaudio/best`""
        } elseif ($video.dynamic_range -ne 'SDR') {
            "-f `"bv*[dynamic_range!=SDR]+bestaudio/b[height<=2160]+bestaudio`""
        } else {
            "-f `"bestvideo+bestaudio/bestaudio`""
        }

        $outputFolder = Join-Path "$env:USERPROFILE\Downloads" `
                        "$($analysis.Channel)/$(if($video.playlist){$video.playlist}else{'Single'})/$($video.OutputFolder)"
        if (-not (Test-Path $outputFolder)) { New-Item -ItemType Directory -Path $outputFolder -Force | Out-Null }

        $output = Join-Path $outputFolder "$($video.playlist_index|NA) - $($video.title).150s [${video.id}].%(ext)s"

        $ytdlpArgs = @(
            "--config-locations `"$configPath`"",
            $format,
            "--output `"$output`"",
            "`"$video.webpage_url`""
        ) -join " "

        for ($attempt = 1; $attempt -le $MaxRetries; $attempt++) {
            Write-Host "`nDownloading: $($video.title)" -ForegroundColor $ColorInfo
            Write-Host "Attempt $attempt of $MaxRetries" -ForegroundColor $ColorInfo
            try {
                Invoke-Expression "yt-dlp $ytdlpArgs 2>&1 | Tee-Object -FilePath `"$logFile`""
                if ($LASTEXITCODE -eq 0) { break }
                else { throw "yt-dlp exited with code $LASTEXITCODE" }
            } catch {
                Write-Warning "Download attempt $attempt failed: $_"
                if ($attempt -lt $MaxRetries) {
                    Start-Sleep -Seconds ([math]::Pow(2, $attempt) * 5)
                } else {
                    "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - $($video.webpage_url)" | Add-Content -Path (Join-Path $directories[3].Path "failed_urls.txt")
                }
            }
        }
    }

    Write-Host "`nDownload session complete!" -ForegroundColor $ColorSuccess
}
#endregion

#region Stats Function
function Get-DownloadStats {
    $archives = Get-ChildItem -Path $directories[1].Path -Filter "*.txt" -ErrorAction SilentlyContinue
    if ($archives) {
        Write-Host "`nDownload Statistics:" -ForegroundColor $ColorInfo
        Write-Host ("-"*40) -ForegroundColor $ColorInfo
        foreach ($archive in $archives) {
            $count = (Get-Content $archive.FullName).Count
            $name = $archive.BaseName -replace '-Single$', '' -replace '-', ': '
            Write-Host "  $name : $count videos" -ForegroundColor $ColorInfo
        }
    } else {
        Write-Host "No download archives found." -ForegroundColor $ColorWarning
    }
}
#endregion

#region Main Execution
Write-Host "`n" + "="*70 -ForegroundColor $ColorSuccess
Write-Host "ENHANCED YT-DLP DOWNLOAD MANAGER READY" -ForegroundColor $ColorSuccess
Write-Host "="*70 -ForegroundColor $ColorSuccess

Write-Host @"
Available Commands:

Features:
  ✓ Smart HDR detection & fallback
  ✓ Automatic folder organization
  ✓ Shorts/Longs separation
  ✓ Best audio quality
  ✓ Automatic audio-only for music tracks
  ✓ Mixed playlist handling
  ✓ No duplicate downloads
  ✓ Metadata & chapter embedding
  ✓ Auto-retry failed downloads
  ✓ Auto-update yt-dlp & FFmpeg
  ✓ Cookies support (optional, via cookies.txt)
  ✓ Download to: $env:USERPROFILE\Downloads
"@ -ForegroundColor $ColorInfo
#endregion
