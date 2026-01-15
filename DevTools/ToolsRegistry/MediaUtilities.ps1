<#
.SYNOPSIS
    Multimedia processing and terminal media utilities for DevTools.

.DESCRIPTION
    Defines CLI-based multimedia utilities for media processing,
    conversion, inspection, and terminal rendering.
    Tools in this category are validated using command availability
    or explicit executable paths where required.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# ==============================
# Media utility tools
# ==============================
$Tools = @(

    # ====================================================
    # FFmpeg — Media processing toolkit
    # ====================================================
    [PSCustomObject]@{
        Name         = 'FFmpeg'
        Category     = 'MediaUtilities'
        ToolType     = 'MediaProcessing'
        WinGetId     = 'FFmpeg.FFmpeg'
        ChocoId      = 'ffmpeg'
        GitHubRepo   = 'ffmpeg/ffmpeg'
        BinaryCheck  = 'ffmpeg.exe'
        Provides     = @(
            'ffmpeg.exe'
            'ffprobe.exe'
        )
        Validation   = [PSCustomObject]@{
            Type  = 'Path'
            Value = @(
                'C:\Program Files\FFmpeg\bin\ffmpeg.exe'
                'C:\Program Files\ffmpeg\bin\ffmpeg.exe'
                'C:\ffmpeg\bin\ffmpeg.exe'
                "$env:ProgramData\chocolatey\bin\ffmpeg.exe"
            )
        }
    }

    # ====================================================
    # Chafa — Terminal image renderer
    # ====================================================
    [PSCustomObject]@{
        Name         = 'Chafa'
        Category     = 'MediaUtilities'
        ToolType     = 'TerminalGraphics'
        WinGetId     = 'hpjansson.Chafa'
        ChocoId      = 'chafa'
        GitHubRepo   = 'hpjansson/chafa'
        BinaryCheck  = 'chafa.exe'
        Provides     = @('chafa.exe')
        Validation   = [PSCustomObject]@{
            Type  = 'Command'
            Value = 'chafa.exe'
        }
    }
)

# ==============================
# Return safe array
# ==============================
@($Tools)
