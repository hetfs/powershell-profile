#Requires -Version 7.0
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

<#
.SYNOPSIS
    Resolves tool dependencies into a deterministic installation order.

.DESCRIPTION
    Performs topological sorting of tool dependencies using Kahn's algorithm.
    Detects missing, duplicate, self, and circular dependencies.

.PARAMETER Tools
    Array of PSCustomObjects representing tools.

.PARAMETER SkipMissingDependencies
    Skip missing dependencies instead of throwing.

.OUTPUTS
    PSCustomObject[]
#>
function Resolve-ToolDependencies {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Low')]
    param(
        [Parameter(Mandatory)][ValidateNotNullOrEmpty()]
        [PSCustomObject[]] $Tools,

        [Alias('SkipMissing')]
        [switch] $SkipMissingDependencies
    )

    begin { Write-Verbose '[DependencyResolver] Initializing' }

    process {
        if ($Tools.Count -eq 0) { return @() }

        if (-not $PSCmdlet.ShouldProcess("$($Tools.Count) tools", 'Resolve tool dependencies')) {
            return $Tools
        }

        # ------------------------------------------------------------
        # Index tools by Name (deduplicate)
        # ------------------------------------------------------------
        $toolIndex = @{}
        foreach ($tool in $Tools) {
            if (-not $tool.Name) { continue }
            $name = $tool.Name.Trim()
            if ([string]::IsNullOrWhiteSpace($name)) { continue }

            if ($toolIndex.ContainsKey($name)) {
                Write-Warning "Duplicate tool '$name' detected. First occurrence retained."
                continue
            }

            # Ensure Dependencies property exists and is an array of strings
            if (-not $tool.PSObject.Properties['Dependencies']) {
                $tool | Add-Member -NotePropertyName Dependencies -NotePropertyValue @() -Force
            }

            $tool.Dependencies = @($tool.Dependencies) |
                                 Where-Object { $_ -is [string] -and $_.Trim() } |
                                 ForEach-Object { $_.Trim() }

            $toolIndex[$name] = $tool
        }

        if ($toolIndex.Count -eq 0) {
            Write-Warning 'No valid tools indexed'
            return @()
        }

        # ------------------------------------------------------------
        # Build dependency graph
        # ------------------------------------------------------------
        $graph    = @{}
        $inDegree = @{}
        foreach ($name in $toolIndex.Keys) {
            $graph[$name]    = [System.Collections.Generic.List[string]]::new()
            $inDegree[$name] = 0
        }

        foreach ($name in $toolIndex.Keys) {
            foreach ($dep in $toolIndex[$name].Dependencies) {
                if ($dep -eq $name) {
                    Write-Warning "Self-dependency ignored for '$name'"
                    continue
                }

                if (-not $toolIndex.ContainsKey($dep)) {
                    $msg = "Tool '$name' depends on missing tool '$dep'"
                    if ($SkipMissingDependencies) {
                        Write-Warning $msg
                        continue
                    }
                    throw $msg
                }

                $graph[$dep].Add($name)
                $inDegree[$name]++
            }
        }

        # ------------------------------------------------------------
        # Kahn’s topological sort
        # ------------------------------------------------------------
        $queue  = [System.Collections.Generic.Queue[string]]::new()
        $sorted = [System.Collections.Generic.List[string]]::new()

        foreach ($name in $inDegree.Keys) {
            if ($inDegree[$name] -eq 0) { $queue.Enqueue($name) }
        }

        while ($queue.Count -gt 0) {
            $current = $queue.Dequeue()
            $sorted.Add($current)

            foreach ($next in $graph[$current]) {
                $inDegree[$next]--
                if ($inDegree[$next] -eq 0) { $queue.Enqueue($next) }
            }
        }

        if ($sorted.Count -ne $toolIndex.Count) {
            $remaining = $toolIndex.Keys | Where-Object { $_ -notin $sorted }
            $cycle = Find-DependencyCycle -Graph $graph -Nodes $remaining
            if ($cycle) { throw "Dependency cycle detected: $cycle" }
            throw "Dependency cycle detected involving: $($remaining -join ', ')"
        }

        return $sorted | ForEach-Object { $toolIndex[$_] }
    }

    end { Write-Verbose '[DependencyResolver] Completed' }
}

# ------------------------------------------------------------
# DFS-based cycle detection
# ------------------------------------------------------------
function Find-DependencyCycle {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][hashtable] $Graph,
        [Parameter(Mandatory)][string[]] $Nodes
    )

    $visited = @{}
    $stack   = [System.Collections.Generic.List[string]]::new()

    function Visit {
        param([string] $Node)

        if ($visited[$Node] -eq 'visiting') {
            $idx = $stack.IndexOf($Node)
            if ($idx -ge 0) { return ($stack[$idx..($stack.Count - 1)] + $Node) -join ' -> ' }
        }

        if ($visited[$Node]) { return $null }

        $visited[$Node] = 'visiting'
        $stack.Add($Node)

        foreach ($n in $Graph[$Node]) {
            $path = Visit $n
            if ($path) { return $path }
        }

        $stack.RemoveAt($stack.Count - 1)
        $visited[$Node] = 'visited'
        return $null
    }

    foreach ($node in $Nodes) {
        $result = Visit $node
        if ($result) { return $result }
    }

    return $null
}
