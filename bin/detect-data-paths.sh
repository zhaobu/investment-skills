#!/usr/bin/env bash
# detect-data-paths.sh
# 自动探测 WorkBuddy 数据源路径（macOS / Linux / QoderWork / Cursor）
# 用法: source bin/detect-data-paths.sh
#
# 首次使用需添加可执行权限：chmod +x bin/detect-data-paths.sh

set -e

# 数据源候选路径（按优先级排序）
detect_data_home() {
  # 1. 用户显式设置的环境变量
  if [ -n "$WORKBUDDY_DATA_HOME" ] && [ -d "$WORKBUDDY_DATA_HOME" ]; then
    echo "$WORKBUDDY_DATA_HOME"
    return 0
  fi

  # 2. 探测各种可能的安装位置
  local candidates=(
    # === experts / stock-partner-team 安装（QoderWork 评估报告中的位置，最优先）===
    "${HOME}/.workbuddy/plugins/marketplaces/experts/plugins/stock-partner-team/skills"
    # === skills-marketplace 散装安装 ===
    "${HOME}/.workbuddy/skills-marketplace/skills"
    # === cb_teams_marketplace 安装（最常见）===
    "${HOME}/.workbuddy/plugins/marketplaces/cb_teams_marketplace/plugins/finance-data/skills"
    # === develope 调试安装 ===
    "/e/develope/WorkBuddy/resources/app.asar.unpacked/resources/builtin-skills"
    "/Applications/WorkBuddy.app/Contents/Resources/builtin-skills"
    # === QoderWork 安装 ===
    "${HOME}/.qoderwork/skills"
    # === Cursor 安装 ===
    "${HOME}/.cursor/skills"
  )

  for path in "${candidates[@]}"; do
    # 展开 ~ 和变量
    path=$(eval echo "$path")
    if [ -d "$path" ]; then
      # 优先匹配包含完整数据工具的目录
      if [ -d "$path/westock-data/scripts" ] || [ -d "$path/neodata-financial-search/scripts" ] || \
         [ -d "$path/westock-tool/scripts" ]; then
        echo "$path"
        return 0
      fi
    fi
  done

  return 1
}

DATA_HOME=$(detect_data_home)

if [ -z "$DATA_HOME" ]; then
  echo "❌ 未找到 WorkBuddy 数据目录" >&2
  echo "" >&2
  echo "请按以下任一方式解决：" >&2
  echo "" >&2
  echo "  1. 设置环境变量（推荐）：" >&2
  echo "     export WORKBUDDY_DATA_HOME=/path/to/finance-data/skills" >&2
  echo "" >&2
  echo "  2. 确保以下任一目录存在：" >&2
  echo "     ~/.workbuddy/plugins/marketplaces/cb_teams_marketplace/plugins/finance-data/skills/" >&2
  echo "     ~/.workbuddy/skills-marketplace/skills/" >&2
  echo "     ~/.workbuddy/plugins/marketplaces/experts/plugins/stock-partner-team/skills/" >&2
  echo "     ~/.qoderwork/skills/" >&2
  echo "     ~/.cursor/skills/" >&2
  echo "" >&2
  echo "  3. 仅使用 invester-dp（不需要联网数据）" >&2
  exit 1
fi

# 设置环境变量
export WESTOCK_SCRIPT="${WESTOCK_SCRIPT:-${DATA_HOME}/westock-data/scripts/index.js}"
export NEODATA_SCRIPT="${NEODATA_SCRIPT:-${DATA_HOME}/neodata-financial-search/scripts/query.py}"
export WETOOL="${WETOOL:-${DATA_HOME}/westock-data/scripts/westock-tool}"
export PYTHON="${PYTHON:-python3}"

echo "✅ WorkBuddy 数据源已就位："
echo "   DATA_HOME     = ${DATA_HOME}"
echo "   WESTOCK_SCRIPT= ${WESTOCK_SCRIPT}"
echo "   NEODATA_SCRIPT= ${NEODATA_SCRIPT}"
echo "   WETOOL        = ${WETOOL}"
echo "   PYTHON        = ${PYTHON}"

# 验证关键文件
warnings=0
if [ ! -f "$WESTOCK_SCRIPT" ]; then
  echo "⚠️ 警告: WESTOCK_SCRIPT 文件不存在: ${WESTOCK_SCRIPT}" >&2
  warnings=$((warnings + 1))
fi
if [ ! -f "$NEODATA_SCRIPT" ]; then
  echo "⚠️ 警告: NEODATA_SCRIPT 文件不存在: ${NEODATA_SCRIPT}" >&2
  warnings=$((warnings + 1))
fi

if [ $warnings -gt 0 ]; then
  echo "" >&2
  echo "💡 提示：可手动设置环境变量覆盖自动探测：" >&2
  echo "   export WESTOCK_SCRIPT=/path/to/westock-data/scripts/index.js" >&2
  echo "   export NEODATA_SCRIPT=/path/to/query.py" >&2
fi
