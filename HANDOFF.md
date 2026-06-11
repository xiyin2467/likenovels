# HANDOFF.md — 研发交接（截至 2026-06-11）

> 本文档是**唯一交接入口**，面向接手的全栈研发。
> 建议工作方式：每个阶段开始时，把本文档 + 该阶段「先读」列出的文档一起提供给 AI，再开工。
> 路线图只规定顺序与验收标准，不含工期；按阶段推进，验收通过再进下一阶段。

## 一、现状

产品/设计/原型阶段已全部完成，三端可运行 demo 齐备；**尚无生产后端，客户端未接任何 API**。接下来的工作就是按本文档第五节的顺序，把原型变成可上架 Google Play 的产品。

## 二、这个项目是怎么做出来的（方法论溯源）

1. **技术底座来自公司短剧 App likereels 的成品 APK 逆向**：`docs/research/app-release.apk.1`（约 132MB，包名 `com.like.app.dev.reels`，Flutter 应用）是 likereels 的发布包。likenovel 的**编程语言与工程方法直接模仿该包逆向出的实现**：Flutter 技术栈本身、`assets/i18n/` 多语言 JSON 方案（语言矩阵 + manifest 版本号 + 缺译回退 en 的机制与该 APK 内部结构完全同构，likenovel 仅去掉简体中文）、资源组织方式（assets 下 fonts/i18n 分目录）等。同时 `D:\likereels` 整个仓库（产品文档、后台、商店物料、政策条例、投放 API 文档）是本项目的**前置项目**，文档骨架（PRODUCT.md / DESIGN.md / 后台 目录模式）一脉相承。
2. **竞品 APK 逆向 → 产品与架构事实**：下载了 GoodNovel v2.5.8.1168 与 iReader 国际版 v8.7.3.1 的 APK 原文件（`docs/research/竞品apk/`，共约 93MB），用 androguard 写脚本批量提取（脚本与原始 JSON 在 `docs/research/_raw/`：`extract_apk.py`、`deep_extract.py`、`enrich_ireader.py`、`scan_zip.py` + 5 份提取结果 JSON），拆出两家的模块结构、SDK 清单、权限、频道配置等事实，整理成《GoodNovel/技术拆解》《iReader国际版/技术拆解》与《APK深度架构映射.md》。
3. **逆向事实 → 我们的架构**：《App架构分配与优化.md》的客户端/后端模块边界、SDK 接入顺序、权限基线，都是从上述 APK 逆向事实映射取舍而来——**不是凭空设计**。变现机制参考 GoodNovel 的成熟闭环后，已收敛为当前 V2：VIP 订阅优先、金币仅为非会员按章兜底、广告仅保留钱包 Watch & earn。
4. **阅读器仿真翻页**：来自 `docs/design/book-page-flip/` 的 skill 包（3D 翻页算法 `references/algorithm.md` + 参考组件 `references/page_flip_widget.dart`），已集成进 `app/lib/features/reader/reader_screen.dart`。
5. **原型三步走**：v0 低保真 HTML（验证信息架构）→ v1 Figma Make 导出的 React 高保真（定视觉）→ v2 Flutter（验证目标技术栈），逐层收敛到现在的 `app/`。
6. **过程记录**：竞品分析与规划阶段的工作计划/设计稿存于 `docs/superpowers/`（plans + specs），可追溯当时的决策依据。

## 三、资产地图

### 3.1 `app/` — Flutter 客户端【起点代码，继续开发】

