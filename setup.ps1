#!/usr/bin/env pwsh
# setup.ps1 — 一键重建 Antigravity 配置
# 用法: .\setup.ps1
#
# 这个脚本会：
# 1. 创建 .agent 目录结构
# 2. 复制你的自定义 workflows 和 skills
# 3. 安装 ECC（如果 ECC 仓库存在的话）

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$AGENT_DIR = Join-Path $env:USERPROFILE '.agent'
$SCRIPT_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path
$ECC_DIR = Join-Path $env:USERPROFILE '.gemini\antigravity\scratch\everything-claude-code'

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  Antigravity 配置重建脚本" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# --- Step 1: 创建目录结构 ---
Write-Host "[1/3] 创建目录结构..." -ForegroundColor Yellow
$dirs = @('workflows', 'skills', 'rules')
foreach ($dir in $dirs) {
    $path = Join-Path $AGENT_DIR $dir
    if (-not (Test-Path $path)) {
        New-Item -ItemType Directory -Path $path -Force | Out-Null
        Write-Host "  创建: $path"
    }
}

# --- Step 2: 复制自定义配置 ---
Write-Host "`n[2/3] 安装自定义配置..." -ForegroundColor Yellow

# 自定义 Workflows
$workflowsSource = Join-Path $SCRIPT_DIR 'workflows'
if (Test-Path $workflowsSource) {
    $files = Get-ChildItem $workflowsSource -File
    foreach ($file in $files) {
        Copy-Item $file.FullName (Join-Path $AGENT_DIR 'workflows' $file.Name) -Force
        Write-Host "  workflow: $($file.Name)"
    }
}

# 自定义 Skills 目录
$customSkillDirs = @('AcademicForge', 'awesome-ai-research-writing', 'skill', 'ui-ux-pro-max-skill')
foreach ($dir in $customSkillDirs) {
    $source = Join-Path $SCRIPT_DIR $dir
    if (Test-Path $source) {
        $dest = Join-Path $AGENT_DIR $dir
        Copy-Item $source $dest -Recurse -Force
        Write-Host "  skill 目录: $dir/"
    }
}

# --- Step 3: 安装 ECC ---
Write-Host "`n[3/3] 安装 ECC..." -ForegroundColor Yellow
if (Test-Path $ECC_DIR) {
    Push-Location $ECC_DIR
    try {
        # 确保依赖是最新的
        if (-not (Test-Path 'node_modules')) {
            Write-Host "  安装 npm 依赖..."
            & npm install --no-audit --no-fund --loglevel=error
        }
        # 更新仓库
        Write-Host "  拉取最新版本..."
        & git pull --quiet 2>$null
        # 在用户 home 目录执行安装
        Write-Host "  部署 ECC 到 .agent/..."
        & node scripts/install-apply.js --target antigravity --profile full 2>$null
        Write-Host "  ECC 安装完成!" -ForegroundColor Green
    }
    finally { Pop-Location }
} else {
    Write-Host "  ECC 仓库不存在，跳过。如需安装请先运行:" -ForegroundColor Red
    Write-Host "  git clone https://github.com/affaan-m/everything-claude-code.git `"$ECC_DIR`""
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  配置完成!" -ForegroundColor Green
Write-Host "========================================`n" -ForegroundColor Cyan
