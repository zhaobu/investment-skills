# 数据映射表 — 6维评分 × 数据源映射

> 本文档为 SKILL.md 的附属引用文件，当需要查取具体数据时加载。

## 数据源优先级规则

| 优先级 | 数据源 | 适用场景 | 调用方式 |
|:---|:---|:---|:---|
| 🥇 第一优先 | `westock-data` | 结构化数据（行情、财报、一致预期） | `node <脚本路径>/index.js` |
| 🥈 第二优先 | `neodata-financial-search` | 自然语言查询（主营构成、研报全文、行业资讯） | `python <脚本路径>/query.py` |
| 🥉 第三优先 | `westock-tool` | 批量筛选（条件选股、预设策略） | `westock-tool` CLI 命令 |

> **规则**：优先使用 `westock-data` 获取结构化数据，只有在其无法覆盖时才降级到 `neodata`。

---

## 详细数据映射

### 维度①：稀缺性

| 评分依据 | 数据获取方式 | 命令/查询 | 关键字段/解析方法 |
|:---|:---|:---|:---|
| 竞争对手数量 | `westock-data sector <板块代码>` | 先用 `search <关键词> --sector` 找到板块代码，再用 `sector <代码>` 列出成分股 | 统计成分股数量，结合研报判断细分领域实际竞争者 |
| 行业壁垒判断 | `neodata` 查询行业研报 | `--query "[公司名]所在行业的竞争格局和进入壁垒"` | 从研报中提取"寡头/垄断/竞争激烈/同质化"等关键词 |
| 定价权判断 | `westock-data finance --type lrb` | `finance <代码> --type lrb --num 4` | 查看毛利率趋势。3年持续提升→定价权强；3年持续下降→竞争加剧 |

> **缺数据处理**：如无法找到细分领域竞争者数量，标注 `[缺失: 行业竞争格局数据不可得]`，该维度最高给 6 分。

---

### 维度②：龙头地位

| 评分依据 | 数据获取方式 | 命令/查询 | 关键字段/解析方法 |
|:---|:---|:---|:---|
| 全球/国内排名 | `westock-data report <代码> --limit 5` | `report <代码> --limit 5` | 提取研报标题中"龙头""领先""第一""TOP"等关键词 |
| 市占率数据 | `neodata` 查询 | `--query "[公司名] 市占率 [行业名]"` | 从研报/资讯中提取市占率百分比 |
| 规模优势验证 | `westock-data quote <代码>` | `quote <代码>` | `total_market_cap` — 与同业对比市值大小 |
| 同业对比 | `westock-tool filter` | 筛选同行业公司，对比营收/利润规模 | 通过 `total_market_cap`、`pe_ratio` 等字段排序 |

> **缺数据处理**：如无法获得确切市占率，按以下规则估算：研报称"龙头"→7分，"龙头之一"→5分，"参与者"→3分。标注 `[估算: 基于研报定性描述]`。

---

### 维度③：3-5年确定性

| 评分依据 | 数据获取方式 | 命令/查询 | 关键字段/解析方法 |
|:---|:---|:---|:---|
| 行业需求是否不可绕过 | `neodata` 查询行业研报 | `--query "[公司名] 所在行业需求驱动因素 长期增长逻辑"` | 从研报中判断：下游需求是否具有长期结构性驱动力？是否有替代方案？|
| 未来3年增长驱动力 | `westock-data consensus <代码>` | `consensus <代码>` | `netProfitYoy` — 查看2026E/2027E/2028E净利润增速 |
| 行业景气度 | `neodata` 查询最新行业资讯 | `--query "[行业名] 2026年景气度 资本开支"` | 提取下游客户资本开支计划、行业扩产信号 |
| 技术路线风险 | `westock-data report <代码> --limit 3` | 最近3篇研报 | 关注研报中"风险提示"部分的技术替代风险描述 |

> **缺数据处理**：无一致预期的标的，该维度最高给 5 分。标注 `[无覆盖: 缺乏卖方一致预期]`。

---

### 维度④：估值未透支

| 评分依据 | 数据获取方式 | 命令/查询 | 关键字段 |
|:---|:---|:---|:---|
| PE_fwd（远期PE） | `westock-data quote <代码>` | `quote <代码>` | `pe_fwd` |
| PE_TTM（静态PE） | 同上 | 同上 | `pe_ratio` |
| YTD 涨跌幅 | 同上 | 同上 | `chg_ytd` |
| 2026E/2027E/2028E PE | `westock-data consensus <代码>` | `consensus <代码>` | `pe` 列的 2026/2027/2028 行 |
| 2026E/2027E/2028E 净利增速 | 同上 | 同上 | `netProfitYoy` (各年行) |
| 一致目标价 | `westock-data rating <代码>` | `rating <代码>` | `targetPrice` (平均目标价) |
| PB / PS 辅助判断 | `westock-data quote <代码>` | `quote <代码>` | `pb_ratio` / `ps_ttm` |

**缺失PE_fwd时的替代方案**：
| 场景 | 处理 | 标注 |
|:---|:---|:---|
| 有 PE_TTM 但无 PE_fwd | 用 PE_TTM * 0.85 估算 PE_fwd | `[估算: PE_fwd≈PE_TTM×0.85]` |
| 无一致预期数据 | 直接用 PE_TTM 评分 | `[替代: 用PE_TTM]` |
| 2028E 无数据 | 用 2027E 替代 | `[替代: 用2027E]` |
| 上市不足1年 | 淘汰，数据不足以评估 | `[淘汰: 数据不足以评估]` |

---

### 维度⑤：主题纯度

