# likenovel 管理后台

基于前台（Flutter App / React 原型）设计语言打造的运营管理面板。技术栈：**React + Vite + Tailwind v4**，对接 `server/` 零依赖 Node API。

## 功能模块

- **数据看板**：累计营收、用户/VIP、在库书籍、金币流通量；近 7 天营收趋势、题材分布、最近订单。
- **书籍管理**：书籍增删改查、题材/状态筛选、搜索；进入单本可管理**章节**（增删改、免费/付费、发布状态）。
- **用户管理**：搜索/筛选、用户详情与消费记录、金币赠送/扣减、封禁/解封、会员标记。
- **订单流水**：充值与会员订单列表、按类型/状态筛选、退款操作。
- **变现配置**：金币充值套餐、会员订阅方案的增删改与上下架（与前台付费墙一致）。

## 设计语言

对齐前台品牌令牌（`app/lib/app/theme.dart`）：

- 主色酒红 `#8B2252`、点缀琥珀金 `#D4A853`、暖米底色 `#FAF7F2`
- 标题 Newsreader 衬线，正文 Inter

## 本地运行

需要先启动后端 API（默认 4000 端口）：

```bash
cd ../server
npm start            # http://localhost:4000
```

再启动后台前端：

```bash
npm install
npm run dev          # http://localhost:5173 （/api 自动代理到 4000）
```

默认登录账号：`admin` / `admin123`

> 后端为内存数据，进程重启后复位。可用环境变量 `API_TARGET` 指定后端地址，`ADMIN_USER` / `ADMIN_PASS` 修改登录凭据。

## 构建

```bash
npm run build        # 产物输出到 dist/
npm run preview
```
