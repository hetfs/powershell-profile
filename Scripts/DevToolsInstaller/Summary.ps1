function Show-Summary {
    param(
        [hashtable]$InstallationResults,
        [hashtable]$ToolsToInstall
    )

    Write-Log "`n" + "="*80 -Level INFO
    Write-Log "INSTALLATION SUMMARY".ToUpper() -Level INFO
    Write-Log "="*80 -Level INFO

    # --------------------------------------------------------
    # Aggregate statistics by category
    # --------------------------------------------------------
    $categoryStats = @{}
    $totalSuccess = 0
    $totalAlready = 0
    $totalFailed = 0
    $totalNoMethods = 0

    foreach ($result in $InstallationResults.GetEnumerator()) {
        $category = $ToolsToInstall[$result.Key].Category
        if (-not $categoryStats.ContainsKey($category)) {
            $categoryStats[$category] = @{Success = 0; Already = 0; Failed = 0; NoMethods = 0}
        }

        switch ($result.Value) {
            'Failed'          { $categoryStats[$category].Failed++; $totalFailed++ }
            'AlreadyInstalled'{ $categoryStats[$category].Already++; $totalAlready++ }
            'NoMethods'       { $categoryStats[$category].NoMethods++; $totalNoMethods++ }
            default           { $categoryStats[$category].Success++; $totalSuccess++ }
        }
    }

    # --------------------------------------------------------
    # Display summary per category
    # --------------------------------------------------------
    Write-Log "`nBY CATEGORY:" -Level INFO
    foreach ($category in $categoryStats.Keys | Sort-Object) {
        $stats = $categoryStats[$category]
        $totalCat = $stats.Success + $stats.Already + $stats.Failed + $stats.NoMethods
        $percent = if ($totalCat -gt 0) { [math]::Round(($stats.Success + $stats.Already) / $totalCat * 100, 1) } else { 0 }

        Write-Log (
            "{0,-20} {1,3}/{2,-3} ({3,5}%) [✓:{4} ⚠:{5} ✗:{6} Ⓜ:{7}]" -f
            $category,
            ($stats.Success + $stats.Already),
            $totalCat,
            $percent,
            $stats.Success,
            $stats.Already,
            $stats.Failed,
            $stats.NoMethods
        ) -Level INFO
    }

    # --------------------------------------------------------
    # Display detailed results
    # --------------------------------------------------------
    Write-Log "`nDETAILED RESULTS:" -Level INFO
    foreach ($category in $categoryStats.Keys | Sort-Object) {
        Write-Log "`n[$category]" -Level INFO
        $categoryTools = $ToolsToInstall.Keys | Where-Object { $ToolsToInstall[$_].Category -eq $category }

        foreach ($toolName in ($categoryTools | Sort-Object)) {
            $displayName = $ToolsToInstall[$toolName].DisplayName
            $status = switch ($InstallationResults[$toolName]) {
                'Failed'           { '✗ Failed' }
                'AlreadyInstalled' { '⚠ Already installed' }
                'NoMethods'        { 'Ⓜ No methods available' }
                default {
                    # Detect pinned Winget source
                    if ($InstallationResults[$toolName] -match 'WinGet \(PinnedSource: (.+?)\)') {
                        "✓ Installed via WinGet (Pinned: $($Matches[1]))"
                    } else {
                        "✓ Installed via $($InstallationResults[$toolName])"
                    }
                }
            }
            Write-Log ("  {0,-35}: {1}" -f $displayName, $status) -Level INFO
        }
    }

    # --------------------------------------------------------
    # Overall statistics
    # --------------------------------------------------------
    Write-Log "`n" + "-"*80 -Level INFO
    Write-Log "OVERALL STATISTICS:" -Level INFO
    Write-Log ("Total tools processed : {0}" -f $ToolsToInstall.Count) -Level INFO
    Write-Log ("Successfully installed: {0}" -f $totalSuccess) -Level SUCCESS
    Write-Log ("Already installed     : {0}" -f $totalAlready) -Level INFO
    Write-Log ("Failed                : {0}" -f $totalFailed) -Level WARN
    Write-Log ("No methods available  : {0}" -f $totalNoMethods) -Level WARN

    $totalAttempted = $totalSuccess + $totalFailed
    if ($totalAttempted -gt 0) {
        $successRate = [math]::Round($totalSuccess / $totalAttempted * 100, 1)
        Write-Log ("Installation success rate: {0}%" -f $successRate) -Level INFO
    }

    # --------------------------------------------------------
    # Script duration
    # --------------------------------------------------------
    $scriptEndTime = Get-Date
    $duration = $scriptEndTime - $script:scriptStartTime
    Write-Log "`nScript completed in $($duration.ToString('mm\:ss'))" -Level INFO
    Write-Log "Log file: $($script:LogPath)" -Level INFO

    if ($totalFailed -gt 0 -or $totalNoMethods -gt 0) {
        Write-Log "`nSome installations failed. Check the log file for details: $($script:LogPath)" -Level WARN
        exit 1
    }
}
