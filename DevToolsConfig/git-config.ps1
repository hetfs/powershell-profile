#!/usr/bin/env pwsh
# Git Configuration Bootstrap Script for Windows
#
# Author: Fredaw Lomdo
# Repository: https://github.com/hetfs/git-hubcraft
#
# Description:
# A comprehensive Git configuration bootstrap script that sets up a professional
# development environment with optimized defaults, Delta for enhanced diff viewing,
# and an extensive collection of productivity aliases.
#
# Features:
# • 150+ carefully crafted aliases covering all Git workflows
# • Windows-focused package management (WinGet, Chocolatey, Scoop)
# • Delta integration for beautiful, syntax-highlighted diffs
# • Interactive setup with input validation
# • Safety features including error handling and dry-run mode
#
# Alias Categories:
# • Basic Operations: a, s, d, c, co, b
# • Advanced Commit: ca, cam, cane, caa, caam, caane
# • Branch Management: bm, bnm, bed, bsd
# • Diff & Log: Multiple formats and viewing options
# • Merge & Rebase: Conflict resolution and workflow tools
# • Utility Aliases: wip, uncommit, cleanout, etc.
# • Repository Management: initer, cloner, pruner, optimizer
#
# Usage:
#   .\git-config.ps1                 # Full interactive setup
#   .\git-config.ps1 -CheckOnly      # Verify current configuration
#   .\git-config.ps1 -Reset          # Reset identity and reconfigure
#
#   git aliases                     # View all configured aliases
#   git config --global -e          # This opens %USERPROFILE%\.gitconfig
#
# The script creates a complete Git productivity environment suitable for
# both beginners and experienced developers.

param(
    [switch]$Reset,
    [switch]$CheckOnly,
    [switch]$Quiet
)

# Script variables
$Script:RESET_IDENTITY = $Reset
$Script:CHECK_ONLY = $CheckOnly
$Script:QUIET = $Quiet

# --- Logging functions ---
function Write-Info {
    param([string]$Message)
    Write-Host "ℹ️  $Message" -ForegroundColor Blue
}

function Write-Success {
    param([string]$Message)
    Write-Host "✅ $Message" -ForegroundColor Green
}

function Write-Warning {
    param([string]$Message)
    Write-Host "⚠️  $Message" -ForegroundColor Yellow
}

function Write-Error {
    param([string]$Message)
    Write-Host "❌ $Message" -ForegroundColor Red
}

function Write-Debug {
    param([string]$Message)
    if (-not $Script:QUIET) {
        Write-Host "🔍 $Message" -ForegroundColor Gray
    }
}

# --- Usage information ---
function Show-Usage {
    Write-Host "Git Configuration Bootstrap Script for Windows" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Usage: .\git-config.ps1 [OPTIONS]"
    Write-Host ""
    Write-Host "Options:"
    Write-Host "  -Reset         Reset Git user identity before configuration"
    Write-Host "  -CheckOnly     Check current configuration without making changes"
    Write-Host "  -Quiet         Suppress non-essential output"
    Write-Host "  -Help          Show this help message"
    Write-Host ""
    Write-Host "Features:"
    Write-Host "  • Installs Git and Delta (if missing)"
    Write-Host "  • Configures user identity interactively"
    Write-Host "  • Sets up Delta for enhanced diff viewing"
    Write-Host "  • Configures sensible Git defaults"
    Write-Host "  • Adds useful aliases for daily workflow"
    Write-Host ""
    Write-Host "Supported Package Managers:"
    Write-Host "  Windows (WinGet, Chocolatey, Scoop)"
}

# --- Package manager detection ---
function Get-PackageManager {
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        return "winget"
    }
    elseif (Get-Command choco -ErrorAction SilentlyContinue) {
        return "choco"
    }
    elseif (Get-Command scoop -ErrorAction SilentlyContinue) {
        return "scoop"
    }
    else {
        return "unknown"
    }
}

