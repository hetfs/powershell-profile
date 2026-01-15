<#
.SYNOPSIS
    Code editors and code-validation tooling for DevTools

.DESCRIPTION
    Defines terminal and GUI code editors plus validation utilities.
    This file only declares tool metadata.
    Installation, validation, and execution are handled by DevTools core.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# ==============================
# Category metadata
# ==============================
$CategoryName        = 'Editors'
$CategoryDescription = 'Code editors, linters, and validation tools'

# ==============================
# Tool definitions
# ==============================
$Tools = @(

    # ====================================================
    # Neovim — Terminal-based code editor
    # ====================================================
    [PSCustomObject]@{
        Name                = 'Neovim'
        Category            = $CategoryName
        CategoryDescription = $CategoryDescription
        ToolType            = 'CodeEditor'
        Homepage            = 'https://neovim.io'
        GitHubRepo          = 'neovim/neovim'
        WinGetId            = 'Neovim.Neovim'
        ChocoId             = 'neovim'
        BinaryCheck         = 'nvim.exe'
        Provides            = @('nvim.exe')
        Dependencies        = @()
        Validation          = [PSCustomObject]@{
            Type  = 'Command'
            Value = 'nvim.exe'
        }
    }

    # ====================================================
    # EditorConfig Checker — .editorconfig validation
    # ====================================================
    [PSCustomObject]@{
        Name                = 'EditorConfig Checker'
        Category            = $CategoryName
        CategoryDescription = $CategoryDescription
        ToolType            = 'CodeValidation'
        Homepage            = 'https://editorconfig-checker.github.io'
        GitHubRepo          = 'editorconfig-checker/editorconfig-checker'
        WinGetId            = 'editorconfig-checker.editorconfig-checker'
        ChocoId             = 'editorconfig-checker'
        BinaryCheck         = 'ec-windows-amd64.exe'
        Provides            = @('ec-windows-amd64.exe')
        Dependencies        = @()
        Validation          = [PSCustomObject]@{
            Type  = 'Command'
            Value = 'ec-windows-amd64.exe'
        }
    }

    # ====================================================
    # Optional Editors (disabled by default)
    # ====================================================

    # ----------------------
    # Vim — Classic terminal editor
    # ----------------------
    # [PSCustomObject]@{
    #     Name                = 'Vim'
    #     Category            = $CategoryName
    #     CategoryDescription = $CategoryDescription
    #     ToolType            = 'CodeEditor'
    #     Homepage            = 'https://www.vim.org'
    #     GitHubRepo          = 'vim/vim'
    #     WinGetId            = 'Vim.Vim'
    #     ChocoId             = 'vim'
    #     BinaryCheck         = 'vim.exe'
    #     Provides            = @('vim.exe')
    #     Dependencies        = @()
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
    #     Homepage            = 'https://code.visualstudio.com'
    #     GitHubRepo          = 'microsoft/vscode'
    #     WinGetId            = 'Microsoft.VisualStudioCode'
    #     ChocoId             = 'vscode'
    #     BinaryCheck         = 'code.exe'
    #     Provides            = @('code.exe')
    #     Dependencies        = @()
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
    #     Homepage            = 'https://www.sublimetext.com'
    #     GitHubRepo          = 'sublimehq/sublime_text'
    #     WinGetId            = 'SublimeHQ.SublimeText'
    #     ChocoId             = 'sublimetext3'
    #     BinaryCheck         = 'sublime_text.exe'
    #     Provides            = @('sublime_text.exe')
    #     Dependencies        = @()
    #     Validation          = [PSCustomObject]@{
    #         Type  = 'Command'
    #         Value = 'sublime_text.exe'
    #     }
    # }
)

# ==============================
# Return tools safely
# ==============================
@($Tools)
