#!/usr/bin/env pwsh
# setup.ps1 — 一键重建 Antigravity 配置
#
# 这个脚本会：
# 1. 恢复你的自定义 workflows 和 skills
# 2. 安装 ECC 到 .agent/
# 3. 清理 Antigravity 不识别的冗余目录
# 4. 修复缺少 frontmatter 的 workflow 文件

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$AGENT_DIR = Join-Path $env:USERPROFILE '.agent'
$SCRIPT_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path
$ECC_DIR = Join-Path $env:USERPROFILE '.gemini\antigravity\scratch\everything-claude-code'

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  Antigravity 配置重建脚本" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# --- Step 1: 创建目录结构 ---
Write-Host "[1/5] 创建目录结构..." -ForegroundColor Yellow
foreach ($dir in @('workflows', 'skills', 'rules')) {
    $path = Join-Path $AGENT_DIR $dir
    if (-not (Test-Path $path)) {
        New-Item -ItemType Directory -Path $path -Force | Out-Null
        Write-Host "  创建: $dir/"
    }
}

# --- Step 2: 恢复自定义配置 ---
Write-Host "`n[2/5] 恢复自定义配置..." -ForegroundColor Yellow

# 自定义 Workflows
$workflowsSource = Join-Path $SCRIPT_DIR 'workflows'
if (Test-Path $workflowsSource) {
    Get-ChildItem $workflowsSource -File | ForEach-Object {
        Copy-Item $_.FullName (Join-Path $AGENT_DIR 'workflows' $_.Name) -Force
        Write-Host "  workflow: $($_.Name)"
    }
}

# 自定义 Skill 目录
foreach ($dir in @('AcademicForge', 'awesome-ai-research-writing', 'skill', 'ui-ux-pro-max-skill')) {
    $source = Join-Path $SCRIPT_DIR $dir
    if (Test-Path $source) {
        Copy-Item $source (Join-Path $AGENT_DIR $dir) -Recurse -Force
        Write-Host "  skill: $dir/"
    }
}

# --- Step 3: 安装 ECC ---
Write-Host "`n[3/5] 安装 ECC..." -ForegroundColor Yellow
if (Test-Path $ECC_DIR) {
    Push-Location $ECC_DIR
    try {
        if (-not (Test-Path 'node_modules')) {
            Write-Host "  安装 npm 依赖..."
            & npm install --no-audit --no-fund --loglevel=error
        }
        Write-Host "  拉取最新版本..."
        & git pull --quiet 2>$null
        Write-Host "  部署 ECC..."
        Push-Location $env:USERPROFILE
        & node "$ECC_DIR\scripts\install-apply.js" --target antigravity --profile full 2>$null
        Pop-Location
        Write-Host "  ECC 安装完成!" -ForegroundColor Green
    }
    finally { Pop-Location }
} else {
    Write-Host "  ECC 仓库不存在。先运行:" -ForegroundColor Red
    Write-Host "  git clone https://github.com/affaan-m/everything-claude-code.git `"$ECC_DIR`""
}

# --- Step 4: 清理冗余目录 ---
Write-Host "`n[4/5] 清理 Antigravity 不识别的冗余文件..." -ForegroundColor Yellow
$junkItems = @('.agents','.claude-plugin','.codex','.cursor','.opencode','mcp-configs','scripts','AGENTS.md','the-security-guide.md','ecc-install-state.json')
foreach ($item in $junkItems) {
    $path = Join-Path $AGENT_DIR $item
    if (Test-Path $path) {
        Remove-Item $path -Recurse -Force
        Write-Host "  已删除: $item"
    }
}

# --- Step 5: 修复缺少 frontmatter 的 workflow ---
Write-Host "`n[5/5] 修复 workflow 格式..." -ForegroundColor Yellow
$fixCount = 0
Get-ChildItem (Join-Path $AGENT_DIR 'workflows') -File -Filter "*.md" | ForEach-Object {
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
$wfCount = (Get-ChildItem (Join-Path $AGENT_DIR 'workflows') -File -Filter "*.md").Count
$skCount = (Get-ChildItem (Join-Path $AGENT_DIR 'skills') -Directory | Where-Object { $_.Name -notin @('.git','.github','assets','bin','data','docs','lib','scripts','skills') } | Where-Object { Test-Path (Join-Path $_.FullName 'SKILL.md') }).Count
$ruCount = (Get-ChildItem (Join-Path $AGENT_DIR 'rules') -File -Filter "*.md").Count
Write-Host "  Workflows: $wfCount" -ForegroundColor Green
Write-Host "  Skills:    $skCount (with SKILL.md)" -ForegroundColor Green
Write-Host "  Rules:     $ruCount" -ForegroundColor Green
Write-Host "========================================`n" -ForegroundColor Cyan
