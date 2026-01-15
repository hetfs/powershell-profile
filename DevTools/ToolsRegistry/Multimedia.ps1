<#
.SYNOPSIS
    Aggregates all Multimedia tools for DevTools.

.DESCRIPTION
    Loads and aggregates all Multimedia subcategory scripts into a single
    array of PSCustomObjects for DevTools consumption.

    Subcategories:
    - ImageEditors.ps1
    - AudioEditors.ps1
    - VideoTools.ps1
    - Downloaders.ps1
    - MediaUtilities.ps1
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# ==============================
# Aggregated Multimedia tools
# ==============================
$MultimediaTools = @()

# ==============================
# Registered Multimedia subcategories
# ==============================
$Subcategories = @(
    'ImageEditors.ps1',
    'AudioEditors.ps1',
    'VideoTools.ps1',
    'Downloaders.ps1',
    'MediaUtilities.ps1'
)

# ==============================
# Helper: Force result to array
# ==============================
function As-Array {
    param([object]$InputObject)

    if ($null -eq $InputObject) {
        @()
    }
    elseif ($InputObject -is [System.Collections.IEnumerable] -and $InputObject -isnot [string]) {
        @($InputObject)
    }
    else {
        @($InputObject)
    }
}

# ==============================
# Load subcategories
# ==============================
foreach ($subcategory in $Subcategories) {
    $path = Join-Path -Path $PSScriptRoot -ChildPath $subcategory

    if (-not (Test-Path -Path $path)) {
        Write-Warning "Multimedia subcategory not found: $subcategory"
        continue
    }

    try {
        $result = & $path
        $result = As-Array $result

        if ($result.Count -gt 0) {
            $MultimediaTools += $result
        }
    } catch {
        Write-Warning "Failed to load Multimedia subcategory '$subcategory': $($_.Exception.Message)"
    }
}

# ==============================
# Flatten and return safe array
# ==============================
@($MultimediaTools)
