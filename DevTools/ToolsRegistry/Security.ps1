<#
.SYNOPSIS
    Security, cryptography, secrets management, and encryption tools.

.DESCRIPTION
    Defines security-focused CLI tools for encryption, key management,
    secret storage, and secure communication.

    Validation strategy:
    - Command validation is used when installers reliably add binaries to PATH
    - Path validation is used when Windows installers are inconsistent

    Returns a stable array of PSCustomObjects for DevTools installer
    and validator consumption.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# ------------------------------------------------
# Category metadata
# ------------------------------------------------
$CategoryName        = 'Security'
$CategoryDescription = 'Security, cryptography, secrets management, and encryption tools.'

# ------------------------------------------------
# Tool definitions
# ------------------------------------------------
$Tools = @(

    # ====================================================
    # Secure Shell
    # ====================================================
    # OpenSSH client for secure remote access, file transfer,
    # and automation over SSH.
    # Windows optional feature reliably exposes ssh.exe in PATH.
    [PSCustomObject]@{
        Name                = 'OpenSSH'
        Category            = $CategoryName
        CategoryDescription = $CategoryDescription
        ToolType            = 'SSHClient'
        WinGetId            = 'OpenSSH.Client'
        ChocoId             = $null
        GitHubRepo          = 'PowerShell/openssh-portable'
        BinaryCheck         = 'ssh.exe'
        Dependencies        = @()
        Provides            = @('ssh.exe', 'scp.exe')
        Validation          = [PSCustomObject]@{
            Type  = 'Command'
            Value = 'ssh.exe'
        }
    }

    # ====================================================
    # Cryptography Foundations
    # ====================================================
    # OpenSSL provides TLS, certificate management,
    # hashing, and low-level crypto primitives.
    # Windows installers do not reliably update PATH,
    # so explicit path validation is required.
    [PSCustomObject]@{
        Name                = 'OpenSSL'
        Category            = $CategoryName
        CategoryDescription = $CategoryDescription
        ToolType            = 'CryptoLibrary'
        WinGetId            = 'ShiningLight.OpenSSL'
        ChocoId             = 'openssl'
        GitHubRepo          = 'openssl/openssl'
        BinaryCheck         = 'openssl.exe'
        Dependencies        = @()
        Provides            = @('openssl.exe')
        Validation          = [PSCustomObject]@{
            Type  = 'Path'
            Value = @(
                "$env:ProgramFiles\OpenSSL-Win64\bin\openssl.exe",
                "$env:ProgramFiles(x86)\OpenSSL-Win32\bin\openssl.exe"
            )
        }
    }

    # ====================================================
    # Secrets Management
    # ====================================================
    # HashiCorp Vault CLI for centralized secrets,
    # credentials, and PKI management.
    # CLI installers reliably expose vault.exe in PATH.
    [PSCustomObject]@{
        Name                = 'Vault'
        Category            = $CategoryName
        CategoryDescription = $CategoryDescription
        ToolType            = 'SecretsManager'
        WinGetId            = 'Hashicorp.Vault'
        ChocoId             = 'vault'
        GitHubRepo          = 'hashicorp/vault'
        BinaryCheck         = 'vault.exe'
        Dependencies        = @()
        Provides            = @('vault.exe')
        Validation          = [PSCustomObject]@{
            Type  = 'Command'
            Value = 'vault.exe'
        }
    }

    # ====================================================
    # Modern Encryption (age / rage)
    # ====================================================
    # age is a simple, modern file encryption tool
    # designed as a safer alternative to GPG.
    [PSCustomObject]@{
        Name                = 'age'
        Category            = $CategoryName
        CategoryDescription = $CategoryDescription
        ToolType            = 'Encryption'
        WinGetId            = 'FiloSottile.age'
        ChocoId             = 'age'
        GitHubRepo          = 'FiloSottile/age'
        BinaryCheck         = 'age.exe'
        Dependencies        = @()
        Provides            = @('age.exe')
        Validation          = [PSCustomObject]@{
            Type  = 'Command'
            Value = 'age.exe'
        }
    }

    # rage is a Rust implementation compatible with age,
    # commonly used by sops and modern secret workflows.
    [PSCustomObject]@{
        Name                = 'rage'
        Category            = $CategoryName
        CategoryDescription = $CategoryDescription
        ToolType            = 'Encryption'
        WinGetId            = 'str4d.rage'
        ChocoId             = 'rage'
        GitHubRepo          = 'str4d/rage'
        BinaryCheck         = 'rage.exe'
        Dependencies        = @()
        Provides            = @('rage.exe')
        Validation          = [PSCustomObject]@{
            Type  = 'Command'
            Value = 'rage.exe'
        }
    }

    # ====================================================
    # Classic Cryptography (GnuPG)
    # ====================================================
    # GnuPG provides OpenPGP encryption, signing,
    # and key management.
    # Windows installers often skip PATH updates,
    # so path-based validation is required.
    [PSCustomObject]@{
        Name                = 'GnuPG'
        Category            = $CategoryName
        CategoryDescription = $CategoryDescription
        ToolType            = 'CryptoSuite'
        WinGetId            = 'GnuPG.GnuPG'
        ChocoId             = 'gnupg'
        GitHubRepo          = 'gpg/gnupg'
        BinaryCheck         = 'gpg.exe'
        Dependencies        = @()
        Provides            = @('gpg.exe', 'gpg-agent.exe')
        Validation          = [PSCustomObject]@{
            Type  = 'Path'
            Value = @(
                "$env:ProgramFiles\GnuPG\bin\gpg.exe",
                "$env:ProgramFiles(x86)\GnuPG\bin\gpg.exe"
            )
        }
    }

    # ====================================================
    # Secrets Encryption & Git Integration
    # ====================================================
    # sops encrypts structured data files using
    # age, GPG, or cloud KMS backends.
    [PSCustomObject]@{
        Name                = 'sops'
        Category            = $CategoryName
        CategoryDescription = $CategoryDescription
        ToolType            = 'SecretsEncryption'
        WinGetId            = 'Mozilla.SOPS'
        ChocoId             = 'sops'
        GitHubRepo          = 'getsops/sops'
        BinaryCheck         = 'sops.exe'
        Dependencies        = @()
        Provides            = @('sops.exe')
        Validation          = [PSCustomObject]@{
            Type  = 'Command'
            Value = 'sops.exe'
        }
    }

)

# ------------------------------------------------
# Return tools array safely
# ------------------------------------------------
@($Tools)
