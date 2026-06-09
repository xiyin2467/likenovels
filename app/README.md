# likenovel — 小说阅读 App

面向英语女性读者的沉浸式小说阅读应用，以 **Flutter** 构建，采用 feature-first 架构。

## 快速开始

### 前置要求

| 工具 | 最低版本 |
|------|---------|
| Flutter SDK | 3.44+ |
| Dart | 3.12+ |
| Chrome | 任意现代版本（Web 调试用） |

> Flutter SDK 已安装在 `C:\flutter`。如终端找不到命令，先执行：
>
> ```powershell
> $env:PATH = "C:\flutter\bin;" + $env:PATH
> ```
>
> 或将 `C:\flutter\bin` 永久添加到系统 PATH：
>
> ```powershell
> [Environment]::SetEnvironmentVariable("PATH", "C:\flutter\bin;" + [Environment]::GetEnvironmentVariable("PATH", "User"), "User")
> ```

### 安装依赖

```powershell
cd D:\likenovel\app
flutter pub get
```

### 检查代码

```powershell
flutter analyze
```

### 运行应用

**Chrome 浏览器（推荐 — 无需 Android SDK）：**

```bash
flutter run -d chrome
```

**Windows 桌面：**

```bash
flutter run -d windows
```

**Android 真机/模拟器**（需先安装 Android SDK）：

```bash
flutter run -d <device_id>
```

### 检查代码

```bash
flutter analyze
```

## 项目结构

```
lib/
├── app/                    # 入口、路由、主题、全局状态
│   ├── app.dart            # MaterialApp.router 根组件
│   ├── router.dart         # GoRouter 路由 + 页面转场动画
│   ├── theme.dart          # ElTheme / ElColors / ElRadius / ElSpacing
│   └── providers.dart      # Riverpod providers (coins, user)
├── core/
│   ├── models/             # Book, Chapter, AppUser, WalletState
│   └── mock/               # 8 本书 Mock 数据 + 章节生成
├── features/
│   ├── onboarding/         # 欢迎页（扇形封面轮播 + 登录按钮）
│   ├── guide/              # 口味偏好标签选择
│   ├── discover/           # 首页（Hero 轮播、排行、推荐、骨架屏）
│   ├── book_detail/        # 书籍详情（渐变 Hero + 章节列表）
│   ├── reader/             # 阅读器（4 主题 / 3 字号 / 付费墙）
│   ├── library/            # 书架（Reading / Unlocked / Finished）
│   ├── wallet/             # 钱包（余额卡片 + 充值 + 每日奖励）
│   ├── profile/            # 个人中心（统计 + 菜单）
│   └── common/             # 子页面（交易、签到、消息、设置等）
└── shared/
    └── widgets/            # BookCover, PaywallSheet, RechargeSheet, Toast
```

## 页面导览

| 路由 | 页面 | 说明 |
|------|------|------|
| `/onboarding` | 欢迎页 | 初始页面，4 本书封面扇形轮播 + 登录 |
| `/guide` | 口味引导 | 标签多选，个性化推荐入口 |
| `/discover` | 首页 | Hero 轮播 / Top Charts / New & Rising / For You |
| `/library` | 书架 | 3 Tab 阅读进度管理 |
| `/wallet` | 钱包 | 渐变余额卡 + 签到 + 充值 |
| `/me` | 个人中心 | 用户卡片 + 8 项设置菜单 |
| `/book/:id` | 书籍详情 | 渐变 Hero + 元数据 + 章节列表 |
| `/reader/:bookId/:chapterId` | 阅读器 | 4 主题切换 + 字号调节 + 内联付费墙 |
| `/subpage/:key` | 子页面 | 交易记录 / 签到 / 消息 / 搜索 等 |

## 技术栈

- **Flutter 3.44** + Dart 3.12
- **Riverpod 3.x** — 状态管理
- **go_router 17.x** — 声明式路由 + deep link
- **google_fonts** — Newsreader（衬线）+ Inter（无衬线）
- **shimmer** — 骨架屏加载效果

## 设计系统

基于 [DESIGN.md](../DESIGN.md) 的 likenovel 设计规范：

- **主色**：石榴酒红 `#8B2252`
- **背景**：暖象牙 `#FAF7F2`
- **字体对**：Newsreader（标题/正文）+ Inter（UI 元素）
- **封面**：零图片依赖，6 种题材用渐变 + 排版生成
- **圆角**：control 13px / card 18px / sheet 26px / frame 40px
- **动画**：push 滑入 220ms / sheet 底部弹出 260ms / Tab 淡入 120ms

## 数据说明

当前全部使用 **Mock 数据**（`core/mock/mock_data.dart`），包含 8 本书、章节生成器、4 个充值包、口味标签等。数据层通过 Repository 模式抽象，后续接入 NestJS 后端时只需替换实现，无需修改 UI 代码。
