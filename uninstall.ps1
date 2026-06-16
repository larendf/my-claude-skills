<#
.SYNOPSIS
  uninstall.ps1 — remove symlinks this repo created in ~\.claude\skills\ (Windows).

.DESCRIPTION
  Windows/PowerShell equivalent of uninstall.sh. Only removes symlinks that
  point back into this repo. Real directories and symlinks pointing elsewhere
  are left untouched.
#>
[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'

$RepoDir   = Split-Path -Parent $MyInvocation.MyCommand.Path
$SkillsSrc = Join-Path $RepoDir 'skills'
$TargetDir = if ($env:CLAUDE_SKILLS_DIR) { $env:CLAUDE_SKILLS_DIR } else { Join-Path $HOME '.claude\skills' }

$removed = 0

Get-ChildItem -Path $SkillsSrc -Recurse -Filter SKILL.md | Sort-Object FullName | ForEach-Object {
    $skillDir = $_.Directory.FullName
    $name     = $_.Directory.Name
    $dest     = Join-Path $TargetDir $name

    $existing = Get-Item -LiteralPath $dest -Force -ErrorAction SilentlyContinue
    if ($existing -and $existing.LinkType -eq 'SymbolicLink' -and $existing.Target -eq $skillDir) {
        Remove-Item -LiteralPath $dest -Force
        Write-Host "  - removed $name"
        $script:removed++
    }
}

Write-Host ''
Write-Host "Done. removed=$removed"
