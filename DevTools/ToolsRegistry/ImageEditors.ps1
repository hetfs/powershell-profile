<#
.SYNOPSIS
    Image editing tools for DevTools.

.DESCRIPTION
    Defines command-line or terminal-based image editing utilities.
    Tools are validated via command availability or explicit paths.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# ==============================
# Image editing tools
# ==============================
$Tools = @(

    # ====================================================
    # CLI / GUI Image Editors
    # ====================================================

    # ---------- ImageMagick ----------
    [PSCustomObject]@{
        Name         = 'ImageMagick'
        Category     = 'ImageEditors'
        ToolType     = 'ImageEditor'
        WinGetId     = 'ImageMagick.ImageMagick'
        ChocoId      = 'imagemagick'
        GitHubRepo   = 'ImageMagick/ImageMagick'
        BinaryCheck  = 'magick.exe'
        Provides     = @('magick.exe')
        Validation   = [PSCustomObject]@{
            Type  = 'Command'
            Value = 'magick.exe'
        }
    }

    # ====================================================
    # Optional editors
    # ====================================================
    <#
    # ---------- GIMP ----------
    [PSCustomObject]@{
        Name         = 'GIMP'
        Category     = 'ImageEditors'
        ToolType     = 'GUI'
        WinGetId     = 'GIMP.GIMP'
        ChocoId      = 'gimp'
        GitHubRepo   = 'GNOME/gimp'
        BinaryCheck  = 'gimp-2.10.exe'
        Provides     = @('gimp-2.10.exe')
        Validation   = [PSCustomObject]@{
            Type  = 'Path'
            Value = @(
                "$env:ProgramFiles\GIMP 2\bin\gimp-2.10.exe",
                "$env:ProgramFiles(x86)\GIMP 2\bin\gimp-2.10.exe"
            )
        }
    }
    #>
)

# ==============================
# Return safe array
# ==============================
@($Tools)
