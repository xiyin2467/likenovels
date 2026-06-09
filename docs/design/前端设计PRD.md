# likenovel 前端设计 PRD（面向 Figma 交付）

> 产品名称：likenovel  
> 定位：英语市场女频网文阅读 App（Android 优先，iOS 跟进）  
> 设计风格：浅色编辑感书房 — 暖象牙底 + 墨梅文字 + 石榴酒红主色 + 金色点缀  
> 本文档用于 Figma 设计交付，包含信息架构、页面规格、组件、状态与交互说明。

---

## 一、信息架构（IA）

### 底部导航（4 Tab）

| Tab | 图标 | 标签 | 对应视图 |
|-----|------|------|----------|
| 1 | home | Discover | 书城首页 |
| 2 | books | Library | 我的书架 |
| 3 | coin | Wallet | 钱包/充值 |
| 4 | user | Me | 个人中心 |

> 底部导航在以下页面隐藏：Onboarding、口味引导、阅读器、书籍详情、子页面。

### 页面层级

```
├── Onboarding（欢迎 + 登录）
├── Guide（口味选择）
├── Discover（首页）
│   ├── 搜索结果
│   ├── 分类/Genre 子页
│   ├── 榜单详情
│   └── 推荐调优
├── Book Detail（书籍详情）
│   ├── 章节目录
│   ├── 书评
│   └── 收藏确认
├── Reader（阅读器）
│   ├── 阅读设置 Sheet
│   └── 付费墙 Sheet
├── Library（书架）
│   ├── 正在读 / 已解锁 / 已读完
│   └── 同步状态
├── Wallet（钱包）
│   ├── 充值 Sheet
│   └── 签到/每日奖励
├── Me（个人中心）
│   ├── Transactions（交易记录）
│   ├── Messages（消息中心）
│   ├── Settings
│   │   ├── Notifications
│   │   ├── Language
│   │   ├── Push management
│   │   └── Privacy & data
│   └── Delete account
└── 充值 Sheet（全局可唤起）
```

---

## 二、设计系统（Design Tokens）

### 颜色

| Token | 值（OKLCH） | 用途 |
|-------|-------------|------|
| `--bg` | oklch(0.975 0.008 60) | App 背景（暖象牙） |
| `--surface` | oklch(0.995 0.004 70) | 卡片/面板 |
| `--surface-2` | oklch(0.955 0.010 58) | 抬升面/输入框 |
| `--surface-3` | oklch(0.928 0.012 56) | 进度槽等 |
| `--line` | oklch(0.905 0.010 50) | 描边 |
| `--ink` | oklch(0.26 0.035 350) | 主文字（墨梅，≥7:1） |
| `--muted` | oklch(0.49 0.028 350) | 次要文字（≥4.5:1） |
| `--faint` | oklch(0.60 0.022 350) | 三级文字 |
| `--primary` | oklch(0.52 0.158 16) | 石榴酒红（主按钮/选中） |
| `--primary-ink` | oklch(0.40 0.150 16) | 浅底上酒红文字/链接 |
| `--primary-soft` | oklch(0.95 0.030 18) | 酒红浅底（标签/选中底） |
| `--gold` | oklch(0.78 0.115 78) | 金色（星标/货币/细节） |
| `--on-primary` | oklch(0.99 0.01 80) | 酒红填充上的近白文字 |
| `--success` | oklch(0.55 0.12 150) | 正向状态（免费/到账） |

### 字体

| 家族 | 用途 |
|------|------|
| **Newsreader**（衬线） | 书名、Hero、封面标题、阅读器正文、统计数字 |
| **Inter**（无衬线） | 导航、按钮、标签、表单、UI chrome |

### 间距与圆角

- 间距基数：4px；常用 8 / 12 / 16 / 18 / 20 / 24
- 圆角：控件 13px、卡片 18px、底部 Sheet 26px、手机外框 40px

### 运动

- UI 过渡：120–220ms ease-out
- 底部 Sheet 上滑：260ms
- `prefers-reduced-motion`：降为即时/淡入

---

## 三、页面规格

### 3.1 Onboarding（欢迎页）

