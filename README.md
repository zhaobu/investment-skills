# 📊 投资决策 Skill 体系 · WorkBuddy

> **一个完整的 A 股投资决策工具链：从发现机会、评估标的到管理持仓，全部覆盖。**
> 当前版本：**v1.1.0**（2026-06-30）— 重大优化，详见 [CHANGELOG.md](CHANGELOG.md)

---

## 🎯 这是什么

这是一套运行在 [WorkBuddy](https://workbuddy.app) / [Cursor](https://cursor.sh) 等 AI Editor 中的**投资决策 Skill** 集合。由 **5 个相互配合的 Skill** 组成，覆盖 A 股投资的完整闭环：

```
市场热点扫描 → 产业链深挖 → 板块精选 → 六维评分 → 持仓管理 → 退出复盘
```

**核心原则**：不追涨杀跌，不做情绪化交易。研究结论要经得起 3 年后回看。

---

## 🧩 Skill 一览

| Skill | 一句话 | 解决什么问题 |
|:---|:---|:---|
| 🔥 **hotspot-chain-hunter** | 热点产业链深挖选股器 | "市场在炒什么？怎么选股？" |
| 🎯 **sector-stock-hunter** | 板块精选 7 步法选股器 | "这个板块里买哪只？" |
| ⭐ **six-dimension-hunter** | 六维捕手评分筛选器 | "这家公司值不值得买？" |
| 📋 **thesis-tracker** | 投资逻辑跟踪器 | "我买的持仓现在怎么处理？" |
| 🧭 **invester-dp** | 四步投资法决策导航 | "我现在该用哪个 Skill？" |

---

## 🆕 v1.1 重大更新

> 从 5 个 541-700 行的"巨石 SKILL.md"重构为模块化架构，全面升级。

### 主要变化
- ✅ **拆分 SKILL.md + references/**：单文件 541-700 行 → 入口 344-420 行 + references
- ✅ **6 维评分单一来源**：消除三处重复定义，避免标准漂移
- ✅ **跨平台数据源路径**：支持 macOS / Linux / Cursor
- ✅ **invester-dp 整合 sector-stock-hunter**：完整覆盖 4 个 Skill（原版只覆盖 3 个）
- ✅ **估值评分改连续函数**：避免边界突变
- ✅ **现金流验证改 3 年滚动**：过滤非经常项美化
- ✅ **反指信号机制**：避免情绪过热时接盘
- ✅ **ATR 止损**：波动率自适应（原版 -15% 一刀切）
- ✅ **监控指标核心/辅助权重**：核心假设不被辅助指标掩盖
- ✅ **信号冲突处理矩阵**：核心假设被推翻 > 一切
- ✅ **产业链模板扩展到 7 种**：新增政策驱动/周期资源/出海链
- ✅ **全局图标规范**：跨 Skill 评级一致

### 📁 新结构
```
investment-skills/
├── README.md
├── CHANGELOG.md                      # 🆕 版本更新日志
├── references/                        # 🆕 全局共享引用
│   ├── scoring-rubric.md             # 🆕 6 维评分标准（单一来源）
│   ├── data-routing.md               # 🆕 数据源路径+降级方案
│   └── icon-legend.md                # 🆕 全局图标规范
├── bin/                              # 🆕 工具脚本
│   ├── detect-data-paths.sh          # 🆕 macOS/Linux 路径探测
│   └── detect-data-paths.ps1         # 🆕 Windows 路径探测
├── hotspot-chain-hunter/
│   ├── SKILL.md
│   └── references/                   # 🆕 拆分出的详细内容
├── sector-stock-hunter/
│   ├── SKILL.md
│   └── references/                   # 🆕 拆分出的详细内容
├── six-dimension-hunter/
│   ├── SKILL.md
│   └── references/                   # 🆕 拆分出的详细内容
├── thesis-tracker/
│   ├── SKILL.md
│   └── references/                   # 🆕 拆分出的详细内容
└── invester-dp/
    └── SKILL.md
```

详细变更见 [CHANGELOG.md](CHANGELOG.md)。

---

## 🚀 快速上手

### 前置条件

这些 Skill 依赖以下金融数据源：

- **neodata-financial-search**：自然语言金融数据搜索（A 股/港股/美股行情、财报、板块、宏观等）
- **westock-data**：腾讯自选股结构化行情数据（实时行情、资金流向、机构评级、一致预期等）

Skill 会自动按优先级（neodata → westock-data → WebSearch）路由数据请求。

### 安装

```bash
# 克隆到本地
git clone https://github.com/zhaobu/investment-skills.git

# 将 Skill 复制到 WorkBuddy 的 skills 目录
cp -r investment-skills/* ~/.workbuddy/skills/

# 加载数据源路径（v1.1 新增）
source ~/.workbuddy/skills/bin/detect-data-paths.sh   # macOS/Linux
# 或
. ~/.workbuddy/skills/bin/detect-data-paths.ps1       # Windows
```

### 一句话开始

打开 AI Editor，直接输入：

> **"我想买股票但不知道买什么"**

系统会自动判断当前阶段，调用对应的 Skill 完成分析。

或者试试这些：

| 你的状态 | 直接说 |
|:---|:---|
| 不知道市场在炒什么 | "帮我跑一下当前热点深挖" |
| 看好某个板块但不会选股 | "用 sector-stock-hunter 从储能板块选股" |
| 看好某个板块但不会拆解产业链 | "帮我分析储能板块的产业链，每个环节选最好的" |
| 已经有目标公司 | "帮我 6 维评分一下宁德时代" |
| 已经买了股票 | "帮我为宁德时代建持仓档案" |
| 持仓跌了 | "帮我检查宁德时代的持仓信号" |
| 想清仓了 | "帮我做宁德时代的退出复盘" |
| 想重评板块 | "重新跑一遍储能板块，看宁德还是首选吗" |
| 想做组合体检 | "帮我做组合月度体检" |

---

## 📋 Skill 详解

### 🔥 hotspot-chain-hunter — 热点产业链深挖选股器

**7 步流程**：
```
Step 0: 市场环境判断（强市/震荡/弱市/退潮）
Step 1: 市场热点扫描（Top 5 方向）
Step 1.5: 持续性验证（4 维过滤一日游）
Step 1.6: 反指信号检查（v1.1 新增，避免情绪过热接盘）
Step 2: 含金量评估 + 生命周期位置（🌱萌芽/🚀主升/🎆高潮/🍂退潮）
Step 3: 产业链拆解（7 种模板，v1.1 从 4 种扩展）
Step 4: 6 维评分（每个子板块精选 Top 1-2）
Step 5: 排除分析
Step 6: 输出完整报告
```

**v1.1 特色**：
- 🛡️ 持续性四维验证
- 📍 生命周期位置判断
- 🔍 方向质量预检
- 🕵️ 潜伏池+轮动触发条件
- 🚨 **反指信号机制**（v1.1 新增）

---

### 🎯 sector-stock-hunter — 板块精选 7 步法选股器

**解决什么问题**：你知道某个板块有行情（如"半导体材料涨了"），但板块内有几十只股票不知道买谁。

**7 步流程**：
```
Step 0: 数据准备 → 板块代码 + 成分股 + 研报
Step 1: 热度初判 → YTD/PE 分位/资金流向
Step 2: 驱动拆解 → 3 年可持续性
Step 2.5: 板块放弃（无持续因素→直接放弃）
Step 3: 排雷预筛选（6 类淘汰）
Step 4: 6 维评分
Step 5: 催化剂日历 ⚠️ catalyst-calendar 暂未提供
Step 6: 加权矩阵终选（1-3 年持有期）
Step 7: 投资逻辑记录
```

**加权矩阵**（Step 6）：

| 维度 | 权重 | 评分逻辑 |
|:---|:---:|:---|
| 2028E PE | 30% | 远期估值越低越好 |
| 现金流质量 | 20% | 3 年 OCF/NI 均值 |
| 护城河/稀缺性 | 20% | 复用维度①② |
| 3 年净利 CAGR | 15% | 增长动力强度 |
| 主题纯度 | 10% | 赛道纯粹度 |
| 当前安全边际 | 5% | 回调空间 |

**v1.1 风险惩罚项**（新增）：
- 3 年 OCF/NI 持续 < 50% → 自动降一档
- 应收账款增速 > 营收增速 3 年连续 → 总分 × 0.9
- 高管/大股东减持 > 3% → 总分 × 0.95

---

### ⭐ six-dimension-hunter — 六维评分筛选器

**6 维框架**（满分 190 分）：

| 维度 | 权重 | 核心标准 |
|:---|:---:|:---|
| ① 稀缺性 | ★★★★ | 全球/国内竞争者数量 |
| ② 龙头地位 | ★★★★ | 全球/国内市占率排名 |
| ③ 3-5 年确定性 | ★★★★ | 下游需求确定性、CAGR |
| ④ 估值未透支 | ★★★★ | PE_fwd + 2028E PE（v1.1 改连续函数） |
| ⑤ 主题纯度 | ★★★ | 主题相关收入占比 |
| ⑥ 现金流验证 | ★★★ | 3 年 OCF/NI 均值（v1.1 改 3 年滚动） |

**v1.1 改进**：
- 🎯 赛道差异化门槛（5 类）
- 🔍 5 类预期差识别
- 📐 同分去重规则
- 🚨 **反指信号机制**（v1.1 新增）

**评级**：
- 🔴 ≥ 140：强烈推荐
- 🟡 110-139：值得关注
- 🟢 75-109：观察等待
- ⛔ < 75：淘汰

详细评分见 [`references/scoring-rubric.md`](references/scoring-rubric.md)

---

### 📋 thesis-tracker — 投资逻辑跟踪器

**7 步流程**：
```
Step 0: 持仓档案初始化
Step 1: 买入逻辑记录（必须可证伪）
Step 2: 监控指标设定（v1.1 核心/辅助权重）
Step 3: 定期复盘
Step 4: 信号触发识别（v1.1 加冲突处理矩阵）
Step 5: 加减仓决策
Step 6: 退出复盘总结
```

**v1.1 特色**：
- ⚡ **3 层止损防线**：初始 / 跟踪 / 硬止损
- 📊 **ATR 止损**（v1.1 新增，波动率自适应）
- 🦢 黑天鹅 3 级响应
- 🧠 7 种常见错误模式
- 🔄 退出强制复盘
- ⚖️ **核心/辅助指标权重**（v1.1 新增）
- 🆘 **信号冲突处理矩阵**（v1.1 新增）

---

### 🧭 invester-dp — 四步投资法决策导航（v1.1 重大更新）

**v1.1 重大变更**：从"三步投资法"升级为"四步投资法"，**完整覆盖 4 个选股/持仓 Skill（原版只覆盖 3 个）**。

**4 大场景入口**：
- 🅰 还没买，不知道买什么 → hotspot-chain-hunter
- 🅰 还没买，知道板块 → sector-stock-hunter → six-dimension-hunter（**v1.1 新增**）
- 🅱 已经买了 → thesis-tracker
- 🅲 已退出 → thesis-tracker Step 6
- 🅳 组合体检 → thesis-tracker 场景 3

**4 步流程**：
```
[Step 1] 确定方向
  ├─ 不知道方向 → hotspot-chain-hunter
  └─ 已知方向（板块名）→ sector-stock-hunter
          ↓
[Step 2] 评估个股 → six-dimension-hunter
          ↓
[Step 3] 建仓 + 监控 → thesis-tracker
          ↓
[Step 4] 退出 + 复盘 → thesis-tracker Step 6
          ↓
     经验反哺 → 回到 Step 1
```

---

## 🎬 实战案例：宁德时代 365 天完整流程（v1.1 扩展）

| 时间 | 动作 | Skill |
|:---|:---|:---|
| Day 1 早上 | 扫热点 → 发现储能方向 | hotspot-chain-hunter |
| Day 1 中午 | 板块精选 → 选出宁德时代等核心标的 | sector-stock-hunter |
| Day 1 下午 | 评宁德时代 → 162/190 强烈推荐 | six-dimension-hunter |
| Day 1 晚上 | 建持仓档案 + 设监控指标 | thesis-tracker |
| Day 30 | 月复盘：储能装机 +45%，继续持有 | thesis-tracker |
| Day 90 | 季报超预期 → 触发加仓信号 | thesis-tracker |
| Day 200 | 储能板块降温 → 重评板块 | hotspot-chain-hunter + sector-stock-hunter |
| Day 200 | 减仓 30% | thesis-tracker |
| Day 365 | 目标价到 → 清仓 → 退出复盘 | thesis-tracker |

---

## 🔧 技术栈

| 组件 | 说明 |
|:---|:---|
| **框架** | WorkBuddy Skill (SKILL.md) 标准格式 |
| **架构** | SKILL.md 入口 + references/ 模块化（v1.1） |
| **数据层** | neodata-financial-search + westock-data |
| **补充** | WebSearch（公开信息检索） |
| **评分模型** | 六维捕手（单一来源 + 加权评分 + 淘汰制） |
| **投资方法论** | 卖方分析师标准（摘要→分析→估值→风险→评级） |

---

## 📚 文档导航

| 文档 | 内容 |
|:---|:---|
| [README.md](README.md) | 本文件 |
| [CHANGELOG.md](CHANGELOG.md) | 版本更新日志 |
| [references/scoring-rubric.md](references/scoring-rubric.md) | 6 维评分标准（单一来源） |
| [references/data-routing.md](references/data-routing.md) | 数据源路径与降级方案 |
| [references/icon-legend.md](references/icon-legend.md) | 全局图标规范 |

---

## ⚠️ 免责声明

> **本仓库所有内容仅供参考学习，不构成任何投资建议。**
>
> 所有数据来源于公开市场信息，可能存在延迟。投资有风险，决策需谨慎。
>
> 作者不持有文中提及的任何股票，亦不提供个股买卖建议。

---

## 📬 联系 & 贡献

- 作者：赵布
- 微信：zhaobulw
- 邮箱： [zhaobulw@qq.com](mailto:zhaobulw@qq.com)
- 反馈问题 / 提出建议 → [提交 Issue](https://github.com/zhaobu/investment-skills/issues)

### 贡献指南

1. Fork 本仓库
2. 创建你的特性分支 (`git checkout -b feature/amazing-skill`)
3. 提交你的改动 (`git commit -m 'Add some amazing-skill'`)
4. 推送到分支 (`git push origin feature/amazing-skill`)
5. 创建一个 Pull Request

> **修改评分标准前**：请先阅读 [references/scoring-rubric.md](references/scoring-rubric.md)，确保理解单一来源原则。

---

## 📜 License

MIT License — 自由使用、修改、分发。
