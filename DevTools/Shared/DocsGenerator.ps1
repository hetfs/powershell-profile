#Requires -Version 7.0
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Generate-DevToolsDocs {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Low')]
    param(
        [Parameter(Mandatory)]
        [PSCustomObject[]]$Tools,

        [Parameter(Mandatory)]
        [string]$OutputPath,

        [switch]$IncludeExamples,
        [switch]$GenerateJson,

        [hashtable]$Categories = @{}
    )

    begin {
        $OutputPath = $PSCmdlet.GetUnresolvedProviderPathFromPSPath($OutputPath)

        $DocsRoot     = Join-Path $OutputPath 'docs'
        $ToolsDocsDir = Join-Path $DocsRoot 'tools'
        $JsonDocsDir  = Join-Path $DocsRoot 'json'
        $ExamplesDir  = Join-Path $DocsRoot 'examples'
    }

    process {
        if ($Tools.Count -eq 0) {
            Write-Warning 'No tools provided'
            return
        }

        if ($WhatIfPreference) {
            Write-Host "[WHATIF] Would generate docs in $DocsRoot" -ForegroundColor Cyan
            return
        }

        if (-not $PSCmdlet.ShouldProcess(
            "DevTools Documentation",
            "Generate documentation",
            "Confirm documentation generation"
        )) {
            return
        }

        foreach ($dir in @($DocsRoot, $ToolsDocsDir, $JsonDocsDir, $ExamplesDir)) {
            if (-not (Test-Path $dir)) {
                New-Item -ItemType Directory -Path $dir -Force | Out-Null
            }
        }

        $normalizedTools = $Tools |
            Where-Object { $_.Name -and $_.Category } |
            Sort-Object Category, Name

        $toolsByCategory = $normalizedTools |
            Group-Object Category |
            Sort-Object Name

        # Categories overview
        $categoriesContent = @(
            '# Tool Categories',
            '',
            '| Category | Tool Count | Description |',
            '|----------|------------|-------------|'
        )

        foreach ($group in $toolsByCategory) {
            $desc = $Categories[$group.Name] ?? "Tools for $($group.Name)"
            $categoriesContent += "| $($group.Name) | $($group.Count) | $desc |"
        }

        Set-Content (Join-Path $DocsRoot 'categories.md') $categoriesContent -Encoding UTF8

        # Per-tool docs
        foreach ($tool in $normalizedTools) {
            $slug = Get-ToolSlug -Tool $tool
            $path = Join-Path $ToolsDocsDir "$slug.md"

            $content = Generate-ToolDocumentation -Tool $tool -Categories $Categories
            Set-Content $path $content -Encoding UTF8

            if ($GenerateJson) {
                Set-Content (
                    Join-Path $JsonDocsDir "$slug.json"
                ) ($tool | ConvertTo-Json -Depth 6) -Encoding UTF8
            }
        }

        # README
        $readme = Generate-Readme `
            -ToolsByCategory $toolsByCategory `
            -ToolCount $normalizedTools.Count `
            -Categories $Categories

        Set-Content (Join-Path $DocsRoot 'README.md') $readme -Encoding UTF8

        if ($IncludeExamples) {
            Generate-UsageExamples `
                -Tools $normalizedTools `
                -ExamplesDir $ExamplesDir `
                -Categories $Categories
        }
    }
}

function Get-ToolSlug {
    [CmdletBinding()]
    param([PSCustomObject]$Tool)

    ("$($Tool.Category)-$($Tool.Name)" `
        -replace '[^\w\s-]', '' `
        -replace '\s+', '-').ToLowerInvariant()
}