| 评分依据 | 数据获取方式 | 命令/查询 | 关键字段/解析方法 |
|:---|:---|:---|:---|
| 主营业务构成（主题相关收入占比） | `neodata` 查询 | `--query "[公司名]主营业务收入构成" --data-type api` | `apiRecall` 中 type=`主营构成与业绩趋势`，提取各产品线收入占比，对照SKILL.md中的主题纯度对照表判断哪些属于主题相关 |
| 前5大客户是否属于主题领域 | `westock-data profile <代码>` | `profile <代码>` | 查看客户列表中是否有该主题领域的核心企业 |
| 主题相关产品ASP | `neodata` 查询研报 | `--query "[公司名] [行业关键词]相关产品单价"` | 从研报中提取主题产品 vs 传统产品的价差 |
| 管理层战略表述 | `westock-data report <代码>` | 阅读最近研报"投资要点"部分 | 搜索主题关键词（如AI/新能源/半导体/创新药等）出现频率 |

**主题纯度判断流程** (按优先级)：
1. **最佳**：年报/中报中有明确分部数据 → 直接计算主题收入占比
2. **次优**：无分部数据，但前5大客户100%属于主题领域 → 主题收入估算为80-100%
3. **再次**：通过研报描述判断产品是否用于主题场景 → 标注 `[估算: 基于产品用途]`
4. **最差**：无任何主题相关业务描述 → 标注 `[不相关: 业务与主题无直接关联]`

> **缺数据处理**：无法获取主题收入占比时，按产品线+客户结构估算，标注 `[估算: 基于主营构成分析]`。

---

### 维度⑥：现金流验证

| 评分依据 | 数据获取方式 | 命令/查询 | 关键字段/计算 |
|:---|:---|:---|:---|
| 经营性现金流 | `westock-data finance --type xjll` | `finance <代码> --type xjll --num 4` | `NetOperateCashFlow` (最近一期完整年报) |
| 归属母公司净利润 | `westock-data finance --type lrb` | `finance <代码> --type lrb --num 4` | `NPParentCompanyOwners` (最近一期完整年报) |
| 现金流/净利润比率 | 计算 | 除以上两个值 | `NetOperateCashFlow / NPParentCompanyOwners` |
| 应收账款趋势 | `westock-data finance --type zcfz` | `finance <代码> --type zcfz --num 4` | 对比最近3年应收账款增速 vs 营收增速 |
| 存货趋势 | 同上 | 同上 | 对比最近3年存货增速 vs 营收增速 |

**缺失数据时的替代方案**：
| 场景 | 处理 | 标注 |
|:---|:---|:---|
| 仅有半年报 | 用半年报TTM替代 | `[TTM数据]` |
| 仅有最近一期财报 | 用最近一期数据 | `[最近一期: YYYY-QQ]` |
| 无现金流量表数据 | 淘汰 | `[淘汰: 无法验证现金流]` |

---

## 数据源初始化流程

### westock-data 初始化（无需额外配置）

```bash
# 各命令的脚本路径
WESTOCK_SCRIPT="C:\Users\liwei\.workbuddy\plugins\marketplaces\cb_teams_marketplace\plugins\finance-data\skills\westock-data\scripts\index.js"

# 查询格式
node "$WESTOCK_SCRIPT" quote <股票代码>
node "$WESTOCK_SCRIPT" finance <股票代码> --type lrb --num 4
node "$WESTOCK_SCRIPT" consensus <股票代码>
node "$WESTOCK_SCRIPT" report <股票代码> --limit 5
node "$WESTOCK_SCRIPT" rating <股票代码>
node "$WESTOCK_SCRIPT" sector <板块代码>
```

### neodata-financial-search 初始化

```bash
# 脚本路径
NEODATA_SCRIPT="C:\Users\liwei\.workbuddy\plugins\marketplaces\cb_teams_marketplace\plugins\finance-data\skills\neodata-financial-search\scripts\query.py"

# 第一步：直接查询（缓存有效时直接返回）
python "$NEODATA_SCRIPT" --query "查询内容"

# 如果返回 TOKEN_MISSING / TOKEN_EXPIRED：
# 1. 调用 connect_cloud_service 获取 token
# 2. python "$NEODATA_SCRIPT" --save-token "<token>"
# 3. 重新执行查询
```

### westock-tool 筛选初始化（批量选股用）

```bash
# 脚本路径
WETOOL_SCRIPT="C:\Users\liwei\.workbuddy\plugins\marketplaces\cb_teams_marketplace\plugins\finance-data\skills\westock-data\scripts\westock-tool"

# 自定义筛选
westock-tool filter --expression "intersect([PE_TTM < 30, ROETTM > 15, TotalMV > 50000000000])" --limit 20

# 预设策略
westock-tool filter --preset LowPE --limit 20
```

---

## 数据可用性检查表

每只标的分析前，先检查数据可用性：

| 检查项 | 命令 | 预期结果 | 缺数据处理 |
|:---|:---|:---|:---|
| 是否有行情数据 | `quote <代码>` | 有 pe_fwd | 无→标注[无行情]，淘汰 |
| 是否有一致预期 | `consensus <代码>` | 有 2026E/2027E 数据 | 无→用历史数据替代 |
| 是否有现金流量表 | `finance --type xjll` | 有 NetOperateCashFlow | 无→标注[无现金流数据] |
| 是否有券商研报 | `report <代码>` | 有研报列表 | 无→标注[无卖方覆盖] |
| 是否有主营构成数据 | `neodata` 查询 | 有营收拆分 | 无→按客户结构估算 |
