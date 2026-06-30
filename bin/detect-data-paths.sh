#!/usr/bin/env bash
# detect-data-paths.sh
# 自动探测 WorkBuddy 数据源路径（macOS / Linux / QoderWork / Cursor）
# 用法: source bin/detect-data-paths.sh
#
# 首次使用需添加可执行权限：chmod +x bin/detect-data-paths.sh
#
# v1.1.3 重大修复：
#   1. 跨目录探测 westock-data / neodata（不再依赖单一 DATA_HOME 包含全部工具）
#   2. 修复 Windows 下 PYTHON=python3 失效的问题（自动探测 PYTHON 路径）
#   3. 新增 OFFLINE_MODE 标志（数据不可用时告知所有 Skill）
#   4. 新增探测 westock-tool（独立目录）和 md-to-html 等辅助工具
#   5. 详细输出每个脚本的探测状态

set -e

# ============================================
# 工具函数：探测单个脚本的实际位置
# ============================================
# 在多个候选目录中搜索指定脚本文件
# 用法: search_script <相对路径> <候选目录列表...>
search_in_dirs() {
  local rel_path="$1"
  shift
  for dir in "$@"; do
    if [ -d "$dir" ] && [ -f "${dir}/${rel_path}" ]; then
      echo "${dir}/${rel_path}"
      return 0
    fi
  done
  return 1
}

# ============================================
# 候选安装根目录列表（按优先级）
# ============================================
get_candidate_roots() {
  echo "${HOME}/.workbuddy/plugins/marketplaces/cb_teams_marketplace/plugins/finance-data/skills" \
       "${HOME}/.workbuddy/plugins/marketplaces/experts/plugins/stock-partner-team/skills" \
       "${HOME}/.workbuddy/skills-marketplace/skills" \
       "${HOME}/.workbuddy/skills" \
       "${HOME}/.workbuddy/plugins/marketplaces/experts/plugins" \
       "${HOME}/.qoderwork/skills" \
       "${HOME}/.cursor/skills" \
       "/Applications/WorkBuddy.app/Contents/Resources/builtin-skills"
}

# ============================================
# 探测 WESTOCK_SCRIPT（westock-data/scripts/index.js）
# ============================================
detect_westock() {
  if [ -n "$WESTOCK_SCRIPT" ] && [ -f "$WESTOCK_SCRIPT" ]; then
    echo "$WESTOCK_SCRIPT"
    return 0
  fi

  for root in $(get_candidate_roots); do
    if found=$(search_in_dirs "westock-data/scripts/index.js" "$root" 2>/dev/null); then
      echo "$found"
      return 0
    fi
    # 也尝试直接在 root 下的 westock-data 子目录
    if [ -f "${root}/westock-data/scripts/index.js" ]; then
      echo "${root}/westock-data/scripts/index.js"
      return 0
    fi
  done
  return 1
}

# ============================================
# 探测 NEODATA_SCRIPT（neodata-financial-search/scripts/query.py）
# ============================================
detect_neodata() {
  if [ -n "$NEODATA_SCRIPT" ] && [ -f "$NEODATA_SCRIPT" ]; then
    echo "$NEODATA_SCRIPT"
    return 0
  fi

  for root in $(get_candidate_roots); do
    if found=$(search_in_dirs "neodata-financial-search/scripts/query.py" "$root" 2>/dev/null); then
      echo "$found"
      return 0
    fi
  done
  return 1
}

# ============================================
# 探测 WETOOL（westock-tool 入口）
# ============================================
detect_wetool() {
  if [ -n "$WETOOL" ] && [ -f "$WETOOL" ]; then
    echo "$WETOOL"
    return 0
  fi

  for root in $(get_candidate_roots); do
    # westock-tool 可能是 scripts/index.js 或 westock-tool 可执行文件
    if [ -f "${root}/westock-tool/scripts/index.js" ]; then
      echo "${root}/westock-tool/scripts/index.js"
      return 0
    fi
    if [ -x "${root}/westock-tool/westock-tool" ]; then
      echo "${root}/westock-tool/westock-tool"
      return 0
    fi
    if [ -f "${root}/westock-data/scripts/westock-tool.js" ]; then
      echo "${root}/westock-data/scripts/westock-tool.js"
      return 0
    fi
  done
  return 1
}