**布局**：全屏，上方 3 张封面轮播（CSS 渐变封面），下方品牌名 + 标语 + 登录按钮组。

**元素**：
- 品牌名："likenovel"，前方带 spark 图标
- 标语：`Romance you won't put down.`
- 副标题：说明免费试读 + 金币解锁机制
- 按钮组（自上而下）：
  1. `Continue with Google`（主按钮，酒红填充）
  2. `Continue with Facebook`（Ghost 按钮）
  3. `Continue with email`（Ghost 按钮）
  4. `Browse as guest`（文字按钮）
- 底部法律声明链接

**交互**：点击任何按钮 → 进入口味引导页。

---

### 3.2 Guide（口味引导）

**布局**：顶部返回栏 + 标题"What do you love?" + 可多选标签网格 + 底部固定 CTA。

**标签列表**：Werewolf / CEO & Billionaire / Reborn / Vampire / Romantasy / Fated mates / Contract marriage / Second chance / Enemies to lovers / Forbidden love

**交互**：
- 选中标签变酒红底 + 白字
- 选 ≥1 个标签后 CTA 文字从"Skip for now"变为"Continue (N selected)"
- 点击 CTA → 进入首页

---

### 3.3 Discover（书城首页）

**顶栏**：
- 左：eyebrow "Discover" + 品牌名 "likenovel"
- 右：金币余额 pill（点击跳转 Wallet）+ 消息铃铛（红点）

**搜索栏**：placeholder "Search titles, authors, tropes"，点击跳转搜索结果页。

**Genre 横滑标签**：For you / Werewolf / CEO / Reborn / Vampire / Romantasy（选中态为酒红浅底）

**内容区（自上而下）**：
1. **Hero 轮播**：大卡片横滑，每张含封面 + 标签 + 标题 + 一句 blurb + 评分/阅读数/章节数
2. **Top charts**：带排名序号的横滑列表（#1 有金色高亮）
3. **New & rising**：封面横滑列表
4. **For you 瀑布流**：2 列封面 + 书名 + 评分，无限滚动（先显示骨架屏再替换内容）

---

### 3.4 Book Detail（书籍详情）

**布局**：全屏，浮动返回按钮。

**Hero 区**：渐变背景 + 居中封面大图（带角标 Hot/Complete）

**正文区**：
- 书名（Newsreader 衬线）
- 评分 + 阅读量 + 章节数 + 状态
- 标签（Genre + trope）
- 简介段落
- 章节列表入口（前 3 章标"Free"，后续标金币价格）

**底部固定栏**：
- 左：心形收藏按钮
- 右：主 CTA `Read chapter 1 free`

---

### 3.5 Reader（阅读器）

**顶栏**（点击内容区显示/隐藏）：
- 返回按钮
- 书名
- 章节目录按钮
- 阅读设置按钮

**正文区**：
- 章节号 kicker + 章节标题
- 正文段落（Newsreader 衬线）
- 付费墙卡片（内联在正文末尾）：锁图标 + "Continue Chapter X" + 提示文字

**底部栏**：
- 阅读进度百分比
- 进度条
- Unlock 按钮

**阅读设置 Sheet**：
- 字号调节（A- / A+）
- 主题选择（4 色块）：Paper / Sepia / Dark / Black

**4 套阅读器主题**：

| 主题 | 背景 | 文字 |
|------|------|------|
| Paper | oklch(0.972 0.006 85) | oklch(0.27 0.012 60) |
| Sepia | oklch(0.91 0.035 75) | oklch(0.33 0.025 55) |
| Dark | oklch(0.21 0.012 300) | oklch(0.88 0.01 80) |
| Black | oklch(0.05 0 0) | oklch(0.80 0 0) |

---

### 3.6 Paywall Sheet（付费墙底部弹窗）

**标题**："Unlock Chapter 12" + 副标题

**3 个选项卡片**：
1. **金币解锁**（主推，高亮边）：coin 图标 + "Unlock with 38 coins" + 余额提示
2. **看广告**：play 图标 + "Watch a short ad" + "About 30 seconds, free"
3. **等待解锁**：clock 图标 + "Wait to unlock" + 倒计时 "Free in 03:58:21"

