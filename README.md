# likenovel — 海外小说 App 研发交接

面向欧美英语市场的网络小说阅读 App。当前仓库包含：Flutter 前台 App 原型、React 管理后台、Node 演示 API、低保真/高保真原型、产品规划、设计系统、竞品研究和上线路线图。

这份 README 是后续研发接手的第一入口。更长的阶段路线与资产溯源见 [`HANDOFF.md`](HANDOFF.md)。

## 1. 当前状态

| 模块 | 状态 | 说明 |
|---|---|---|
| 前台 App `app/` | 可运行原型 | Flutter + Riverpod + go_router，当前纯 mock 数据，无真实 API。 |
| 管理后台 `后台/` | 可运行演示后台 | React + Vite + Tailwind，对接 `server/` 演示 API。 |
| 演示 API `server/` | 可运行脚手架 | 零依赖 Node 内存数据，仅用于支撑后台演示，生产后端需按文档重写。 |
| 原型资产 `prototypes/` | 参考资产 | V0 低保真验证 IA，V1 Figma Make 导出作为视觉参考。 |
| 文档 `docs/` | 已形成规划基线 | 覆盖产品、设计、后端契约、变现、SDK、埋点、竞品研究。 |

重要现状：

- 前台 App 还没有接真实后端，`app/lib/core/mock/mock_data.dart` 是当前数据源。
- 管理后台已能管理书籍、章节、用户、订单、金币套餐、会员套餐。
- `server/` 是演示 API，不是生产后端。生产建议按 `docs/plan/后端API与数据模型.md` 用 NestJS + PostgreSQL 重写。
- 变现模型已收敛为“订阅优先”：VIP 全场畅读为主，金币只作为非会员按章解锁出口。
- 书籍 `chapterPrice = 0` 表示全书免费，前台不出现 `Unlock`，后台不需要再配置免费章节数。
- Google Play 商品映射字段为 `googlePlayProductId`，金币套餐和会员套餐都需要配置。

## 2. 快速启动

以下命令默认在 Windows / PowerShell 环境执行，仓库路径为 `D:\likenovel`。

### 2.1 前台 App

首次安装依赖：

```powershell
$env:PATH = "C:\flutter\bin;" + $env:PATH
cd D:\likenovel\app
flutter pub get
```

本机 Chrome 调试：

```powershell
cd D:\likenovel\app
flutter run -d chrome
```

同 WiFi 手机/其他设备预览正式 Web 产物：

```powershell
cd D:\likenovel\app
flutter build web
python -m http.server 5174 --bind 0.0.0.0 --directory build/web
```

然后用局域网 IP 打开，例如：

```text
http://192.168.110.55:5174
```

Windows 桌面运行：

```powershell
cd D:\likenovel\app
flutter run -d windows
```

### 2.2 后端演示 API

```powershell
cd D:\likenovel\server
npm install
npm run dev
```

默认地址：

```text
http://localhost:4000
```

默认后台账号：

```text
admin / admin123
```

### 2.3 管理后台

先启动 `server/`，再启动后台：

```powershell
cd D:\likenovel\后台
npm install
npm run dev
```

默认地址：

```text
http://localhost:5173
```

`后台/package.json` 的 `dev` 默认监听 `0.0.0.0:5173`，同 WiFi 设备也可通过电脑局域网 IP 访问。

### 2.4 原型

V0 低保真：

```text
直接双击 prototypes/v0-lofi/index.html
```

V1 Figma 高保真：

```powershell
cd D:\likenovel\prototypes\v1-figma
npm install
npm run dev
```

## 3. 验证命令

接手后建议先跑完这些命令，确认环境和当前基线一致。

```powershell
# 前台 App 全量测试
cd D:\likenovel\app
flutter test

# 前台 App Web 构建
cd D:\likenovel\app
flutter build web

# 管理后台构建
cd D:\likenovel\后台
npm run build

# 演示 API 冒烟测试
cd D:\likenovel\server
npm test
```

当前已覆盖的关键测试包括：

- 付费墙会员主 CTA 与金币折叠入口。
- 金币余额足够时直接解锁，余额不足时进入充值。
- 用户在同一本书选择过金币解锁后，后续余额足够时点击 `Unlock` 直接扣币，不弹窗。
- `chapterPrice = 0` 的免费书显示 `Free`，阅读器不出现 `Unlock`。
- 后端允许创建/更新免费书，新增章节自动免费。
- 金币套餐和会员套餐保存 `googlePlayProductId`。

