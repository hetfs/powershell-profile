<#
.SYNOPSIS
    Code editors and editing tooling

.DESCRIPTION
    Defines terminal, GUI, validation, and note-taking editors.
    Returns a stable array of PSCustomObjects for installers,
    validators, and documentation generators.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# ==============================
# Category metadata
# ==============================
$CategoryName        = 'Editors'
$CategoryDescription = 'Code editors, linters, validators, and note-taking tools'

# ==============================
# Tool definitions
# ==============================
$Tools = @(

    # ----------------------
    # Neovim — Terminal-based code editor
    # ----------------------
    [PSCustomObject]@{
        Name                = 'Neovim'
        Category            = $CategoryName
        CategoryDescription = $CategoryDescription
        ToolType            = 'CodeEditor'
        WinGetId            = 'Neovim.Neovim'
        ChocoId             = 'neovim'
        GitHubRepo          = 'neovim/neovim'
        BinaryCheck         = 'nvim.exe'
        Dependencies        = @()
        Provides            = @('nvim.exe')
        Validation          = [PSCustomObject]@{
            Type  = 'Command'
            Value = 'nvim.exe'
        }
    }

    # ----------------------
    # EditorConfig Checker — .editorconfig validation
    # ----------------------
    [PSCustomObject]@{
        Name                = 'EditorConfig Checker'
        Category            = $CategoryName
        CategoryDescription = $CategoryDescription
        ToolType            = 'CodeValidation'
        WinGetId            = 'editorconfig-checker.editorconfig-checker'
        ChocoId             = 'editorconfig-checker'
        GitHubRepo          = 'editorconfig-checker/editorconfig-checker'
        BinaryCheck         = 'ec-windows-amd64'
        Dependencies        = @()
        Provides            = @('ec-windows-amd64')
        Validation          = [PSCustomObject]@{
            Type  = 'Command'
            Value = 'ec-windows-amd64'
        }
    }

    # ====================================================
    # Optional Editors (uncomment if desired)
    # ====================================================

    # ----------------------
    # Vim — Classic terminal editor
    # ----------------------
    # [PSCustomObject]@{
    #     Name                = 'Vim'
    #     Category            = $CategoryName
    #     CategoryDescription = $CategoryDescription
    #     ToolType            = 'CodeEditor'
    #     WinGetId            = 'Vim.Vim'
    #     ChocoId             = 'vim'
    #     GitHubRepo          = 'vim/vim'
    #     BinaryCheck         = 'vim.exe'
    #     Dependencies        = @()
    #     Provides            = @('vim.exe')
    #     Validation          = [PSCustomObject]@{
    #         Type  = 'Command'
    #         Value = 'vim.exe'
    #     }
    # }

    # ----------------------
    # Visual Studio Code — GUI code editor
    # ----------------------
    # [PSCustomObject]@{
    #     Name                = 'Visual Studio Code'
    #     Category            = $CategoryName
    #     CategoryDescription = $CategoryDescription
    #     ToolType            = 'CodeEditor'
    #     WinGetId            = 'Microsoft.VisualStudioCode'
    #     ChocoId             = 'vscode'
    #     GitHubRepo          = 'microsoft/vscode'
    #     BinaryCheck         = 'code.exe'
    #     Dependencies        = @()
    #     Provides            = @('code.exe')
    #     Validation          = [PSCustomObject]@{
    #         Type  = 'Command'
    #         Value = 'code.exe'
    #     }
    # }

    # ----------------------
    # Sublime Text — Lightweight GUI editor
    # ----------------------
    # [PSCustomObject]@{
    #     Name                = 'Sublime Text'
    #     Category            = $CategoryName
    #     CategoryDescription = $CategoryDescription
    #     ToolType            = 'CodeEditor'
    #     WinGetId            = 'SublimeHQ.SublimeText'
    #     ChocoId             = 'sublimetext3'
    #     GitHubRepo          = 'sublimehq/sublime_text'
    #     BinaryCheck         = 'sublime_text.exe'
    #     Dependencies        = @()
    #     Provides            = @('sublime_text.exe')
    #     Validation          = [PSCustomObject]@{
    #         Type  = 'Command'
    #         Value = 'sublime_text.exe'
    #     }
    # }
)

# ==============================
# Return tools array safely
# ==============================
@($Tools)
