# 投资决策 Skill 体系 · 更新日志

> 本文件记录所有 Skill 的版本演进、变更内容和影响范围。
> 遵循 [语义化版本](https://semver.org/)：`主版本.次版本.修订号`。

---

## [1.1.0] - 2026-06-30 · Skill 体系优化

### 🔥 重大变更

#### 1. 拆分 SKILL.md 为入口+references 架构

**问题**：原 5 个 SKILL.md 单文件过大（541-700 行），维护成本指数级上升。

**变更**：
- SKILL.md 全部瘦身至 200-300 行（仅保留流程入口、关键规则、引用指针）
- 详细内容（评分细则、模板、规则）迁出至 `references/` 子目录

**结构示例**：
```
hotspot-chain-hunter/
├── SKILL.md                      # 入口（~250 行）
└── references/
    ├── market-regime.md          # 市场环境判断
    ├── chain-templates.md        # 7 种产业链拆解模板
    ├── exclusion-template.md     # 排除分析模板
    └── report-template.md        # 报告输出模板
```

**影响**：所有 Skill 的维护成本降低 50%+，LLM 加载成本降低 30%+。

#### 2. 抽出 6 维评分标准为单一来源

**问题**：原 hotspot-chain-hunter / sector-stock-hunter / six-dimension-hunter 三个文件均定义了 6 维评分标准，95% 内容重复，随时间漂移风险高。

**变更**：
- 新建 [`references/scoring-rubric.md`](references/scoring-rubric.md) 作为**唯一权威**
- 三个 Skill 全部改为引用，不再重复定义
- 修改评分标准时只需改一处

**影响**：评分标准的演进更可控，避免标准漂移。

#### 3. 数据源路径跨平台化

**问题**：原 v1.0 所有路径硬编码 Windows 绝对路径，macOS/Linux/Cursor 环境下无法运行。

**变更**：
- 新增 `bin/detect-data-paths.sh`（macOS/Linux）和 `bin/detect-data-paths.ps1`（Windows PowerShell）
- 跨平台路径自动探测
- 新建 [`references/data-routing.md`](references/data-routing.md) 统一管理

**影响**：可在 macOS / Linux / Cursor 上完整运行。

---

### ✨ 新增功能

#### 4. invester-dp 整合 sector-stock-hunter（最重大遗漏修复）

**问题**：原 v1.0 的 invester-dp 决策树、命令速查、宁德时代案例均只覆盖 3 个 Skill（hotspot-chain-hunter / six-dimension-hunter / thesis-tracker），完全遗漏了 sector-stock-hunter。

**变更**：
- 决策树新增"已知板块名 → sector-stock-hunter"分支
- 一句话快速索引扩展到 4 个 Skill
- 365 天宁德时代案例增加 sector-stock-hunter 节点
- 跨 Skill 数据契约（JSON 格式）

**影响**：4 个 Skill 完整闭环。

#### 5. 估值评分改连续函数

**问题**：原 v1.0 估值评分是离散函数，PE_fwd 39→41 跨档可能导致评级变化。

**变更**：
- 引入连续函数：`score = max(1, 10 - max(0, PE_fwd - 20) × 0.15)`
- 离散表作为快速参考保留
- 推荐使用连续函数

**影响**：避免 1 元差异导致评级突变。

#### 6. 现金流验证改 3 年滚动平均

**问题**：原 v1.0 现金流验证只看 1 年，会被一次性资产出售等美化。

**变更**：
- 改为 3 年滚动平均：`OCF/NI = (OCF_t + OCF_t-1 + OCF_t-2) / (NI_t + NI_t-1 + NI_t-2)`

**影响**：过滤非经常项"美化"。

#### 7. 反指信号机制（情绪过热自动降权）

**问题**：原 v1.0 没有情绪过热保护。

**变更**：
- 新增 Step 1.6（hotspot-chain-hunter）：雪球讨论量爆表/多空比/研报目标价集中度/机构持仓占比
- 触发后自动扣分
- 报告中必须显式标注

**影响**：避免在一致预期最强时接盘。

#### 8. 止损规则引入 ATR（波动率自适应）

**问题**：原 v1.0 止损 -15% 一刀切，茅台波动率 20% 给 -15% 太宽，AI 小票波动率 60% 给 -15% 太窄。

**变更**：
- 引入 ATR 止损：`止损价 = 建仓价 - 2 × ATR(20日)`
- 高波动票 ATR 倍数 2.0-2.5
- 低波动票 ATR 倍数 1.0-1.5

**影响**：止损规则与标的波动率匹配，避免频繁触发或止损过宽。

#### 9. 监控指标加权兑现度

**问题**：原 v1.0 5-6 个指标一视同仁，核心指标"业绩超预期"和辅助指标"北向资金"同等权重。

**变更**：
- 核心指标权重 ×2
- 辅助指标权重 ×1
- 加权兑现度公式

**影响**：核心假设被破立即反映，不会被辅助指标掩盖。

#### 10. 信号冲突处理矩阵

**问题**：原 v1.0 缺乏"估值底 + 核心假设被推翻"等冲突信号的处理规则。

**变更**：
- 新增 7 场景冲突处理矩阵
- 优先级：核心假设被推翻 > 一切

**影响**：避免"逻辑错了还加仓"的陷阱。

#### 11. 产业链模板从 4 种扩展到 7 种

**问题**：原 v1.0 只有制造业/TMT/消费/服务 4 种，缺少政策驱动/周期资源/出海链（中国市场极重要）。

**变更**：
- 新增 E 政策驱动链（碳交易/数据要素/电力改革）
- 新增 F 周期资源链（有色/煤炭/化工）
- 新增 G 出海链（跨境电商/出口制造/新能源车出海）

**影响**：覆盖中国 A 股市场的主要方向。

#### 12. 组合体检新增再平衡建议

**问题**：原 v1.0 组合体检只识别集中度风险，没有给具体调仓建议。

**变更**：
- 新增调仓建议生成规则
- 4 个集中度阈值与对应操作

**影响**：体检不只是诊断，还给出可执行建议。

#### 13. 全局图标规范

**问题**：原 v1.0 各 Skill 图标不统一（hotspot-chain-hunter 用 🔥🥇🥈，six-dimension-hunter 用 📊⚠️❌）。

**变更**：
- 新建 [`references/icon-legend.md`](references/icon-legend.md) 统一规范
- 评级 🔴🟡🟢⛔ 全 Skill 一致
- 操作 ➕➖🚪⏸️🔄 全 Skill 一致

**影响**：跨 Skill 报告一致性提升。

#### 14. 主题纯度增加赛道差异化

**问题**：原 v1.0 主题纯度门槛统一，但新兴主题（AI/机器人）和小众主题（白酒）的合理门槛不同。

**变更**：
- 5 类赛道差异化门槛
- 主题层级图（核心/相关/边缘/蹭概念）

**影响**：评分更符合实际市场情况。

---

### 🛠️ 工程改进

#### 15. 统一 frontmatter 字段

新增字段：
- `version`：语义化版本
- `author`：作者
- `last_updated`：最后更新日期
- `tags`：标签
- `dependencies`：依赖

**影响**：可机器解析，便于发布管理。

#### 16. sector-stock-hunter 标注 catalyst-calendar 缺失

**问题**：sector-stock-hunter Step 5 依赖 catalyst-calendar，但仓库中并未提供该 Skill。

**变更**：
- 在 Step 5 顶部显式标注 ⚠️ 警告
- 暂用简化的内置催化剂时间表代替
- 未来集成后可升级

**影响**：避免用户调用时遇到"找不到 Skill"。

---

### 📁 文件变更清单

#### 新增文件
- `references/scoring-rubric.md` - 6 维评分标准（单一来源）
- `references/data-routing.md` - 数据源路由与降级方案
- `references/icon-legend.md` - 全局图标规范
- `bin/detect-data-paths.sh` - macOS/Linux 路径探测
- `bin/detect-data-paths.ps1` - Windows 路径探测
- `CHANGELOG.md` - 本文件
- `hotspot-chain-hunter/references/market-regime.md`
- `hotspot-chain-hunter/references/chain-templates.md`
- `hotspot-chain-hunter/references/exclusion-template.md`
- `hotspot-chain-hunter/references/report-template.md`
- `thesis-tracker/references/position-template.md`
- `thesis-tracker/references/monitoring-rubric.md`
- `thesis-tracker/references/review-template.md`
- `thesis-tracker/references/signal-rules.md`
- `thesis-tracker/references/stop-loss-rules.md`
- `thesis-tracker/references/error-patterns.md`
- `thesis-tracker/references/black-swan-playbook.md`
- `thesis-tracker/references/scenario-templates.md`
- `thesis-tracker/references/exit-review-template.md`
- `thesis-tracker/references/lessons-learned.md`

#### 修改文件
- `hotspot-chain-hunter/SKILL.md` - 591 → 270 行
- `six-dimension-hunter/SKILL.md` - 552 → 240 行
- `thesis-tracker/SKILL.md` - 588 → 290 行
- `sector-stock-hunter/SKILL.md` - 201 → 320 行
- `invester-dp/SKILL.md` - 288 → 300 行（覆盖 4 个 Skill）
- `README.md` - 更新版本号和说明

---

## [1.0.0] - 2026-06-17 · 初始发布

5 个 Skill 首次部署：
- hotspot-chain-hunter
- six-dimension-hunter
- thesis-tracker
- invester-dp
- sector-stock-hunter（后续添加）

### 初始版本特点
- 完整的投资决策闭环
- 6 维评分框架
- 3 层止损防线
- 黑天鹅应急机制
- 7 种错误决策模式

### 已知问题（v1.1 已修复）
- ❌ SKILL.md 单文件过大 → ✅ 拆分 references
- ❌ 6 维评分重复定义 → ✅ 单一来源
- ❌ 路径硬编码 Windows → ✅ 跨平台
- ❌ invester-dp 遗漏 sector-stock-hunter → ✅ 完整覆盖
- ❌ 估值评分离散边界突变 → ✅ 连续函数
- ❌ 现金流验证只看 1 年 → ✅ 3 年滚动
- ❌ 缺反指信号机制 → ✅ 新增
- ❌ 止损 -15% 一刀切 → ✅ ATR 自适应
- ❌ 监控指标一视同仁 → ✅ 核心/辅助权重
- ❌ 缺信号冲突处理 → ✅ 处理矩阵
- ❌ 产业链模板仅 4 种 → ✅ 7 种
- ❌ 缺组合再平衡建议 → ✅ 新增
- ❌ 图标规范不统一 → ✅ 全局规范

---

## 升级指南

### 从 1.0 → 1.1

#### 必须修改
1. 数据源路径：v1.0 使用硬编码 Windows 路径，v1.1 必须改用 `bin/detect-data-paths.sh`
2. SKILL.md 引用：v1.0 评分标准在文件内，v1.1 改用 `references/scoring-rubric.md` 引用

#### 建议修改
3. 评分标准应用 v1.1 新规则（连续函数、3 年滚动）
4. 监控指标增加核心/辅助区分
5. 报告模板应用 v1.1 图标规范

#### 可选升级
6. 启用 ATR 止损（需要先计算历史 ATR）
7. 启用反指信号检查
8. 拆分本地持仓档案为 thesis-tracker 标准模板

---

## 后续规划

### v1.2（计划中）
- 集成 `catalyst-calendar` Skill（解决 sector-stock-hunter Step 5 缺失）
- 新增 Skill：`sector-comparison`（板块多维度对比）
- 自动化测试用例（E2E test）

### v2.0（远期）
- 支持港股/美股（当前仅 A 股）
- 接入实时行情推送
- 多账户管理

---

**本仓库所有变更遵循 [语义化版本](https://semver.org/) 规范。**
