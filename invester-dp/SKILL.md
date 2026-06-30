---
name: invester-dp
description: 🧭 一键导航：四步投资法决策助手。面对任何投资问题，自动判断你处于哪个阶段，告诉你该调用哪个 Skill、怎么串联、输出什么。避免"四个 Skill 在手但不知道用哪个"的困惑。
version: 1.1.0
author: zhaobu
last_updated: 2026-06-30
tags: [决策, 导航, 路由]
dependencies:
  skills: [hotspot-chain-hunter, sector-stock-hunter, six-dimension-hunter, thesis-tracker]
  data: []
agent_created: true
---

# 四步投资法 · 决策导航助手

## Overview

**你不是不会用工具，你是不确定现在该用哪个工具。**

这个 Skill 是一个**投资决策导航**。你只需描述你当下的状态，它就告诉你：
1. 你现在处在什么阶段？
2. 应该用四个 Skill 中的哪一个？
3. 下一步需要做什么？
4. 输出形式是什么？

> **v1.1 重大更新（2026-06-30）**
> - 从"三步投资法"升级为"四步投资法"（新增 `sector-stock-hunter`）
> - 完整覆盖全部 4 个 Skill 的路由与触发语
> - 决策树新增"已知板块名"分支
> - 一句话快速索引扩展到 4 个 Skill
> - 365 天宁德时代案例增加 sector-stock-hunter 节点

---

## 四句话记住四个 Skill

| Skill | 一句话 | 解决什么问题 |
|:---|:---|:---|
| **hotspot-chain-hunter** | **"市场在炒什么？怎么选股？"** | 不知道市场在炒什么，跟哪条线 |
| **sector-stock-hunter** | **"已知XX板块，怎么选股？"** | 已经看好某个板块，但板块内有几十只不知道买谁 |
| **six-dimension-hunter** | **"这家公司值得买吗？"** | 已经看到某家公司，想知道能不能长期持有 |
| **thesis-tracker** | **"我买的这家现在怎么处理？"** | 已经买了，该加仓/减仓/清仓/持有 |

---

## 四步投资法流程

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

## 使用指引：你在哪个阶段？

### 🅰 场景：还没买，想知道该买什么

#### 🅰a 子场景：不知道市场在炒什么

```
"我想买股票，但不知道买什么方向"
  │
  └─ 用 hotspot-chain-hunter
     输入："帮我跑一下当前热点深挖"
     输出：热点方向 + 产业链 + 精选标的
     ↓
  得到候选标的后 → six-dimension-hunter 评分
```

#### 🅰b 子场景：已知板块/方向，但不知道怎么选股（v1.1 新增）

```
"我知道XX板块很火，但不会选股"（如"光伏板块"、"AI算力"）
  │
  └─ 用 sector-stock-hunter（v1.1 新增）
     输入："帮我用 sector-stock-hunter 从光伏板块选股"
     输出：板块成分股 → 排雷 → 6 维评分 → 加权矩阵 → Top 1-2
     ↓
  选出 Top 1-2 标的后 → six-dimension-hunter 完整复评
```

#### 🅰c 子场景：已经有具体目标公司

```
"我听说XX公司不错"（如"宁德时代"）
  │
  └─ 用 six-dimension-hunter
     输入："帮我 6 维评分一下宁德时代"
     输出：完整 6 维评分 + 买入区间 + 目标价
```

#### 🅰d 子场景：想自选筛选条件

```
"帮我筛 PE<30、ROE>20%、现金流好的"
  │
  └─ 用 six-dimension-hunter
     输入："用 6 维评分自定义筛选 PE<30、ROE>20%、OCF/NI>80%"
     输出：候选标的列表 + 6 维评分
```

---

### 🅱 场景：已经买了，想知道怎么处理

