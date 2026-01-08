# ----------------------------------------
# ToolValidator.ps1 - DevTools tool validation
# ----------------------------------------
# Requires PowerShell 7+
# StrictMode safe, CI safe, parser safe
# ----------------------------------------

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

#region ===== Normalize Single Tool =====

function ConvertTo-NormalizedTool {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [PSCustomObject]$Tool
    )

    # ------------------------------------------------------------
    # Required properties
    # ------------------------------------------------------------
    foreach ($prop in @('Name', 'Category')) {
        if (-not $Tool.PSObject.Properties[$prop] -or
            [string]::IsNullOrWhiteSpace($Tool.$prop)) {
            throw "Tool definition missing required property '$prop'"
        }
    }

    # ------------------------------------------------------------
    # Safe optional accessor
    # ------------------------------------------------------------
    function Get-Optional {
        param (
            [string]$Name,
            $Default = $null
        )
        if ($Tool.PSObject.Properties[$Name]) {
            return $Tool.$Name
        }
        return $Default
    }

    # ------------------------------------------------------------
    # Normalized object
    # ------------------------------------------------------------
    $normalized = [PSCustomObject]@{
        Name                = $Tool.Name.Trim()
        DisplayName         = (Get-Optional 'DisplayName' $Tool.Name).ToString().Trim()
        Category            = $Tool.Category.Trim()
        CategoryDescription = (Get-Optional 'CategoryDescription' '').ToString().Trim()

        # Installer selectors
        WinGetId           = Get-Optional 'WinGetId'
        ChocoId            = Get-Optional 'ChocoId'
        GitHubRepo         = Get-Optional 'GitHubRepo'
        GitHubAssetPattern = Get-Optional 'GitHubAssetPattern'

        InstallerScript    = Get-Optional 'InstallerScript'

        # Validation hooks
        BinaryCheck        = Get-Optional 'BinaryCheck'
        AltCheck           = Get-Optional 'AltCheck'

        # Behavior flags
        AddToPath          = [bool](Get-Optional 'AddToPath' $false)
        ChocoParams        = Get-Optional 'ChocoParams'

        # Preserve original
        Raw                = $Tool
    }

    return $normalized
}

#endregion

#region ===== Validate and Normalize Tool Array =====

function Validate-AndNormalizeTools {
    [CmdletBinding()]
    [OutputType([PSCustomObject[]])]
    param (
        [Parameter(Mandatory = $true)]
        [PSCustomObject[]]$Tools,

        [Parameter(Mandatory = $true)]
        [PSCustomObject]$Categories
    )

    $validatedTools = [System.Collections.Generic.List[object]]::new()
    $namesSeen = @{}

    foreach ($tool in $Tools) {
        if (-not $tool) { continue }

        # Normalize
        $normalized = ConvertTo-NormalizedTool -Tool $tool

        # Duplicate detection
        if ($namesSeen.ContainsKey($normalized.Name)) {
            throw "Duplicate tool name detected: '$($normalized.Name)'"
        }
        $namesSeen[$normalized.Name] = $true

        # Category validation
        if (-not $Categories.PSObject.Properties[$normalized.Category]) {
            throw "Tool '$($normalized.Name)' references unknown category '$($normalized.Category)'"
        }

        $validatedTools.Add($normalized)
    }

    return $validatedTools.ToArray()
}

#endregion