## 4. 项目结构

```text
likenovel/
├── README.md                         # 当前交接入口
├── HANDOFF.md                        # 阶段路线图、资产地图、上线顺序
├── PRODUCT.md                        # 产品上下文
├── DESIGN.md                         # 设计系统
│
├── app/                              # Flutter 前台 App 原型
│   ├── lib/app/                      # 应用入口、路由、主题、全局状态
│   ├── lib/core/                     # 模型与 mock 数据
│   ├── lib/features/                 # feature-first 页面模块
│   ├── lib/shared/                   # 复用组件
│   ├── assets/fonts/                 # Inter / Newsreader 本地字体
│   ├── assets/i18n/                  # 多语言 JSON
│   └── test/                         # Flutter widget / 行为测试
│
├── server/                           # 管理后台演示 API
│   ├── src/index.js                  # 路由与接口实现
│   ├── src/db.js                     # 内存种子数据与派生规则
│   └── test/smoke.mjs                # 冒烟测试
│
├── 后台/                             # React 管理后台
│   ├── src/pages/                    # Dashboard / Books / Users / Orders / Monetization
│   ├── src/components/               # Layout / UI 原子组件 / Toast
│   ├── src/api.js                    # API 封装
│   └── README.md
│
├── docs/
│   ├── plan/                         # 产品规划、技术方案、后端契约、变现模型
│   ├── design/                       # 前端 PRD、翻页算法资料
│   ├── research/                     # 竞品研究与 APK 逆向事实
│   └── superpowers/                  # 历史工作计划与规格记录
│
└── prototypes/
    ├── v0-lofi/                      # 低保真 HTML 原型
    └── v1-figma/                     # Figma Make 导出 React 原型
```

## 5. 前台 App 说明

核心技术：

- Flutter 3.44+ / Dart 3.12+
- Riverpod 3.x 状态管理
- go_router 17.x 路由
- 本地打包 Inter / Newsreader 字体
- feature-first 目录组织

关键文件：

| 文件 | 作用 |
|---|---|
| `app/lib/main.dart` | App 启动入口。 |
| `app/lib/app/app.dart` | `MaterialApp.router` 根组件。 |
| `app/lib/app/router.dart` | 路由、付费墙、充值、会员、金币解锁等原型业务流程。 |
| `app/lib/app/providers.dart` | Riverpod 全局状态：金币、收藏、章节解锁、金币偏好、会员、翻页模式等。 |
| `app/lib/core/mock/mock_data.dart` | 当前书籍、章节、充值包、会员套餐 mock 数据。 |
| `app/lib/core/models/book.dart` | `Book` / `Chapter` 等模型，`Book.isFree` 来自 `chapterPrice == 0`。 |
| `app/lib/features/book_detail/book_detail_screen.dart` | 书籍详情页，免费书显示 `Free` 标签。 |
| `app/lib/features/reader/reader_screen.dart` | 阅读器，负责主题、翻页、章节可读性、内联付费卡。 |
| `app/lib/shared/widgets/sheets.dart` | Paywall / Recharge / Membership sheets。 |

当前业务状态仍是本地模拟：

- `coinsProvider`：金币余额，默认 640。
- `favoritesProvider`：收藏书籍 ID 集合。
- `unlockedChaptersProvider`：已金币解锁章节账本。
- `coinUnlockPreferenceProvider`：用户在某本书选择过金币解锁后，后续同书余额足够时直接扣币。
- `membershipProvider`：会员状态，会员有效时全场畅读。
- `pageTurnModeProvider`：阅读器翻页模式记忆。

接 API 时，优先把这些 Provider 改造成服务端数据的本地缓存层。

## 6. 管理后台说明

技术栈：

- React 19
- Vite 8
- Tailwind 4
- react-router

功能模块：

- 数据看板：营收、用户、VIP、书籍、金币、趋势、题材分布、最近订单。
- 书籍管理：书籍 CRUD、题材/状态筛选、搜索、章节管理。
- 用户管理：用户列表、详情、订单记录、金币调整、封禁/解封。
- 订单流水：充值/会员订单筛选、退款演示。
- 变现配置：金币充值套餐、会员套餐、上下架、Google Play product id。

