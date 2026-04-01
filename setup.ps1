#!/usr/bin/env pwsh
<#
  Durable bootstrap for Antigravity custom config.

  Goals:
  1) Keep long-lived assets in ~/.agents
  2) Recreate Antigravity skills junction after reinstall
  3) Sync repo-managed workflows/skills/rules and custom bundles

  Usage:
    .\setup.ps1
    .\setup.ps1 -DryRun
#>

[CmdletBinding()]
param(
    [string]$RepoPath = '',
    [string]$AgentsHome = (Join-Path $env:USERPROFILE '.agents'),
    [string]$AntigravityHome = (Join-Path $env:USERPROFILE '.gemini\antigravity'),
    [switch]$DryRun
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if ([string]::IsNullOrWhiteSpace($RepoPath)) {
    if (-not [string]::IsNullOrWhiteSpace($PSScriptRoot)) {
        $RepoPath = $PSScriptRoot
    }
    else {
        $RepoPath = (Get-Location).Path
    }
}

function Write-Section {
    param([string]$Text)
    Write-Host "`n== $Text ==" -ForegroundColor Cyan
}

function Invoke-Change {
    param(
        [string]$Description,
        [scriptblock]$Action
    )
    if ($DryRun) {
        Write-Host "[dry-run] $Description" -ForegroundColor Yellow
        return
    }
    Write-Host $Description -ForegroundColor DarkGray
    & $Action
}

function Normalize-Path {
    param([string]$PathValue)
    if ([string]::IsNullOrWhiteSpace($PathValue)) {
        return ''
    }
    try {
        return ([System.IO.Path]::GetFullPath($PathValue)).TrimEnd('\\')
    }
    catch {
        return $PathValue.TrimEnd('\\')
    }
}

function Ensure-Directory {
    param([string]$PathValue)
    if (Test-Path -LiteralPath $PathValue) {
        $item = Get-Item -LiteralPath $PathValue -Force
        if (-not $item.PSIsContainer) {
            throw "Path exists but is not a directory: $PathValue"
        }
        return
    }
    Invoke-Change "Create directory: $PathValue" {
        New-Item -ItemType Directory -Path $PathValue -Force | Out-Null
    }
}

function Copy-FolderChildren {
    param(
        [string]$Source,
        [string]$Destination
    )
    if (-not (Test-Path -LiteralPath $Source)) {
        return
    }
    Ensure-Directory -PathValue $Destination
    $items = Get-ChildItem -LiteralPath $Source -Force
    foreach ($item in $items) {
        $destPath = Join-Path $Destination $item.Name
        if ($item.PSIsContainer) {
            Invoke-Change "Copy directory: $($item.FullName) -> $destPath" {
                Copy-Item -LiteralPath $item.FullName -Destination $destPath -Recurse -Force
            }
        }
        else {
            Invoke-Change "Copy file: $($item.FullName) -> $destPath" {
                Copy-Item -LiteralPath $item.FullName -Destination $destPath -Force
            }
        }
    }
}

function Ensure-AntigravitySkillsJunction {
    param(
        [string]$AntigravitySkillsPath,
        [string]$TargetSkillsPath
    )
    $targetCanonical = Normalize-Path -PathValue $TargetSkillsPath

    if (Test-Path -LiteralPath $AntigravitySkillsPath) {
        $existing = Get-Item -LiteralPath $AntigravitySkillsPath -Force
        $isLink = [bool]($existing.Attributes -band [IO.FileAttributes]::ReparsePoint)
        $linkTarget = ''
        if ($isLink -and $null -ne $existing.Target) {
            $linkTarget = Normalize-Path -PathValue (($existing.Target -join ''))
        }

        if ($isLink -and $linkTarget -ieq $targetCanonical) {
            Write-Host "Junction already correct: $AntigravitySkillsPath -> $TargetSkillsPath" -ForegroundColor Green
            return
        }

        if ($isLink) {
            Invoke-Change "Remove old skills link: $AntigravitySkillsPath" {
                Remove-Item -LiteralPath $AntigravitySkillsPath -Force
            }
        }
        else {
            # Preserve existing files before converting to a junction.
            Copy-FolderChildren -Source $AntigravitySkillsPath -Destination $TargetSkillsPath
            $backupPath = "$AntigravitySkillsPath.backup.$(Get-Date -Format 'yyyyMMddHHmmss')"
            Invoke-Change "Backup existing directory: $AntigravitySkillsPath -> $backupPath" {
                Move-Item -LiteralPath $AntigravitySkillsPath -Destination $backupPath -Force
            }
        }
    }

    Invoke-Change "Create junction: $AntigravitySkillsPath -> $TargetSkillsPath" {
        New-Item -ItemType Junction -Path $AntigravitySkillsPath -Target $TargetSkillsPath | Out-Null
    }
}

$agentsWorkflows = Join-Path $AgentsHome 'workflows'
$agentsSkills = Join-Path $AgentsHome 'skills'
$agentsRules = Join-Path $AgentsHome 'rules'
$antigravitySkills = Join-Path $AntigravityHome 'skills'

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host " Durable Antigravity Bootstrap" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

Write-Section "Ensure persistent directories"
Ensure-Directory -PathValue $AgentsHome
Ensure-Directory -PathValue $agentsWorkflows
Ensure-Directory -PathValue $agentsSkills
Ensure-Directory -PathValue $agentsRules
Ensure-Directory -PathValue $AntigravityHome

Write-Section "Sync repo-managed content"
$repoWorkflows = Join-Path $RepoPath 'workflows'
$repoSkills = Join-Path $RepoPath 'skills'
$repoRules = Join-Path $RepoPath 'rules'

Copy-FolderChildren -Source $repoWorkflows -Destination $agentsWorkflows
Copy-FolderChildren -Source $repoSkills -Destination $agentsSkills
Copy-FolderChildren -Source $repoRules -Destination $agentsRules

foreach ($bundle in @('AcademicForge', 'awesome-ai-research-writing', 'skill', 'ui-ux-pro-max-skill')) {
    $bundlePath = Join-Path $RepoPath $bundle
    if (Test-Path -LiteralPath $bundlePath) {
        Invoke-Change "Copy bundle: $bundlePath -> $AgentsHome" {
            Copy-Item -LiteralPath $bundlePath -Destination $AgentsHome -Recurse -Force
        }
    }
}

Write-Section "Ensure Antigravity compatibility link"
Ensure-AntigravitySkillsJunction -AntigravitySkillsPath $antigravitySkills -TargetSkillsPath $agentsSkills

Write-Section "Summary"
$workflowCount = (Get-ChildItem -Path $agentsWorkflows -File -Filter '*.md' -ErrorAction SilentlyContinue).Count
$skillCount = (Get-ChildItem -Path $agentsSkills -Recurse -File -Filter 'SKILL.md' -ErrorAction SilentlyContinue).Count
$ruleCount = (Get-ChildItem -Path $agentsRules -File -Filter '*.md' -ErrorAction SilentlyContinue).Count

$linkType = '(missing)'
$linkTarget = ''
if (Test-Path -LiteralPath $antigravitySkills) {
    $linkItem = Get-Item -LiteralPath $antigravitySkills -Force
    $linkType = if ($linkItem.LinkType) { $linkItem.LinkType } else { 'Directory' }
    if ($linkItem.Target) {
        $linkTarget = ($linkItem.Target -join '')
    }
}

Write-Host "Repo path:           $RepoPath" -ForegroundColor Green
Write-Host "Persistent root:     $AgentsHome" -ForegroundColor Green
Write-Host "Antigravity root:    $AntigravityHome" -ForegroundColor Green
Write-Host "Antigravity skills:  $antigravitySkills" -ForegroundColor Green
Write-Host "Link type:           $linkType" -ForegroundColor Green
Write-Host "Link target:         $linkTarget" -ForegroundColor Green
Write-Host "Workflows (*.md):    $workflowCount" -ForegroundColor Green
Write-Host "Skills (SKILL.md):   $skillCount" -ForegroundColor Green
Write-Host "Rules (*.md):        $ruleCount" -ForegroundColor Green

if ($DryRun) {
    Write-Host "`nDry run only. Re-run without -DryRun to apply changes." -ForegroundColor Yellow
}
else {
    Write-Host "`nBootstrap complete." -ForegroundColor Cyan
}
