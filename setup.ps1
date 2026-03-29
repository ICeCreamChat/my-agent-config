#!/usr/bin/env pwsh
# setup.ps1 — 一键重建 Antigravity 配置
#
# 正确目录: C:\Users\ICe\.agents\  （带 s）
# Antigravity 通过 .gemini\antigravity\skills junction 指向此处

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$AGENTS_DIR = Join-Path $env:USERPROFILE '.agents'
$SCRIPT_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path
$ECC_DIR = Join-Path $env:USERPROFILE '.gemini\antigravity\scratch\everything-claude-code'

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  Antigravity 配置重建脚本" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# --- Step 1: 创建目录 ---
Write-Host "[1/4] 创建目录结构..." -ForegroundColor Yellow
foreach ($dir in @('workflows', 'skills', 'rules')) {
    $path = Join-Path $AGENTS_DIR $dir
    if (-not (Test-Path $path)) {
        New-Item -ItemType Directory -Path $path -Force | Out-Null
        Write-Host "  创建: $dir/"
    }
}

# --- Step 2: 恢复自定义配置 ---
Write-Host "`n[2/4] 恢复自定义配置..." -ForegroundColor Yellow
$workflowsSource = Join-Path $SCRIPT_DIR 'workflows'
if (Test-Path $workflowsSource) {
    Get-ChildItem $workflowsSource -File | ForEach-Object {
        Copy-Item $_.FullName (Join-Path $AGENTS_DIR 'workflows' $_.Name) -Force
        Write-Host "  workflow: $($_.Name)"
    }
}
foreach ($dir in @('AcademicForge', 'awesome-ai-research-writing', 'skill', 'ui-ux-pro-max-skill')) {
    $source = Join-Path $SCRIPT_DIR $dir
    if (Test-Path $source) {
        Copy-Item $source (Join-Path $AGENTS_DIR $dir) -Recurse -Force
        Write-Host "  custom: $dir/"
    }
}

# --- Step 3: 安装 ECC ---
Write-Host "`n[3/4] 安装 ECC..." -ForegroundColor Yellow
if (Test-Path $ECC_DIR) {
    Push-Location $ECC_DIR
    try {
        if (-not (Test-Path 'node_modules')) {
            Write-Host "  安装 npm 依赖..."
            & npm install --no-audit --no-fund --loglevel=error
        }
        Write-Host "  拉取最新版本..."
        & git pull --quiet 2>$null

        # ECC 安装到临时 .agent 目录，然后移到 .agents
        $tempDir = Join-Path $env:TEMP "ecc-install-$(Get-Date -Format 'yyyyMMddHHmmss')"
        New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
        Push-Location $tempDir
        & node "$ECC_DIR\scripts\install-apply.js" --target antigravity --profile full 2>$null
        Pop-Location

        # 从临时目录的 .agent 复制到 .agents
        $tempAgent = Join-Path $tempDir '.agent'
        if (Test-Path $tempAgent) {
            # workflows
            if (Test-Path "$tempAgent\workflows") {
                Copy-Item "$tempAgent\workflows\*" (Join-Path $AGENTS_DIR 'workflows') -Force
            }
            # skills
            if (Test-Path "$tempAgent\skills") {
                $excludeDirs = @('.git','.github','assets','bin','data','docs','lib','scripts','skills')
                Get-ChildItem "$tempAgent\skills" -Directory | Where-Object { $_.Name -notin $excludeDirs } | ForEach-Object {
                    Copy-Item $_.FullName (Join-Path $AGENTS_DIR 'skills' $_.Name) -Recurse -Force
                }
            }
            # rules
            if (Test-Path "$tempAgent\rules") {
                Copy-Item "$tempAgent\rules\*" (Join-Path $AGENTS_DIR 'rules') -Force
            }
            # 清理临时目录
            Remove-Item $tempDir -Recurse -Force -ErrorAction SilentlyContinue
        }
        Write-Host "  ECC 安装完成!" -ForegroundColor Green
    }
    finally { Pop-Location }
} else {
    Write-Host "  ECC 仓库不存在。先运行:" -ForegroundColor Red
    Write-Host "  git clone https://github.com/affaan-m/everything-claude-code.git `"$ECC_DIR`""
}

# --- Step 4: 修复缺少 frontmatter 的 workflow ---
Write-Host "`n[4/4] 修复 workflow 格式..." -ForegroundColor Yellow
$fixCount = 0
Get-ChildItem (Join-Path $AGENTS_DIR 'workflows') -File -Filter "*.md" | ForEach-Object {
    $content = Get-Content $_.FullName -Raw
    if (-not $content.StartsWith('---')) {
        $firstLine = (Get-Content $_.FullName -TotalCount 3 | Where-Object { $_ -match '\S' } | Select-Object -First 1) -replace '^#+ ',''
        if (-not $firstLine) { $firstLine = ($_.BaseName -replace '-',' ') }
        $newContent = "---`r`ndescription: $firstLine`r`n---`r`n`r`n$content"
        Set-Content $_.FullName $newContent -NoNewline
        $fixCount++
    }
}
Write-Host "  修复了 $fixCount 个文件"

# --- 统计 ---
Write-Host "`n========================================" -ForegroundColor Cyan
$wf = (Get-ChildItem (Join-Path $AGENTS_DIR 'workflows') -File -Filter "*.md").Count
$sk = (Get-ChildItem (Join-Path $AGENTS_DIR 'skills') -Directory | Where-Object { Test-Path (Join-Path $_.FullName 'SKILL.md') }).Count
$ru = (Get-ChildItem (Join-Path $AGENTS_DIR 'rules') -File -Filter "*.md").Count
Write-Host "  Workflows: $wf" -ForegroundColor Green
Write-Host "  Skills:    $sk" -ForegroundColor Green
Write-Host "  Rules:     $ru" -ForegroundColor Green
Write-Host "  位置: $AGENTS_DIR" -ForegroundColor Green
Write-Host "========================================`n" -ForegroundColor Cyan