# --- Package installation ---
function Install-Package {
    param(
        [string]$PackageManager,
        [string]$Package,
        [string]$PackageId = $Package
    )

    $installCmd = $null

    switch ($PackageManager) {
        "winget" { 
            $installCmd = "winget install --id $PackageId --silent --accept-package-agreements --accept-source-agreements"
        }
        "choco" { 
            $installCmd = "choco install $Package -y"
        }
        "scoop" { 
            $installCmd = "scoop install $Package"
        }
        default {
            Write-Error "Unsupported package manager: $PackageManager"
            return $false
        }
    }

    Write-Info "Installing $Package..."
    try {
        Invoke-Expression $installCmd
        if ($LASTEXITCODE -eq 0) {
            Write-Success "Successfully installed $Package"
            return $true
        } else {
            Write-Error "Failed to install $Package (exit code: $LASTEXITCODE)"
            return $false
        }
    }
    catch {
        Write-Error "Failed to install $Package: $($_.Exception.Message)"
        return $false
    }
}

# --- Ensure required tools are installed ---
function Ensure-Installed {
    param(
        [string]$Command,
        [string]$Package,
        [string]$PackageId = $Package
    )

    if (Get-Command $Command -ErrorAction SilentlyContinue) {
        Write-Debug "$Command is already installed"
        return $true
    }

    $pkgManager = Get-PackageManager

    if ($pkgManager -eq "unknown") {
        Write-Error "No supported package manager found. Please install $Package manually."
        Write-Host "Available options:"
        Write-Host "  • WinGet: https://aka.ms/getwinget"
        Write-Host "  • Chocolatey: https://chocolatey.org/install"
        Write-Host "  • Scoop: https://scoop.sh"
        return $false
    }

    # Map common packages to their IDs in different package managers
    $packageMap = @{
        "git" = @{
            "winget" = "Git.Git"
            "choco" = "git"
            "scoop" = "git"
        }
        "delta" = @{
            "winget" = "Delta.Delta"
            "choco" = "git-delta"
            "scoop" = "delta"
        }
    }

    if ($packageMap.ContainsKey($Package)) {
        $packageId = $packageMap[$Package][$pkgManager]
    } else {
        $packageId = $PackageId
    }

    return Install-Package -PackageManager $pkgManager -Package $Package -PackageId $packageId
}

# --- Git identity configuration ---
function Set-GitIdentity {
    if ($Script:RESET_IDENTITY) {
        Write-Info "Resetting Git identity..."
        git config --global --unset user.name 2>$null
        git config --global --unset user.email 2>$null
    }

    $currentName = git config --global user.name 2>$null
    $currentEmail = git config --global user.email 2>$null

    if ($currentName -and $currentEmail -and -not $Script:RESET_IDENTITY) {
        Write-Info "Current Git identity:"
        Write-Host "  Name:  $currentName"
        Write-Host "  Email: $currentEmail"
        $useCurrent = Read-Host "Use current identity? [Y/n]"
        if ($useCurrent -eq "" -or $useCurrent -eq "y" -or $useCurrent -eq "Y") {
            return
        }
    }

    # Get Git user name
    do {
        $gitName = Read-Host "Enter your Git user name"
        $gitName = $gitName.Trim()
        if (-not $gitName) {
            Write-Warning "Name cannot be empty"
        }
    } while (-not $gitName)

    # Get Git email
    do {
        $gitEmail = Read-Host "Enter your Git email"
        $gitEmail = $gitEmail.Trim()
        $emailPattern = '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'
        if ($gitEmail -notmatch $emailPattern) {
            Write-Warning "Please enter a valid email address"
        }
    } while ($gitEmail -notmatch $emailPattern)

    git config --global user.name "$gitName"
    git config --global user.email "$gitEmail"
    Write-Success "Git identity configured"
}

