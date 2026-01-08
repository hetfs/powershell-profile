<#
.SYNOPSIS
    Network and web-related CLI tools for Windows.

.DESCRIPTION
    Defines HTTP clients, file downloaders, network diagnostics,
    security scanners, certificate management, and traffic inspection tools.

    Returns a stable array of PSCustomObjects for DevTools installer
    and validator consumption.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# -----------------------------
# Category metadata
# -----------------------------
$CategoryName        = 'Network'
$CategoryDescription = 'Network, Web, HTTP, Security, and Traffic Inspection Tools'

# -----------------------------
# Tool definitions
# -----------------------------
$Tools = @(

    # ====================================================
    # HTTP & API Clients
    # ====================================================
    # [PSCustomObject]@{
    #     Name                = 'HTTPie CLI'
    #     Category            = $CategoryName
    #     ToolType            = 'HttpClient'
    #     CategoryDescription = $CategoryDescription
    #     WinGetId            = 'httpie.httpie'
    #     ChocoId             = 'httpie'
    #     GitHubRepo          = 'httpie/httpie'
    #     BinaryCheck         = 'http.exe'
    #     Dependencies        = @()
    #     Provides            = @('http.exe')
    #     Validation          = [PSCustomObject]@{ Type='Command'; Value='http.exe' }
    # }

    [PSCustomObject]@{
        Name                = 'curl'
        Category            = $CategoryName
        ToolType            = 'HttpClient'
        CategoryDescription = $CategoryDescription
        WinGetId            = 'curl.curl'
        ChocoId             = 'curl'
        GitHubRepo          = 'curl/curl'
        BinaryCheck         = 'curl.exe'
        Dependencies        = @()
        Provides            = @('curl.exe')
        Validation          = [PSCustomObject]@{ Type='Command'; Value='curl.exe' }
    }

    [PSCustomObject]@{
        Name                = 'wget'
        Category            = $CategoryName
        ToolType            = 'FileDownloader'
        CategoryDescription = $CategoryDescription
        WinGetId            = 'GnuWin32.Wget'
        ChocoId             = 'wget'
        GitHubRepo          = 'mirror/wget'
        BinaryCheck         = 'wget.exe'
        Dependencies        = @()
        Provides            = @('wget.exe')
        Validation          = [PSCustomObject]@{ Type='Command'; Value='wget.exe' }
    }

    # ====================================================
    # Network Diagnostics & Monitoring
    # ====================================================
    [PSCustomObject]@{
        Name                = 'Globalping'
        Category            = $CategoryName
        ToolType            = 'NetworkMonitoring'
        CategoryDescription = $CategoryDescription
        WinGetId            = 'jsdelivr.globalping'
        ChocoId             = 'globalping'
        GitHubRepo          = 'jsdelivr/globalping'
        BinaryCheck         = 'globalping.exe'
        Dependencies        = @()
        Provides            = @('globalping.exe')
        Validation          = [PSCustomObject]@{ Type='Command'; Value='globalping.exe' }
    }

    [PSCustomObject]@{
        Name                = 'dog'
        Category            = $CategoryName
        ToolType            = 'DnsClient'
        CategoryDescription = $CategoryDescription
        WinGetId            = 'ogham.dog'
        ChocoId             = 'dog'
        GitHubRepo          = 'ogham/dog'
        BinaryCheck         = 'dog.exe'
        Dependencies        = @()
        Provides            = @('dog.exe')
        Validation          = [PSCustomObject]@{ Type='Command'; Value='dog.exe' }
    }

    # ====================================================
    # Security & TLS
    # ====================================================
    [PSCustomObject]@{
        Name                = 'Trivy'
        Category            = $CategoryName
        ToolType            = 'SecurityScanner'
        CategoryDescription = $CategoryDescription
        WinGetId            = 'AquaSecurity.Trivy'
        ChocoId             = 'trivy'
        GitHubRepo          = 'aquasecurity/trivy'
        BinaryCheck         = 'trivy.exe'
        Dependencies        = @()
        Provides            = @('trivy.exe')
        Validation          = [PSCustomObject]@{ Type='Command'; Value='trivy.exe' }
    }

    [PSCustomObject]@{
        Name                = 'Smallstep CLI'
        Category            = $CategoryName
        ToolType            = 'CertificateManagement'
        CategoryDescription = $CategoryDescription
        WinGetId            = 'smallstep.step'
        ChocoId             = 'step-cli'
        GitHubRepo          = 'smallstep/cli'
        BinaryCheck         = 'step.exe'
        Dependencies        = @()
        Provides            = @('step.exe')
        Validation          = [PSCustomObject]@{ Type='Command'; Value='step.exe' }
    }

    # ====================================================
    # Traffic Inspection & Debugging
    # # ====================================================
    # [PSCustomObject]@{
    #     Name                = 'HTTP Toolkit'
    #     Category            = $CategoryName
    #     ToolType            = 'TrafficInspection'
    #     CategoryDescription = $CategoryDescription
    #     WinGetId            = $null
    #     ChocoId             = $null
    #     GitHubRepo          = 'httptoolkit/httptoolkit'
    #     BinaryCheck         = 'httptoolkit.exe'
    #     Dependencies        = @()
    #     Provides            = @('httptoolkit.exe')
    #     Validation          = [PSCustomObject]@{ Type='Command'; Value='httptoolkit.exe' }
    # }
)

# -----------------------------
# Return tools array safely
# -----------------------------
@($Tools)
