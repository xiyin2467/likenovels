# likenovel — 海外小说 App

面向海外市场的网络小说 App，首发英语市场（女频/男频方向待定）。当前已完成竞品分析、产品规划、设计系统、UI 原型（V0 低保真 + V1 Figma 高保真）、Flutter 前端原型、管理后台（React）及其演示 API。

> **研发交接请从 [`HANDOFF.md`](HANDOFF.md) 开始**：资产地图、事实来源文档、到上线的分阶段路线图。

## 快速启动

### Flutter App（推荐）

```powershell
# 1. 确保 Flutter 在 PATH 中（SDK 已安装在 C:\flutter）
$env:PATH = "C:\flutter\bin;" + $env:PATH
# 2. 安装依赖
cd D:\likenovel\app
flutter pub get
# 3. 启动（Chrome 浏览器，无需 Android SDK）
flutter run -d chrome
# 或 Windows 桌面
flutter run -d windows
```

> 启动前可先 `flutter analyze` 检查代码质量。

### 管理后台 + 演示 API

```powershell
cd D:\likenovel\server; npm run dev    # API → http://localhost:4000
cd D:\likenovel\后台; npm run dev      # 管理后台 → http://localhost:5173
```

### V0 低保真原型

```powershell
# 最快：直接双击
prototypes/v0-lofi/index.html
```

### V1 Figma 高保真原型

```powershell
cd D:\likenovel\prototypes\v1-figma
npm install
npm run dev
```

## 项目结构

```text
likenovel/
├── README.md                         # 本文件
├── PRODUCT.md                        # 产品上下文（定位/用户/价值主张）
├── DESIGN.md                         # 视觉系统与设计规范
│
├── HANDOFF.md                        # 研发交接入口（资产地图 + 上线路线图）
│
├── app/                              # Flutter 前端（可运行原型，纯 mock 数据）
│   └── README.md                     # 运行说明
├── server/                           # 管理端演示 API（零依赖 Node + JSON 存储；生产后端按规划用 NestJS 重写）
├── 后台/                             # 运营管理后台（React + Vite + Tailwind，对接 server/）
│
├── docs/
│   ├── plan/                         # 项目规划
│   │   ├── 市场与定位建议.md
│   │   ├── 产品功能规划.md           # MoSCoW 功能清单
│   │   ├── MVP范围与路线图.md
│   │   ├── 变现模型.md
│   │   ├── 技术选型建议.md
│   │   ├── App架构分配与优化.md      # 客户端/后端/SDK/合规模块边界
│   │   ├── 对标GoodNovel差距分析.md
│   │   ├── 内容供给方案.md
│   │   ├── 埋点事件字典.md
│   │   └── 后端API与数据模型.md      # MVP 接口契约 + 表结构
│   ├── design/                       # 产品设计
│   │   └── 前端设计PRD.md            # 页面规格/组件库/交互规格
│   └── research/                     # 竞品分析
│       ├── 竞品横向对比.md
│       ├── APK深度架构映射.md
│       ├── GoodNovel/                # 技术拆解 + 产品分析
│       ├── iReader国际版/            # 技术拆解 + 产品分析
│       ├── _raw/                     # androguard 提取脚本 + JSON 数据
│       └── apks/                     # 竞品 APK 原文件
│
└── prototypes/                       # 原型参考（非生产代码）
    ├── v0-lofi/                      # V0 低保真原型（HTML/CSS/JS）
    │   ├── index.html                # 双击即可查看
    │   ├── styles.css
    │   └── app.js
    └── v1-figma/                     # V1 Figma Make 导出（React + Tailwind）
        └── ...                       # npm install && npm run dev
```

## 三套原型资产

| 版本 | 位置 | 查看方式 | 定位 |
|---|---|---|---|
| V0 低保真 | `prototypes/v0-lofi/index.html` | 直接双击打开 | 交互逻辑与信息架构验证 |
| V1 Figma 高保真 | `prototypes/v1-figma/` | `npm install && npm run dev` | 视觉设计目标 |
| V2 Flutter 原型 | `app/` | `flutter run -d chrome` | 目标技术栈可行性验证 |

## 建议阅读顺序

1. `docs/research/竞品横向对比.md` — 产品和技术结论
2. `docs/research/APK深度架构映射.md` — APK 事实到模块取舍的映射
3. `docs/plan/App架构分配与优化.md` — 客户端/后端/SDK 边界
4. `docs/plan/对标GoodNovel差距分析.md` — 现状差距与补齐优先级
5. `docs/plan/市场与定位建议.md` → `产品功能规划.md` → `MVP范围与路线图.md` → `变现模型.md`
6. `docs/plan/后端API与数据模型.md` + `埋点事件字典.md` — 工程交付
7. `DESIGN.md` + `docs/design/前端设计PRD.md` — 设计系统与页面规格

## 核心结论

- **对标 GoodNovel**（出海网文标杆），iReader 仅作体验借鉴
- **首发市场**：欧美英语；品类方向（女频/男频）待定，规划文档现按女频假设撰写；架构预留多语言（默认 English，JSON i18n 脚手架）
- **底部导航（4 Tab）**：首页 / 分类 / 书架 / 我的；钱包并入「我的」（push 进入）
- **订阅优先变现**：会员订阅（VIP，全场畅读）为主付费产品；金币充值仅作为非会员按章出口；外加激励视频广告 + 等待解锁
- **技术栈**：Flutter + NestJS + FCM + Google Billing（内购+订阅）+ AppLovin MAX；字体本地打包（Inter / Newsreader）
- **MVP**：注册 → 发现/分类 → 读书 → 付费墙 → 充值/会员 → 解锁闭环
