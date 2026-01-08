<#
.SYNOPSIS
    Multimedia tools for image processing, audio/video editing,
    and 3D or creative workflows.

.DESCRIPTION
    Defines tools for multimedia tasks including image, audio, video,
    3D modeling, and creative utilities.
    Returns a stable array of PSCustomObjects for DevTools consumption.
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
    # Image Tools
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
        Provides            = @('magick.exe','convert.exe')
        Validation          = [PSCustomObject]@{
            Type  = 'Command'
            Value = 'magick.exe'
        }
    }

    # [PSCustomObject]@{
    #     Name                = 'GIMP'
    #     Category            = $CategoryName
    #     CategoryDescription = $CategoryDescription
    #     ToolType            = 'ImageEditor'
    #     WinGetId            = 'GIMP.GIMP'
    #     ChocoId             = 'gimp'
    #     GitHubRepo          = 'GIMP/GIMP'
    #     BinaryCheck         = 'gimp.exe'
    #     Dependencies        = @()
    #     Provides            = @('gimp.exe')
    #     Validation          = [PSCustomObject]@{
    #         Type  = 'Command'
    #         Value = 'gimp.exe'
    #     }
    # }

    # ====================================================
    # Audio Tools
    # ====================================================
    # [PSCustomObject]@{
    #     Name                = 'Audacity'
    #     Category            = $CategoryName
    #     CategoryDescription = $CategoryDescription
    #     ToolType            = 'AudioEditor'
    #     WinGetId            = 'Audacity.Audacity'
    #     ChocoId             = 'audacity'
    #     GitHubRepo          = 'audacity/audacity'
    #     BinaryCheck         = 'audacity.exe'
    #     Dependencies        = @()
    #     Provides            = @('audacity.exe')
    #     Validation          = [PSCustomObject]@{
    #         Type  = 'Command'
    #         Value = 'audacity.exe'
    #     }
    # }

    # ====================================================
    # Video Tools
    # ====================================================
    # [PSCustomObject]@{
    #     Name                = 'VLC Media Player'
    #     Category            = $CategoryName
    #     CategoryDescription = $CategoryDescription
    #     ToolType            = 'VideoPlayer'
    #     WinGetId            = 'VideoLAN.VLC'
    #     ChocoId             = 'vlc'
    #     GitHubRepo          = 'videolan/vlc'
    #     BinaryCheck         = 'vlc.exe'
    #     Dependencies        = @()
    #     Provides            = @('vlc.exe')
    #     Validation          = [PSCustomObject]@{
    #         Type  = 'Command'
    #         Value = 'vlc.exe'
    #     }
    # }

    # [PSCustomObject]@{
    #     Name                = 'Auto-Editor'
    #     Category            = $CategoryName
    #     CategoryDescription = $CategoryDescription
    #     ToolType            = 'VideoEditor'
    #     WinGetId            = ''
    #     ChocoId             = ''
    #     GitHubRepo          = 'ryanil95/auto-editor'
    #     BinaryCheck         = 'auto-editor.exe'
    #     Dependencies        = @('Python')
    #     Provides            = @('auto-editor.exe')
    #     Validation          = [PSCustomObject]@{
    #         Type  = 'Command'
    #         Value = 'auto-editor.exe'
    #     }
    # }

    # [PSCustomObject]@{
    #     Name                = 'OBS Studio'
    #     Category            = $CategoryName
    #     CategoryDescription = $CategoryDescription
    #     ToolType            = 'ScreenRecording'
    #     WinGetId            = 'OBSProject.OBSStudio'
    #     ChocoId             = 'obs-studio'
    #     GitHubRepo          = 'obsproject/obs'
    #     BinaryCheck         = 'obs64.exe'
    #     Dependencies        = @()
    #     Provides            = @('obs64.exe')
    #     Validation          = [PSCustomObject]@{
    #         Type  = 'Command'
    #         Value = 'obs64.exe'
    #     }
    # }
    #
    # ====================================================
    # Downloaders
    # ====================================================
    [PSCustomObject]@{
        Name                = 'yt-dlp'
        Category            = $CategoryName
        CategoryDescription = $CategoryDescription
        ToolType            = 'VideoDownloader'
        WinGetId            = ''
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
    # 3D and Creative Tools
    # ====================================================
    # [PSCustomObject]@{
    #     Name                = 'Blender'
    #     Category            = $CategoryName
    #     CategoryDescription = $CategoryDescription
    #     ToolType            = '3DModeling'
    #     WinGetId            = 'BlenderFoundation.Blender'
    #     ChocoId             = 'blender'
    #     GitHubRepo          = 'blender/blender'
    #     BinaryCheck         = 'blender.exe'
    #     Dependencies        = @()
    #     Provides            = @('blender.exe')
    #     Validation          = [PSCustomObject]@{
    #         Type  = 'Command'
    #         Value = 'blender.exe'
    #     }
    # }

    # ====================================================
    # Utilities and Media Processing
    # ====================================================
    # [PSCustomObject]@{
    #     Name                = 'FFmpeg'
    #     Category            = $CategoryName
    #     CategoryDescription = $CategoryDescription
    #     ToolType            = 'MediaProcessing'
    #     WinGetId            = 'FFmpeg.FFmpeg'
    #     ChocoId             = 'ffmpeg'
    #     GitHubRepo          = 'ffmpeg/ffmpeg'
    #     BinaryCheck         = 'ffmpeg.exe'
    #     Dependencies        = @()
    #     Provides            = @('ffmpeg.exe','ffprobe.exe')
    #     Validation          = [PSCustomObject]@{
    #         Type  = 'Command'
    #         Value = 'ffmpeg.exe'
    #     }
    # }

    # [PSCustomObject]@{
    #     Name                = 'Chafa'
    #     Category            = $CategoryName
    #     CategoryDescription = $CategoryDescription
    #     ToolType            = 'TerminalGraphics'
    #     WinGetId            = ''
    #     ChocoId             = 'chafa'
    #     GitHubRepo          = 'hishamhm/chafa'
    #     BinaryCheck         = 'chafa.exe'
    #     Dependencies        = @()
    #     Provides            = @('chafa.exe')
    #     Validation          = [PSCustomObject]@{
    #         Type  = 'Command'
    #         Value = 'chafa.exe'
    #     }
    # }

    # [PSCustomObject]@{
    #     Name                = 'Poppler'
    #     Category            = $CategoryName
    #     CategoryDescription = $CategoryDescription
    #     ToolType            = 'PDFProcessing'
    #     WinGetId            = 'Poppler.Poppler'
    #     ChocoId             = 'poppler'
    #     GitHubRepo          = 'poppler/poppler'
    #     BinaryCheck         = 'pdftoppm.exe'
    #     Dependencies        = @()
    #     Provides            = @('pdftoppm.exe','pdfinfo.exe','pdftocairo.exe')
    #     Validation          = [PSCustomObject]@{
    #         Type  = 'Command'
    #         Value = 'pdftoppm.exe'
    #     }
    # }

    # [PSCustomObject]@{
    #     Name                = 'Signet'
    #     Category            = $CategoryName
    #     CategoryDescription = $CategoryDescription
    #     ToolType            = 'MediaSecurity'
    #     WinGetId            = ''
    #     ChocoId             = ''
    #     GitHubRepo          = 'signet/signet'
    #     BinaryCheck         = 'signet.exe'
    #     Dependencies        = @()
    #     Provides            = @('signet.exe')
    #     Validation          = [PSCustomObject]@{
    #         Type  = 'Command'
    #         Value = 'signet.exe'
    #     }
    # }
)

# ==============================
# Return tools array safely
# ==============================
@($Tools)
