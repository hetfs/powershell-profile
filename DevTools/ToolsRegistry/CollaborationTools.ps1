<#
.SYNOPSIS
    Developer collaboration and communication tools.

.DESCRIPTION
    Defines real-time and async collaboration platforms for
    teams, communities, open-source projects, and private work.

    Each tool is commented with a precise recommendation
    describing when and why it should be used.

    Returns a stable array of PSCustomObjects for DevTools
    installer and validator consumption.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# ------------------------------------------------
# Category metadata
# ------------------------------------------------
$CategoryName        = 'CollaborationTools'
$CategoryDescription = 'Developer collaboration, communication, and community platforms.'

# ------------------------------------------------
# Tool definitions
# ------------------------------------------------
$Tools = @(

# ====================================================
# Terminal-native | Power users
# Recommended for SSH environments, servers,
# and distraction-free IRC workflows.
# ====================================================
[PSCustomObject]@{
    Name                = 'HexChat'
    Category            = $CategoryName
    CategoryDescription = $CategoryDescription
    ToolType            = 'ChatClient'
    WinGetId            = 'HexChat.HexChat'
    ChocoId             = 'hexchat' # Optional fallback
    GitHubRepo          = 'https://hexchat.github.io/'
    # Correct BinaryCheck path
    BinaryCheck         = 'C:\Program Files\HexChat\hexchat.exe'
    Dependencies        = @()
    Provides            = @('hexchat.exe')
    Validation          = [PSCustomObject]@{
        Type  = 'Path'
        Value = 'C:\Program Files\HexChat\hexchat.exe'
    }
}

# ====================================================
# Team-first | Real-time | Corporate
# Recommended for internal company communication,
# structured teams, integrations, and compliance.
# ====================================================
[PSCustomObject]@{
    Name                = 'Slack'
    Category            = $CategoryName
    CategoryDescription = $CategoryDescription
    ToolType            = 'TeamCollaboration'
    WinGetId            = 'SlackTechnologies.Slack'
    ChocoId             = 'slack'
    GitHubRepo          = $null
    # Dynamic BinaryCheck using USERPROFILE
    BinaryCheck         = Join-Path $env:LOCALAPPDATA 'slack\slack.exe'
    Dependencies        = @()
    Provides            = @('slack.exe')
    Validation          = [PSCustomObject]@{
        Type  = 'Path'
        Value = Join-Path $env:LOCALAPPDATA 'slack\slack.exe'
    }
}

# ====================================================
# Community-first | Real-time | Informal
# Recommended for developer communities, OSS projects,
# public servers, and mixed voice + text workflows.
# ====================================================
[PSCustomObject]@{
    Name                = 'Discord'
    Category            = $CategoryName
    CategoryDescription = $CategoryDescription
    ToolType            = 'CommunityCollaboration'
    WinGetId            = 'Discord.Discord'
    ChocoId             = 'discord'
    GitHubRepo          = $null
    # Dynamic BinaryCheck using LOCALAPPDATA
    BinaryCheck         = Join-Path $env:LOCALAPPDATA 'Discord\Update.exe'
    Dependencies        = @()
    Provides            = @('Discord.exe')
    Validation          = [PSCustomObject]@{
        Type  = 'Path'
        Value = Join-Path $env:LOCALAPPDATA 'Discord\Update.exe'
    }
}

# ====================================================
# Video-first | Meetings | Remote work
# Recommended for standups, reviews, workshops,
# interviews, and screen-sharing sessions.
# ====================================================
[PSCustomObject]@{
    Name                = 'Zoom'
    Category            = $CategoryName
    CategoryDescription = $CategoryDescription
    ToolType            = 'VideoConferencing'
    WinGetId            = 'Zoom.Zoom'
    ChocoId             = 'zoom'
    GitHubRepo          = ''
    # Dynamic BinaryCheck using ProgramFiles
    BinaryCheck         = Join-Path $env:ProgramFiles 'Zoom\bin\Zoom.exe'
    Dependencies        = @()
    Provides            = @('Zoom.exe')
    Validation          = [PSCustomObject]@{
        Type  = 'Path'
        Value = Join-Path $env:ProgramFiles 'Zoom\bin\Zoom.exe'
    }
}

# ====================================================
# Open-source | Self-hosted | Enterprise-grade
# Recommended when data ownership, compliance,
# and on-prem or private cloud hosting matter.
# ====================================================
[PSCustomObject]@{
    Name                = 'Mattermost'
    Category            = $CategoryName
    CategoryDescription = $CategoryDescription
    ToolType            = 'OpenSourceCollaboration'
    WinGetId            = 'Mattermost.MattermostDesktop'
    ChocoId             = 'mattermost-desktop'
    GitHubRepo          = 'mattermost/mattermost'
    BinaryCheck         = Join-Path $env:LOCALAPPDATA 'Programs\mattermost-desktop\Mattermost.exe'
    Dependencies        = @()
    Provides            = @('Mattermost.exe')
    Validation          = [PSCustomObject]@{
        Type  = 'Path'
        Value = Join-Path $env:LOCALAPPDATA 'Programs\mattermost-desktop\Mattermost.exe'
    }
}

# ====================================================
# Open-source | Community & Self-hosted
# Recommended for teams that want Slack-like UX
# with full backend control.
# ====================================================
[PSCustomObject]@{
    Name                = 'Rocket.Chat'
    Category            = $CategoryName
    CategoryDescription = $CategoryDescription
    ToolType            = 'OpenSourceCollaboration'
    WinGetId            = 'RocketChat.RocketChat'
    ChocoId             = 'rocketchat'
    GitHubRepo          = 'RocketChat/Rocket.Chat'
    BinaryCheck         = Join-Path $env:LOCALAPPDATA 'Programs\Rocket.Chat\Rocket.Chat.exe'
    Dependencies        = @()
    Provides            = @('Rocket.Chat.exe')
    Validation          = [PSCustomObject]@{
        Type  = 'Path'
        Value = Join-Path $env:LOCALAPPDATA 'Programs\Rocket.Chat\Rocket.Chat.exe'
    }
}

# ====================================================
# Async-first | Structured conversations
# Recommended for distributed teams, fewer meetings,
# long-lived discussions, and high signal-to-noise.
# ====================================================
[PSCustomObject]@{
    Name                = 'Zulip'
    Category            = $CategoryName
    CategoryDescription = $CategoryDescription
    ToolType            = 'AsyncFirstCollaboration'
    WinGetId            = 'Zulip.Zulip'
    ChocoId             = 'zulip'
    GitHubRepo          = 'zulip/zulip'
    BinaryCheck         = Join-Path $env:LOCALAPPDATA 'Programs\Zulip\Zulip.exe'
    Dependencies        = @()
    Provides            = @('Zulip.exe')
    Validation          = [PSCustomObject]@{
        Type  = 'Path'
        Value = Join-Path $env:LOCALAPPDATA 'Programs\Zulip\Zulip.exe'
    }
}

# ====================================================
# Privacy-first | Decentralized | Encrypted
# Recommended for secure communication, federated
# networks, and long-term privacy.
# ====================================================
[PSCustomObject]@{
    Name                = 'Element'
    Category            = $CategoryName
    CategoryDescription = $CategoryDescription
    ToolType            = 'DecentralizedCollaboration'
    WinGetId            = 'Element.Element'
    ChocoId             = 'element-desktop'
    GitHubRepo          = 'element-hq/element-web'
    BinaryCheck         = Join-Path $env:LOCALAPPDATA 'element-desktop\Element.exe'
    Dependencies        = @()
    Provides            = @('Element.exe')
    Validation          = [PSCustomObject]@{
        Type  = 'Path'
        Value = Join-Path $env:LOCALAPPDATA 'element-desktop\Element.exe'
    }
}

)

# ------------------------------------------------
# Return tools array safely
# ------------------------------------------------
@($Tools)
