function Detect-PackageManagers {
    $availableMethods = @{
        WinGet = $false
        Chocolatey = $false
        GitHub = $true
    }
    
    # Test for WinGet
    try {
        $wingetPath = "$env:LOCALAPPDATA\Microsoft\WindowsApps\winget.exe"
        $wingetPath2 = "$env:ProgramFiles\WindowsApps\Microsoft.DesktopAppInstaller_*_*__8wekyb3d8bbwe\winget.exe"
        
        if (Test-Path $wingetPath -PathType Leaf) {
            $availableMethods.WinGet = $true
            $wingetVersion = & $wingetPath --version 2>$null
            Write-Log ("WinGet detected at {0}: {1}" -f $wingetPath, $wingetVersion) -Level INFO
        } elseif (Get-Command winget -ErrorAction SilentlyContinue) {
            $availableMethods.WinGet = $true
            $wingetVersion = winget --version 2>$null
            Write-Log "WinGet detected via PATH: $wingetVersion" -Level INFO
        } else {
            Write-Log "WinGet not detected in common locations" -Level WARN
        }
    } catch {
        Write-Log "WinGet detection failed: $_" -Level DEBUG
    }
    
    # Test for Chocolatey
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
    } catch {
        Write-Log "Chocolatey detection failed: $_" -Level DEBUG
    }
    
    Write-Log "Available methods: WinGet=$($availableMethods.WinGet), Chocolatey=$($availableMethods.Chocolatey), GitHub=$($availableMethods.GitHub)" -Level INFO
    return $availableMethods
}

function Determine-MethodOrder {
    param(
        [string]$Method,
        [switch]$SkipWinget,
        [hashtable]$AvailableMethods
    )
    
    if ($SkipWinget) {
        $methodsOrder = @('GitHub', 'Chocolatey')
        Write-Log "Skipping WinGet as requested" -Level INFO
    } elseif ($Method -eq 'All') {
        $methodsOrder = @('WinGet', 'GitHub', 'Chocolatey')
    } else {
        $methodsOrder = @($Method)
    }
    
    # Filter out unavailable methods
    $filteredOrder = @()
    foreach ($method in $methodsOrder) {
        if ($AvailableMethods[$method]) {
            $filteredOrder += $method
        } else {
            Write-Log "Method $method is not available, skipping" -Level WARN
        }
    }
    
    if ($filteredOrder.Count -eq 0) {
        Write-Log "No installation methods available!" -Level ERROR
        exit 1
    }
    
    Write-Log "Installation method order: $($filteredOrder -join ' → ')" -Level INFO
    return $filteredOrder
}
