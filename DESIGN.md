# DESIGN.md — likenovel 设计系统

> register: product。调性：浅色编辑感书房（暖象牙底 + 墨梅文字 + 石榴酒红主色 + 金色细节）。
> 颜色策略：Committed（克制的浅底 + 酒红主色贯穿强调 + 金色点缀）。
> 此前的「暗夜书房」深色方案在实机评审中显得偏「玩具感」，故全面改为下述浅色编辑方向，并与品类头部（GoodNovel / Dreame / Webnovel）的视觉预期对齐。

## 设计原则

1. **可读优先**：内容（书名、简介、章节）用衬线，UI chrome 用无衬线，层级清晰。
2. **零图片依赖**：所有封面用 CSS 渐变 + 排版生成（见「封面系统」），永不破图，风格统一。
3. **真实感**：统一 SVG 图标、骨架屏、悬停/按下态、瀑布流无限加载，贴近上线产品。
4. **克制的浪漫**：以酒红 + 金色表达「言情」，避免粉色俗套与渐变文字等 AI 套路。

## 颜色（OKLCH）

暖象牙浅色面 + 墨梅文字 + 石榴酒红主色，金色仅用于星标/货币/细节。

```css
--bg:         oklch(0.975 0.008 60);   /* 暖象牙，App 背景 */
--surface:    oklch(0.995 0.004 70);   /* 卡片/面板 */
--surface-2:  oklch(0.955 0.010 58);   /* 抬升面/输入 */
--surface-3:  oklch(0.928 0.012 56);   /* 进度槽等更深面 */
--line:       oklch(0.905 0.010 50);   /* 描边 */
--line-strong:oklch(0.84  0.014 48);   /* 强描边 */
--ink:        oklch(0.26 0.035 350);   /* 主文字：墨梅（对 bg ≥ 7:1）*/
--muted:      oklch(0.49 0.028 350);   /* 次要文字（≥ 4.5:1）*/
--faint:      oklch(0.60 0.022 350);   /* 三级文字 */
--primary:    oklch(0.52 0.158 16);    /* 石榴酒红：主按钮/选中 */
--primary-press: oklch(0.45 0.155 16);
--primary-ink:oklch(0.40 0.150 16);    /* 浅底上的酒红文字/链接（≥ 4.5:1）*/
--primary-soft:oklch(0.95 0.030 18);   /* 酒红浅底（标签/选中底）*/
--gold:       oklch(0.78 0.115 78);    /* 金色：星标/货币/细节 */
--gold-soft:  oklch(0.95 0.045 82);
--success:    oklch(0.55 0.12 150);    /* 免费/到账等正向状态 */
--on-primary: oklch(0.99 0.01 80);     /* 酒红填充上的近白文字 */
```

文字填充规则：酒红填充（L≈0.52）用近白文字 `--on-primary`；金色（L≈0.78）作面时用深色文字。浅底上的链接/强调文字用更深的 `--primary-ink`（L≈0.40）以保证对比度。

## 封面系统（CSS 生成，无图片）

每本书有一个 `cls`（题材类），决定封面渐变；标题用 Newsreader 居中、作者小字、顶部高光描边。可叠加角标（Hot / Complete）与排行序号。题材色板：

```css
.c-werewolf  /* 蓝黑夜 */   .c-ceo       /* 炭灰 + 金 */
.c-reborn    /* 石榴红 */   .c-vampire   /* 血黑 */
.c-romantasy /* 紫罗兰 */   .c-modern    /* 玫瑰 */
```

好处：永不破图、风格统一、可在封面上叠加运营元素（角标/排名），且无需管理二进制资源。

## 阅读器主题（4 套，实时切换）

```css
[data-theme="paper"] { --r-bg: oklch(0.972 0.006 85); --r-ink: oklch(0.27 0.012 60); }
[data-theme="sepia"] { --r-bg: oklch(0.91 0.035 75);  --r-ink: oklch(0.33 0.025 55); }
[data-theme="dark"]  { --r-bg: oklch(0.21 0.012 300); --r-ink: oklch(0.88 0.01 80); }
[data-theme="black"] { --r-bg: oklch(0.05 0 0);       --r-ink: oklch(0.80 0 0); }
```

字号通过 `--r-size` 实时 +/− 调节（0.92–1.32rem）；首字下沉用主色（深色主题用金色）。

## 字体（2 个家族）

- **Newsreader**（衬线）：书名、Hero、封面标题、阅读器正文、统计数字 —— 文学/阅读质感。
- **Inter**（无衬线）：导航、按钮、标签、计量、表单等所有 UI chrome。
- Flutter App 中**字体本地打包**（`app/assets/fonts/` 下的可变字体 TTF，经 `AppFont` 封装），不再依赖 Google Fonts 网络加载——离线可用、首屏无字体闪烁，符合出海弱网/合规要求。低保真原型（v0-lofi）仍用 Google Fonts CDN。

## 图标

统一内联 SVG 图标系统（`app.js` 的 `ICONS`），`currentColor` 描边，随字号缩放。Google / Facebook 用官方多色品牌标（提升登录页可信度），其余为 1.85 描边的单色线性图标。

## 间距与圆角

- 间距基数 4px；常用 8/12/16/18/20/24。
- 圆角：控件 13、卡片 18、底部 sheet 26、手机外框 40。

## 运动

- UI 过渡 120–220ms，ease-out。底部 sheet 上滑 260ms。
- 瀑布流首屏与加载更多均先显示骨架屏（shimmer）再替换为内容。
- `prefers-reduced-motion` 下统一降为即时/淡入。

## 组件状态

按钮/可点项均含 default/hover/focus-visible/active；列表含锁定/新章/已存等状态；阅读器含 4 主题切换与字号实时调节；付费墙含解锁成功 toast；瀑布流含骨架屏 + 无限加载；底部导航在阅读器/详情/引导/登录页/钱包页自动隐藏。

## 导航与变现入口（IA 摘要）

- **底部导航 4 Tab**：首页（Home）/ 分类（Categories）/ 书架（Library）/ 我的（Me）。
- **钱包并入「我的」**：钱包不占 Tab，由「我的」push 进入（带返回）。承载订阅优先的变现入口：
  - **金币充值（消耗型）**：钱包页 "Top up coins" → Recharge Sheet。套餐卡片**收进 Sheet**，不在首屏平铺，弱化「商店感」。
  - **会员订阅（VIP，订阅型）**：钱包页金色「VIP Membership」卡片 / 付费墙主按钮 → Membership Sheet（周/月/年套餐，全场畅读 + 零广告 + 离线整本 + 徽章）。
- 详见 `docs/design/前端设计PRD.md`、`docs/plan/变现模型.md`。

## 响应式

默认在桌面以「手机外框」预览（≤412px 宽）；视口 ≤480px 时自动全屏铺满（去外框/圆角/阴影），即真机表现。

## 文件

`prototypes/v0-lofi/`：`index.html` · `styles.css` · `app.js`（封面与数据均由 JS 用 CSS 生成，无图片资源）。双击 `index.html` 即可查看，移动端视图最佳。