```
"我已经买了XX股票，接下来怎么办？"
  │
  ├─ 第一次管理？ → thesis-tracker Step 0-1
  │                   输入："帮我为宁德时代建持仓档案"
  │                   输出：完整投资档案（买入逻辑+监控指标）
  │
  ├─ 定期复盘？ → thesis-tracker Step 3
  │              输入："帮我复盘宁德时代"
  │              输出：逻辑兑现度 + 加减仓建议
  │
  ├─ 出现新情况？
  │    │
  │    ├─ 股价大跌/大涨 → thesis-tracker Step 4-5
  │    │                  输入："宁德时代跌到 360 了，该怎么操作"
  │    │
  │    ├─ 公司出业绩/发公告 → thesis-tracker Step 2-3
  │    │                       输入："宁德时代发中报了，帮我检查监控指标"
  │    │
  │    ├─ 所在板块有大事 → hotspot-chain-hunter
  │    │                     输入："储能板块出了政策，对宁德影响多大"
  │    │                     输出：板块层面的重新评估
  │    │
  │    ├─ 想全面重评板块 → sector-stock-hunter（v1.1 新增）
  │    │                    输入："重新跑一遍储能板块，看宁德还是首选吗"
  │    │                    输出：板块最新评分，宁德排名是否变化
  │    │
  │    └─ 想卖了 → thesis-tracker Step 6
  │                 输入："我想清仓宁德时代，帮我做退出复盘"
  │
  └─ 整体看组合？ → thesis-tracker 场景 3（组合体检）
                    输入："帮我做组合月度体检"
                    输出：组合整体评估 + 再平衡建议
```

---

### 🅲 场景：已经退出，想反思学习

```
"我之前买了宁德时代，现在全卖掉了，想复盘"
  │
  └─ 用 thesis-tracker Step 6
     输入："帮我做宁德时代的退出复盘"
     输出：退出复盘报告 + 经验教训 + lessons-learned.md 更新
```

---

### 🅳 场景：整体看一下投资状况

```
"帮我看看我现在持仓怎么样"
  │
  └─ 用 thesis-tracker 场景 3（组合体检）
     输入："帮我做组合月度体检"
     输出：组合整体表现 + 相关性检查 + 调仓建议
```

---

## 决策树（一图看懂）

```
你现在是什么状态？
       │
       ├── "我还没买股票" ─────────────────────────────┐
       │   │                                             │
       │   ├── 不知道买什么（不知道方向）                │
       │   │    → hotspot-chain-hunter                   │
       │   │    ↓                                        │
       │   │    得到候选 → six-dimension-hunter 评分    │
       │   │    ↓                                        │
       │   │    评分通过 → thesis-tracker 建仓档案      │
       │   │                                            │
       │   ├── 知道板块名（如"光伏"）                    │
       │   │    → sector-stock-hunter（v1.1 新增）       │
       │   │    ↓                                        │
       │   │    选出 Top 1-2 → six-dimension-hunter     │
       │   │    ↓                                        │
       │   │    评分通过 → thesis-tracker 建仓档案      │
       │   │                                            │
       │   ├── 知道具体公司 → six-dimension-hunter      │
       │   │    ↓                                        │
       │   │    评分通过 → thesis-tracker 建仓档案      │
       │   │                                            │
       │   └── 自定义筛选条件                           │
       │        → six-dimension-hunter                   │
       │                                                │
       ├── "我已经买了股票" ───────────────────────────┐
       │   │                                             │
       │   ├── 还没建档 → thesis-tracker Step 0-1       │
       │   ├── 定期复盘 → thesis-tracker Step 3         │
       │   ├── 出现新情况                               │
       │   │    ├─ 股价异动 → thesis-tracker Step 4-5  │
       │   │    ├─ 业绩/公告 → thesis-tracker Step 2-3 │
       │   │    ├─ 板块大事 → hotspot-chain-hunter      │
       │   │    └─ 想重评板块 → sector-stock-hunter    │
       │   ├── 想卖了 → thesis-tracker Step 6           │
       │   └── 组合检查 → thesis-tracker 场景 3         │
       │                                                │
       └── "我想复盘学习" ─────────────────────────────┐
           │                                             │
           └── thesis-tracker Step 6                     │
               输出 ../thesis-tracker/references/lessons-learned.md
```

---

## 实战案例：四步投资法管理宁德时代 365 天

### Day 1（建仓前）