关键规则：

- `单章解锁金币 = 0` 表示全书免费。
- 免费书无需配置免费章节数，后台会禁用该输入，后端新增章节也会自动免费。
- 付费书仍按 `freeChapters` 派生免费章，后续章节走 VIP/金币。
- 变现配置中金币套餐与会员套餐都需要维护 `googlePlayProductId`，生产接 Google Play Billing 时用它映射商品。

关键文件：

| 文件 | 作用 |
|---|---|
| `后台/src/api.js` | 管理后台 API 封装。 |
| `后台/src/pages/Books.jsx` | 书籍 CRUD 与付费配置。 |
| `后台/src/pages/BookDetail.jsx` | 单本章节管理与付费派生展示。 |
| `后台/src/pages/Monetization.jsx` | 金币套餐 / 会员套餐配置。 |
| `后台/src/components/ui.jsx` | Button / Card / Badge / Input / Switch / Modal 等通用 UI。 |

## 7. 演示 API 说明

`server/` 只用于本地演示，不是生产后端。

技术特点：

- 零依赖 Node。
- 内存数据，进程重启后复位。
- 管理端演示接口集中在 `src/index.js`。
- 种子数据与派生规则在 `src/db.js`。

当前覆盖：

- 登录：`POST /api/auth/login`
- 看板：`GET /api/stats`
- 书籍：`GET/POST/PUT/DELETE /api/books`
- 章节：`POST/PUT/DELETE /api/books/:id/chapters`
- 用户：`GET /api/users`、金币调整、封禁
- 订单：列表、退款
- 变现：金币套餐 `/api/packages`、会员套餐 `/api/plans`

生产化方向：

- 使用 NestJS + PostgreSQL 重写。
- 合并 C 端接口与 Admin 端接口。
- 加正式鉴权、角色权限、数据库事务、幂等、Google 验单、RTDN、广告发奖校验。
- 接口与表结构以 `docs/plan/后端API与数据模型.md` 为准。

## 8. 当前核心业务规则

### 8.1 阅读与解锁

章节可读性按以下顺序判断：

```text
书籍 chapterPrice = 0，全书免费
→ 付费书的免费章
→ VIP 会员有效，全场畅读
→ 已通过金币/其他方式解锁该章节
→ 否则触发付费墙
```

前台当前行为：

- 书籍详情页：免费书显示 `Free` 标签，不显示金币单价。
- 阅读器：免费书每章直接下一章，不出现 `Unlock`。
- 付费书：免费章直接读；付费章触发 Paywall。
- Paywall 主推 VIP：`Read free with VIP`。
- 金币入口藏在 `Other ways to continue`。
- 余额足够：`Pay X coins` 直接扣币解锁。
- 余额不足：`Top up to unlock`，提示 `Not enough coins` 后进入充值。
- 用户在某本书第一次选择金币解锁后，后续同书点 `Unlock` 且余额足够时直接扣币解锁，不再弹窗。

### 8.2 会员与金币

- VIP 是主付费产品，权益是全场畅读、零广告、离线整本、会员徽章。
- 金币只给非会员按章购买使用。
- 会员端应隐藏金币消费入口和广告激励入口。
- 当前原型只有总金币余额，生产需要区分充值币 / 奖励币，并按文档做流水账。

### 8.3 Google Play 商品

后台字段：

```text
googlePlayProductId
```

适用对象：

- 金币充值套餐：Google Play 消耗型内购商品。
- 会员套餐：Google Play subscription 商品。

生产接入时：

- 前台展示套餐从后端拉取。
- 购买成功只把 purchase token 交给后端。
- 后端用 Google Play Developer API 验单。
- 客户端不能自行加币或开会员。

## 9. 重要文档索引

