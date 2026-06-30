#!/usr/bin/env bash
# detect-data-paths.sh
# 自动探测 WorkBuddy 数据源路径（macOS / Linux）
# 用法: source bin/detect-data-paths.sh

set -e

if [ -n "$WORKBUDDY_DATA_HOME" ]; then
  DATA_HOME="$WORKBUDDY_DATA_HOME"
elif [ -d "${HOME}/.workbuddy/plugins" ]; then
  DATA_HOME="${HOME}/.workbuddy/plugins/marketplaces/cb_teams_marketplace/plugins/finance-data/skills"
elif [ -d "/Applications/WorkBuddy.app/Contents/Resources/builtin-skills" ]; then
  DATA_HOME="/Applications/WorkBuddy.app/Contents/Resources/builtin-skills"
else
  echo "❌ 未找到 WorkBuddy 数据目录" >&2
  echo "   请设置环境变量：export WORKBUDDY_DATA_HOME=/path/to/finance-data/skills" >&2
  exit 1
fi

export WESTOCK_SCRIPT="${DATA_HOME}/westock-data/scripts/index.js"
export NEODATA_SCRIPT="${DATA_HOME}/neodata-financial-search/scripts/query.py"
export WETOOL="${DATA_HOME}/westock-data/scripts/westock-tool"
export PYTHON="${PYTHON:-python3}"

echo "✅ WorkBuddy 数据源已就位："
echo "   WESTOCK_SCRIPT = ${WESTOCK_SCRIPT}"
echo "   NEODATA_SCRIPT = ${NEODATA_SCRIPT}"
echo "   WETOOL         = ${WETOOL}"
echo "   PYTHON         = ${PYTHON}"

# 验证路径
if [ ! -f "$WESTOCK_SCRIPT" ]; then
  echo "⚠️ 警告: WESTOCK_SCRIPT 文件不存在: ${WESTOCK_SCRIPT}" >&2
fi
if [ ! -f "$NEODATA_SCRIPT" ]; then
  echo "⚠️ 警告: NEODATA_SCRIPT 文件不存在: ${NEODATA_SCRIPT}" >&2
fi