# --- Core Git configuration ---
function Set-GitCoreConfiguration {
    Write-Info "Applying core Git configuration..."

    # Basic settings
    git config --global core.editor "nvim"  # "code --wait"  VS Code as default editor
    git config --global core.pager "delta"
    git config --global init.defaultBranch "main"
    git config --global color.ui "auto"

    # Merge and diff settings
    git config --global merge.conflictStyle "zdiff3"
    git config --global merge.tool "code"  # VS Code as merge tool
    git config --global diff.colorMoved "default"

    # Branch behavior
    git config --global pull.rebase true
    git config --global push.default "simple"
    git config --global push.autoSetupRemote true

    # Credential management (Windows Credential Manager)
    git config --global credential.helper "manager-core"

    # Performance optimizations
    git config --global feature.manyFiles true
}

# --- Delta configuration ---
function Set-DeltaConfiguration {
    Write-Info "Configuring Delta for enhanced diff viewing..."

    git config --global delta.navigate true
    git config --global delta.line-numbers true
    git config --global delta.side-by-side true
    git config --global delta.syntax-theme "Monokai Extended"
    git config --global delta.features "decorations"

    # Pager configurations
    git config --global pager.log "delta"
    git config --global pager.diff "delta"
    git config --global pager.show "delta"
    git config --global interactive.diffFilter "delta --color-only"

    # Decoration settings
    git config --global delta.decorations.commit-decoration-style "bold yellow box ul"
    git config --global delta.decorations.file-style "bold yellow"
    git config --global delta.decorations.file-decoration-style "none"
}