| 目的 | 文档 |
|---|---|
| 阶段路线、资产地图、上线顺序 | `HANDOFF.md` |
| 产品定位 | `PRODUCT.md` |
| 设计系统 | `DESIGN.md` |
| 页面规格、状态、交互 | `docs/design/前端设计PRD.md` |
| 后端接口、表结构、前后端状态映射 | `docs/plan/后端API与数据模型.md` |
| 客户端/后端/SDK 模块边界 | `docs/plan/App架构分配与优化.md` |
| 变现策略 | `docs/plan/变现模型.md` |
| 金币/会员数值与权益 | `docs/plan/金币与会员权益.md` |
| 埋点事件 | `docs/plan/埋点事件字典.md` |
| MVP 范围和里程碑 | `docs/plan/MVP范围与路线图.md` |
| 竞品结论 | `docs/research/竞品横向对比.md` |
| APK 逆向事实到架构映射 | `docs/research/APK深度架构映射.md` |
| 翻页算法资料 | `docs/design/book-page-flip/README.md` |

冲突处理原则：

- 接口和字段以 `docs/plan/后端API与数据模型.md` 为准。
- 页面和交互以 `docs/design/前端设计PRD.md` 为准。
- 颜色、字体、间距、圆角以 `DESIGN.md` 为准。
- 变现规则以 `docs/plan/金币与会员权益.md` 和 `docs/plan/变现模型.md` 为准。

## 10. 后续研发建议顺序

### 阶段 0：接手确认

1. 跑通前台、后台、演示 API。
2. 跑完 `flutter test`、`npm test`、`npm run build`。
3. 在前台手动走一遍：书籍详情 → 阅读器 → 付费墙 → 金币解锁 → 余额不足充值 → VIP。
4. 在后台手动改一本书为 `单章解锁金币 = 0`，确认前台逻辑对应。

### 阶段 1：生产后端

按 `docs/plan/后端API与数据模型.md` 实现 NestJS + PostgreSQL 模块化单体：

- identity
- content / discovery
- reader
- entitlement
- wallet
- payment
- membership
- ads
- growth
- admin

优先打通内容和章节读取，再做解锁、钱包、支付。

### 阶段 2：前台接 API

建议替换顺序：

1. 首页 / 分类 / 搜索 / 榜单。
2. 书籍详情 / 章节列表。
3. 阅读器正文和章节放行。
4. 付费墙、金币解锁、充值、会员。
5. 书架、收藏、进度、历史。
6. 我的、设置、语言、消息、隐私。

每替换一块，都保留现有 widget 测试或补新测试。

### 阶段 3：Google Play / 广告 / 推送

- Google Billing：金币消耗型内购 + VIP 订阅。
- RTDN：订阅续期、到期、退款。
- AppLovin MAX：钱包 Watch & earn，付费墙不做广告解锁。
- FCM：新章提醒、等待解锁完成、召回。
- Firebase Analytics / Crashlytics：先接，后续所有漏斗需要可观测。

### 阶段 4：内容入库和上架

- 首批书源、版权、翻译、章节切分。
- 管理后台补内容导入能力。
- Google Play 合规：隐私政策、用户协议、账号注销、GDPR/CCPA、内容分级、数据安全表单。
- 内部测试轨道先验证支付、订阅、推送、广告。

## 11. 常见坑

- 不要把 `server/` 当生产后端扩写太远。它是演示脚手架，生产应重写。
- 不要让客户端自行判定付费权益。生产必须由服务端判定章节正文是否可读。
- 不要在客户端购买成功后直接加币或开会员。必须后端验单。
- 不要引入新颜色/字体。用 `DESIGN.md` 和现有 `ElTheme`。
- 不要恢复“金币书 / VIP 书”双通道。当前模型是会员全场畅读，金币仅是非会员出口。
- 不要忘记 `chapterPrice = 0` 的免费书特殊语义：全书免费、无 Unlock、无免费章节数配置。
- 不要在同 WiFi 设备上用 `localhost` 打开服务。手机要用电脑局域网 IP。

## 12. 当前服务地址速查

| 服务 | 地址 |
|---|---|
| 后端演示 API | `http://localhost:4000` |
| 管理后台 | `http://localhost:5173` |
| 前台 App 局域网 Web | `http://<你的电脑局域网 IP>:5174` |

当前这台机器最近使用的 WiFi IP 是：

```text
192.168.110.55
```

如果网络变化，重新用 PowerShell 查看：

```powershell
Get-NetIPConfiguration | Where-Object { $_.IPv4Address } | ForEach-Object { "$($_.InterfaceAlias) $($_.IPv4Address.IPAddress)" }
```
