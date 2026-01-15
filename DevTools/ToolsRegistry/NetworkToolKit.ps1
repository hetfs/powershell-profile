<#
.SYNOPSIS
    Network and web-related tools for Windows.

.DESCRIPTION
    Defines HTTP clients, file downloaders, network diagnostics,
    security scanners, certificate management, and traffic inspection tools.
    Returns a stable array of PSCustomObjects for DevTools installer
    and validator consumption.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# ==============================
# Category metadata
# ==============================
$CategoryName        = 'NetworkToolKit'
$CategoryDescription = 'Network, Web, HTTP, Security, and Traffic Inspection Tools'

# ==============================
# Tool definitions
# ==============================
$Tools = @(

    # ====================================================
    # HTTP & API Clients (CLI)
    # ====================================================
    [PSCustomObject]@{
        Name                = 'HTTPie CLI'
        Category            = $CategoryName
        CategoryDescription = $CategoryDescription
        ToolType            = 'HttpClient'
        WinGetId            = 'httpie.httpie'
        ChocoId             = 'httpie'
        GitHubRepo          = 'httpie/httpie'
        BinaryCheck         = 'HTTPie.exe'
        Dependencies        = @()
        Provides            = @('HTTPie.exe')
        Validation = [PSCustomObject]@{
            Type  = 'Path'
            Value = @(
                Join-Path $env:LOCALAPPDATA 'Programs\HTTPie\HTTPie.exe'
                Join-Path $env:LOCALAPPDATA 'Programs\HTTPie\bin\HTTPie.exe'
            )
        }
    }

    [PSCustomObject]@{
        Name                = 'curl'
        Category            = $CategoryName
        CategoryDescription = $CategoryDescription
        ToolType            = 'CLI'
        WinGetId            = 'curl.curl'
        ChocoId             = 'curl'
        GitHubRepo          = 'curl/curl'
        BinaryCheck         = 'curl.exe'
        Dependencies        = @()
        Provides            = @('curl.exe')
        Validation          = [PSCustomObject]@{
            Type  = 'Command'
            Value = 'curl.exe'
        }
    }

    [PSCustomObject]@{
        Name                = 'wget'
        Category            = $CategoryName
        CategoryDescription = $CategoryDescription
        ToolType            = 'CLI'
        WinGetId            = 'GnuWin32.Wget'
        ChocoId             = 'wget'
        GitHubRepo          = 'mirror/wget'
        BinaryCheck         = 'wget.exe'
        Dependencies        = @()
        Provides            = @('wget.exe')
        Validation          = [PSCustomObject]@{
            Type  = 'Command'
            Value = 'wget.exe'
        }
    }

    # ====================================================
    # Network Diagnostics & Monitoring (CLI)
    # ====================================================
    [PSCustomObject]@{
        Name                = 'Globalping'
        Category            = $CategoryName
        CategoryDescription = $CategoryDescription
        ToolType            = 'CLI'
        WinGetId            = 'jsdelivr.globalping'
        ChocoId             = 'globalping'
        GitHubRepo          = 'jsdelivr/globalping'
        BinaryCheck         = 'globalping.exe'
        Dependencies        = @()
        Provides            = @('globalping.exe')
        Validation          = [PSCustomObject]@{
            Type  = 'Command'
            Value = 'globalping.exe'
        }
    }

    [PSCustomObject]@{
        Name                = 'dog'
        Category            = $CategoryName
        CategoryDescription = $CategoryDescription
        ToolType            = 'CLI'
        WinGetId            = 'ogham.dog'
        ChocoId             = 'dog'
        GitHubRepo          = 'ogham/dog'
        BinaryCheck         = 'dog.exe'
        Dependencies        = @()
        Provides            = @('dog.exe')
        Validation          = [PSCustomObject]@{
            Type  = 'Command'
            Value = 'dog.exe'
        }
    }

    # ====================================================
    # Security & TLS (CLI)
    # ====================================================
    [PSCustomObject]@{
        Name                = 'Trivy'
        Category            = $CategoryName
        CategoryDescription = $CategoryDescription
        ToolType            = 'CLI'
        WinGetId            = 'AquaSecurity.Trivy'
        ChocoId             = 'trivy'
        GitHubRepo          = 'aquasecurity/trivy'
        BinaryCheck         = 'trivy.exe'
        Dependencies        = @()
        Provides            = @('trivy.exe')
        Validation          = [PSCustomObject]@{
            Type  = 'Command'
            Value = 'trivy.exe'
        }
    }

    [PSCustomObject]@{
        Name                = 'Smallstep CLI'
        Category            = $CategoryName
        CategoryDescription = $CategoryDescription
        ToolType            = 'CLI'
        WinGetId            = 'smallstep.step'
        ChocoId             = 'step-cli'
        GitHubRepo          = 'smallstep/cli'
        BinaryCheck         = 'step.exe'
        Dependencies        = @()
        Provides            = @('step.exe')
        Validation          = [PSCustomObject]@{
            Type  = 'Command'
            Value = 'step.exe'
        }
    }

    # ====================================================
    # Traffic Inspection & Debugging (GUI)
    # ====================================================
    [PSCustomObject]@{
        Name                = 'HTTP Toolkit'
        Category            = $CategoryName
        CategoryDescription = $CategoryDescription
        ToolType            = 'TrafficInspection'
        WinGetId            = 'HTTPToolKit.HTTPToolKit'
        ChocoId             = $null
        GitHubRepo          = 'httptoolkit/httptoolkit'
        BinaryCheck         = 'httptoolkit.exe'
        Dependencies        = @()
        Provides            = @('httptoolkit.exe')
        Validation          = [PSCustomObject]@{
            Type  = 'Path'
            Value =@(
            Join-Path $env:LOCALAPPDATA 'Programs\HTTP Toolkit\HTTP Toolkit.exe'

            )
        }
    }

)

# ==============================
# Return tools array safely
# ==============================
@($Tools)