- 技术栈：Flutter + Riverpod（状态）+ go_router（路由）+ 本地打包字体（Inter/Newsreader 可变字体）。
- 已实现页面：引导/登录、题材引导页、首页（运营位 + 瀑布流）、分类、书架、我的、书籍详情、阅读器（4 主题/字号调节/滚动与仿真翻页/目录/收藏）、钱包（充值 Sheet/会员 Sheet/签到/Watch & earn）、付费墙（VIP 主 CTA + 金币折叠入口；余额足够 `Pay X coins`，不足 `Top up to unlock`），19 种语言的 i18n 脚手架，约 20 个「我的」子页（消息/搜索/榜单/交易流水/购买历史/阅读历史/推送管理/隐私/编辑资料等，见 `features/common/sub_pages.dart`）。
- **关键现状：纯 mock 数据驱动**。所有书籍/章节数据在 `lib/core/mock/mock_data.dart`（`kBooks` 等常量）；全部业务状态在 `lib/app/providers.dart` 的 6 个 Riverpod Provider（金币 `coinsProvider`、收藏 `favoritesProvider`、解锁账本 `unlockedChaptersProvider`、题材偏好 `preferencesProvider`、翻页模式 `pageTurnModeProvider`、会员 `membershipProvider`）。`pubspec.yaml` 无任何网络库。
- 付费墙/充值/订阅的完整交互逻辑在 `lib/app/router.dart`（`_showPaywall` / `_showRecharge` / `_showMembership` / `_simulateRewardAd`）——这是未来接 API 时要服务端化的「业务规则原型」。

### 3.2 `后台/` — 运营管理后台【起点代码，继续开发】

- 技术栈：React 19 + Vite + Tailwind 4 + react-router。
- 已实现：登录、仪表盘（营收/用户/书籍/金币统计 + 趋势）、书籍管理（增删改 + 章节管理 + 免费章数/解锁定价）、用户管理（查改 + 手动调币）、订单（查询/退款）、变现配置（金币套餐 + 会员计划增删改）。
- API 封装在 `src/api.js`，指向 `http://localhost:4000`。生产后端就绪后只需改 base URL 并补鉴权。

### 3.3 `server/` — 管理端演示 API【脚手架，需重写为生产后端】

- 零依赖 Node（`src/index.js` 单文件 27 个端点 + `src/db.js` JSON 文件存储 + `test/smoke.mjs` 冒烟测试）。
- **只用于支撑管理后台演示**，没有 C 端接口、没有真数据库、没有真鉴权。生产后端按第五节阶段 1 用 NestJS + PostgreSQL 重写；本脚手架的管理端点行为（books/chapters/users/orders/packages/plans/stats）可作为 admin 模块的参考实现。

### 3.4 研究资产与素材（全量清单）

| 位置 | 内容 | 用途 |
|---|---|---|
| `docs/research/app-release.apk.1` | **likereels 成品 APK**（约 132MB，包名 `com.like.app.dev.reels`，Flutter） | 本项目技术栈与工程方法的逆向模仿对象（i18n 方案/资源组织均源于此），见第二节第 1 条 |
| `docs/research/竞品apk/` | GoodNovel v2.5.8.1168、iReader 国际版 v8.7.3.1 **APK 原文件**（手动下载，共约 93MB） | 逆向分析的原始素材，可随时重新提取 |
| `docs/research/_raw/` | androguard 提取脚本 ×4 + 逆向结果 JSON ×5（goodnovel/ireader 的 deep/scan 数据） | 逆向工具链，可复用于分析其他竞品 |
| `docs/research/GoodNovel/`、`iReader国际版/` | 各自的《技术拆解.md》+《产品分析.md》 | 模块/SDK/变现/体验的事实依据 |
| `docs/research/竞品横向对比.md`、`APK深度架构映射.md`、`竞品深挖与差距清单.md` | 横向结论 + APK 事实到模块取舍的映射 + 差距清单（含合规项） | 架构与功能决策的依据 |
| `docs/research/海外小说App金币体系调研报告.md` | 六大平台（Webnovel/Dreame/GoodNovel/Wattpad/Galatea/Piccoma）金币/会员体系深度调研 + 定价与机制设计建议 | 付费路径设计的对标依据，《金币与会员权益.md》第 6 节引用 |
| `docs/design/book-page-flip/` | 仿真翻页 skill 包：算法文档 + `page_flip_widget.dart` 参考组件 | 阅读器翻页效果的实现来源与调参手册 |
| `docs/superpowers/` | 竞品分析与规划阶段的 plan/spec 工作记录 | 决策过程追溯 |
| `app/assets/fonts/` | Inter、Newsreader 可变字体 TTF（本地打包，不依赖 Google Fonts） | 设计系统指定字体，离线可用 |
| `app/assets/i18n/` | 19 语言 JSON + manifest（语言矩阵对齐 likereels） | i18n 数据源，缺译自动回退 en |
| `prototypes/v0-lofi/` | 低保真 HTML 原型（双击 `index.html`） | 信息架构参考，不维护 |
| `prototypes/v1-figma/` | Figma Make 导出的 React 高保真原型 | **视觉验收基准**，不维护 |
| `D:\likereels`（仓库外，同级项目） | **本项目的前置项目**（公司短剧 App 完整仓库）：产品文档、管理后台、应用商店物料（logo/五连图/简介）、APP 政策条例全套、官网页面、FB/Google/TikTok 投放 API 文档等 | 工程方法与文档骨架的来源；阶段 7 上架物料与政策文本可直接借鉴 |

