<#
.SYNOPSIS
    Audio editing and processing tools for DevTools.

.DESCRIPTION
    Defines command-line or GUI audio editing utilities.
    Validation uses commands or explicit executable paths.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# ==============================
# Audio editing tools
# ==============================
$Tools = @(

    # ====================================================
    # CLI / GUI Audio Editors
    # ====================================================

    # ---------- Audacity ----------
    [PSCustomObject]@{
        Name         = 'Audacity'
        Category     = 'AudioEditors'
        ToolType     = 'AudioEditor'
        WinGetId     = 'Audacity.Audacity'
        ChocoId      = 'audacity'
        GitHubRepo   = 'audacity/audacity'
        BinaryCheck  = 'audacity.exe'
        Provides     = @('audacity.exe')
        Validation   = [PSCustomObject]@{
            Type  = 'Path'
            Value = @(
                "$env:ProgramFiles\Audacity\audacity.exe",
                "$env:ProgramFiles(x86)\Audacity\audacity.exe"
            )
        }
    }

    # ====================================================
    # Optional audio tools
    # ====================================================
)

# ==============================
# Return safe array
# ==============================
@($Tools)
