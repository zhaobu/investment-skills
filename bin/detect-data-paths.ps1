# detect-data-paths.ps1
# 自动探测 WorkBuddy 数据源路径（Windows）
# 用法: . .\bin\detect-data-paths.ps1

$ErrorActionPreference = 'Stop'

if ($env:WORKBUDDY_DATA_HOME) {
  $DATA_HOME = $env:WORKBUDDY_DATA_HOME
} elseif (Test-Path "$HOME\.workbuddy\plugins") {
  $DATA_HOME = "$HOME\.workbuddy\plugins\marketplaces\cb_teams_marketplace\plugins\finance-data\skills"
} elseif (Test-Path "E:\develope\WorkBuddy\resources\app.asar.unpacked\resources\builtin-skills") {
  $DATA_HOME = "E:\develope\WorkBuddy\resources\app.asar.unpacked\resources\builtin-skills"
} else {
  Write-Error "❌ 未找到 WorkBuddy 数据目录`n   请设置环境变量：`$env:WORKBUDDY_DATA_HOME = 'C:\path\to\finance-data\skills'"
  exit 1
}

$env:WESTOCK_SCRIPT = "$DATA_HOME\westock-data\scripts\index.js"
$env:NEODATA_SCRIPT = "$DATA_HOME\neodata-financial-search\scripts\query.py"
$env:WETOOL = "$DATA_HOME\westock-data\scripts\westock-tool"
if (-not $env:PYTHON) {
  $env:PYTHON = "python"
}

Write-Host "✅ WorkBuddy 数据源已就位：" -ForegroundColor Green
Write-Host "   WESTOCK_SCRIPT = $($env:WESTOCK_SCRIPT)"
Write-Host "   NEODATA_SCRIPT = $($env:NEODATA_SCRIPT)"
Write-Host "   WETOOL         = $($env:WETOOL)"
Write-Host "   PYTHON         = $($env:PYTHON)"

if (-not (Test-Path $env:WESTOCK_SCRIPT)) {
  Write-Warning "WESTOCK_SCRIPT 文件不存在：$($env:WESTOCK_SCRIPT)"
}
if (-not (Test-Path $env:NEODATA_SCRIPT)) {
  Write-Warning "NEODATA_SCRIPT 文件不存在：$($env:NEODATA_SCRIPT)"
}
