<#
.SYNOPSIS
    Cross-platform remote desktop and remote access tools.

.DESCRIPTION
    Defines remote access solutions with a clear trust and deployment model.

    This category intentionally installs only RustDesk by default.
    Other tools are documented as alternatives to clarify the remote
    access landscape and help users make informed architectural choices.

    Themes covered:
    - Self-hosted vs managed services
    - GUI vs browser-based access
    - Individual vs team-oriented workflows
    - Security, privacy, and control trade-offs
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# ------------------------------------------------
# Category metadata
# ------------------------------------------------
$CategoryName         = 'RemoteAccess'
$CategoryDescription = 'Cross-platform remote desktop, remote access, and device management tools.'

# ------------------------------------------------
# Tool definitions
# ------------------------------------------------
$Tools = @(

    # ====================================================
    # RustDesk
    # ----------------------------------------------------
    # Theme: Self-hosted, private remote desktop
    # Positioning:
    # - Open-source alternative to TeamViewer and AnyDesk
    # - Full control over infrastructure and data
    # - End-to-end encrypted connections
    # Best for:
    # - Developers
    # - Privacy-conscious teams
    # - Cross-platform personal or enterprise remote access
    # Trade-offs:
    # - Requires minimal setup for self-hosting advanced features
    # ====================================================
[PSCustomObject]@{
    Name                = 'RustDesk'
    Category            = $CategoryName
    CategoryDescription = $CategoryDescription
    ToolType            = 'RemoteDesktop'

    WinGetId            = 'RustDesk.RustDesk'
    ChocoId             = 'rustdesk'
    GitHubRepo          = 'rustdesk/rustdesk'

    BinaryCheck         = 'rustdesk.exe'
    Dependencies        = @()
    Provides            = @('rustdesk.exe')

    Validation          = [PSCustomObject]@{
        Type  = 'Path'
        Value = "$env:ProgramFiles\RustDesk\rustdesk.exe"
    }
}

    # ====================================================
    # Alternatives (Informational Only)
    # ----------------------------------------------------
    # The following tools are NOT installed by DevTools.
    # They are listed to document the remote-access ecosystem
    # and clarify when RustDesk may or may not be the best fit.
    # ====================================================

    # ----------------------------------------------------
    # TigerVNC
    # Theme: Low-level, direct VNC access
    # Best for:
    # - Private LAN environments
    # - Lightweight GUI forwarding
    # Trade-offs:
    # - No built-in encryption by default
    # - Manual security hardening required
    # https://github.com/TigerVNC/tigervnc
    # ----------------------------------------------------

    # ----------------------------------------------------
    # Remmina
    # Theme: Multi-protocol client hub
    # Best for:
    # - Developers managing many servers
    # - Mixed environments (RDP, VNC, SSH, SPICE)
    # Trade-offs:
    # - Client-only
    # - Primarily Linux-focused
    # https://remmina.org/
    # ----------------------------------------------------

    # ----------------------------------------------------
    # xrdp
    # Theme: Native Linux RDP integration
    # Best for:
    # - Accessing Linux desktops from Windows RDP clients
    # Trade-offs:
    # - Linux-only server
    # - Desktop experience varies by distro and DE
    # https://github.com/neutrinolabs/xrdp
    # ----------------------------------------------------

    # ----------------------------------------------------
    # Apache Guacamole
    # Theme: Browser-based remote desktop gateway
    # Best for:
    # - Teams
    # - Zero-client environments
    # - Centralized access control
    # Trade-offs:
    # - Requires server-side deployment
    # - More infrastructure complexity
    # https://github.com/apache/guacamole-client
    # ----------------------------------------------------

    # ----------------------------------------------------
    # MeshCentral
    # Theme: Full device management and remote support
    # Best for:
    # - IT teams
    # - Secure remote assistance
    # - Fleet management
    # Trade-offs:
    # - Heavier than pure remote desktop tools
    # - Requires self-hosted server
    # https://github.com/Ylianst/MeshCentral
    # ----------------------------------------------------
)

# ------------------------------------------------
# Return tools array safely for DevTools
# ------------------------------------------------
@($Tools)
