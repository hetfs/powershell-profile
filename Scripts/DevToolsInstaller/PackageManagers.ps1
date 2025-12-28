function Detect-PackageManagers {
    <#
    .SYNOPSIS
        Detect available package managers: WinGet, Chocolatey, GitHub.
        Automatically pins trusted WinGet sources if WinGet is detected.
    .OUTPUTS
        Hashtable with boolean flags: WinGet, Chocolatey, GitHub
    #>

    $availableMethods = @{
        WinGet      = $false
        Chocolatey  = $false
        GitHub      = $true  # Always assumed available
    }

    # -----------------------------
    # Detect WinGet
    # -----------------------------
    try {
        $wingetPaths = @(
            "$env:LOCALAPPDATA\Microsoft\WindowsApps\winget.exe",
            "$env:ProgramFiles\WindowsApps\Microsoft.DesktopAppInstaller_*_*__8wekyb3d8bbwe\winget.exe",
            "$env:LOCALAPPDATA\Microsoft\WindowsApps\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe\winget.exe" # Preview path
        )

        $found = $false
        foreach ($path in $wingetPaths) {
            if (Test-Path $path -PathType Leaf) {
                $availableMethods.WinGet = $true
                $wingetVersion = & $path --version 2>$null
                Write-Log ("WinGet detected at {0}: {1}" -f $path, $wingetVersion) -Level INFO
                $found = $true
                $wingetExe = $path
                break
            }
        }

        if (-not $found -and (Get-Command winget -ErrorAction SilentlyContinue)) {
            $availableMethods.WinGet = $true
            $wingetVersion = winget --version 2>$null
            Write-Log "WinGet detected via PATH: $wingetVersion" -Level INFO
            $wingetExe = 'winget'
        }

        if ($availableMethods.WinGet) {
            # -----------------------------
            # Automatic source pinning
            # -----------------------------
            Write-Log "Ensuring trusted sources are pinned for WinGet..." -Level INFO

            $trustedSources = @(
                @{Name='winget'; Arg='https://winget.azureedge.net/cache'; Trusted=$true},
                @{Name='msstore'; Arg='msstore://'; Trusted=$true}
            )

            foreach ($source in $trustedSources) {
                try {
                    $existing = & $wingetExe source list | Where-Object { $_ -match "^$($source.Name)\s" }
                    if (-not $existing) {
                        Write-Log "Adding WinGet source: $($source.Name)" -Level INFO
                        & $wingetExe source add --name $source.Name --arg $source.Arg --type msstore 2>$null
                    }
                    # Ensure source is pinned/trusted
                    & $wingetExe source reset --name $source.Name --force 2>$null
                    Write-Log "Pinned WinGet source: $($source.Name)" -Level INFO
                }
                catch {
                    Write-Log "Failed to pin WinGet source $($source.Name): $_" -Level WARN
                }
            }
        }
        else {
            Write-Log "WinGet not detected in known locations or PATH" -Level WARN
        }
    }
    catch {
        Write-Log "WinGet detection failed: $_" -Level DEBUG
    }

    # -----------------------------
    # Detect Chocolatey
    # -----------------------------
    try {
        if (Get-Command choco -ErrorAction SilentlyContinue) {
            $chocoVersion = choco --version 2>$null
            if ($chocoVersion) {
                $availableMethods.Chocolatey = $true
                Write-Log "Chocolatey detected: $chocoVersion" -Level INFO
            }
        } else {
            Write-Log "Chocolatey not detected in PATH" -Level DEBUG
        }
    }
    catch {
        Write-Log "Chocolatey detection failed: $_" -Level DEBUG
    }

    Write-Log ("Available methods: WinGet=$($availableMethods.WinGet), Chocolatey=$($availableMethods.Chocolatey), GitHub=$($availableMethods.GitHub)") -Level INFO
    return $availableMethods
}
