<p align="center">
  <h1 align="center">🐟 六维捕手 · Six Dimension Hunter</h1>
  <p align="center"><strong>通用选股六维评分筛选器 — 用卖方研究的方法论，做买方级别的投资决策</strong></p>
  <p align="center">
    <a href="https://github.com/zhaobu/six-dimension-hunter/stargazers"><img src="https://img.shields.io/github/stars/zhaobu/six-dimension-hunter" alt="Stars"></a>
    <a href="https://github.com/zhaobu/six-dimension-hunter/issues"><img src="https://img.shields.io/github/issues/zhaobu/six-dimension-hunter" alt="Issues"></a>
    <a href="https://github.com/zhaobu/six-dimension-hunter/blob/main/LICENSE"><img src="https://img.shields.io/github/license/zhaobu/six-dimension-hunter" alt="License"></a>
    <a href="https://github.com/zhaobu/six-dimension-hunter/releases"><img src="https://img.shields.io/github/v/release/zhaobu/six-dimension-hunter" alt="Release"></a>
  </p>
</p>

---

## 📋 简介

**六维捕手** 是一个基于 **WorkBuddy** 平台的 AI 选股技能（Skill），通过一套完整的 **6维评分框架**，从全A股市场筛选值得长期持有的核心标的。**可适配任何行业**——AI、新能源、消费、医药、半导体、军工、传统制造等。

> **核心理念**：研究结论要经得起3年后回看。

### 它能做什么

| 场景 | 示例 |
|:---|:---|
| 全市场扫射 | "帮我筛选值得长期持有的核心标的" |
| 指定板块深挖 | "帮我看看半导体材料板块有哪些值得买的" |
| 单标的全维度评估 | "帮我6维评分一下中际旭创" |
| 自定义筛选 | "帮我筛PE<30、ROE>20%、现金流好的消费股" |

### 6维框架一览

| # | 维度 | 权重 | 回答的问题 |
|:---:|:---|:---:|:---|
| ① | **稀缺性** | ★★★★ | 这个生意别人能做吗？ |
| ② | **龙头地位** | ★★★★ | 它是行业老大吗？ |
| ③ | **3-5年确定性** | ★★★★ | 未来增长靠谱吗？ |
| ④ | **估值未透支** | ★★★★ | 价格合理吗？ |
| ⑤ | **主题纯度** | ★★★ | 主营业务是真的在赛道上吗？ |
| ⑥ | **现金流验证** | ★★★ | 赚的是真金白银吗？ |

---

## 🚀 快速开始

### 前置条件

