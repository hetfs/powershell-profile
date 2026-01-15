<#
.SYNOPSIS
    Multimedia downloader tools for DevTools.

.DESCRIPTION
    Defines command-line tools used for downloading multimedia content.
    Tools in this category are validated using command availability
    or explicit executable paths where required.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# ==============================
# Downloader tools
# ==============================
$Tools = @(

    # ====================================================
    # Video downloaders
    # ====================================================

    # ---------- yt-dlp ----------
    [PSCustomObject]@{
        Name         = 'yt-dlp'
        Category     = 'Downloaders'
        ToolType     = 'VideoDownloader'
        WinGetId     = 'yt-dlp.yt-dlp'
        ChocoId      = 'yt-dlp'
        GitHubRepo   = 'yt-dlp/yt-dlp'
        BinaryCheck  = 'yt-dlp.exe'
        Provides     = @('yt-dlp.exe')
        Validation   = [PSCustomObject]@{
            Type  = 'Command'
            Value = 'yt-dlp.exe'
        }
    }

    # ====================================================
    # Optional downloader tools
    # Uncomment if needed
    # ====================================================

    <#
    # ---------- asciinema ----------
    [PSCustomObject]@{
        Name         = 'asciinema'
        Category     = 'Downloaders'
        ToolType     = 'CLI'
        WinGetId     = 'Asciinema.Asciinema'
        ChocoId      = 'asciinema'
        GitHubRepo   = 'asciinema/asciinema'
        BinaryCheck  = 'asciinema'
        Dependencies = @('python')
        Provides     = @('asciinema')
        Validation   = [PSCustomObject]@{
            Type  = 'Path'
            Value = @(
                "$env:LOCALAPPDATA\Programs\Python\Python39\Scripts\asciinema.exe",
                "$env:LOCALAPPDATA\Programs\Python\Python310\Scripts\asciinema.exe",
                "$env:LOCALAPPDATA\Programs\Python\Python311\Scripts\asciinema.exe"
            )
        }
    }
    #>
)

# ==============================
# Return safe array
# ==============================
@($Tools)
