# detect-data-paths.ps1
# 自动探测 WorkBuddy 数据源路径（Windows）
# 用法: . .\bin\detect-data-paths.ps1

$ErrorActionPreference = 'Stop'

function Find-DataHome {
    # 1. 用户显式设置的环境变量
    if ($env:WORKBUDDY_DATA_HOME -and (Test-Path $env:WORKBUDDY_DATA_HOME)) {
        return $env:WORKBUDDY_DATA_HOME
    }

    # 2. 探测各种可能的安装位置
    $candidates = @(
        # === cb_teams_marketplace 安装（最常见）===
        "$HOME\.workbuddy\plugins\marketplaces\cb_teams_marketplace\plugins\finance-data\skills"
        "$HOME\.workbuddy\skills-marketplace\skills"
        # === experts / stock-partner-team 安装（QoderWork 评估报告中的位置）===
        "$HOME\.workbuddy\plugins\marketplaces\experts\plugins\stock-partner-team\skills"
        # === develope 调试安装 ===
        "E:\develope\WorkBuddy\resources\app.asar.unpacked\resources\builtin-skills"
        # === QoderWork 安装 ===
        "$HOME\.qoderwork\skills"
        # === Cursor 安装 ===
        "$HOME\.cursor\skills"
    )

    foreach ($path in $candidates) {
        $expandedPath = [Environment]::ExpandEnvironmentVariables($path)
        if (Test-Path $expandedPath) {
            # 优先匹配包含完整数据工具的目录
            if ((Test-Path "$expandedPath\westock-data") -or
                (Test-Path "$expandedPath\neodata-financial-search") -or
                (Test-Path "$expandedPath\westock-tool")) {
                return $expandedPath
            }
        }
    }

    return $null
}

$DATA_HOME = Find-DataHome

if (-not $DATA_HOME) {
    Write-Error "❌ 未找到 WorkBuddy 数据目录`n`n请按以下任一方式解决：`n`n  1. 设置环境变量（推荐）：`n     `$env:WORKBUDDY_DATA_HOME = 'C:\path\to\finance-data\skills'`n`n  2. 确保以下任一目录存在：`n     ~\.workbuddy\plugins\marketplaces\cb_teams_marketplace\plugins\finance-data\skills\`n     ~\.workbuddy\skills-marketplace\skills\`n     ~\.workbuddy\plugins\marketplaces\experts\plugins\stock-partner-team\skills\`n     ~\.qoderwork\skills\`n     ~\.cursor\skills\`n`n  3. 仅使用 invester-dp（不需要联网数据）"
    exit 1
}

# 设置环境变量（如果尚未设置）
if (-not $env:WESTOCK_SCRIPT) {
    $env:WESTOCK_SCRIPT = "$DATA_HOME\westock-data\scripts\index.js"
}
if (-not $env:NEODATA_SCRIPT) {
    $env:NEODATA_SCRIPT = "$DATA_HOME\neodata-financial-search\scripts\query.py"
}
if (-not $env:WETOOL) {
    $env:WETOOL = "$DATA_HOME\westock-data\scripts\westock-tool"
}
if (-not $env:PYTHON) {
    $env:PYTHON = "python"
}

Write-Host "✅ WorkBuddy 数据源已就位：" -ForegroundColor Green
Write-Host "   DATA_HOME     = $DATA_HOME"
Write-Host "   WESTOCK_SCRIPT= $($env:WESTOCK_SCRIPT)"
Write-Host "   NEODATA_SCRIPT= $($env:NEODATA_SCRIPT)"
Write-Host "   WETOOL        = $($env:WETOOL)"
Write-Host "   PYTHON        = $($env:PYTHON)"

# 验证关键文件
$warnings = 0
if (-not (Test-Path $env:WESTOCK_SCRIPT)) {
    Write-Warning "WESTOCK_SCRIPT 文件不存在：$($env:WESTOCK_SCRIPT)"
    $warnings++
}
if (-not (Test-Path $env:NEODATA_SCRIPT)) {
    Write-Warning "NEODATA_SCRIPT 文件不存在：$($env:NEODATA_SCRIPT)"
    $warnings++
}

if ($warnings -gt 0) {
    Write-Host ""
    Write-Host "💡 提示：可手动设置环境变量覆盖自动探测：" -ForegroundColor Yellow
    Write-Host "   `$env:WESTOCK_SCRIPT = 'C:\path\to\westock-data\scripts\index.js'"
    Write-Host "   `$env:NEODATA_SCRIPT = 'C:\path\to\query.py'"
}
