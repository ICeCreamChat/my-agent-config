---
description: 使用 scientific-visualization 创建出版级科研图表，支持 matplotlib/seaborn/plotly，色盲友好配色，多期刊格式导出（PDF/EPS/TIFF/PNG）
---

# 科研可视化工作流

基于 **scientific-visualization**（Academic Forge 本地内置，MIT 许可）

## 技能路径

```
c:\Users\ICe\.agent\AcademicForge\skills\scientific-visualization
```

## 核心能力

| 能力 | 说明 |
|------|------|
| 📈 出版级样式模板 | 期刊风格（Nature/Science/Cell）、字体/线宽/配色一致化 |
| 📐 多子图布局 | Panel labels、legend、单位、误差线规范 |
| 🎨 色盲友好配色 | Okabe-Ito 色板、灰度可读性校验 |
| 📤 导出优化 | PDF/EPS/TIFF/PNG，分辨率与尺寸对齐投稿要求 |
| 📊 统计可视化 | 误差线（SD/SEM/CI）、显著性标注、个体数据点展示 |

## 工具链

- **matplotlib** — 多面板精细控制，使用提供的 `.mplstyle` 样式文件
- **seaborn** — 统计图表（箱线图、小提琴图、热力图、聚类图）
- **plotly** — 交互式探索 + 静态图导出

## 使用方式

1. 阅读 `SKILL.md` 获取完整指令
2. 按目标期刊配置样式：
   ```python
   from style_presets import configure_for_journal
   configure_for_journal('nature', figure_width='single')
   ```
3. 使用色盲友好配色创建图表
4. 导出前检查尺寸与分辨率合规性
5. 使用提交前检查清单验证所有项

## 适用场景

- 论文投稿级图表制作
- 统计结果可视化（含误差线与显著性）
- 多面板组合图（Figure 1/2/3...）
- 现有图表改造为出版标准
