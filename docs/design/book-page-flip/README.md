# Book Page Flip Skill - 使用说明

## 概述

这是一个为Flutter小说阅读器提供仿真翻页效果的skill，支持真实3D翻页、触摸滑动和点击翻页。

## Skill内容

### 核心文件

- **SKILL.md** - Skill主文件，包含使用指南和输出规范
- **references/page_flip_widget.dart** - 完整的Flutter翻页组件代码
- **references/algorithm.md** - 翻页算法的数学原理和实现细节
- **references/example_structure.md** - 完整示例项目结构

## 如何使用

### 1. 触发Skill

在对话中提到以下关键词即可触发：
- "小说阅读器翻页效果"
- "书籍翻页"
- "page flip"
- "电子书翻页"
- "阅读器UI"

### 2. Skill输出内容

Skill会根据需求提供：

#### 完整代码组件
- `PageFlipWidget` - 主翻页组件
- `FlipBookController` - 控制器
- 完整的使用示例

#### 实现指导
- 翻页动画原理（贝塞尔曲线、3D变换）
- 手势处理逻辑
- 阴影和光照计算
- 性能优化策略

### 3. 集成到项目

```dart
// 1. 复制 page_flip_widget.dart 到项目

// 2. 使用组件
PageFlipWidget(
  controller: FlipBookController(),
  pages: yourPageList,
  flipSpeed: 0.6,
  shadowIntensity: 0.5,
  onPageChanged: (index) {
    print('当前页: $index');
  },
)
```

## 核心特性

✅ 真实3D翻页效果  
✅ 触摸滑动翻页  
✅ 点击翻页  
✅ 动态阴影效果  
✅ 高性能渲染  
✅ 易于定制  

## 支持的交互方式

1. **触摸滑动** - 手指滑动翻页
2. **点击翻页** - 点击屏幕左侧/右侧区域
3. **编程控制** - 通过Controller控制翻页

## 参数配置

| 参数 | 说明 | 默认值 |
|------|------|--------|
| flipSpeed | 翻页速度(0-1) | 0.5 |
| shadowIntensity | 阴影强度(0-1) | 0.5 |
| dragSensitivity | 拖拽灵敏度 | 1.0 |
| cornerRadius | 页面圆角 | 8.0 |
| enableTapFlip | 启用点击翻页 | true |
| tapAreaRatio | 点击区域比例 | 0.3 |

## 性能优化建议

1. 使用 `RepaintBoundary` 隔离重绘
2. 页面内容预渲染
3. 限制缓存页面数量
4. 避免实时阴影计算

## 适用场景

- 小说阅读器App
- 电子书应用
- 杂志阅读器
- PDF阅读器
- 任何需要翻页效果的文档阅读应用

## 技术要求

- Flutter >= 3.0.0
- Dart >= 2.17.0

## 常见问题

### Q: 如何自定义翻页效果？

A: 修改 `page_flip_widget.dart` 中的参数，如 `flipSpeed`、`shadowIntensity` 等。

### Q: 支持左右翻页吗？

A: 支持！通过 `FlipDirection` 枚举控制，支持左翻和右翻。

### Q: 如何处理大量文本？

A: 使用分页加载策略，只渲染可见页面及其前后页。

## 示例项目

完整的示例项目结构请参考 `references/example_structure.md`

## 版本历史

- v1.0.0 - 初始版本，支持基本的3D翻页效果

## 作者

由DuMate Skill Creator创建

---

**提示**：使用此skill时，可以直接说"我需要一个Flutter翻页效果"或"帮我实现小说阅读器翻页"即可触发。
