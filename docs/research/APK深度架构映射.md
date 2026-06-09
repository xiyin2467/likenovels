# APK 深度架构映射

> 数据来源：`docs/research/_raw/goodnovel.json`、`docs/research/_raw/ireader.json`。
> 目的：把 APK 静态拆解结果转化为我们自己的 App 架构分配，而不是停留在竞品功能清单。

## 1. 总结

GoodNovel 是主要架构蓝本：它的 APK 清楚暴露出出海网文 App 的核心链路：发现内容、书籍详情、阅读器、章节解锁、充值钱包、等待解锁、推送召回、广告聚合、归因和多语言。

iReader 当前包实质是掌阅国内版，不能作为出海技术栈蓝本。它的价值在于阅读体验底盘：书架、TXT/HTML/PDF/漫画阅读、字体皮肤、护眼、笔记、同步、TTS/AI 朗读等。但它的权限、国内支付、国内广告、厂商推送、加固/插件化不应进入海外 MVP。

## 2. GoodNovel 模块映射

| APK 线索 | 归类 | 对我们 App 的处理 |
|---|---|---|
| `ui.home.MainActivity`、`NewStoreResourceActivity`、`StoreSecondaryActivity` | App Shell + 书城/运营位 | **采用**。对应 `Discover` 与运营位配置。 |
| `ui.home.category.*`、`GenresActivity`、`RankNewPageActivity`、`RankHistoryActivity` | 分类/榜单 | **采用**。MVP 必须有分类和榜单，不必先做复杂推荐算法。 |
| `ui.search.SearchActivity`、`tag.TagGatherActivity`、`TagSearchActivity` | 搜索/标签 | **采用搜索，标签延后**。搜索是基础入口，标签聚合可作为 Should/Could。 |
| `ui.detail.BookDetailActivity`、`AuthorPageActivity`、`SeriesListActivity`、`TopFansActivity` | 书籍详情/作者/系列/粉丝榜 | **采用书籍详情，延后作者主页和粉丝榜**。 |
| `ui.reader.book.ReaderActivity`、`ReaderCatalogActivity`、`ReaderEndRecommendActivity` | 阅读器/目录/章末推荐 | **采用**。阅读器、目录、进度、章末推荐是核心体验。 |
| `ui.order.UnlockChapterActivity`、`BulkOrderActivity`、`WaitUnlockListActivity` | 单章解锁/批量购买/等待解锁 | **采用单章和等待解锁，批量购买延后**。 |
| `ui.recharge.RechargeActivity`、`wallet.WalletActivity`、`WalletHistoryActivity`、`ExpenseRecordActivity` | 充值/钱包/流水 | **采用**。钱包账务透明是付费信任基础。 |
| `ui.gems.GemsDetailActivity`、`home.ExchangeActivity` | 二级虚拟货币/兑换 | **延后**。MVP 只保留 Coins + Bonus，避免货币系统复杂化。 |
| `ui.inbox.*`、`ui.message.NotifyMessageActivity` | 站内信/通知 | **Should**。MVP 可先做推送入口和通知页骨架。 |
| `ui.setting.LanguageActivity`、`PushManagerActivity`、`TermsPolicyActivity` | 多语言/推送管理/条款隐私 | **采用**。合规与国际化必须从第一天设计。 |
| `ui.community.*`、`ui.comment.*` | 社区/评论/段评 | **延后**。先做书评/评分骨架，社区不进 MVP。 |
| `ui.writer.*` | 作者中心/UGC | **延后**。内容供给未验证前不建设 UGC 创作中心。 |
| `reader.comic.*`、`player.*`、`AudioPlayerService` | 漫画/有声 | **延后**。第二阶段能力。 |

## 3. GoodNovel 基础设施映射

| APK 线索 | 归类 | 对我们 App 的处理 |
|---|---|---|
| `com.android.vending.BILLING`、`ProxyBillingActivity` | Google Play Billing | **MVP 必须接入**。所有数字内容内购走官方 Billing。 |
| `FirebaseMessagingService`、`FCMService` | FCM 推送 | **MVP 必须接入**。用于追更、等待解锁、召回。 |
| AppLovin、AdMob、ironSource、Unity、Mintegral、Vungle、Fyber | 广告聚合 | **MVP 必须接入激励广告**。建议 AppLovin MAX 聚合，首版只做 Rewarded。 |
| AppsFlyer、Adjust | 买量归因 | **MVP 必须至少择一**。上线投放前接好事件口径。 |
| Firebase、SensorsData | 分析/性能/埋点 | **MVP 必须有事件体系**。可以先 Firebase + 自建事件规范。 |
| Google/Facebook/Twitter SDK | 三方登录/分享 | **Google 必须，Facebook/Apple Should**。Twitter 不进入 MVP。 |
| Sobot 客服 | 客服 | **可延后**。MVP 用邮箱/FAQ 即可，量起后接 Intercom/Zendesk。 |

