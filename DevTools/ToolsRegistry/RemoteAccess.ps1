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

# ==============================
# Category metadata
# ==============================
$CategoryName        = 'RemoteAccess'
$CategoryDescription = 'Cross-platform remote desktop, remote access, and device management tools'

# ==============================
# Tool definitions
# ==============================
$Tools = @(

    # ====================================================
    # RustDesk
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
            Value = Join-Path $env:ProgramFiles 'RustDesk\rustdesk.exe'
        }
    }

    # ====================================================
    # Alternatives (Informational Only)
    # ====================================================
    # The following tools are NOT installed by DevTools.
    # They are listed to document the remote-access ecosystem
    # and help users evaluate architectural trade-offs.

    # ----------------------------------------------------
    # TigerVNC
    # Low-level VNC server and client.
    # Best for:
    # - Private LAN usage
    # - Lightweight GUI forwarding
    # Trade-offs:
    # - No encryption by default
    # - Manual security hardening required
    # https://github.com/TigerVNC/tigervnc

    # ----------------------------------------------------
    # Remmina
    # Multi-protocol remote desktop client.
    # Supports RDP, VNC, SSH, SPICE.
    # Best for:
    # - Managing many remote systems
    # - Mixed protocol environments
    # Trade-offs:
    # - Client-only
    # - Primarily Linux-focused
    # https://remmina.org/

    # ----------------------------------------------------
    # xrdp
    # RDP server for Linux systems.
    # Best for:
    # - Accessing Linux desktops from Windows RDP clients
    # Trade-offs:
    # - Linux-only server
    # - Desktop experience depends on DE and distro
    # https://github.com/neutrinolabs/xrdp

    # ----------------------------------------------------
    # Apache Guacamole
    # Browser-based remote desktop gateway.
    # Supports RDP, VNC, SSH via web UI.
    # Best for:
    # - Teams
    # - Zero-client environments
    # - Centralized access control
    # Trade-offs:
    # - Requires server deployment
    # - More infrastructure complexity
    # https://github.com/apache/guacamole-client

    # ----------------------------------------------------
    # MeshCentral
    # Full device management and remote support platform.
    # Best for:
    # - IT teams
    # - Fleet management
    # - Secure remote assistance
    # Trade-offs:
    # - Heavier than pure remote desktop tools
    # - Requires self-hosted server
    # https://github.com/Ylianst/MeshCentral
)

# ==============================
# Return tools array safely
# ==============================
@($Tools)
