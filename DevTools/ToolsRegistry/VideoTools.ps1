<#
.SYNOPSIS
    Video playback and related tools for DevTools.

.DESCRIPTION
    Defines video-focused GUI tools.
    Tools in this category are validated using explicit executable paths.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# ==============================
# Video tools
# ==============================
$Tools = @(

    # ====================================================
    # Video Players
    # ====================================================

    # ---------- VLC Media Player ----------
    [PSCustomObject]@{
        Name         = 'VLC Media Player'
        Category     = 'VideoTools'
        ToolType     = 'VideoPlayer'
        WinGetId     = 'VideoLAN.VLC'
        ChocoId      = 'vlc'
        GitHubRepo   = 'videolan/vlc'
        BinaryCheck  = 'vlc.exe'
        Provides     = @('vlc.exe')
        Validation   = [PSCustomObject]@{
            Type  = 'Path'
            Value = @(
                'C:\Program Files\VideoLAN\VLC\vlc.exe',
                'C:\Program Files (x86)\VideoLAN\VLC\vlc.exe'
            )
        }
    }

    # ====================================================
    # Optional video tools
    # Uncomment if needed
    # ====================================================

    <#
    # ---------- OBS Studio ----------
    [PSCustomObject]@{
        Name         = 'OBS Studio'
        Category     = 'VideoTools'
        ToolType     = 'ScreenRecording'
        WinGetId     = 'OBSProject.OBSStudio'
        ChocoId      = 'obs-studio'
        GitHubRepo   = 'obsproject/obs'
        BinaryCheck  = 'obs64.exe'
        Provides     = @('obs64.exe')
        Validation   = [PSCustomObject]@{
            Type  = 'Path'
            Value = @(
                'C:\Program Files\obs-studio\bin\64bit\obs64.exe',
                'C:\Program Files (x86)\obs-studio\bin\64bit\obs64.exe'
            )
        }
    }

    # ---------- Blender ----------
    [PSCustomObject]@{
        Name         = 'Blender'
        Category     = 'VideoTools'
        ToolType     = '3DModeling'
        WinGetId     = 'BlenderFoundation.Blender'
        ChocoId      = 'blender'
        GitHubRepo   = 'blender/blender'
        BinaryCheck  = 'blender.exe'
        Provides     = @('blender.exe')
        Validation   = [PSCustomObject]@{
            Type  = 'Path'
            Value = @(
                'C:\Program Files\Blender Foundation\Blender 5.0\blender.exe'
            )
        }
    }
    #>
)

# ==============================
# Return safe array
# ==============================
@($Tools)