## 4. iReader 可借鉴模块

| APK 线索 | 可借鉴点 | 处理 |
|---|---|---|
| `Activity_BookBrowser_TXT`、`Activity_BookBrowser_HTML` | 文本/HTML 阅读内核 | **借鉴**：章节正文用结构化文本/轻量 HTML，客户端负责排版。 |
| `ActivityReaderSetting`、`ActivitySettingProtectEyes`、`ActivityReadProgressStyle` | 阅读设置/护眼/进度样式 | **采用到阅读器**：字号、行距、主题、进度。 |
| `ActivityBookShelf`、`BookshelfProviderService`、`SyncIntentService` | 书架与同步 | **采用**：Library、进度同步、已解锁章节同步。 |
| `ActivityBookBrowserNotebook`、`ActivityMyCloudNoteList` | 笔记/云笔记 | **Could**：非 MVP，可在留存稳定后做。 |
| `ActivityAllFont`、`ActivitySkin` | 字体和皮肤 | **Should/Could**：MVP 内置少量主题，字体下载延后。 |
| TTS/AI Radio/AI Read | 有声和 AI 阅读 | **Won't（本期）**：第二阶段产品差异化。 |
| `ActivityFee`、`ActivityReFee`、`VoucherRewardVideoActivity` | 计费/代金券/激励视频 | **借鉴机制，不借技术栈**：我们用 Google Billing + AppLovin。 |

## 5. iReader 禁用/风险模块

以下能力属于国内生态或高合规风险，不进入海外 App：

- 支付宝、微信、QQ 钱包支付。
- 穿山甲、快手、广点通、百度、Sigmob、Beizi、Maplehaze 等国内广告聚合。
- 小米、Vivo、魅族、OPPO/Heytap、华为、个推、友盟、阿里 ACCS/Agoo、Yunba 等国内推送体系。
- `MANAGE_EXTERNAL_STORAGE`、`SYSTEM_ALERT_WINDOW`、`REQUEST_INSTALL_PACKAGES`、`WRITE_SETTINGS`、日历读写、自启动、应用安装相关权限。
- 国内加固壳、强插件化、应用内下载/安装 APK。
- 国内一键登录、微博/抖音/微信/QQ 登录。

## 6. 我们的模块分层结论

### MVP 必须

- App Shell：`Discover / Library / Wallet / Account`
- 内容发现：推荐流、分类、榜单、搜索
- 书籍：详情、章节列表、状态、相似推荐
- 阅读器：正文、目录、进度、字号、主题、缓存
- 解锁：付费墙、金币解锁、等待解锁、激励广告
- 钱包：余额、充值、流水、消费记录
- 增长：FCM、追更通知、等待解锁提醒
- 数据：核心事件埋点、崩溃、性能、归因
- 合规：隐私条款、CMP、账号注销、通知管理、多语言框架

### MVP 后优先补

- 批量解锁、自动解锁
- 签到/任务体系
- 站内信/消息中心
- 书评/评分
- 标签聚合与更完整搜索
- 个性化推荐规则化

### 明确延后

- 社区/发帖/关注
- 作者中心/UGC
- 漫画、有声、TTS/AI
- 订阅会员
- 复杂二级货币体系

## 7. 当前原型与架构的缺口

当前 `prototypes/v0-lofi/` 已覆盖 App Shell、Discover、Library、Wallet、Account、Detail、Reader、Paywall、Recharge、部分二级页。下一步应补齐：

- 搜索结果页：来自 GoodNovel `SearchActivity`。
- 章节目录页：来自 GoodNovel `ReaderCatalogActivity` 与 iReader 阅读内核。
- 消息/通知页：来自 GoodNovel `InboxListActivity`、`NotifyMessageActivity`。
- 语言页与推送管理页：来自 GoodNovel `LanguageActivity`、`PushManagerActivity`。
- 书评/评分入口：来自 GoodNovel 评论模块，但只做轻量骨架。

