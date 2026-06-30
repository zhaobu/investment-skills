# 投资决策 Skill 体系 · WorkBuddy / QoderWork / Cursor 通用

> **一个完整的 A 股投资决策工具链：从发现机会、评估标的到管理持仓，全部覆盖。**
> 当前版本：**v1.1.3**（2026-06-30）— 跨目录数据源探测 + 离线模式标志
>
> ✅ **WorkBuddy** | ✅ **QoderWork** | ✅ **Cursor** | ✅ **通用 AI 编辑器**

---

## 🎯 这是什么

这是一套运行在 [WorkBuddy](https://workbuddy.app) / [Cursor](https://cursor.sh) / **QoderWork** 等 AI 编辑器中的**投资决策 Skill** 集合。由 **5 个相互配合的 Skill** 组成，覆盖 A 股投资的完整闭环：

```
市场热点扫描 → 产业链深挖 → 板块精选 → 六维评分 → 持仓管理 → 退出复盘
```

**核心原则**：不追涨杀跌，不做情绪化交易。研究结论要经得起 3 年后回看。

---

## 🆕 v1.1.3 重要修复（基于真实环境测试）

> 实地测试发现 v1.1.2 在用户实际环境（westock 与 neodata 不在同一目录）下失效。v1.1.3 全部修复。

### v1.1.3 核心变更

| # | 问题 | 严重性 | 修复 |
|:--|:---|:---:|:---|
| 1 | 路径探测假设所有数据源在同一个 `DATA_HOME`，但实测 westock 和 neodata 在不同目录 | 🔴 | ✅ 改为独立探测每个数据源 |
| 2 | 脚本默认 `PYTHON=python3`，但 Windows 上 `python3` 命令不存在 | 🔴 | ✅ 自动探测 WorkBuddy 自带 Python / `python.exe` |
| 3 | `WETOOL` 路径错误（指向 `westock-data/scripts/westock-tool` 但实际是独立目录） | 🟡 | ✅ 多路径探测 |
| 4 | 离线环境（无 westock/neodata）下所有 Skill 都会走完整流程但都失败 | 🟡 | ✅ 新增 `OFFLINE_MODE` 标志，未找到数据源时显式告知 |
| 5 | sector-stock-hunter Step 6 加权矩阵示例计算错误（8.45→8.35 标错） | 🟢 | ✅ 修正所有 3 个示例分数 |
| 6 | sector-stock-hunter Step 3 排雷条件 #2 逻辑歧义（"或/且"未括号化） | 🟡 | ✅ 改用括弧 `(PE_fwd>150 或 PE_TTM>200) 且 净利增速<50%` |
| 7 | sector-stock-hunter 缺乏板块类型差异化处理（周期股/防御型用同一 PE 阈值是错的） | 🟡 | ✅ 新增 5 种板块类型的 PE/CAGR 调整表 |
| 8 | sector-stock-hunter "次选"在 6 维 < 110 分时仍强行输出 | 🟢 | ✅ 改为"次选 6 维必须 ≥ 110，否则不输出" |

### v1.1.3 实地验证

```bash
$ bash bin/detect-data-paths.sh
✅ WorkBuddy 数据源已就位（v1.1.3 跨目录探测）

   数据脚本：
     WESTOCK_SCRIPT  = /c/Users/liwei/.workbuddy/plugins/marketplaces/experts/plugins/stock-partner-team/skills/westock-data/scripts/index.js
     NEODATA_SCRIPT  = /c/Users/liwei/.workbuddy/skills-marketplace/skills/neodata-financial-search/scripts/query.py
     WETOOL          = /c/Users/liwei/.workbuddy/plugins/marketplaces/experts/plugins/stock-partner-team/skills/westock-tool/scripts/index.js

   运行环境：
     PYTHON          = /c/Users/liwei/.workbuddy/binaries/python/versions/3.13.12/python
```

> ✅ westock 来自 `stock-partner-team` 目录，neodata 来自 `skills-marketplace` 目录，**被正确组合**

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

## 🆕 v1.1.2 跨 AI 工具兼容版本

> 解决 QoderWork 评估报告 (`~/.qoderwork/.../investment-skills-评估报告.md`) 发现的 3 个核心问题。

### 主要问题（QoderWork 评估报告）

| # | 问题 | 严重性 | 修复 |
|:--|:---|:---:|:---:|
| 1 | westock-data 路径硬编码，不匹配用户实际安装位置 | 🔴 严重 | ✅ v1.1.2 自动探测 |
| 2 | neodata 路径与 westock-data 不在同一目录 | 🔴 严重 | ✅ v1.1.2 分别探测 |
| 3 | 缺失 catalyst-calendar / morning-note 依赖未明确 | 🟡 中等 | ✅ v1.1.2 标记为 optional |

### v1.1.2 兼容性矩阵

| AI 工具 | 路径自动探测 | 5 个 Skill 可用性 |
|:---|:---:|:---|
| **WorkBuddy**（cb_teams_marketplace 安装） | ✅ | ✅ 完全可用 |
| **WorkBuddy**（experts/stock-partner-team 安装） | ✅ | ✅ 完全可用（QoderWork 评估报告中的实际位置） |
| **WorkBuddy**（skills-marketplace 散装） | ✅ | ✅ 完全可用 |
| **QoderWork** | ✅ | ✅ 完全可用 |
| **Cursor** | ✅ | ✅ 完全可用 |
| **macOS WorkBuddy.app** | ✅ | ✅ 完全可用 |
| **develope 调试版 WorkBuddy** | ✅ | ✅ 完全可用 |
| **纯 Chat（无数据源）** | ❌ | ⚠️ 仅 invester-dp 可用 |

### v1.1 自动探测的 7+ 种路径

`bin/detect-data-paths.sh`（macOS/Linux/QoderWork/Cursor）按以下顺序自动探测：

1. `WORKBUDDY_DATA_HOME` 环境变量
2. `WESTOCK_SCRIPT` / `NEODATA_SCRIPT` 环境变量
3. `~/.workbuddy/plugins/marketplaces/experts/plugins/stock-partner-team/skills`
4. `~/.workbuddy/skills-marketplace/skills`
5. `~/.workbuddy/plugins/marketplaces/cb_teams_marketplace/plugins/finance-data/skills`
6. `E:/develope/WorkBuddy/resources/...`
7. `/Applications/WorkBuddy.app/...`
8. `~/.qoderwork/skills`
9. `~/.cursor/skills`

---

## 🚀 快速上手

### 方式 1：WorkBuddy / QoderWork / Cursor 一键安装

```bash
# 克隆到本地
git clone https://github.com/zhaobu/investment-skills.git

# 复制 Skill 到目标目录
# WorkBuddy:
cp -r investment-skills/* ~/.workbuddy/skills/
# QoderWork:
cp -r investment-skills/* ~/.qoderwork/skills/
# Cursor:
cp -r investment-skills/* ~/.cursor/skills/

# 加载数据源路径（v1.1.2 自动探测）
source ~/.workbuddy/skills/bin/detect-data-paths.sh   # macOS/Linux/QoderWork
# 或
. ~/.workbuddy/skills/bin/detect-data-paths.ps1       # Windows
```

### 方式 2：仅使用 invester-dp（不需要数据源）

如果你的环境**没有**安装 westock-data / neodata（如纯 Cursor 演示）：

```bash
# 仍然可以安装，但只能完整使用 invester-dp
# 其他 4 个 Skill 会显示"数据不可用"提示，但流程仍可走通
```

### 验证安装

```bash
# 加载数据源
source bin/detect-data-paths.sh

# 验证路径（应显示绿色 ✅）
echo $WESTOCK_SCRIPT
echo $NEODATA_SCRIPT

# 测试数据工具
node "$WESTOCK_SCRIPT" quote 000001    # 测试 westock（应返回平安银行数据）
python "$NEODATA_SCRIPT" --query "贵州茅台主营构成"   # 测试 neodata
```

### 一句话开始

打开 AI 编辑器，直接输入：

> **"我想买股票但不知道买什么"**

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
Step 5: 催化剂日历 ⚠️ catalyst-calendar 是 optional skill
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

**评级**：
- 🔴 ≥ 140：强烈推荐
- 🟡 110-139：值得关注
- 🟢 75-109：观察等待
- ⛔ < 75：淘汰

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

### 🧭 invester-dp — 四步投资法决策导航

**v1.1 重大变更**：从"三步投资法"升级为"四步投资法"，**完整覆盖 4 个选股/持仓 Skill**。

**4 大场景入口**：
- 🅰 还没买，不知道买什么 → hotspot-chain-hunter
- 🅰 还没买，知道板块 → sector-stock-hunter → six-dimension-hunter
- 🅱 已经买了 → thesis-tracker
- 🅲 已退出 → thesis-tracker Step 6
- 🅳 组合体检 → thesis-tracker 场景 3

---

## 🔧 跨 AI 工具兼容性（v1.1.2 重点）

### 数据源路径自动探测

`bin/detect-data-paths.sh`（macOS/Linux/QoderWork/Cursor）和 `bin/detect-data-paths.ps1`（Windows）会自动探测以下安装位置：

```
优先级 1: 环境变量 WORKBUDDY_DATA_HOME / WESTOCK_SCRIPT / NEODATA_SCRIPT
优先级 2: ~/.workbuddy/plugins/marketplaces/experts/plugins/stock-partner-team/skills
优先级 3: ~/.workbuddy/skills-marketplace/skills
优先级 4: ~/.workbuddy/plugins/marketplaces/cb_teams_marketplace/plugins/finance-data/skills
优先级 5: /e/develope/WorkBuddy/resources/...
优先级 6: /Applications/WorkBuddy.app/...
优先级 7: ~/.qoderwork/skills
优先级 8: ~/.cursor/skills
```

### 离线模式（v1.1.2 新增）

如果未检测到数据源，**仅 `invester-dp` 可完整使用**，其他 4 个 Skill 会：
1. 在 Step 0 输出"离线模式"提示
2. 数据位置标 `[数据不可用]`
3. 仍可走流程但需用户手动提供数据

### 缺失依赖 Skill 处理

| Skill | 状态 | v1.1.2 处理 |
|:---|:---|:---|
| `catalyst-calendar` | 已在 `equity-research` 插件中存在，但本仓库不提供 | 标 `optional_skills`，Step 5 暂用简化时间表 |
| `morning-note` | 同上 | 标 `optional_skills`，可用 `automation_update` 替代 |

---

## 🎬 实战案例：宁德时代 365 天完整流程

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
| **框架** | WorkBuddy / QoderWork / Cursor Skill 通用 SKILL.md 格式 |
| **架构** | SKILL.md 入口 + references/ 模块化 |
| **数据层** | neodata-financial-search + westock-data |
| **补充** | WebSearch（公开信息检索） |
| **评分模型** | 六维捕手（单一来源 + 加权评分 + 淘汰制） |
| **路径探测** | bin/detect-data-paths.{sh,ps1}（v1.1.2 跨平台多 AI 工具） |
| **投资方法论** | 卖方分析师标准（摘要→分析→估值→风险→评级） |

---

## 📚 文档导航

| 文档 | 内容 |
|:---|:---|
| [README.md](README.md) | 本文件 |
| [CHANGELOG.md](CHANGELOG.md) | 版本更新日志 |
| [references/scoring-rubric.md](references/scoring-rubric.md) | 6 维评分标准（单一来源） |
| [references/data-routing.md](references/data-routing.md) | 数据源路径与降级方案（v1.1.2 多 AI 工具） |
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
> **修改数据源路径前**：请先运行 `bin/detect-data-paths.sh` 确认你的环境能被正确识别。

---

## 📜 License

MIT License — 自由使用、修改、分发。
