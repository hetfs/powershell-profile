<#
.SYNOPSIS
    Documentation tools, renderers, linters, and viewers (Windows only).

.DESCRIPTION
    Defines Windows-supported documentation tooling for DevTools,
    including Markdown renderers, documentation linters,
    PDF processors, viewers, and diff tools.
    Returns a stable array of PSCustomObjects for installation and validation.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# ==============================
# Category metadata
# ==============================
$CategoryName        = 'Documentation'
$CategoryDescription = 'Documentation renderers, linters, PDF tools, and helpers'

# ==============================
# Tool definitions
# ==============================
$Tools = @(

    # ====================================================
    # Markdown & Text Rendering
    # ====================================================

    # ---------- GLOW ----------
    [PSCustomObject]@{
        Name                = 'glow'
        Category            = $CategoryName
        CategoryDescription = $CategoryDescription
        ToolType            = 'MarkdownRenderer'
        WinGetId            = 'charmbracelet.glow'
        ChocoId             = 'glow'
        GitHubRepo          = 'charmbracelet/glow'
        BinaryCheck         = 'glow.exe'
        Dependencies        = @()
        Provides            = @('glow.exe')
        Validation          = [PSCustomObject]@{
            Type  = 'Command'
            Value = 'glow.exe'
        }
    }

    # ====================================================
    # Documentation Linters
    # ====================================================

    # ---------- VALE ----------
    [PSCustomObject]@{
        Name                = 'Vale'
        Category            = $CategoryName
        CategoryDescription = $CategoryDescription
        ToolType            = 'Linter'
        WinGetId            = 'errata-ai.Vale'
        ChocoId             = 'vale'
        GitHubRepo          = 'errata-ai/vale'
        BinaryCheck         = 'vale.exe'
        Dependencies        = @()
        Provides            = @('vale.exe')
        Validation          = [PSCustomObject]@{
            Type  = 'Command'
            Value = 'vale.exe'
        }
    }

    # ====================================================
    # PDF Processing & Viewing
    # ====================================================

    # ---------- POPPLER ----------
    [PSCustomObject]@{
        Name                = 'Poppler'
        Category            = $CategoryName
        CategoryDescription = $CategoryDescription
        ToolType            = 'PDFProcessing'
        WinGetId            = 'Poppler.Poppler'
        ChocoId             = 'poppler'
        GitHubRepo          = 'poppler/poppler'
        BinaryCheck         = 'pdftoppm.exe'
        Dependencies        = @()
        Provides            = @(
            'pdftoppm.exe',
            'pdfinfo.exe',
            'pdftocairo.exe'
        )
        Validation          = [PSCustomObject]@{
            Type  = 'Command'
            Value = 'pdftoppm.exe'
        }
    }

    # ---------- OKULAR ----------
    [PSCustomObject]@{
        Name                = 'Okular'
        Category            = $CategoryName
        CategoryDescription = $CategoryDescription
        ToolType            = 'PDFViewer'
        WinGetId            = 'KDE.Okular'
        ChocoId             = 'okular'
        GitHubRepo          = 'KDE/okular'
        BinaryCheck         = 'okular.exe'
        Dependencies        = @()
        Provides            = @('okular.exe')
        Validation          = [PSCustomObject]@{
            Type  = 'Path'
            Value = @(
                'C:\Program Files\KDE\Okular\bin\okular.exe',
                'C:\Program Files (x86)\KDE\Okular\bin\okular.exe'
            )
        }
    }

    # ====================================================
    # Diff & Merge Tools
    # ====================================================

    # ---------- KDIFF3 ----------
    # KDiff3 – File and directory diff and merge tool
    # https://github.com/KDE/kdiff3
    [PSCustomObject]@{
        Name                = 'KDiff3'
        Category            = $CategoryName
        CategoryDescription = $CategoryDescription
        ToolType            = 'DiffMerge'
        WinGetId            = 'KDE.KDiff3'
        ChocoId             = 'kdiff3'
        GitHubRepo          = 'KDE/kdiff3'
        BinaryCheck         = 'kdiff3.exe'
        Dependencies        = @()
        Provides            = @('kdiff3.exe')
        Validation          = [PSCustomObject]@{
            Type  = 'Path'
            Value = @(
                'C:\Program Files\KDiff3\kdiff3.exe',
                'C:\Program Files (x86)\KDiff3\kdiff3.exe'
            )
        }
    }

    # ====================================================
    # CLI Helpers & Reference Tools
    # ====================================================

    # ---------- TLRC ----------
    [PSCustomObject]@{
        Name                = 'tlrc'
        Category            = $CategoryName
        CategoryDescription = $CategoryDescription
        ToolType            = 'CLIHelper'
        WinGetId            = 'tldr-pages.tlrc'
        ChocoId             = 'tlrc'
        GitHubRepo          = 'tldr-pages/tlrc'
        BinaryCheck         = 'tldr.exe'
        Dependencies        = @()
        Provides            = @('tldr.exe')
        Validation          = [PSCustomObject]@{
            Type  = 'Command'
            Value = 'tldr.exe'
        }
    }
)

# ==============================
# Return tools array safely
# ==============================
@($Tools)
