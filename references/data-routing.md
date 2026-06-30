# 数据源路由与降级方案

> **本文件定义所有 Skill 调用的数据源路径、优先级与降级策略**。
> 修改路径或优先级时，**只改这一处**。

---

## 1. 数据源优先级

| 优先级 | 数据源 | 适用场景 | 失败时降级 |
|:---:|:---|:---|:---|
| 1 | **neodata-financial-search** | 自然语言查询，板块/宏观/概念 | → westock-data |
| 2 | **westock-data** | 结构化行情/财务/一致预期/资金流 | → Westock-Tool 批量筛选 |
| 3 | **Westock-Tool** | 批量筛选/排行/事件触发 | → WebSearch |
| 4 | **WebSearch** | 公开信息补充（政策/新闻/研报） | → 标注 `[数据不可用]` |

---

## 2. 跨平台路径（v1.1 新增）

> **重要**：v1.0 中所有路径硬编码 Windows 绝对路径，无法在 macOS / Linux / Cursor 环境下运行。
> v1.1 起统一使用 `${WORKBUDDY_DATA_HOME}` 变量。

### 2.1 路径解析规则

**优先级**：
1. 环境变量 `WORKBUDDY_DATA_HOME`（用户显式设置）
2. 自动探测：尝试以下位置按顺序查找
   - `${HOME}/.workbuddy/plugins/...`（macOS/Linux）
   - `C:/Users/${USERNAME}/.workbuddy/plugins/...`（Windows）
   - `E:/develope/WorkBuddy/resources/...`（Windows + develope 安装）

### 2.2 各平台推荐路径

| 平台 | 路径 |
|:---|:---|
| Windows（默认） | `C:\Users\${USERNAME}\.workbuddy\plugins\marketplaces\cb_teams_marketplace\plugins\finance-data\skills\` |
| Windows（dev 安装） | `E:\develope\WorkBuddy\resources\app.asar.unpacked\resources\builtin-skills\` |
| macOS | `${HOME}/.workbuddy/plugins/marketplaces/cb_teams_marketplace/plugins/finance-data/skills/` |
| Linux | `${HOME}/.workbuddy/plugins/marketplaces/cb_teams_marketplace/plugins/finance-data/skills/` |

### 2.3 路径探测脚本

**`bin/detect-data-paths.sh`**（macOS/Linux）：
```bash
#!/usr/bin/env bash
# 自动探测数据源路径
if [ -n "$WORKBUDDY_DATA_HOME" ]; then
  DATA_HOME="$WORKBUDDY_DATA_HOME"
elif [ -d "${HOME}/.workbuddy/plugins" ]; then
  DATA_HOME="${HOME}/.workbuddy/plugins/marketplaces/cb_teams_marketplace/plugins/finance-data/skills"
elif [ -d "/Applications/WorkBuddy.app/Contents/Resources/builtin-skills" ]; then
  DATA_HOME="/Applications/WorkBuddy.app/Contents/Resources/builtin-skills"
else
  echo "❌ 未找到 WorkBuddy 数据目录，请设置 WORKBUDDY_DATA_HOME 环境变量" >&2
  exit 1
fi
export WESTOCK_SCRIPT="${DATA_HOME}/westock-data/scripts/index.js"
export NEODATA_SCRIPT="${DATA_HOME}/neodata-financial-search/scripts/query.py"
export WETOOL="${DATA_HOME}/westock-data/scripts/westock-tool"
echo "✅ WESTOCK_SCRIPT=${WESTOCK_SCRIPT}"
echo "✅ NEODATA_SCRIPT=${NEODATA_SCRIPT}"
```

**`bin/detect-data-paths.ps1`**（Windows）：
```powershell
# 自动探测数据源路径
if ($env:WORKBUDDY_DATA_HOME) {
  $DATA_HOME = $env:WORKBUDDY_DATA_HOME
} elseif (Test-Path "$HOME/.workbuddy/plugins") {
  $DATA_HOME = "$HOME/.workbuddy/plugins/marketplaces/cb_teams_marketplace/plugins/finance-data/skills"
} elseif (Test-Path "E:\develope\WorkBuddy\resources\app.asar.unpacked\resources\builtin-skills") {
  $DATA_HOME = "E:\develope\WorkBuddy\resources\app.asar.unpacked\resources\builtin-skills"
} else {
  Write-Error "❌ 未找到 WorkBuddy 数据目录，请设置 WORKBUDDY_DATA_HOME 环境变量"
  exit 1
}
$env:WESTOCK_SCRIPT = "$DATA_HOME/westock-data/scripts/index.js"
$env:NEODATA_SCRIPT = "$DATA_HOME/neodata-financial-search/scripts/query.py"
$env:WETOOL = "$DATA_HOME/westock-data/scripts/westock-tool"
Write-Host "✅ WESTOCK_SCRIPT=$env:WESTOCK_SCRIPT"
```

### 2.4 使用方式

```bash
# 加载路径
source bin/detect-data-paths.sh        # macOS/Linux
. bin/detect-data-paths.ps1            # Windows PowerShell