**底部**：文字链接 "Need more coins? Top up" → 唤起充值 Sheet

---

### 3.7 Library（书架）

**顶栏**：eyebrow "Library" + 标题 "My books" + Synced 状态 pill

**继续阅读卡片**：大卡片，封面 + 书名 + 进度百分比 + 章节

**Tab 标签**：Reading / Unlocked / Finished

**书籍列表**：封面 + 书名 + 作者 + 进度

**空状态**（Finished tab）：图标 + 标题 + 说明文字

---

### 3.8 Wallet（钱包）

**顶栏**：eyebrow "Wallet" + 标题 "Coins & rewards"

**余额卡片**（渐变/发光效果）：
- "Available balance"
- 金币数量（大字 + coin 图标）
- 换算提示 "About 32 standard chapters"
- CTA 按钮 "Top up coins"

**奖励入口网格**（2 格）：
1. Daily check-in → +20 coins
2. Watch & earn → +12 coins

**充值套餐区**：
- section head "Recharge packages" + More 链接
- 套餐卡片（显示 2 个精选）

> 注意：此前钱包页有"Recent activity"流水区块，已移除。交易记录收纳至「Me → Transactions」。

---

### 3.9 Me（个人中心）

**顶栏**：eyebrow "Account" + 标题 "Me" + Settings 齿轮按钮

**个人卡片**：头像 + 昵称 + 等级/连续签到天数 + Edit 按钮

**统计行**：Books / Chapters / Streak

**菜单列表**：

| 图标 | 标签 | 右侧值 | 跳转目标 |
|------|------|---------|----------|
| wallet | Wallet & purchases | 1,240 | purchase-history |
| lock | Transactions | — | wallet-history |
| bell | Messages | 3 | message-center |
| sliders | Notifications | On | notifications |
| language | Language | English | language |
| shield | Push management | — | push-management |
| lock | Privacy & data | — | privacy |
| trash | Delete account | — | delete-account（红色危险项） |

---

### 3.10 Recharge Sheet（充值弹窗，全局可唤起）

**标题**："Top up coins" + "Secure checkout via Google Play"

**套餐列表**：

| 金币 | 赠送 | 价格 | 标签 |
|------|------|------|------|
| 300 coins | First-time price | $0.99 | Starter |
| 600 coins | +60 bonus | $4.99 | — |
| 1,400 coins | +240 bonus | $9.99 | Best value（高亮） |
| 3,200 coins | +720 bonus | $19.99 | — |

**操作**：选中套餐 → Pay with Google Play 按钮  
**底部小字**：Prices localized by region. Bonus coins are non-refundable.

---

### 3.11 子页面（通用容器）

**顶栏**：返回按钮 + eyebrow（来源） + 标题

以下子页面使用此容器：

| Key | Eyebrow | 标题 | 内容类型 |
|-----|---------|------|----------|
| wallet-history | Wallet | Transactions | 流水列表 |
| purchase-history | Wallet | Purchases | 购买记录列表 |
| daily-checkin | Rewards | Daily check-in | 7 天签到网格 |
| message-center | Inbox | Messages | 消息列表 |
| settings | Account | Settings | 设置列表 |
| notifications | Settings | Notifications | 开关列表 |
| language | Settings | Language | 单选列表 |
| push-management | Compliance | Push management | 开关列表 |
| privacy | Settings | Privacy & data | 操作列表 |
| delete-account | Account | Delete account | 危险操作确认 |
| search-results | Search | Results | 书籍列表 |
| top-charts | Charts | Top this week | 排名列表 |
| new-releases | New | New & rising | 书籍列表 |
| for-you | Personalized | For you | 书籍列表 |
| genre-* | Genre | [类型名] | 书籍列表 |
| chapter-catalog | Chapters | All chapters | 章节列表 |
| book-reviews | Reviews | Reader reviews | 评价列表 |

---

## 四、组件库（Component Library）

### 按钮