| 时间 | 用户状态 | 用哪个 Skill | 输入 | 输出 |
|:---|:---|:---|:---|:---|
| 早上 | "今天什么方向有钱？" | hotspot-chain-hunter | "帮我跑热点深挖" | 储能方向 → 储能电池子板块 → 宁德时代被推荐 |
| 中午 | "储能板块里买哪只最稳？" | sector-stock-hunter（v1.1） | "用 sector-stock-hunter 从储能板块选股" | 储能板块成分股 → 排雷 → 6 维评分 → 加权矩阵 → 宁德 vs 比亚迪，宁德第一 |
| 下午 | "宁德真的值得买吗？" | six-dimension-hunter | "帮我评分宁德时代" | 162/190，🔴 强烈推荐，目标价 550，空间 36% |
| 晚上 | "决定了，明天买" | thesis-tracker | "帮我建宁德档案" | 投资档案（买入逻辑+监控指标+止损规则） |

### Day 30（首次月复盘）

| 时间 | 用户状态 | 用哪个 Skill | 输入 | 输出 |
|:---|:---|:---|:---|:---|
| 月底 | "持仓一个月了，复盘一下" | thesis-tracker Step 3 | "帮我复盘宁德" | 储能装机 Q2+45%，市占率 35%，加权兑现度 88% → 🟢 A 兑现 → 继续持有 |

### Day 90（季报披露）

| 时间 | 用户状态 | 用哪个 Skill | 输入 | 输出 |
|:---|:---|:---|:---|:---|
| 财报日 | "宁德发了季报，怎么看？" | thesis-tracker Step 2-3 | "检查宁德监控指标" | 净利超预期 15%，触发"业绩超预期"加仓信号 |
| 决策 | "加仓多少？" | thesis-tracker Step 5 | "执行加仓" | 加仓 15%，更新档案 |

### Day 200（市场变化）

| 时间 | 用户状态 | 用哪个 Skill | 输入 | 输出 |
|:---|:---|:---|:---|:---|
| 行业变动 | "储能板块最近跌了很多" | hotspot-chain-hunter | "储能板块现在什么情况？" | 储能从🟡适中降温至🟢冷门，但基本面未变 |
| 重评板块 | "宁德在储能板块里还是首选吗？" | sector-stock-hunter（v1.1） | "重新跑一遍储能板块" | 宁德仍然第一，但总分从 162 降至 155 |
| 重评个股 | "那宁德还要留着吗？" | thesis-tracker Step 3 | "重新评估宁德逻辑" | 储能装机 Q3+15%（接近看空阈值），减仓 30% |

### Day 365（退出）

| 时间 | 用户状态 | 用哪个 Skill | 输入 | 输出 |
|:---|:---|:---|:---|:---|
| 目标价到 | "宁德涨到 550 了" | thesis-tracker Step 4 | "检查清仓信号" | 触发目标价到位 → 清仓 |
| 复盘 | "卖完了，学点什么？" | thesis-tracker Step 6 | "帮我做退出复盘" | 退出报告 + 经验教训 + lessons-learned.md 更新 |

---

## 一句话快速索引

把你当前的状态替换进去，直接当输入：

| 你的状态 | 对应的 Skill | 具体命令 |
|:---|:---|:---|
| "我不知道市场现在在炒什么" | `hotspot-chain-hunter` | "帮我跑一下当前热点深挖" |
| "我知道XX板块很火，但不会选股" | `sector-stock-hunter` | "用 sector-stock-hunter 从XX板块选股" |
| "我知道XX公司，帮我看看" | `six-dimension-hunter` | "帮我 6 维评分一下 XX" |
| "帮我筛 PE<30、ROE>20%、现金流好" | `six-dimension-hunter` | "用 6 维评分自定义筛选" |
| "我刚买了XX股票，帮我建个档案" | `thesis-tracker` | "帮我为 XX 建持仓档案，建仓价 XX" |
| "我的XX股票跌了，该怎么办" | `thesis-tracker` | "帮我检查 XX 的持仓信号，当前价 XX" |
| "帮我做一次持仓周复盘" | `thesis-tracker` | "帮我做持仓周复盘" |
| "我想重评板块，看宁德还是首选吗" | `sector-stock-hunter` | "重新跑一遍 XX 板块" |
| "我想清仓XX了，帮我做个退出复盘" | `thesis-tracker` | "帮我做 XX 的退出复盘，清仓价 XX" |
| "我之前买了XX现在全卖了" | `thesis-tracker` | "帮我做 XX 的退出复盘总结" |
| "帮我做组合月度体检" | `thesis-tracker` | "帮我做组合月度体检" |

