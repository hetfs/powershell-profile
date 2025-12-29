@(
    # ====================================================
    # Network & Web Tools
    # ====================================================

    [PSCustomObject]@{
        Name        = "HTTPie CLI"
        Category    = "Network"
        WinGetId    = "httpie.httpie"
        ChocoId     = "httpie"
        GitHubRepo  = "httpie/httpie"
        BinaryCheck = "http.exe"
        Dependencies= @()
        Purpose     = "User-friendly command-line HTTP client for APIs"
    },

    [PSCustomObject]@{
        Name        = "HTTP Toolkit"
        Category    = "Network"
        WinGetId    = $null
        ChocoId     = $null
        GitHubRepo  = "httptoolkit/httptoolkit"
        BinaryCheck = "httptoolkit.exe"
        Dependencies= @()
        Purpose     = "Debug, test, and intercept HTTP(S) traffic"
    },

    [PSCustomObject]@{
        Name        = "Globalping"
        Category    = "Network"
        WinGetId    = "jsdelivr.globalping"
        ChocoId     = "globalping"
        GitHubRepo  = "jsdelivr/globalping"
        BinaryCheck = "globalping.exe"
        Dependencies= @()
        Purpose     = "Monitor uptime and latency from multiple global locations"
    },

    [PSCustomObject]@{
        Name        = "dog"
        Category    = "Network"
        WinGetId    = "ogham.dog"
        ChocoId     = "dog"
        GitHubRepo  = "ogham/dog"
        BinaryCheck = "dog.exe"
        Dependencies= @()
        Purpose     = "Modern command-line DNS client"
    },

    [PSCustomObject]@{
        Name        = "Trivy"
        Category    = "Network"
        WinGetId    = "AquaSecurity.Trivy"
        ChocoId     = "trivy"
        GitHubRepo  = "aquasecurity/trivy"
        BinaryCheck = "trivy.exe"
        Dependencies= @()
        Purpose     = "Security scanner for containers, filesystems, and repositories"
    },

    [PSCustomObject]@{
        Name        = "Smallstep CLI"
        Category    = "Network"
        WinGetId    = "smallstep.step"
        ChocoId     = "step-cli"
        GitHubRepo  = "smallstep/cli"
        BinaryCheck = "step.exe"
        Dependencies= @()
        Purpose     = "Certificate management and automation CLI for TLS"
    },

    [PSCustomObject]@{
        Name        = "wget"
        Category    = "Network"
        WinGetId    = "GnuWin32.Wget"
        ChocoId     = "wget"
        GitHubRepo  = "mimoo/wget-win"
        BinaryCheck = "wget.exe"
        Dependencies= @()
        Purpose     = "Download files from the web via HTTP/HTTPS/FTP"
    },

    [PSCustomObject]@{
        Name        = "curl"
        Category    = "Network"
        WinGetId    = "curl.curl"
        ChocoId     = "curl"
        GitHubRepo  = "curl/curl"
        BinaryCheck = "curl.exe"
        Dependencies= @()
        Purpose     = "Transfer data from or to a server, supports multiple protocols"
    }
)
