<#
.SYNOPSIS
    Prompt, shell UI, and theming tools for enhanced terminal experience.

.DESCRIPTION
    Defines prompt engines, shell UX enhancements, and theming tools
    that improve usability, readability, and aesthetics of the terminal.

    Returns a stable array of PSCustomObjects for DevTools installer
    and validation pipelines.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# ==============================
# Category metadata
# ==============================
$CategoryName        = 'PromptUI'
$CategoryDescription = 'Prompt engines, shell UX enhancements, and terminal theming tools'

# ==============================
# Tool definitions
# ==============================
$Tools = @(

    # ====================================================
    # Prompt Engines
    # ====================================================
    [PSCustomObject]@{
        Name                = 'Starship Prompt'
        Category            = $CategoryName
        CategoryDescription = $CategoryDescription
        ToolType            = 'PromptEngine'
        WinGetId            = 'Starship.Starship'
        ChocoId             = 'starship'
        GitHubRepo          = 'starship/starship'
        BinaryCheck         = 'starship.exe'
        Dependencies        = @()
        Provides            = @('starship.exe')
        Validation          = [PSCustomObject]@{
            Type  = 'Command'
            Value = 'starship'
        }
    }

)

# ==============================
# Return tools array safely
# ==============================
@($Tools)