### 3.5 本地启动

```powershell
# 后台演示 API（http://localhost:4000）
cd server; npm run dev
# 管理后台（http://localhost:5173）
cd 后台; npm run dev
# Flutter 客户端（SDK 在 C:\flutter，已加入用户 PATH；Chrome 调试最快）
cd app; flutter pub get; flutter run -d chrome
```

> 注意：支付（Billing）、广告（MAX）、推送（FCM）只能在 **Android 真机/模拟器**验证，Chrome 仅用于 UI 与接口联调。

## 四、唯一事实来源（开发时以这些为准）

| 主题 | 文档 |
|---|---|
| 接口契约 + 数据库表结构 + 前后端状态映射 | `docs/plan/后端API与数据模型.md` ★最重要 |
| 客户端/后端模块边界、SDK 接入顺序、权限基线 | `docs/plan/App架构分配与优化.md` |
| 页面规格 / 组件 / 交互 | `docs/design/前端设计PRD.md` |
| 设计 token（颜色/字体/间距/圆角/动效） | `DESIGN.md` |
| 埋点事件 | `docs/plan/埋点事件字典.md` |
| 技术栈决策及理由 | `docs/plan/技术选型建议.md` |
| MVP 范围与里程碑验收 | `docs/plan/MVP范围与路线图.md` |
| 变现规则（金币/VIP/广告/等待解锁/定价） | `docs/plan/变现模型.md` |
| 金币/会员权益数值与解锁规则（现状基线，梳理中） | `docs/plan/金币与会员权益.md` |
| 内容来源方案 | `docs/plan/内容供给方案.md` |
| 合规差距清单（GDPR/注销/分级） | `docs/plan/对标GoodNovel差距分析.md`、`docs/research/竞品深挖与差距清单.md` |

> 冲突处理原则：范围以《MVP范围与路线图.md》为准；接口与字段以《后端API与数据模型.md》为准；视觉以 `DESIGN.md` + v1 原型为准。

## 五、从现在到上线的路线图

### 阶段 0 — 环境与认知

1. 跑通 3.5 节三个启动命令；`flutter analyze` 零错误；`cd server && npm test` 冒烟通过。
2. 通读第四节打 ★ 的文档 + 把三端 demo 各点一遍（重点走一次：试读 → 付费墙 → 充值 → 解锁）。
3. 在 Flutter 原型里读懂 `providers.dart` 与 `router.dart` 的 `_showPaywall` 逻辑——后面所有服务端化都以它为行为基准。

### 阶段 1 — 生产后端（先读：后端API与数据模型.md、App架构分配与优化.md、技术选型建议.md）

**目标**：按契约实现全部 C 端接口 + 并入管理端接口，管理后台无缝切换。