function Generate-ToolDocumentation {
    [CmdletBinding()]
    param(
        [PSCustomObject]$Tool,
        [hashtable]$Categories = @{}
    )

    $content = @(
        "# $($Tool.Name)",
        '',
        '## Basic Information',
        '',
        '| Property | Value |',
        '|----------|-------|',
        "| Name | $($Tool.Name) |",
        "| Category | $($Tool.Category) |",
        "| Tool Type | $($Tool.ToolType) |",
        ''
    )

    if ($Tool.Description) {
        $content += @('## Description', '', $Tool.Description, '')
    }

    $content += @('## Installation Sources', '')

    $hasSource = $false
    if ($Tool.WinGetId) {
        $content += "- WinGet: $($Tool.WinGetId)"
        $hasSource = $true
    }
    if ($Tool.ChocoId) {
        $content += "- Chocolatey: $($Tool.ChocoId)"
        $hasSource = $true
    }
    if ($Tool.GitHubRepo) {
        $content += "- GitHub: https://github.com/$($Tool.GitHubRepo)"
        $hasSource = $true
    }

    if (-not $hasSource) {
        $content += 'Manual installation required'
    }

    $content += @('', '## Verification', '')

    if ($Tool.BinaryCheck) {
        $content += @(
            "Binary check: $($Tool.BinaryCheck)",
            '```powershell',
            "Get-Command $($Tool.BinaryCheck)",
            '```'
        )
    }
    else {
        $content += 'No binary check specified'
    }

    $content += @(
        '',
        '---',
        "*Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')*"
    )

    return $content
}

function Generate-Readme {
    [CmdletBinding()]
    param(
        [System.Management.Automation.GroupInfo[]]$ToolsByCategory,
        [int]$ToolCount,
        [hashtable]$Categories = @{}
    )

    $content = @(
        '# DevTools Documentation',
        '',
        "- Total tools: $ToolCount",
        "- Categories: $($ToolsByCategory.Count)",
        ''
    )

    foreach ($group in $ToolsByCategory) {
        $desc = $Categories[$group.Name] ?? "$($group.Count) tools"
        $content += @(
            "## $($group.Name)",
            '',
            $desc,
            ''
        )
    }

    return $content
}

function Generate-UsageExamples {
    [CmdletBinding()]
    param(
        [PSCustomObject[]]$Tools,
        [string]$ExamplesDir,
        [hashtable]$Categories = @{}
    )

    $toolsByCategory = $Tools | Group-Object Category | Sort-Object Name

    foreach ($group in $toolsByCategory) {
        $categoryName = $group.Name
        $file = Join-Path $ExamplesDir "$categoryName-examples.md"

        $content = @("# $categoryName Examples", '')

        foreach ($tool in $group.Group | Sort-Object Name) {
            $content += @(
                "## $($tool.Name)",
                '',
                '```powershell'
            )

            if ($tool.BinaryCheck) {
                $content += "$($tool.BinaryCheck) --help"
            }
            else {
                $content += '# No binary defined'
            }

            $content += '```'
        }

        Set-Content $file $content -Encoding UTF8
        Write-Verbose "Generated examples for ${categoryName}: ${file}"
    }

    $general = Join-Path $ExamplesDir 'general-examples.md'
    Set-Content $general @(
        '# General Examples',
        '',
        '```powershell',
        '.\DevTools.ps1 -WhatIf',
        '```'
    ) -Encoding UTF8

    Write-Verbose "Generated general examples: ${general}"
}

function Test-ToolDocumentation {
    [CmdletBinding()]
    param([PSCustomObject[]]$Tools)

    $result = [PSCustomObject]@{
        IsValid     = $true
        Issues      = [System.Collections.Generic.List[string]]::new()
        Warnings    = [System.Collections.Generic.List[string]]::new()
        ToolCount   = $Tools.Count
        ValidTools  = 0
    }

    foreach ($tool in $Tools) {
        $hasIssue = $false

        if (-not $tool.Name) {
            $result.Issues.Add('Tool missing Name')
            $hasIssue = $true
        }

        if (-not $tool.Category) {
            $result.Issues.Add("Tool '$($tool.Name)' missing Category")
            $hasIssue = $true
        }

        if (-not ($tool.WinGetId -or $tool.ChocoId -or $tool.GitHubRepo)) {
            $result.Warnings.Add(
                "Tool '$($tool.Name)' has no installation source defined"
            )
        }

        if (-not $hasIssue) {
            $result.ValidTools++
        }
        else {
            $result.IsValid = $false
        }
    }

    return $result
}