- **WorkBuddy** 桌面版（[下载](https://workbuddy.cn)）
- 已配置的金融数据源（本 Skill 自带对接 `westock-data` 和 `neodata-financial-search`）

### 安装

**方式一：一键安装（推荐）**

在 WorkBuddy 对话中输入：

```
/search 安装 六维捕手
```

**方式二：手动安装**

```bash
# 克隆仓库到 WorkBuddy skills 目录
git clone https://github.com/zhaobu/six-dimension-hunter.git ~/.workbuddy/skills/six-dimension-hunter
```

然后在 WorkBuddy 中重新加载技能即可使用。

### 快速使用

安装完成后，直接对 WorkBuddy 说：

> **"帮我用6维标准筛选半导体材料的核心标的"**

或者试试更具体的：

> **"帮我6维评分一下安集科技"**

---

## 🧩 6维评分方法论

### 评分标准

| 维度 | 10分 | 7-9分 | 4-6分 | 1-3分 |
|:---|:---|:---|:---|:---|
| ①稀缺性 | 全球仅1-2家能做 | 全球3-5家/国内2-3家 | 同类5-10家 | 大宗同质化 |
| ②龙头地位 | 全球#1，市占率>25% | 国内#1或全球#2-3 | 国内Top3但非龙头 | 无明确龙头地位 |
| ③3-5年确定性 | 不可绕过的物理/商业瓶颈 | 高概率持续增长 | 有增长但存在替代路径 | 概念性/周期性强 |
| ④估值未透支 | PE_fwd<30, 2028E PE<20 | PE_fwd 30-50 | PE_fwd 50-80 | PE_fwd>80或亏损 |
| ⑤主题纯度 | 主题收入占比>60% | 主题收入占比30-60% | 主题收入占比15-30% | 主题收入占比<15% |
| ⑥现金流验证 | 经营现金流/净利>120% | 80-120% | 50-80% | <50% |

### 综合评级

```
加权总分 = ①×4 + ②×4 + ③×4 + ④×4 + ⑤×3 + ⑥×3
满分 = 190分

≥140分 → 🔴 强烈推荐（核心仓位）
110-139分 → 🟡 值得关注（观察仓位）
75-109分 → 🟢 观察等待（等待回调）
<75分 → ⛔ 淘汰（不参与）
```

### 主题纯度对照表

本 Skill 的核心创新是**可插拔的主题纯度维度**——根据你关注的行业，自动调整判断标准：

| 投资主题 | 主题相关业务定义 | 典型高分标的 |
|:---|:---|:---|
| 🔴 **AI/算力** | AI芯片/光模块/服务器/算力租赁 | 中际旭创、海光信息 |
| 🟢 **新能源** | 光伏/锂电池/储能/新能源车 | 宁德时代、比亚迪 |
| 🔵 **半导体** | 芯片设计/制造/封测/设备/材料 | 中芯国际、北方华创 |
| 🟡 **消费/白酒** | 白酒/食品饮料/品牌消费 | 贵州茅台、伊利股份 |
| 🟤 **医药** | 创新药/医疗器械/CXO | 恒瑞医药、药明康德 |
| ⚪ **高端制造** | 精密零部件/工业母机/机器人 | 汇川技术、绿的谐波 |
| 🟣 **军工** | 航空/航天/舰船/信息化 | 中航沈飞、航发动力 |

---

## 📊 输出示例

运行后你会得到类似这样的分析报告：

```markdown
## 📊 安集科技(688019) — 6维评分报告

### 评级总览
| 综合评级 | 加权总分 | 操作建议 |
|:---:|:---:|:---|
| 🔴 强烈推荐 | 161/190分 | 核心仓位，逢低建仓 |

### 六维评分明细
| 维度 | 分数 | 判断依据 | 数据来源 |
|:---|:---:|:---|:---|
| ①稀缺性 | 8/10 | CMP抛光液国内唯一可量产企业 | [研报] |
| ②龙头地位 | 8/10 | 国内CMP抛光液#1,市占率约30% | [研报] |
| ③3-5年确定性 | 8/10 | 半导体材料国产替代,3年净利CAGR 34% | [consensus] |
| ④估值未透支 | 5/10 | PE_fwd=59.26, 2028E PE=26.03 | [quote] |
| ⑤主题纯度 | 10/10 | 集成电路收入占比99.78% | [主营构成] |
| ⑥现金流验证 | 5/10 | 经营现金流/净利=56.1% | [finance] |

### 关键财务数据
- PE_fwd: 59.26
- 2028E PE: 26.03（3年后估值消化至合理区）
- 一致目标价: 297.18元（上行空间+37.3%）
- 3年净利CAGR: 34%

### 建议买入区间
- 低估区间: <195元 | 合理区间: 195-250元 | 高估警戒: >297元
```

---

## 🔧 数据源说明

本 Skill 对接两个金融数据源进行实时数据查询：

| 数据源 | 类型 | 覆盖范围 |
|:---|:---|:---|
| **westock-data** | 结构化数据API | 行情、一致预期、三大报表、研报、板块成分股 |
| **neodata-financial-search** | 自然语言查询 | 主营构成、研报全文、行业资讯、财务复合指标 |

两个数据源均通过 WorkBuddy 内置工具自动调用，无需用户手动配置 Token 或 API Key。

---

## 🤝 贡献指南

欢迎贡献！无论是报告 Bug、提出新功能建议，还是提交 PR：

1. Fork 本仓库
2. 创建你的特性分支 (`git checkout -b feat/amazing-feature`)
3. 提交改动 (`git commit -m 'feat: add amazing feature'`)
4. 推送到分支 (`git push origin feat/amazing-feature`)
5. 提交 Pull Request

### 开发路线图

- [ ] 增加港股/美股支持
- [ ] 增加 DCF 估值模块联动
- [ ] 增加技术面辅助判断
- [ ] 支持批量扫描全市场并输出排名
- [ ] 增加回测模块验证6维框架有效性

---

## 📄 License

[MIT](LICENSE)

---

## ⚠️ 免责声明

本 Skill 提供的所有分析**仅供参考，不构成个人投资建议**。所有数据来源于公开市场信息，可能存在延迟。投资有风险，决策需谨慎。

---

<p align="center">
  Made with ❤️ by <a href="https://github.com/zhaobu">zhaobu</a>
</p>