# ============================================
# 探测 Python 解释器（修复 v1.1.2 的 Windows 失效问题）
# ============================================
detect_python() {
  # 1. 用户显式设置
  if [ -n "$PYTHON" ] && command -v "$PYTHON" >/dev/null 2>&1; then
    echo "$PYTHON"
    return 0
  fi

  # 2. WorkBuddy 自带的 Python（Windows 关键路径）
  local wb_python_paths=(
    "${HOME}/.workbuddy/binaries/python/versions/3.13.12/python"
    "${HOME}/.workbuddy/binaries/python/versions/3.13.12/python.exe"
    "C:/Users/${USER}/.workbuddy/binaries/python/versions/3.13.12/python.exe"
  )
  for p in "${wb_python_paths[@]}"; do
    if [ -x "$p" ] || [ -f "$p" ]; then
      echo "$p"
      return 0
    fi
  done

  # 3. 系统 Python（按优先级）
  if command -v python3 >/dev/null 2>&1; then
    echo "python3"
    return 0
  fi
  if command -v python >/dev/null 2>&1; then
    echo "python"
    return 0
  fi

  return 1
}

# ============================================
# 主流程
# ============================================
WESTOCK_SCRIPT=$(detect_westock || true)
NEODATA_SCRIPT=$(detect_neodata || true)
WETOOL=$(detect_wetool || true)
PYTHON=$(detect_python || true)

export WESTOCK_SCRIPT
export NEODATA_SCRIPT
export WETOOL
export PYTHON

# 判断离线模式
OFFLINE_MODE=0
if [ -z "$WESTOCK_SCRIPT" ] && [ -z "$NEODATA_SCRIPT" ]; then
  OFFLINE_MODE=1
fi
if [ -n "$OFFLINE_MODE_FORCE" ]; then
  OFFLINE_MODE=1
fi
export OFFLINE_MODE

# ============================================
# 输出报告
# ============================================
if [ "$OFFLINE_MODE" = "1" ]; then
  cat <<EOF
⚠️  WorkBuddy 数据源未检测到（OFFLINE_MODE=1）
   - 5 个 Skill 中仅 invester-dp 可正常工作
   - 其他 4 个 Skill 将标记 [数据不可用] 并走降级流程
   - WebSearch 仍可作为补充数据源
EOF
  if [ -z "$SKIP_HINTS" ]; then
    cat <<EOF

💡 解决方式（按优先级）：
   1. 设置环境变量（推荐）：
      export WESTOCK_SCRIPT=/path/to/westock-data/scripts/index.js
      export NEODATA_SCRIPT=/path/to/neodata-financial-search/scripts/query.py
      source bin/detect-data-paths.sh

   2. 安装缺失的数据源：
      - westock-data: 自选股数据
      - neodata-financial-search: 自然语言金融搜索

   3. 设置 OFFLINE_MODE_FORCE=1 显式启用离线模式（不报探测警告）
EOF
  fi
  return 0 2>/dev/null || exit 0
fi

# 在线模式：详细输出
echo "✅ WorkBuddy 数据源已就位（v1.1.3 跨目录探测）"
echo ""
echo "   数据脚本："
[ -n "$WESTOCK_SCRIPT" ] && echo "     WESTOCK_SCRIPT  = ${WESTOCK_SCRIPT}" || echo "     WESTOCK_SCRIPT  = ❌ 未找到"
[ -n "$NEODATA_SCRIPT" ] && echo "     NEODATA_SCRIPT  = ${NEODATA_SCRIPT}" || echo "     NEODATA_SCRIPT  = ❌ 未找到"
[ -n "$WETOOL" ] && echo "     WETOOL          = ${WETOOL}" || echo "     WETOOL          = ⚠️ 可选，未找到"
echo ""
echo "   运行环境："
[ -n "$PYTHON" ] && echo "     PYTHON          = ${PYTHON}" || echo "     PYTHON          = ❌ 未找到（neodata 无法执行）"
echo ""

# 警告：部分数据源缺失
warnings=0
if [ -z "$WESTOCK_SCRIPT" ]; then
  echo "⚠️ 警告: westock-data 未找到，依赖结构化数据的 Skill 将受限" >&2
  warnings=$((warnings + 1))
fi
if [ -z "$NEODATA_SCRIPT" ]; then
  echo "⚠️ 警告: neodata-financial-search 未找到，依赖自然语言查询的 Skill 将受限" >&2
  warnings=$((warnings + 1))
fi
if [ -z "$PYTHON" ]; then
  echo "⚠️ 警告: Python 未找到" >&2
  warnings=$((warnings + 1))
fi

if [ $warnings -gt 0 ]; then
  echo "" >&2
  echo "💡 提示：可手动设置环境变量覆盖自动探测" >&2
fi