---

## 常见误区

| 误区 | 你可能会问 | 正确做法 |
|:---|:---|:---|
| **用错 Skill** | "我有持仓了，帮我用六维捕手重新评一下" | 应该用 thesis-tracker 做持仓评估 |
| **跳步** | "帮我用热点深挖选 XX 公司" | 先 hotspot-chain-hunter，再 six-dimension-hunter |
| **板块名已知还用热点扫描** | "帮我从光伏板块选股" | 应该用 sector-stock-hunter，更精准 |
| **不做建档** | "我买了直接监控就行了吧" | 没有投资档案的持仓，遇到波动会不知道是否该卖 |
| **不做复盘** | "卖了就卖了，懒得复盘" | 不复盘等于"用一个亏钱的经验换了一个更贵的亏钱经验" |
| **频繁换股** | "这个涨了换那个" | 持仓未满 3 个月不轻易换，除非核心假设被推翻 |
| **不区分"评分"和"复评"** | "我还有XX股票，帮我重新评分" | 持仓的应该用 thesis-tracker 跟踪，不是重新 6 维评分 |

---

## 四步投资法依赖关系

```
hotspot-chain-hunter     sector-stock-hunter
   │ (输出候选标的)         │ (板块精选 Top 1-2)
   │                       │
   └────────┬──────────────┘
            ▼
    six-dimension-hunter
            │ (输出评分+买入区间)
            ▼
       thesis-tracker
            │ (建仓档案 → 监控 → 加减仓 → 退出复盘)
            ▼
        经验反哺 ←────────── 回到热点扫描/板块精选，优化方向判断
```

**调用规则**：
- **起点（选股）**：根据用户状态选 hotspot-chain-hunter 或 sector-stock-hunter
- **必经节点（评分）**：所有标的进入持仓前必须经过 six-dimension-hunter
- **终点（持仓）**：所有持仓都进入 thesis-tracker 管理
- **回环（复盘）**：退出后的经验回到 Step 1

---

## 使用节奏建议

| 频率 | 任务 | 工具 |
|:---|:---|:---|
| 每日盘前 | 快速检查持仓信号 | 人工 / thesis-tracker 自动化 |
| 每周一 | 热点扫描 | hotspot-chain-hunter（10 分钟） |
| 周末 | 自选股评分 | six-dimension-hunter（30 分钟） |
| 每月 | 组合体检 | thesis-tracker 场景 3（30 分钟） |
| 选中板块 | 板块精选 | sector-stock-hunter（1-2 小时） |
| 季度财报 | 持仓复盘 | thesis-tracker Step 2-3 |
| 退出时 | 退出复盘 | thesis-tracker Step 6 |

---

## 跨 Skill 数据契约

为支持调用链自动化，约定以下数据格式：

**hotspot-chain-hunter → six-dimension-hunter**：
```json
[
  {
    "code": "300750",
    "name": "宁德时代",
    "sector": "储能",
    "subSector": "储能电池",
    "sixDimScore": 162,
    "rating": "强烈推荐",
    "recommendedAction": "建仓"
  }
]
```

**sector-stock-hunter → six-dimension-hunter**：
```json
{
  "sector": "储能",
  "topPicks": [
    {"code": "300750", "name": "宁德时代", "weightedScore": 92, "rank": 1}
  ]
}
```

**six-dimension-hunter → thesis-tracker**：
```json
{
  "code": "300750",
  "name": "宁德时代",
  "sixDimScore": 162,
  "rating": "强烈推荐",
  "buyRange": "320-360",
  "targetPrice": 550,
  "stopLoss": 290,
  "coreReasons": ["储能装机高增", "市占率35%", "OCF/NI 105%"]
}
```

---

## 边界与原则

- **不构成投资建议**：所有报告末尾必须标注
- **4 个 Skill 协同**：本 Skill 本身不产生投资建议，只做导航
- **保持中立**：不为某个 Skill 站队，按用户实际状态推荐

---

**本报告仅供参考，不构成个人投资建议。所有数据来源于公开市场信息，可能存在延迟。投资有风险，决策需谨慎。**
