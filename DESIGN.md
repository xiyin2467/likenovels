# DESIGN.md — Emberlune 设计系统

> register: product。调性：暗夜书房（深色优先 + 暖琥珀金标志色 + 文学衬线/干净无衬线）。颜色策略：Committed（深色面 + 琥珀金贯穿强调）。

## 颜色（OKLCH）

冷调墨梅深色面 + 暖琥珀金标志色，形成冷/暖互补对比（刻意避开"暖底+暖主色"的 AI 套路）。

```css
--bg:        oklch(0.16 0.014 305);   /* 深墨梅，App 背景 */
--surface:   oklch(0.205 0.018 306);  /* 卡片/面板 */
--surface-2: oklch(0.255 0.020 306);  /* 抬升面/输入 */
--line:      oklch(0.32 0.020 306);   /* 描边 */
--ink:       oklch(0.96 0.008 80);    /* 主文字（暖近白，对 bg ≥ 7:1）*/
--muted:     oklch(0.74 0.014 300);   /* 次要文字（≥ 3.5:1）*/
--primary:   oklch(0.81 0.13 73);     /* 琥珀金：高亮/选中/标志 */
--primary-press: oklch(0.73 0.14 64);
--on-primary: oklch(0.18 0.02 70);    /* 琥珀金按钮上的深色文字 */
--accent:    oklch(0.62 0.15 18);     /* 暗玫瑰/石榴红：浪漫点缀（克制）*/
--gold-soft: oklch(0.86 0.07 80);     /* 星标/细节 */
```

阅读器主题：

```css
[data-theme="dark"]  { --r-bg: oklch(0.16 0.014 305); --r-ink: oklch(0.90 0.006 80); }
[data-theme="black"] { --r-bg: oklch(0.04 0 0);       --r-ink: oklch(0.82 0 0); }
[data-theme="sepia"] { --r-bg: oklch(0.90 0.03 75);   --r-ink: oklch(0.33 0.02 60); }
[data-theme="paper"] { --r-bg: oklch(0.972 0.004 85); --r-ink: oklch(0.27 0.01 60); }
```

文字填充规则：琥珀金按钮（L≈0.81）用深色文字 `--on-primary`；玫瑰红填充（L≈0.62 饱和）用白字。

## 字体（2 个家族）

- **Newsreader**（衬线）：书名、Hero、阅读器正文 —— 文学/阅读质感。
- **Inter**（无衬线）：导航、按钮、标签、数据等所有 UI chrome。
- 通过 Google Fonts 加载，`display=swap`。

## 间距与圆角

- 间距基数 4px；常用 8/12/16/20/24。
- 圆角：控件 12、卡片 16、底部 sheet 22、手机外框 44。

## 运动

- UI 过渡 150–220ms，ease-out。底部 sheet 上滑 220ms。`prefers-reduced-motion` 下改为即时/淡入。

## 组件状态

按钮/可点项均含 default/hover/focus-visible/active/disabled；列表含锁定态；阅读器含主题切换与字号实时调节；付费墙含解锁成功态。

## 文件

`项目设计/核心界面原型/`：`index.html` · `styles.css` · `app.js` · `assets/`（7 张封面）。双击 index.html 即可查看。