| 变体 | 样式 | 使用场景 |
|------|------|----------|
| btn-primary | 酒红填充 + 白字 | 主 CTA |
| btn-ghost | 透明底 + 酒红边框 | 次要操作 |
| btn-text | 纯文字酒红色 | 三级操作 |
| btn-onlight | 浅色底上的强调按钮 | 余额卡片内 |
| btn-block | 全宽 | 表单/Sheet |
| btn-sm | 小尺寸 | 阅读器底栏 |
| icon-btn | 纯图标圆形 | 导航操作 |
| pill | 胶囊形 | 状态/金币余额 |

**状态**：default / hover / focus-visible / active / disabled

### 封面（Cover）

- 纯 CSS 渐变 + 排版，无图片依赖
- 6 个题材色板：werewolf（蓝黑夜）/ ceo（炭灰+金）/ reborn（石榴红）/ vampire（血黑）/ romantasy（紫罗兰）/ modern（玫瑰）
- 可叠加角标：Hot（flame 图标）/ Complete（check 图标）
- 可叠加排名序号

### 卡片

| 类型 | 用途 |
|------|------|
| hero-card | 首页大轮播 |
| rank-card | 榜单横滑 |
| book-card | 普通封面卡 |
| continue-card | 书架继续阅读 |
| balance-card | 钱包余额（带 glow 效果） |
| profile-card | 个人信息 |
| sub-card | 子页面说明卡 |
| danger-card | 危险操作（红色） |

### 列表项

| 类型 | 用途 |
|------|------|
| menu-item | 个人中心菜单（图标 + 标签 + 值 + 箭头） |
| ledger-row | 交易流水行（图标 + 名称/时间 + 金额±） |
| pack-row | 充值套餐（金币 + 赠送 + 价格 + 标签） |
| option | 付费墙选项（图标 + 主副文字 + 箭头） |
| reward | 奖励入口格子（图标 + 标题 + CTA） |

### 导航

| 组件 | 说明 |
|------|------|
| tabbar | 底部 4 Tab 导航 |
| topbar | 页面顶栏（品牌 + 操作区） |
| subbar | 子页面顶栏（返回 + 标题） |
| chip-row | 横滑标签/筛选 |

### 表单控件

| 组件 | 说明 |
|------|------|
| searchbar | 搜索栏（点击态） |
| stepper | +/− 调节（字号） |
| swatch | 主题色块按钮 |
| toggle | 开关（用于设置） |
| taste-chip | 口味多选标签 |
| checkin-day | 签到日格子 |

### 反馈

| 组件 | 说明 |
|------|------|
| toast | 底部浮动提示 |
| dot | 红点徽标（未读） |
| empty-state | 空列表状态（图标 + 文字） |
| skeleton | 骨架屏（shimmer 动画） |

---

## 五、交互规格

### 导航转场

| 动作 | 动画 |
|------|------|
| Tab 切换 | 淡入（120ms） |
| 进入子页面 | 从右滑入（220ms ease-out） |
| 返回 | 向右滑出 |
| Sheet 出现 | 从底部滑上（260ms）+ scrim 淡入 |
| Sheet 关闭 | 向下滑出 + scrim 淡出 |
| 进入阅读器 | 全屏淡入 |

### 列表/瀑布流

- 首次加载：显示骨架屏 → 内容替换（淡入）
- 无限加载：底部触发加载更多骨架 → 追加内容
- 空状态：居中图标 + 文字说明

### 阅读器

- 点击正文区：顶栏/底栏 toggle 显示/隐藏
- 字号调节：实时改变文字大小（0.92rem–1.32rem）
- 主题切换：实时切换 4 种配色
- 付费墙：内联卡片 + 底部 Unlock 按钮均可触发 Paywall Sheet

### Sheet（底部弹窗）

- 顶部 grab 手柄（拖拽提示）
- 背后 scrim（点击关闭）
- 内容滚动（套餐列表超出时）

---

## 六、状态清单

设计师需为每个关键组件提供以下状态：

### 按钮状态
- Default / Hover / Focus-visible / Active / Disabled

### 阅读器
- 4 主题 × 3 字号档位 = 12 种组合
- 顶底栏显示/隐藏

