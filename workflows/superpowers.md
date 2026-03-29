---
description: 使用 superpowers 流程型技能库，强调先设计后实现再验证的工程纪律，包含头脑风暴、计划编写执行、系统化调试、TDD 与代码审查（14 个 skills）
---

# 工程流程与纪律工作流

基于 **superpowers**（by [@obra](https://github.com/obra)，MIT 许可）

## 技能路径

```
c:\Users\ICe\.agent\AcademicForge\skills\superpowers
```

## 包含 Skills（14 个）

| Skill | 用途 |
|-------|------|
| `brainstorming` | 把模糊需求收敛成可执行方案 |
| `writing-plans` | 把任务拆到可验证的粒度 |
| `executing-plans` | 按计划逐步执行并追踪进度 |
| `systematic-debugging` | 按步骤定位根因，避免拍脑袋修 bug |
| `test-driven-development` | 以测试驱动最小改动实现 |
| `requesting-code-review` | 发起代码审查请求 |
| `receiving-code-review` | 接收并处理审查反馈，形成闭环 |
| `verification-before-completion` | 完成前做证据化验证 |
| `using-superpowers` | 技能调度入口，确定何时使用哪个 skill |
| `dispatching-parallel-agents` | 并行代理调度 |
| `subagent-driven-development` | 子代理驱动开发 |
| `finishing-a-development-branch` | 分支完成与合并流程 |
| `using-git-worktrees` | Git worktree 多分支并行工作 |
| `writing-skills` | 编写新 skill 的元技能 |

## 核心理念

**先设计 → 后实现 → 再验证**，减少"直接开写导致返工"。

## 使用方式

1. 进入技能路径，选择对应场景的子目录
2. 阅读子目录中的 `SKILL.md`
3. 严格按照 skill 指令执行（rigid 类型 skill 不可变通）

## 在学术项目中的价值

- 📌 **课题与实验规划** — 先澄清假设、变量、验收标准
- 🧪 **实验管线开发** — 拆成可追踪步骤
- 🛠️ **复现实验与排错** — 系统化调试减少不可复现与隐性错误
- ✅ **交付质量** — 通过测试与验证保证结果与代码一致
