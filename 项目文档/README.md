# 海外小说类 App 项目总览

本仓库用于规划与构建一款**面向海外市场的网络小说 App**。当前已完成两个子项目：**竞品分析 + 产品规划**、**核心界面高保真原型**。

## 项目结构

```text
likenovels/
├─ 竞品分析/                 # 竞品 APK 拆解（产品 + 技术）
│  ├─ 竞品apk/               # GoodNovel、iReader 原始 APK
│  ├─ GoodNovel/             # 技术拆解.md · 产品分析.md
│  ├─ iReader国际版/         # 技术拆解.md · 产品分析.md
│  ├─ 竞品横向对比.md         # 两者对比与结论
│  └─ _raw/                  # androguard 提取脚本 + 原始 JSON 数据
├─ 项目规划/                 # 基于竞品的产品规划
│  ├─ 市场与定位建议.md
│  ├─ 产品功能规划.md         # MoSCoW 功能清单
│  ├─ MVP范围与路线图.md
│  ├─ 变现模型.md
│  └─ 技术选型建议.md
├─ 项目设计/                 # 产品界面原型与视觉方案
│  └─ 核心界面原型/
│     ├─ index.html          # 可点击 Web App 原型
│     ├─ styles.css          # 产品化 UI 样式
│     ├─ app.js              # 页面路由、弹层、瀑布流、二级页面交互
│     └─ assets/             # 小说封面图
├─ 项目文档/                 # 本总览（README）
├─ PRODUCT.md                # 产品上下文
├─ DESIGN.md                 # 视觉系统与设计规范
└─ docs/superpowers/         # 设计文档(spec) 与实现计划(plan)
```

## 建议阅读顺序

1. `竞品分析/竞品横向对比.md` — 先看结论。
2. `竞品分析/GoodNovel/*` 与 `竞品分析/iReader国际版/*` — 看依据。
3. `项目规划/市场与定位建议.md` → `产品功能规划.md` → `MVP范围与路线图.md` → `变现模型.md` → `技术选型建议.md`。
4. `项目设计/核心界面原型/index.html` — 直接打开查看可点击 App 原型。
5. `PRODUCT.md` 与 `DESIGN.md` — 查看产品上下文与界面设计系统。

## 核心结论速览

- **对标 GoodNovel**（真正的出海网文产品）；本仓库内的 iReader 包实为掌阅**国内版**，仅作体验借鉴与出海反面参照。
- **首发市场**：欧美英语，女频网文为核心；架构预留多语言以便扩张拉美/东南亚。
- **变现三件套**：金币内购解锁 + 激励视频广告 + 等待解锁。
- **出海技术栈**：Flutter 客户端 + FCM + Google Play Billing + AppLovin MAX + AppsFlyer/Adjust + Google/Facebook/Apple 登录，合规权限最小化。
- **MVP**：免登录试读 → 付费墙 → 解锁/充值闭环 + 归因埋点 + 合规，单形态（文字）跑通后再扩。

## 分析方法与可信度

- 工具：Python + androguard 静态分析（本机无 Java/jadx/apktool）。
- GoodNovel 未加固，解析完整、可信度高；iReader 加固且 zip 中央目录缺失，已用自研流式解析器还原清单与组件（事实可信，细粒度功能为类名推断）。
- 未做动态运行/抓包：定价、广告频次、解锁节奏等运营细节需实机验证（文档中已区分「事实/推断」）。

## 核心界面原型状态

原型位置：`项目设计/核心界面原型/index.html`

当前原型是一个**单 App 容器的可点击 Web 原型**，不是四屏展示板。已覆盖：

- 主 Tab：`Discover`、`Library`、`Wallet`、`Me`。
- 核心链路：发现小说 → 书籍详情 → 阅读器 → 付费墙 → 充值。
- Discover：推荐卡、榜单、新书、双列瀑布流，并在接近底部时自动追加内容，避免很快滑到底。
- Library：继续阅读、阅读进度、书架列表、Reading/Unlocked/Finished 二级页。
- Wallet：余额、签到、广告解锁、充值套餐、交易流水、交易详情。
- Me：用户信息、阅读数据、购买历史、通知、语言、隐私、账号删除等二级页。
- 底部导航：全局固定在 App 底部，不随页面滚动。

原型使用纯 `HTML/CSS/JS`，无需构建步骤；双击 `index.html` 即可查看。当前仍是产品原型，不是 Flutter 生产代码。

## 下一步（建议）

1. **继续打磨原型**：补登录/注册、搜索结果、榜单详情、章节目录、书评等更完整页面。
2. **内容供给方案**：确定首批书源与更新管线（决定留存成败）。
3. **技术脚手架**：按《技术选型建议.md》搭建 Flutter 客户端 + 后端 + 最小 CMS。
4. **原型转 Flutter**：将当前 `index.html` 的信息架构和交互流转成 Flutter 页面结构。

## 相关文档

- 设计文档（spec）：`docs/superpowers/specs/2026-06-08-competitor-analysis-and-planning-design.md`
- 实现计划（plan）：`docs/superpowers/plans/2026-06-08-competitor-analysis-and-planning.md`