# 然后调用
node "$WESTOCK_SCRIPT" quote <代码>
"$PYTHON" "$NEODATA_SCRIPT" --query "<查询>"
```

---

## 3. 降级方案

### 3.1 三级降级模型

| 等级 | 条件 | 处理 |
|:---:|:---|:---|
| **L1 数据齐全** | 所有需要数据可获取 | 正常输出，标注来源 |
| **L2 部分缺失** | 1-2 个关键数据缺失 | 用代理指标替代，标注 `[估算]` |
| **L3 关键全缺** | 核心数据无法获取 | 仅基于现有信息做粗评，明确告知用户 |

### 3.2 代理指标映射（缺数据时使用）

| 缺失数据 | 代理指标 | 标注 |
|:---|:---|:---|
| 2028E PE | 用 2027E PE 替代 | `[估算: 用 2027E 替代 2028E]` |
| 2026E 净利 | 用 TTM 净利 + 一致增速估算 | `[估算: TTM × (1+一致增速)]` |
| 经营现金流 | 看应收账款周转率 + 净利含金量 | `[估算: 基于应收周转]` |
| 主营构成 | 用研报描述替代 | `[估算: 研报推断]` |
| 市占率 | 用"营收/行业总规模"估算 | `[估算: 行业总规模推算]` |
| 机构评级 | 用 Westock 5 家券商平均替代 | `[估算: 5 家平均]` |

### 3.3 关键数据全缺的处理原则

当以下核心数据**全部缺失**时，应**明确告知用户**数据不足，建议补充数据后重试：

- L3 触发条件：PE_fwd + 2028E PE + 现金流 + 主营构成 四项中缺失 3 项以上
- 处理：只输出"数据不足以评分" + 列出现有可获取的数据 + 建议重试条件

---

## 4. 已知数据源限制

| 限制 | 影响 | 替代方案 |
|:---|:---|:---|
| `westock sector --search` 不存在 | 板块代码搜索失败 | 用 `neodata` 查板块代码 |
| `westock report <代码>` 不稳定 | 研报数量不稳定 | 多次尝试或用 `neodata` 查研报 |
| `westock consensus` 的 `institutionCnt` 偶为 0 | 机构覆盖判断失败 | 用 `neodata` 查机构评级 |
| `consensus` 全为 0 | 无法做估值评分 | 标 `[缺失]`，用 PE_TTM 替代 |
| neodata 偶发 `data not found` | 单次查询失败 | 重试 2-3 次，更换关键词 |
| westock 网络超时 | 数据获取失败 | 降级到 WebSearch |

---

## 5. 数据新鲜度规则

| 数据类型 | 有效期限 | 超过期限标注 |
|:---|:---:|:---|
| 实时行情（PE/价/市值） | 1 天 | `[STALE: 1天前]` |
| 财务数据（季报） | 90 天 | `[STALE: X天前]` |
| 一致预期 | 30 天 | `[STALE: X天前]` |
| 行业数据 | 30 天 | `[STALE: X天前]` |
| 政策/新闻 | 7 天 | `[STALE: X天前]` |

---

## 6. 路由决策树

```
数据需求
  │
  ├─ 需要自然语言查询（"XX行业研报"）→ neodata
  │
  ├─ 需要结构化数据（PE/财报/一致预期）
  │    │
  │    ├─ 批量筛选 → Westock-Tool
  │    └─ 单标查询 → westock-data
  │
  └─ 需要公开信息补充（新闻/政策）→ WebSearch
```

**调用顺序示例**：
```bash
# 完整流程：单标的全维度评分
# Step 1: 基础数据
node "$WESTOCK_SCRIPT" quote <代码>          # westock-data
# Step 2: 一致预期
node "$WESTOCK_SCRIPT" consensus <代码>      # westock-data
# Step 3: 财务数据
node "$WESTOCK_SCRIPT" finance <代码> --type lrb --num 4
node "$WESTOCK_SCRIPT" finance <代码> --type xjll --num 4
# Step 4: 主营构成（如果前 3 步数据有缺失）
python "$NEODATA_SCRIPT" --query "<公司名>主营业务收入构成"
# Step 5: 补充信息（如果上述仍未覆盖）
WebSearch "<公司名> 2026 行业地位 研报"
```
