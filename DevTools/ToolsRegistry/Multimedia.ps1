<#
.SYNOPSIS
    Multimedia tools for image processing, audio/video editing,
    media playback, downloading, and creative workflows.

.DESCRIPTION
    Defines multimedia tools for DevTools consumption.
    GUI applications and Python-backed tools are validated using explicit paths.
    Native CLI tools are validated using command availability.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# ==============================
# Category metadata
# ==============================
$CategoryName        = 'Multimedia'
$CategoryDescription = 'Multimedia, audio, video, image, and creative tools'

# ==============================
# Tool definitions
# ==============================
$Tools = @(

    # ====================================================
    # Image Processing (CLI)
    # ====================================================

    [PSCustomObject]@{
        Name                = 'ImageMagick'
        Category            = $CategoryName
        CategoryDescription = $CategoryDescription
        ToolType            = 'ImageProcessing'
        WinGetId            = 'ImageMagick.ImageMagick'
        ChocoId             = 'imagemagick'
        GitHubRepo          = 'ImageMagick/ImageMagick'
        BinaryCheck         = 'magick.exe'
        Dependencies        = @()
        Provides            = @('magick.exe', 'convert.exe')
        Validation          = [PSCustomObject]@{
            Type  = 'Command'
            Value = 'magick.exe'
        }
    }

    # ====================================================
    # Image Editors (GUI)
    # ====================================================

    [PSCustomObject]@{
        Name                = 'GIMP'
        Category            = $CategoryName
        CategoryDescription = $CategoryDescription
        ToolType            = 'ImageEditor'
        WinGetId            = 'GIMP.GIMP'
        ChocoId             = 'gimp'
        GitHubRepo          = 'GIMP/GIMP'
        BinaryCheck         = 'gimp.exe'
        Dependencies        = @()
        Provides            = @('gimp.exe')
        Validation          = [PSCustomObject]@{
            Type  = 'Path'
            Value = @(
                'C:\Program Files\GIMP 2\bin\gimp-2.10.exe',
                'C:\Program Files (x86)\GIMP 2\bin\gimp-2.10.exe'
            )
        }
    }

    # ====================================================
    # Audio Editors (GUI)
    # ====================================================

    [PSCustomObject]@{
        Name                = 'Audacity'
        Category            = $CategoryName
        CategoryDescription = $CategoryDescription
        ToolType            = 'AudioEditor'
        WinGetId            = 'Audacity.Audacity'
        ChocoId             = 'audacity'
        GitHubRepo          = 'audacity/audacity'
        BinaryCheck         = 'audacity.exe'
        Dependencies        = @()
        Provides            = @('audacity.exe')
        Validation          = [PSCustomObject]@{
            Type  = 'Path'
            Value = @(
                'C:\Program Files\Audacity\audacity.exe',
                'C:\Program Files (x86)\Audacity\audacity.exe'
            )
        }
    }

    # ====================================================
    # Video Players and Recorders (GUI)
    # ====================================================

    [PSCustomObject]@{
        Name                = 'VLC Media Player'
        Category            = $CategoryName
        CategoryDescription = $CategoryDescription
        ToolType            = 'VideoPlayer'
        WinGetId            = 'VideoLAN.VLC'
        ChocoId             = 'vlc'
        GitHubRepo          = 'videolan/vlc'
        BinaryCheck         = 'vlc.exe'
        Dependencies        = @()
        Provides            = @('vlc.exe')
        Validation          = [PSCustomObject]@{
            Type  = 'Path'
            Value = @(
                'C:\Program Files\VideoLAN\VLC\vlc.exe',
                'C:\Program Files (x86)\VideoLAN\VLC\vlc.exe'
            )
        }
    }

    [PSCustomObject]@{
        Name                = 'OBS Studio'
        Category            = $CategoryName
        CategoryDescription = $CategoryDescription
        ToolType            = 'ScreenRecording'
        WinGetId            = 'OBSProject.OBSStudio'
        ChocoId             = 'obs-studio'
        GitHubRepo          = 'obsproject/obs'
        BinaryCheck         = 'obs64.exe'
        Dependencies        = @()
        Provides            = @('obs64.exe')
        Validation          = [PSCustomObject]@{
            Type  = 'Path'
            Value = @(
                'C:\Program Files\obs-studio\bin\64bit\obs64.exe',
                'C:\Program Files (x86)\obs-studio\bin\64bit\obs64.exe'
            )
        }
    }

    # ====================================================
    # Video Downloaders (CLI)
    # ====================================================

    [PSCustomObject]@{
        Name                = 'yt-dlp'
        Category            = $CategoryName
        CategoryDescription = $CategoryDescription
        ToolType            = 'VideoDownloader'
        WinGetId            = 'yt-dlp.yt-dlp'
        ChocoId             = 'yt-dlp'
        GitHubRepo          = 'yt-dlp/yt-dlp'
        BinaryCheck         = 'yt-dlp.exe'
        Dependencies        = @()
        Provides            = @('yt-dlp.exe')
        Validation          = [PSCustomObject]@{
            Type  = 'Command'
            Value = 'yt-dlp.exe'
        }
    }

    # ====================================================
    # Terminal Recording (Python-backed CLI)
    # ====================================================

    [PSCustomObject]@{
        Name                = 'asciinema'
        Category            = 'Terminal'
        CategoryDescription = 'Terminal session recorder'
        ToolType            = 'CLI'
        WinGetId            = 'Asciinema.Asciinema'
        ChocoId             = 'asciinema'
        GitHubRepo          = 'asciinema/asciinema'
        BinaryCheck         = 'asciinema'
        Dependencies        = @('python')
        Provides            = @('asciinema')
        Validation          = [PSCustomObject]@{
            Type  = 'Path'
            Value = @(
                "$env:LOCALAPPDATA\Programs\Python\Python39\Scripts\asciinema.exe",
                "$env:LOCALAPPDATA\Programs\Python\Python310\Scripts\asciinema.exe",
                "$env:LOCALAPPDATA\Programs\Python\Python311\Scripts\asciinema.exe",
                "$env:ProgramFiles\Python39\Scripts\asciinema.exe",
                "$env:ProgramFiles\Python310\Scripts\asciinema.exe",
                "$env:ProgramFiles\Python311\Scripts\asciinema.exe",
                "$env:ProgramData\chocolatey\bin\asciinema.exe"
            )
        }
    }

    # ====================================================
    # 3D and Creative Tools (GUI)
    # ====================================================

    [PSCustomObject]@{
        Name                = 'Blender'
        Category            = $CategoryName
        CategoryDescription = $CategoryDescription
        ToolType            = '3DModeling'
        WinGetId            = 'BlenderFoundation.Blender'
        ChocoId             = 'blender'
        GitHubRepo          = 'blender/blender'
        BinaryCheck         = 'blender.exe'
        Dependencies        = @()
        Provides            = @('blender.exe')
        Validation          = [PSCustomObject]@{
            Type  = 'Path'
            Value = @(
                'C:\Program Files\Blender Foundation\Blender 5.0\blender.exe'
            )
        }
    }

    # ====================================================
    # Media Processing Utilities (CLI)
    # ====================================================

    [PSCustomObject]@{
        Name                = 'FFmpeg'
        Category            = $CategoryName
        CategoryDescription = $CategoryDescription
        ToolType            = 'MediaProcessing'
        WinGetId            = 'FFmpeg.FFmpeg'
        ChocoId             = 'ffmpeg'
        GitHubRepo          = 'ffmpeg/ffmpeg'
        BinaryCheck         = 'ffmpeg.exe'
        Dependencies        = @()
        Provides            = @('ffmpeg.exe', 'ffprobe.exe')
        Validation          = [PSCustomObject]@{
            Type  = 'Path'
            Value = @(
                'C:\Program Files\FFmpeg\bin\ffmpeg.exe',
                'C:\Program Files\ffmpeg\bin\ffmpeg.exe',
                'C:\ffmpeg\bin\ffmpeg.exe',
                "$env:ProgramData\chocolatey\bin\ffmpeg.exe"
            )
        }
    }

    [PSCustomObject]@{
        Name                = 'Chafa'
        Category            = $CategoryName
        CategoryDescription = $CategoryDescription
        ToolType            = 'TerminalGraphics'
        WinGetId            = 'hpjansson.Chafa'
        ChocoId             = 'chafa'
        GitHubRepo          = 'hpjansson/chafa'
        BinaryCheck         = 'chafa.exe'
        Dependencies        = @()
        Provides            = @('chafa.exe')
        Validation          = [PSCustomObject]@{
            Type  = 'Command'
            Value = 'chafa.exe'
        }
    }
)

# ==============================
# Return tools array safely
# ==============================
@($Tools)
