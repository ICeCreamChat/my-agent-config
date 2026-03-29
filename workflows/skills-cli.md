---
description: 使用 Skills CLI（npx skills）搜索、安装、更新和管理 Agent Skills，支持 Antigravity 等 40+ 编码代理
---

# Skills CLI 技能管理工作流

基于 **skills** CLI（开放 Agent Skills 生态系统的包管理器，MIT 许可）

## 工具路径

```
c:\Users\ICe\.agent\skill\skills
```

## 核心命令

| 命令 | 用途 |
|------|------|
| `npx skills find [query]` | 按关键词搜索技能 |
| `npx skills add <package>` | 从 GitHub/URL/本地路径安装技能 |
| `npx skills add <pkg> --list` | 列出仓库中可用的技能（不安装） |
| `npx skills list` | 查看已安装的技能 |
| `npx skills check` | 检查已安装技能是否有更新 |
| `npx skills update` | 更新所有已安装技能到最新版本 |
| `npx skills remove [skills]` | 移除已安装的技能 |
| `npx skills init [name]` | 创建新的 SKILL.md 模板 |

## 安装来源格式

```bash
# GitHub 简写
npx skills add vercel-labs/agent-skills

# 完整 GitHub URL
npx skills add https://github.com/vercel-labs/agent-skills

# 仓库中指定技能路径
npx skills add https://github.com/vercel-labs/agent-skills/tree/main/skills/web-design-guidelines

# 本地路径
npx skills add ./my-local-skills
```

## 常用选项

| 选项 | 说明 |
|------|------|
| `-g, --global` | 安装到用户目录（跨项目可用） |
| `-a, --agent <agents>` | 指定目标代理（如 `antigravity`, `claude-code`） |
| `-s, --skill <skills>` | 安装指定技能（`'*'` 表示全部） |
| `-y, --yes` | 跳过确认提示（CI/CD 友好） |
| `--all` | 安装所有技能到所有代理 |
| `--copy` | 复制文件而非创建符号链接 |

## 安装路径（已配置）

本机技能统一安装到以下路径：

```
c:\Users\ICe\.agent\skills
```

工作流文件输出路径：

```
c:\Users\ICe\.agent\workflows
```

## 使用流程

### 1. 搜索技能

```bash
# 交互式搜索
npx skills find

# 按关键词搜索
npx skills find react performance
npx skills find academic writing
```

也可浏览在线目录：https://skills.sh/

### 2. 安装技能

所有技能安装到 `c:\Users\ICe\.agent\skills`：

```bash
# 安装指定技能到 Antigravity（全局）
npx skills add vercel-labs/agent-skills -a antigravity -s frontend-design -g -y

# 安装全部技能到 Antigravity
npx skills add vercel-labs/agent-skills -a antigravity --skill '*' -g -y
```

### 3. 检查与更新

```bash
# 检查更新
npx skills check

# 更新全部
npx skills update
```

### 4. 创建自定义技能

```bash
# 在技能目录下创建新技能
npx skills init my-custom-skill
```

生成的 `SKILL.md` 模板包含 `name` 和 `description` 必填字段。

### 5. 新技能安装后写工作流

安装新技能后，应在以下路径创建对应的工作流 `.md` 文件：

```
c:\Users\ICe\.agent\workflows\<技能名>.md
```

工作流文件格式：

```markdown
---
description: 一句话描述该技能的用途和触发场景
---

# 技能名称

## 技能路径
## 核心能力
## 使用方式
## 适用场景
```

## 内置 find-skills 技能

Skills CLI 自带一个 `find-skills` 技能，当用户问到"怎么做 X"或"有没有 X 相关的 skill"时自动触发，协助搜索和推荐合适的技能。

## 推荐验证标准

推荐技能前应验证：
1. **安装量** — 优先推荐 1K+ 安装的技能
2. **来源信誉** — 官方源（`vercel-labs`, `anthropics`）更可信
3. **GitHub Stars** — 低于 100 stars 的仓库需谨慎