1. **工程搭建**：NestJS + PostgreSQL + TypeORM/Prisma；按《App架构分配与优化.md》第 3 节划分模块：`identity / content / discovery / reader / entitlement / wallet / payment / membership / ads / growth / admin`。模块化单体，不做微服务。
2. **通用约定**（契约第 1 节）：`/api/v1` 前缀；JWT 鉴权（游客也发短期匿名 token）；分页 `{ items, page, size, total }`；错误 `{ code, message }` 用稳定业务码（如 `INSUFFICIENT_BALANCE`）；解锁/验单/发奖等写操作支持 `Idempotency-Key`。
3. **建表**（契约第 3 节，13 张）：`user`、`book`（含 `free_chapter_count`、`chapter_price`、`age_rating`；`unlock_type` 已废弃）、`chapter`、`chapter_entitlement`、`wallet` + `wallet_ledger`（流水含 `balance_after` 对账字段）、`payment_order`、`reading_progress`、`subscription`、`checkin_log`、`user_preference`、`wait_unlock`、`library_item`、`message`。
4. **按依赖顺序实现接口**（清单见契约第 2 节，约 45 个）：
   - ① content + discovery：`/home`、`/genres`、`/ranks`、`/search`、`/books/{id}`、`/books/{id}/chapters`——纯读，先让客户端有数据可接；
   - ② identity：游客 / 邮箱 / OAuth / 游客升级 / `/me` / 偏好 / 注销 / 数据导出；
   - ③ reader：书架、进度、历史、`/chapters/{id}/content`（放行判定见下）；
   - ④ entitlement + wallet：解锁（coins/ad/wait 三 method）、等待解锁计时、余额、流水；
   - ⑤ payment + membership：Google 验单、订阅验单、RTDN webhook、会员状态（全场畅读）；
   - ⑥ growth：push-token、站内信、签到；
   - ⑦ admin：把 `server/` 现有 27 个管理端点并入 admin 模块（加角色鉴权），数据源换成同一个 PostgreSQL。
5. **核心放行规则**（必须服务端判定，客户端只渲染）：`GET /chapters/{id}/content` 按「免费章 → 有效会员 → 已购 entitlement」三路放行；会员全场畅读，非会员可金币/广告/等待解锁单章。与前台 `_canRead` 逻辑一一对应（契约 2.4/2.6 节有明确规则）。
6. **种子数据**：写 seed 脚本灌 3–5 本带完整章节的测试书（可先抓 `app/lib/core/mock/mock_data.dart` 里的 mock 书目结构）。
7. **验收**：契约内全部接口可用并有 e2e 冒烟测试（参考 `server/test/smoke.mjs` 的风格扩写）；管理后台 `后台/src/api.js` 切到新服务后六个页面功能不回退；用 curl 走通「游客 token → 拉书 → 拉章节 → 解锁失败（余额不足）→ 调币 → 解锁成功 → 流水正确」。

### 阶段 2 — 客户端接 API（先读：后端API与数据模型.md 第 5 节映射表、前端设计PRD.md）

**目标**：删除 `mock_data.dart` 后 App 功能完整。

1. **网络层**：新建 `lib/core/api/`——dio + 拦截器（token 注入、401 刷新、业务错误码→统一异常、重试）；`flutter_secure_storage` 存 token；环境配置区分 dev/prod base URL。
2. **Repository 层**：每个业务域一个 repository（book/reader/wallet/account/growth），Riverpod 的 `FutureProvider`/`AsyncNotifier` 包装；现有 6 个 Provider 改造为「接口数据的本地缓存层」，对应关系按契约第 5 节映射表逐行执行（该表把每个页面交互 → Riverpod 状态 → 接口 → 落库表都列好了，**照表施工**）。
3. **替换顺序**（每替换一页跑一遍回归）：首页 → 分类 → 详情 → 章节列表（锁状态来自 `/books/{id}/entitlements`）→ 阅读器正文（`/chapters/{id}/content`，402 时弹付费墙）→ 书架/收藏 → 钱包/流水/订单 → 签到 → 偏好/资料/语言 → 消息中心 → 阅读历史。
4. **进度同步**：阅读器翻章节流上报 `PUT /me/progress/{book_id}`（节流，如 5 秒/次或翻章时）；启动时拉取续读位置。
5. **离线兜底**：已读章节正文本地缓存（drift 或 hive），弱网/离线可读已缓存章节；列表页骨架屏 + 失败重试态（设计 PRD 已有规格）。
6. **验收**：物理删除 `mock_data.dart` 与 providers 里的硬编码初值（如金币 640），编译通过、全功能可用；断网时已读章节可读、未读章节有明确报错态。