### 付费墙
- 余额充足（直接解锁）
- 余额不足（提示充值）
- 广告加载中
- 等待解锁倒计时

### 书架
- 有书 / 空状态
- 同步中 / 已同步

### 钱包
- 有余额
- 零余额（突出 Top up）

### 签到
- 已签（done）/ 当日可签（now）/ 未签（locked）

### 通知/消息
- 有未读（红点）/ 无未读

---

## 七、图标集（24×24 描边线性）

所有图标统一风格：24×24 viewBox，1.85px 描边，圆角端点，currentColor 填充跟随文字色。

需设计的图标列表：

`chevron-left` · `chevron-right` · `search` · `home` · `books` · `user` · `bell` · `coin` · `spark` · `sliders` · `play` · `heart` · `heart-fill` · `list` · `text` · `sync` · `plus` · `gift` · `lock` · `clock` · `settings` · `star` · `flame` · `check` · `check-circle` · `globe` · `shield` · `trash` · `bookmark` · `language` · `mail` · `wallet`

特殊：`google` 和 `facebook` 使用官方多色品牌标识。

---

## 八、响应式与适配

- **设计基准**：412×892pt（Android 标准密度）
- **安全区**：顶部 status bar 24pt，底部 gesture bar 34pt
- **底部导航高度**：56pt
- **Sheet 最大高度**：视口 85%
- **横屏**：阅读器支持横屏全屏阅读

---

## 九、Figma 交付要求

### 页面组织建议

```
📁 likenovel
├── 📄 Cover（封面/概述）
├── 📄 Design Tokens（颜色/字体/间距/圆角/阴影）
├── 📄 Icons（图标集）
├── 📄 Components（组件库）
├── 📄 Onboarding & Guide
├── 📄 Discover（首页）
├── 📄 Book Detail
├── 📄 Reader & Paywall
├── 📄 Library
├── 📄 Wallet & Recharge
├── 📄 Profile & Settings
└── 📄 Subpages（子页面合集）
```

### 命名规范

- 组件：`类型/变体/状态`，如 `Button/Primary/Default`
- 颜色样式：`bg`、`surface`、`ink`、`primary`、`gold` 等
- 文字样式：`Heading/H1`、`Body/Regular`、`Label/Small` 等

### 交付物清单

- [ ] Design Token 定义（颜色 / 字体 / 间距 / 圆角）
- [ ] 图标集（SVG 组件化）
- [ ] 组件库（含所有状态变体）
- [ ] 各页面 Frame（412pt 宽）
- [ ] 交互原型连线（页面跳转 + Sheet + 返回）
- [ ] 阅读器 4 主题切换原型
- [ ] 空状态 / 加载态 / 错误态

---

## 十、MVP 边界提醒

以下功能**不在 MVP 设计范围**，Figma 中无需设计：

- 漫画/有声/TTS
- 社区/发帖/关注
- 作者创作中心
- 订阅会员
- 邀请裂变
- 批量订购/自动解锁
- 个性化推荐算法（先用编辑位代替）
- Apple/Facebook 登录（Should，非 MVP）

---

## 十一、关键用户流程（供原型连线参考）

### 流程 A：新用户首次体验
```
Onboarding → 选择登录方式 → Guide 选口味 → Discover 首页
```

### 流程 B：发现并阅读一本书
```
Discover → 点击封面 → Book Detail → Read chapter 1 free → Reader
```

### 流程 C：触达付费墙并解锁
```
Reader（读到付费墙）→ Paywall Sheet → 选择解锁方式：
  ├── 金币解锁 → Toast 成功 → 继续阅读
  ├── 看广告 → 广告播放 → 继续阅读
  └── 等待解锁 → 提示倒计时 → 返回书架
```

### 流程 D：充值金币
```
任意页面金币 pill / Wallet Tab / Paywall 底部链接 → Recharge Sheet → 选套餐 → Pay → Toast 成功
```

### 流程 E：查看交易记录
```
Me Tab → 点击 Transactions → wallet-history 子页面（流水列表）
```

### 流程 F：签到领币
```
Wallet Tab → 点击 Daily check-in → 签到页 → 领取
```