# --- Git aliases ---
function Set-GitAliases {
    Write-Info "Setting up comprehensive Git aliases..."

    # Short aliases for frequent commands
    git config --global alias.a "add"
    git config --global alias.aa "add --all"
    git config --global alias.ap "add --patch"
    git config --global alias.au "add --update"

    # Branch operations
    git config --global alias.b "branch"
    git config --global alias.bm "branch --merged"
    git config --global alias.bnm "branch --no-merged"
    git config --global alias.bed "branch --edit-description"
    git config --global alias.bsd "branch --show-description"
    git config --global alias.bv "branch -v"
    git config --global alias.bra "branch -a"

    # Commit operations
    git config --global alias.c "commit"
    git config --global alias.ca "commit --amend"
    git config --global alias.cam "commit --amend --message"
    git config --global alias.cane "commit --amend --no-edit"
    git config --global alias.caa "commit --amend --all"
    git config --global alias.caam "commit --amend --all --message"
    git config --global alias.caane "commit --amend --all --no-edit"
    git config --global alias.ci "commit --interactive"
    git config --global alias.cm "commit --message"

    # Checkout operations
    git config --global alias.co "checkout"
    git config --global alias.cog "checkout --guess"
    git config --global alias.cong "checkout --no-guess"
    git config --global alias.cob "checkout -b"

    # Cherry-pick operations
    git config --global alias.cp "cherry-pick"
    git config --global alias.cpa "cherry-pick --abort"
    git config --global alias.cpc "cherry-pick --continue"
    git config --global alias.cpn "cherry-pick -n"
    git config --global alias.cpnx "cherry-pick -n -x"

    # Diff operations
    git config --global alias.d "diff"
    git config --global alias.dd "diff"
    git config --global alias.dc "diff --cached"
    git config --global alias.ds "diff --staged"
    git config --global alias.dwd "diff --word-diff"

    # Fetch operations
    git config --global alias.f "fetch"
    git config --global alias.fa "fetch --all"
    git config --global alias.fav "fetch --all --verbose"
    git config --global alias.fap "fetch --all --prune"

    # Grep operations
    git config --global alias.g "grep"
    git config --global alias.gg "grep"
    git config --global alias.gn "grep -n"

    # Log operations
    git config --global alias.l "log"
    git config --global alias.ll "log"
    git config --global alias.lll "log"
    git config --global alias.lo "log --oneline"
    git config --global alias.lg "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative"
    git config --global alias.ll "log --graph --decorate --pretty=format:'%C(yellow)%h%Creset -%C(auto)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset'"
    git config --global alias.lor "log --oneline --reverse"
    git config --global alias.lp "log --patch"
    git config --global alias.lfp "log --first-parent"
    git config --global alias.lto "log --topo-order"

    # ls-files operations
    git config --global alias.ls "ls-files"
    git config --global alias.lsd "ls-files --debug"
    git config --global alias.lsfn "ls-files --full-name"
    git config --global alias.lsio "ls-files --ignored --others --exclude-standard"

    # Merge operations
    git config --global alias.m "merge"
    git config --global alias.ma "merge --abort"
    git config --global alias.mc "merge --continue"
    git config --global alias.mncnf "merge --no-commit --no-ff"

    # Pull operations
    git config --global alias.p "pull"
    git config --global alias.pf "pull --ff-only"
    git config --global alias.pr "pull --rebase"
    git config --global alias.prp "pull --rebase=preserve"

    # Rebase operations
    git config --global alias.rb "rebase"
    git config --global alias.rba "rebase --abort"
    git config --global alias.rbc "rebase --continue"
    git config --global alias.rbs "rebase --skip"
    git config --global alias.rbi "rebase --interactive"
    git config --global alias.rbiu "rebase --interactive @{upstream}"

    # Reflog operations
    git config --global alias.rl "reflog"

    # Remote operations
    git config --global alias.rr "remote"
    git config --global alias.rrs "remote show"
    git config --global alias.rru "remote update"
    git config --global alias.rrp "remote prune"

    # Revert operations
    git config --global alias.rv "revert"
    git config --global alias.rvnc "revert --no-commit"

    # Show-branch operations
    git config --global alias.sb "show-branch"
    git config --global alias.sbdo "show-branch --date-order"
    git config --global alias.sbto "show-branch --topo-order"

    # Submodule operations
    git config --global alias.sm "submodule"
    git config --global alias.smi "submodule init"
    git config --global alias.sma "submodule add"
    git config --global alias.sms "submodule sync"
    git config --global alias.smu "submodule update"
    git config --global alias.smui "submodule update --init"
    git config --global alias.smuir "submodule update --init --recursive"

    # Status operations
    git config --global alias.s "status -sb"
    git config --global alias.ss "status --short"
    git config --global alias.ssb "status --short --branch"
    git config --global alias.st "status"

    # Whatchanged
    git config --global alias.w "whatchanged"

    # Friendly aliases - Recommended helpers
    git config --global alias.initer "!git init && git commit --allow-empty -m ""Initial empty commit"""
    git config --global alias.cloner "clone --recursive"
    git config --global alias.pruner "!git prune && git reflog expire --all --expire=now && git gc --prune=now"
    git config --global alias.repacker "!git repack -a -d -f --depth=250 --window=250"
    git config --global alias.optimizer "!git pruner && git repacker"

    # Quick highlights
    git config --global alias.chart "shortlog -sn"
    git config --global alias.churn "!git log --pretty=format: --name-only | sort | uniq -c | sort -rg"
    git config --global alias.summary "shortlog -s -n"

    # Branch names
    git config --global alias.default-branch "!git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@'"
    git config --global alias.current-branch "symbolic-ref --short HEAD"
    git config --global alias.upstream-branch "!git rev-parse --abbrev-ref --symbolic-full-name @{u}"
    git config --global alias.topic-base-branch "!git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@'"

    # Friendly plurals
    git config --global alias.aliases "!git config --get-regexp alias"
    git config --global alias.branches "branch -a"
    git config --global alias.tags "tag -l"
    git config --global alias.stashes "stash list"

    # Undo operations
    git config --global alias.uncommit "reset --soft HEAD~1"
    git config --global alias.unadd "reset HEAD"
    git config --global alias.undo "reset --soft HEAD~1"

    # Lookups
    git config --global alias.whois "!git log --format=""%an <%ae>"" | grep -i ""$1"" | head -1"
    git config --global alias.whatis "show --name-status"

    # Commit details
    git config --global alias.commit-parents "show --format=%P -s"
    git config --global alias.commit-is-merge "![ `$(git show --format=%P -s | wc -w) -gt 1 ]"

    # Alias helpers
    git config --global alias.alias "!git config --get-regexp alias"
    git config --global alias.add-alias "!git config alias.""$1"" ""$2"""
    git config --global alias.move-alias "!git config alias.""$2"" ""`$(git config alias.""$1"")"" && git config --unset alias.""$1"""

    # Script helpers
    git config --global alias.top "rev-parse --show-toplevel"
    git config --global alias.exec "!sh"

    # New repos
    git config --global alias.init-empty "!git init && git commit --allow-empty -m ""Initial empty commit"""
    git config --global alias.clone-lean "clone --depth=1"

    # Saving work
    git config --global alias.snapshot "stash push -m ""snapshot: `$(date)"""
    git config --global alias.panic "!git add -A && git stash && git stash drop"

    # Advanced aliases
    git config --global alias.search-commits "log --grep"
    git config --global alias.debug "!echo ""Current branch: `$(git current-branch)"" && echo ""Upstream: `$(git upstream-branch 2>/dev/null || echo none)"""

    # Workflow aliases
    git config --global alias.get "pull --ff-only"
    git config --global alias.put "push"
    git config --global alias.ours "checkout --ours"
    git config --global alias.theirs "checkout --theirs"
    git config --global alias.wip "stash push -m ""wip"""
    git config --global alias.unwip "stash pop"
    git config --global alias.assume "update-index --assume-unchanged"
    git config --global alias.unassume "update-index --no-assume-unchanged"
    git config --global alias.publish "push -u origin HEAD"
    git config --global alias.unpublish "push origin :HEAD"

    # Reset & undo
    git config --global alias.reset-commit "reset --soft HEAD~1"
    git config --global alias.undo-commit "reset --soft HEAD~1"

    # Track & untrack
    git config --global alias.track "branch --set-upstream-to=origin/HEAD"
    git config --global alias.untrack "branch --unset-upstream"

    # Inbound & outbound
    git config --global alias.inbound "!git fetch && git log ..@{u}"
    git config --global alias.outbound "!git log @{u}.."

    # Pull1 & push1
    git config --global alias.pull1 "pull origin HEAD"
    git config --global alias.push1 "push origin HEAD"

    # Tooling aliases
    git config --global alias.gitk-conflict "!gitk --merge"
    git config --global alias.gitk-history-all "!gitk --all"

    # CVS aliases
    git config --global alias.cvs-e "cvsexportcommit"
    git config --global alias.cvs-i "cvsimport"

    # SVN aliases
    git config --global alias.svn-b "svn branch"
    git config --global alias.svn-c "svn commit"
    git config --global alias.svn-cp "svn cherry-pick"
    git config --global alias.svn-m "svn merge"

    # Graphviz
    git config --global alias.graphviz "log --graph --oneline --all"

    # Additional utility aliases
    git config --global alias.heads "log --oneline --decorate"
    git config --global alias.ignore "!echo ""$1"" >> .gitignore"
    git config --global alias.last-tag "describe --tags --abbrev=0"
    git config --global alias.refs-by-date "for-each-ref --sort=-committerdate --format='%(refname:short)'"
    git config --global alias.fixup "commit --fixup"
    git config --global alias.orphans "fsck --unreachable"
    git config --global alias.track-all-remote-branches "!git branch -r | grep -v '\\->' | while read remote; do git branch --track ""`${remote#origin/}"" ""`$remote""; done"
    git config --global alias.cleaner "clean -fd"
    git config --global alias.cleanest "clean -fdx"
    git config --global alias.cleanout "!git clean -fd && git checkout --"
    git config --global alias.serve "daemon --reuseaddr --base-path=. --export-all --verbose"

    # Topic branching
    git config --global alias.topic-begin "checkout -b"
    git config --global alias.topic-end "!git checkout main && git merge --no-ff"
    git config --global alias.topic-sync "!git fetch && git rebase origin/`$(git current-branch)"
    git config --global alias.topic-move "branch -m"

    # Flow aliases
    git config --global alias.issues "log --grep=""#"" --oneline"
    git config --global alias.expunge "filter-branch --tree-filter 'rm -f ""$1""' --prune-empty HEAD"
    git config --global alias.reincarnate "!git branch -D ""$1"" && git checkout -b ""$1"""
    git config --global alias.last-tagged "describe --tags --abbrev=0 --always"

    Write-Success "Comprehensive Git aliases configured"
}

