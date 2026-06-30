# detect-data-paths.ps1
# 自动探测 WorkBuddy 数据源路径（Windows PowerShell）
# 用法: . .\bin\detect-data-paths.ps1
#
# v1.1.3 重大修复：
#   1. 跨目录探测 westock-data / neodata
#   2. 修复 PYTHON 探测（Windows 上 python3 通常不存在）
#   3. 新增 OFFLINE_MODE 标志
#   4. 详细输出每个脚本的探测状态

# 关闭错误立即退出（用 try/catch 控制）
$ErrorActionPreference = "Continue"

# ============================================
# 候选安装根目录列表（按优先级）
# ============================================
function Get-CandidateRoots {
  $homeDir = $env:USERPROFILE
  $candidates = @(
    "$homeDir\.workbuddy\plugins\marketplaces\cb_teams_marketplace\plugins\finance-data\skills",
    "$homeDir\.workbuddy\plugins\marketplaces\experts\plugins\stock-partner-team\skills",
    "$homeDir\.workbuddy\skills-marketplace\skills",
    "$homeDir\.workbuddy\skills",
    "$homeDir\.workbuddy\plugins\marketplaces\experts\plugins",
    "$homeDir\.qoderwork\skills",
    "$homeDir\.cursor\skills",
    "C:\Program Files\WorkBuddy\resources\builtin-skills"
  )
  return $candidates
}

# ============================================
# 在多个候选目录中搜索指定脚本
# ============================================
function Find-ScriptInDirs {
  param([string]$RelPath, [string[]]$Roots)
  foreach ($root in $Roots) {
    $fullPath = Join-Path $root $RelPath
    if (Test-Path $fullPath) {
      return $fullPath
    }
  }
  return $null
}

# ============================================
# 探测各个数据源
# ============================================
$roots = Get-CandidateRoots

# WESTOCK_SCRIPT
if ($env:WESTOCK_SCRIPT -and (Test-Path $env:WESTOCK_SCRIPT)) {
  $script:WestockScript = $env:WESTOCK_SCRIPT
} else {
  $script:WestockScript = Find-ScriptInDirs -RelPath "westock-data\scripts\index.js" -Roots $roots
}

# NEODATA_SCRIPT
if ($env:NEODATA_SCRIPT -and (Test-Path $env:NEODATA_SCRIPT)) {
  $script:NeodataScript = $env:NEODATA_SCRIPT
} else {
  $script:NeodataScript = Find-ScriptInDirs -RelPath "neodata-financial-search\scripts\query.py" -Roots $roots
}

# WETOOL
if ($env:WETOOL -and (Test-Path $env:WETOOL)) {
  $script:Wetool = $env:WETOOL
} else {
  $script:Wetool = Find-ScriptInDirs -RelPath "westock-tool\scripts\index.js" -Roots $roots
  if (-not $script:Wetool) {
    $script:Wetool = Find-ScriptInDirs -RelPath "westock-data\scripts\westock-tool.js" -Roots $roots
  }
}

# PYTHON（关键修复：Windows 上 python3 通常不存在）
if ($env:PYTHON -and (Get-Command $env:PYTHON -ErrorAction SilentlyContinue)) {
  $script:Python = $env:PYTHON
} else {
  $candidates = @(
    "$env:USERPROFILE\.workbuddy\binaries\python\versions\3.13.12\python.exe",
    "$env:USERPROFILE\.workbuddy\binaries\python\versions\3.13.13\python.exe",
    "$env:USERPROFILE\.workbuddy\binaries\python\envs\default\Scripts\python.exe"
  )
  $script:Python = $null
  foreach ($p in $candidates) {
    if (Test-Path $p) {
      $script:Python = $p
      break
    }
  }
  if (-not $script:Python) {
    # 系统 Python 兜底
    $pyCmd = Get-Command python -ErrorAction SilentlyContinue
    if ($pyCmd) { $script:Python = $pyCmd.Source }
  }
}

# ============================================
# 设置环境变量（导出到调用方）
# ============================================
$env:WESTOCK_SCRIPT = $script:WestockScript
$env:NEODATA_SCRIPT = $script:NeodataScript
$env:WETOOL = $script:Wetool
$env:PYTHON = $script:Python

# 判断离线模式
$offlineMode = $false
if (-not $script:WestockScript -and -not $script:NeodataScript) {
  $offlineMode = $true
}
if ($env:OFFLINE_MODE_FORCE) {
  $offlineMode = $true
}
$env:OFFLINE_MODE = if ($offlineMode) { "1" } else { "0" }

# ============================================
# 输出报告
# ============================================
if ($offlineMode) {
  Write-Host ""
  Write-Host "[WARN] WorkBuddy data sources not detected (OFFLINE_MODE=1)" -ForegroundColor Yellow
  Write-Host "   - Only invester-dp works fully"
  Write-Host "   - Other 4 Skills will mark [data unavailable]"
  Write-Host "   - WebSearch can still supplement"
  Write-Host ""
  Write-Host "Solutions:"
  Write-Host "   1. Set environment variables:"
  Write-Host "      \$env:WESTOCK_SCRIPT = 'C:\path\to\westock-data\scripts\index.js'"
  Write-Host "      \$env:NEODATA_SCRIPT = 'C:\path\to\neodata-financial-search\scripts\query.py'"
  Write-Host "      . .\bin\detect-data-paths.ps1"
  Write-Host ""
  Write-Host "   2. Install missing data sources"
  Write-Host ""
  Write-Host "   3. Set \$env:OFFLINE_MODE_FORCE = '1' to suppress warnings"
  return
}

Write-Host "[OK] WorkBuddy data sources ready (v1.1.3 cross-directory detection)" -ForegroundColor Green
Write-Host ""
Write-Host "   Scripts:"
if ($script:WestockScript) { Write-Host "     WESTOCK_SCRIPT  = $script:WestockScript" } else { Write-Host "     WESTOCK_SCRIPT  = [X] not found" -ForegroundColor Red }
if ($script:NeodataScript) { Write-Host "     NEODATA_SCRIPT  = $script:NeodataScript" } else { Write-Host "     NEODATA_SCRIPT  = [X] not found" -ForegroundColor Red }
if ($script:Wetool) { Write-Host "     WETOOL          = $script:Wetool" } else { Write-Host "     WETOOL          = [WARN] optional, not found" -ForegroundColor Yellow }
Write-Host ""
Write-Host "   Runtime:"
if ($script:Python) { Write-Host "     PYTHON          = $script:Python" } else { Write-Host "     PYTHON          = [X] not found" -ForegroundColor Red }

# 警告
$warnings = 0
if (-not $script:WestockScript) { $warnings++ }
if (-not $script:NeodataScript) { $warnings++ }
if (-not $script:Python) { $warnings++ }

if ($warnings -gt 0) {
  Write-Host ""
  Write-Host "[WARN] Some data sources missing. Set environment variables to override." -ForegroundColor Yellow
}
