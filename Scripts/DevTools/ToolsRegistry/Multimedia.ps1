@(
    # ====================================================
    # Multimedia Tools
    # ====================================================

    [PSCustomObject]@{
        Name        = "VLC Media Player"
        Category    = "Multimedia"
        WinGetId    = "VideoLAN.VLC"
        ChocoId     = "vlc"
        GitHubRepo  = "videolan/vlc"
        BinaryCheck = "vlc.exe"
        Dependencies= @()
        Purpose     = "Cross-platform media player supporting most audio/video formats"
    },

    [PSCustomObject]@{
        Name        = "ffmpeg"
        Category    = "Multimedia"
        WinGetId    = "FFmpeg.FFmpeg"
        ChocoId     = "ffmpeg"
        GitHubRepo  = "FFmpeg/FFmpeg"
        BinaryCheck = "ffmpeg.exe"
        Dependencies= @()
        Purpose     = "Command-line tool to convert, stream, and manipulate audio/video"
    },

    [PSCustomObject]@{
        Name        = "OBS Studio"
        Category    = "Multimedia"
        WinGetId    = "OBSProject.OBSStudio"
        ChocoId     = "obs-studio"
        GitHubRepo  = "obsproject/obs-studio"
        BinaryCheck = "obs64.exe"
        Dependencies= @()
        Purpose     = "Screen recording and live streaming software"
    },

    [PSCustomObject]@{
        Name        = "Audacity"
        Category    = "Multimedia"
        WinGetId    = "Audacity.Audacity"
        ChocoId     = "audacity"
        GitHubRepo  = "audacity/audacity"
        BinaryCheck = "audacity.exe"
        Dependencies= @()
        Purpose     = "Audio recording and editing software"
    },

    [PSCustomObject]@{
        Name        = "ImageMagick"
        Category    = "Multimedia"
        WinGetId    = "ImageMagick.ImageMagick"
        ChocoId     = "imagemagick"
        GitHubRepo  = "ImageMagick/ImageMagick"
        BinaryCheck = "magick.exe"
        Dependencies= @()
        Purpose     = "Image manipulation and conversion CLI tool"
    },

    [PSCustomObject]@{
        Name        = "yt-dlp"
        Category    = "Multimedia"
        WinGetId    = $null
        ChocoId     = "yt-dlp"
        GitHubRepo  = "yt-dlp/yt-dlp"
        BinaryCheck = "yt-dlp.exe"
        Dependencies= @()
        Purpose     = "Download videos from YouTube and other platforms"
    },

    [PSCustomObject]@{
        Name        = "Poppler"
        Category    = "Multimedia"
        WinGetId    = "Poppler.Poppler"
        ChocoId     = "poppler"
        GitHubRepo  = "poppler/poppler"
        BinaryCheck = "pdftoppm.exe"
        Dependencies= @()
        Purpose     = "PDF rendering and conversion CLI tools"
    },

    [PSCustomObject]@{
        Name        = "Chafa"
        Category    = "Multimedia"
        WinGetId    = $null
        ChocoId     = "chafa"
        GitHubRepo  = "domenkozar/chafa"
        BinaryCheck = "chafa.exe"
        Dependencies= @()
        Purpose     = "Convert images to terminal graphics"
    },

    [PSCustomObject]@{
        Name        = "Editly"
        Category    = "Multimedia"
        WinGetId    = $null
        ChocoId     = $null
        GitHubRepo  = "mifi/editly"
        BinaryCheck = "editly.exe"
        Dependencies= @("Node.js")
        Purpose     = "Command-line video editing using Node.js"
    },

    [PSCustomObject]@{
        Name        = "Auto-Editor"
        Category    = "Multimedia"
        WinGetId    = $null
        ChocoId     = $null
        GitHubRepo  = "WyattBlue/auto-editor"
        BinaryCheck = "auto-editor.exe"
        Dependencies= @("Python")
        Purpose     = "Automatic video editing tool"
    },

    [PSCustomObject]@{
        Name        = "Signet"
        Category    = "Multimedia"
        WinGetId    = $null
        ChocoId     = $null
        GitHubRepo  = "digitalrune/signet"
        BinaryCheck = "signet.exe"
        Dependencies= @()
        Purpose     = "Audio and media file signing and verification"
    }
)
