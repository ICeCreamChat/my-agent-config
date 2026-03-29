---
description: 使用 planning-with-files 进行文件化任务管理，通过 task_plan.md / findings.md / progress.md 实现跨会话上下文持久化
---

# 文件化任务管理工作流

基于 **planning-with-files**（by [@OthmanAdi](https://github.com/OthmanAdi)，MIT 许可）

## 技能路径

```
c:\Users\ICe\.agent\AcademicForge\skills\planning-with-files
```

## 核心文件

| 文件 | 用途 | 更新时机 |
|------|------|----------|
| `task_plan.md` | 阶段拆解、验收标准、状态追踪 | 每个阶段完成后 |
| `findings.md` | 研究发现与关键证据沉淀 | 任何发现之后 |
| `progress.md` | 执行日志、测试结果与错误记录 | 整个会话过程中 |

## 关键规则

1. **先建计划** — 复杂任务必须先创建 `task_plan.md`
2. **2 次操作规则** — 每 2 次查看/搜索后立即保存发现到文件
3. **决策前阅读** — 重大决策前重新阅读计划文件
4. **行动后更新** — 完成每个阶段后更新状态
5. **记录所有错误** — 每个错误都进计划文件
6. **3 次失败协议** — 同一问题 3 次失败后上报用户

## 使用方式

1. 阅读 `SKILL.md` 完整指令
2. 从模板目录复制模板到项目根目录
3. 按模板结构创建 `task_plan.md`、`findings.md`、`progress.md`
4. 执行过程中持续更新这三个文件

## 在学术项目中的价值

- 🧭 **实验路线清晰化** — 降低中途跑偏风险
- 🧠 **上下文持久化** — 跨会话保持研究结论、假设与决策链
- 🧪 **复现实验更稳定** — 错误与尝试路径可追溯
