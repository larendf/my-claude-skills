<#
.SYNOPSIS
  install.ps1 — symlink every skill in this repo into ~\.claude\skills\ (Windows).

.DESCRIPTION
  Windows/PowerShell equivalent of install.sh. Skills stay version-controlled
  here; edits are live everywhere because the target is a symlink, not a copy.
  Re-run any time you add a new skill.

  Creating symlinks on Windows requires either Developer Mode (Settings →
  Privacy & security → For developers → Developer Mode) or an elevated
  (Run as Administrator) PowerShell session. If neither is available the script
  reports which links it could not create.

.PARAMETER Force
  Replace existing entries, even real directories.

.PARAMETER DryRun
  Print what would happen, change nothing.

.EXAMPLE
  .\install.ps1            # symlink all skills (skips ones already linked here)
  .\install.ps1 -Force     # replace existing entries, even real directories
  .\install.ps1 -DryRun    # preview, change nothing

  Custom location:
  $env:CLAUDE_SKILLS_DIR = 'D:\skills'; .\install.ps1
#>
[CmdletBinding()]
param(
    [switch]$Force,
    [switch]$DryRun
)

$ErrorActionPreference = 'Stop'

$RepoDir    = Split-Path -Parent $MyInvocation.MyCommand.Path
$SkillsSrc  = Join-Path $RepoDir 'skills'
$TargetDir  = if ($env:CLAUDE_SKILLS_DIR) { $env:CLAUDE_SKILLS_DIR } else { Join-Path $HOME '.claude\skills' }

if (-not (Test-Path $TargetDir)) {
    if (-not $DryRun) { New-Item -ItemType Directory -Path $TargetDir -Force | Out-Null }
}

$linked = 0; $skipped = 0; $replaced = 0; $failed = 0

Get-ChildItem -Path $SkillsSrc -Recurse -Filter SKILL.md | Sort-Object FullName | ForEach-Object {
    $skillDir = $_.Directory.FullName
    $name     = $_.Directory.Name
    $dest     = Join-Path $TargetDir $name

    $existing = Get-Item -LiteralPath $dest -Force -ErrorAction SilentlyContinue

    # Already linked here?
    if ($existing -and $existing.LinkType -eq 'SymbolicLink' -and $existing.Target -eq $skillDir) {
        Write-Host "  [=] $name (already linked)"
        $script:skipped++
        return
    }

    if ($existing) {
        if (-not $Force) {
            Write-Host "  [!] $name exists at $dest - skipping (use -Force to replace)"
            $script:skipped++
            return
        }
        if (-not $DryRun) { Remove-Item -LiteralPath $dest -Recurse -Force }
        $script:replaced++
    }

    if ($DryRun) {
        Write-Host "  -> would link $name -> $skillDir"
        $script:linked++
        return
    }

    try {
        New-Item -ItemType SymbolicLink -Path $dest -Target $skillDir -ErrorAction Stop | Out-Null
        Write-Host "  [+] linked $name"
        $script:linked++
    } catch {
        Write-Host "  [x] failed to link $name - $($_.Exception.Message)"
        Write-Host "      (enable Developer Mode or run PowerShell as Administrator)"
        $script:failed++
    }
}

Write-Host ''
Write-Host "Done. linked=$linked replaced=$replaced skipped=$skipped failed=$failed"
Write-Host "Target: $TargetDir"
if ($DryRun) { Write-Host '(dry run - nothing changed)' }