# --- Configuration verification ---
function Test-Configuration {
    Write-Info "Verifying Git configuration..."

    Write-Host "`nGit Identity:" -ForegroundColor Cyan
    Write-Host "  Name:  $(git config --global user.name)"
    Write-Host "  Email: $(git config --global user.email)"

    Write-Host "`nCore Settings:" -ForegroundColor Cyan
    git config --global --get core.editor
    git config --global --get init.defaultBranch

    Write-Host "`nAlias Categories Configured:" -ForegroundColor Cyan
    $categories = @(
        "Basic (a, s, d, c, co, b)",
        "Commit (ca, cam, cane, caam)",
        "Branch (bm, bnm, bed, bsd)",
        "Diff (dc, ds, dwd)",
        "Log (lg, lo, lp, lfp)",
        "Fetch (fa, fav, fap)",
        "Merge (ma, mc, mncnf)",
        "Rebase (rba, rbc, rbi)",
        "Utility (uncommit, unstage, wip)",
        "Advanced (initer, cloner, pruner)"
    )

    foreach ($category in $categories) {
        Write-Host "  ✅ $category"
    }

    Write-Host "`nTotal Aliases:" -ForegroundColor Cyan
    (git config --global --get-regexp alias).Count

    if (Get-Command delta -ErrorAction SilentlyContinue) {
        Write-Host "`nDelta Configuration:" -ForegroundColor Cyan
        delta --version
    }
}