### 阶段 3 — 账号体系（先读：契约 2.1 identity 节）

1. 游客模式：首启静默调 `POST /auth/guest`，匿名 token 落本地——**用户无感知，不强制登录**。
2. 邮箱注册/登录、Google 登录（`google_sign_in` 取 id_token → `POST /auth/oauth`）。
3. 游客升级正式号：`POST /auth/upgrade`，服务端合并钱包/书架/进度/解锁记录（注意冲突策略：金币相加、书架并集、进度取较新）。
4. 账号注销：`POST /me/delete`，软删除 + 异步物理清理 PII（30 天内），**Google Play 硬性要求**。
5. 登录态壳：router 增加重定向逻辑（引导页只在首启出现；登录页可从「我的」进入）。
6. **验收**：四条链路（游客直用 / 邮箱 / Google / 游客升级）全通；升级后旧设备数据完整保留；注销后数据按政策清除。

### 阶段 4 — 支付与解锁闭环服务端化（先读：变现模型.md、契约 2.4/2.5/2.6 节）

1. **Google Play Console 配置**：金币内购商品（消耗型，4 档：$0.99 / $4.99 / $9.99 / $19.99）+ VIP 订阅（weekly/monthly/yearly）；金币不设 $49.99/$99.99 大额档，避免截留应转订阅的重度用户。
2. **客户端**：接 `in_app_purchase`（或 `purchases_flutter`）；`RechargeSheet`/`MembershipSheet` 的套餐数据改从 `/recharge/packages`、`/membership/plans` 拉取；购买成功后把 purchase_token 交给后端验单，**客户端不自行加币**。
3. **服务端验单**：`POST /payment/google/verify`（Google Play Developer API 校验 token → 幂等入账 → 写 `payment_order` + `wallet_ledger`）；订阅走 `POST /membership/google/verify` 写 `subscription`。
4. **RTDN**：配置 Google Real-time Developer Notifications → `POST /membership/rtdn`，处理续期/到期/退订/退款；会员权益变更后实时影响全场畅读放行。
5. **解锁服务端化**：非会员金币入口走 `POST /chapters/{id}/unlock`（method=coins）：余额足够时直接扣币写 `chapter_entitlement`，余额不足返回 `INSUFFICIENT_BALANCE` 并由前台进入充值页；VIP 用户不进入支付墙，`GET /chapters/{id}/content` 直接按订阅放行。等待解锁走 `POST /chapters/{id}/wait-unlock`（后续版本，服务端计时，客户端只显示倒计时）。删除 `router.dart` 里的本地扣币逻辑。
6. **安全**：验单防重放（provider_token 唯一索引）、掉单补单（客户端启动时重试未完成购买）、退款回收金币（负向 ledger）。
7. **验收**：内部测试轨道真机走通「试读 → 付费墙 → 订阅 → 全场畅读」「试读 → 付费墙 → 金币解锁单章」；管理后台订单页能看到真实订单并能对账（ledger 的 `balance_after` 连续）。

### 阶段 5 — 增长基建（先读：埋点事件字典.md、App架构分配与优化.md 第 4/6 节）

按 SDK 接入顺序表执行：

1. **Firebase Crashlytics + Analytics**（最先，所有后续功能都要可观测）。
2. **埋点**：新建 `lib/features/analytics/` 模块（事件常量 + facade），按字典覆盖核心漏斗 15 事件（`app_open` → `chapter_complete`），关键事件双发后端（自有 events 表，便于对账）。
3. **FCM**：token 上报 `POST /me/push-token`；服务端按 `user_preference.push_prefs` 分群过滤；MVP 推送场景：新章提醒、等待解锁完成、召回。
4. **激励广告**：AppLovin MAX SDK + 聚合（AdMob 等）；MVP 仅接钱包「Watch & earn」，付费墙不做广告解锁模块。服务端 `POST /ads/reward` 校验后发奖（幂等 + 每日次数上限，防刷）。
5. **归因**：AppsFlyer 或 Adjust（选型见第六节未决问题），买量前必须就绪。
6. **验收**：Firebase 后台能看到漏斗事件流；真机收到推送并能深链到书；激励视频测试模式发币成功且有日上限；Crashlytics 能收到测试崩溃。

