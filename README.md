# my-agent-config

我的 Antigravity 自定义配置。与 ECC (Everything Claude Code) 配合使用。

## 重建步骤

如果重装了 Antigravity 或换了电脑，运行：

```powershell
# 在 PowerShell 中执行
cd C:\Users\ICe\.gemini\antigravity\scratch\my-agent-config
.\setup.ps1
```

这会自动：
1. 恢复自定义 workflows 和 skills
2. 拉取最新 ECC 并安装到 `.agent/`

## 目录结构

```
my-agent-config/
├── setup.ps1                   # 一键重建脚本
├── workflows/                  # 自定义 workflows
│   ├── ai-research.md
│   ├── humanizer.md
│   ├── planning-with-files.md
│   ├── scientific-visualization.md
│   ├── scientific-writing.md
│   ├── skills-cli.md
│   ├── superpowers.md
│   └── ui-ux-pro-max.md
├── AcademicForge/              # 自定义 skill
├── awesome-ai-research-writing/
├── skill/
└── ui-ux-pro-max-skill/
```

## 依赖

- [Everything Claude Code](https://github.com/affaan-m/everything-claude-code) — 克隆在 `~/.gemini/antigravity/scratch/everything-claude-code/`