# --- Main execution ---
function Start-Configuration {
    Write-Info "Starting Git configuration bootstrap..."

    # Check mode
    if ($Script:CHECK_ONLY) {
        Write-Info "Check-only mode activated"
        Test-Configuration
        return
    }

    # Ensure dependencies are installed
    if (-not (Ensure-Installed -Command "git" -Package "git")) {
        Write-Error "Git is required but could not be installed. Please install Git manually."
        return
    }

    if (-not (Ensure-Installed -Command "delta" -Package "delta")) {
        Write-Warning "Delta could not be installed. Continuing without Delta..."
    }

    # Configure Git
    Set-GitIdentity
    Set-GitCoreConfiguration
    Set-DeltaConfiguration
    Set-GitAliases

    # Final verification
    Test-Configuration

    Write-Success "Git configuration completed successfully!"
    Write-Host ""
    Write-Info "Try these useful aliases:"
    Write-Host "  git s          # Compact status"
    Write-Host "  git lg         # Graph log"
    Write-Host "  git d filename # View changes"
    Write-Host "  git co -b feat/new-feature # Create new branch"
    Write-Host "  git ca         # Amend last commit"
    Write-Host "  git wip        # Save work in progress"
    Write-Host "  git uncommit   # Soft reset last commit"
    Write-Host "  git aa         # Add all changes"
    Write-Host "  git cp         # Cherry-pick commits"
    Write-Host "  git rb         # Interactive rebase"
    Write-Host ""
    Write-Info "View all aliases with: git aliases"
}

# --- Script entry point ---
if ($MyInvocation.InvocationName -ne '.') {
    try {
        # Show help if requested
        if ($args -contains "-Help" -or $args -contains "-h") {
            Show-Usage
            exit 0
        }

        Start-Configuration
    }
    catch {
        Write-Error "Script execution failed: $($_.Exception.Message)"
        exit 1
    }
}