### 阶段 6 — 内容入库（先读：内容供给方案.md）

1. 书源确定后（第六节未决问题 2），写批量导入脚本（txt/epub → 章节切分 → admin API 入库），或扩展管理后台上传能力。
2. 每本书配置：免费章数、非会员章价、品类标签、`age_rating`（成人向内容必须标 mature，商店分级要用）。`unlock_type` 已废弃，会员默认全场畅读。
3. 首页运营位/榜单在管理后台配置（如现有能力不足，扩展 admin 的 discovery 配置接口）。
4. **验收**：首批书全部可读可解锁；至少 1 本完整书在真机走通全闭环——这是 V0.1 里程碑验收线。

### 阶段 7 — 上架 Google Play（先读：对标GoodNovel差距分析.md 合规节）

1. **合规闭环**：隐私政策 + 用户条款页（站内 WebView + 商店链接）；GDPR 同意管理（Google UMP/CMP，欧洲用户首启弹窗，与 `privacy_prefs` 联动）；账号注销入口可见；Play Console 数据安全表单如实填写；IARC 内容分级（含 mature 内容声明）。
2. **权限自查**：只保留 `INTERNET`、`ACCESS_NETWORK_STATE`、`POST_NOTIFICATIONS`、Billing/AD_ID（见架构文档第 7 节的禁用清单）。
3. **打包**：正式签名 keystore（备份！）、App Bundle、混淆规则、版本号策略。
4. **商店物料**：图标、截图（真机截原型页即可）、特色图、简介文案（注意品类方向，见第六节问题 1）；logo/五连图/政策条例的格式与文本可直接参考 `D:\likereels` 现成素材。
5. **发布**：内部测试 → 封闭测试（跑通买量归因数据）→ 正式发布。
6. **验收**：上架成功；买量 → 留存 → 付费数据看板可用（Firebase + 归因平台 + 管理后台仪表盘三方数字能对上）。

## 六、未决问题

1. **首发品类方向**：女频或男频未最终确定。注意 `docs/plan/` 下的规划文档（市场定位、内容供给、前端设计 PRD 等）目前按女频假设撰写，若定为男频，选品、封面题材色板、首页运营位文案需相应调整，但产品架构与变现闭环不受影响。
2. **内容版权来源**：首批 50–100 本书从哪来（采购/翻译/签约）？阶段 6 的硬依赖。
3. **支付与开发者主体**：Google Play 开发者账号、收款税务主体。阶段 4 的硬依赖。
4. **归因平台选型**：AppsFlyer 还是 Adjust（影响阶段 5 SDK 集成）。
5. **正式定价**：金币套餐/VIP 价格（当前管理后台与文档中均为占位示例值）。
6. **App 正式名称与图标**（likenovel 为工作名）。

## 七、给 AI 辅助开发的约定

- 仓库根目录可建 `AGENTS.md`，写明：代码规范、目录约定、设计 token 引用方式、提交信息格式（**不要再用「更新」**，用 `feat:/fix:/refactor:` 前缀 + 一句话说明）。
- 每阶段开工前，把本文档该阶段的「先读」文档一并喂给 AI；接口与字段一律以《后端API与数据模型.md》为准，**不允许 AI 自行发明字段或接口**；发现契约缺口时先补文档再写代码。
- 客户端改造严格按契约第 5 节「前台 ↔ 后端数据闭环映射表」逐行执行，每行完成后在表上打勾跟踪进度。
- UI 改动对照 `DESIGN.md` 色板与 v1 原型，禁止引入文档外的颜色/字体；新页面先查《前端设计PRD.md》有无现成规格。
- 涉及钱（验单/扣币/发奖）的代码必须有幂等处理和单元测试；涉及合规（注销/CMP/权限）的改动对照阶段 7 清单复查。
- 每阶段结束跑 `flutter analyze` + 后端测试套件，全绿再进下一阶段；阶段验收点列在第五节各阶段末尾。
