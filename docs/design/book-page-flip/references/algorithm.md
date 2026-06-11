# 翻页效果算法详解

## 数学模型

### 1. 翻页几何模型

翻页效果本质是对一个平面的3D变换，将一个矩形页面绕一条轴旋转。

#### 核心参数

```
翻页轴：页面边缘的一条直线
翻页角度：θ (0 ≤ θ ≤ π)
页面弯曲度：由贝塞尔曲线控制
```

#### 坐标变换

页面上的任意点 P(x, y) 在翻页后的位置：

```
P'(x', y', z') = Rotate(P, θ, axis)

其中：
- Rotate: 绕轴旋转矩阵
- θ: 当前翻页角度
- axis: 翻页轴（通常是左边缘或右边缘）
```

### 2. 贝塞尔曲线弯曲

为了模拟真实页面的弯曲，使用二次贝塞尔曲线：

```
B(t) = (1-t)²P₀ + 2(1-t)tP₁ + t²P₂

其中：
- P₀: 起点
- P₁: 控制点（决定弯曲程度）
- P₂: 终点
- t: 参数 (0 ≤ t ≤ 1)
```

#### 控制点计算

```dart
// 根据翻页角度计算控制点位置
Offset calculateControlPoint(double angle, Offset start, Offset end) {
  // 弯曲强度与角度的关系
  double curvature = sin(angle);
  // 控制点在起点和终点连线的垂直方向偏移
  double offset = (start - end).distance * curvature * 0.3;
  return Offset.midpoint(start, end) + Offset(0, offset);
}
```

### 3. 阴影计算

阴影强度取决于页面的朝向：

```dart
// 阴影强度计算
double calculateShadow(double angle, double distance) {
  // angle: 翻页角度
  // distance: 到翻页轴的距离
  
  // 页面朝向因子
  double orientation = cos(angle);
  
  // 距离衰减
  double attenuation = 1.0 - (distance / maxDistance).clamp(0.0, 1.0);
  
  return orientation * attenuation * maxShadowIntensity;
}
```

#### 阴影渲染

使用`ShaderMask`实现渐变阴影：

```dart
ShaderMask(
  shaderCallback: (Rect bounds) {
    return LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [
        Colors.black.withOpacity(0.0),
        Colors.black.withOpacity(shadowIntensity),
      ],
    ).createShader(bounds);
  },
  blendMode: BlendMode.multiply,
  child: pageContent,
)
```

## 手势处理

### 1. 触摸事件解析

```dart
void handleDragStart(DragStartDetails details) {
  // 记录起始位置
  _dragStart = details.localPosition;
  _dragStartTime = DateTime.now();
  
  // 判断翻页方向
  if (_dragStart.dx < screenWidth / 3) {
    _flipDirection = FlipDirection.left;
  } else if (_dragStart.dx > screenWidth * 2 / 3) {
    _flipDirection = FlipDirection.right;
  }
}
```

### 2. 拖拽过程更新

```dart
void handleDragUpdate(DragUpdateDetails details) {
  // 计算拖拽距离
  double dragDistance = (details.localPosition - _dragStart).dx.abs();
  
  // 转换为翻页角度
  double angle = (dragDistance / screenWidth) * pi;
  angle = angle.clamp(0.0, pi);
  
  // 更新状态
  setState(() {
    _currentAngle = angle;
    _currentPosition = details.localPosition;
  });
}
```

### 3. 松手判断

```dart
void handleDragEnd(DragEndDetails details) {
  // 计算速度
  double velocity = details.velocity.pixelsPerSecond.dx;
  
  // 计算已经翻过的角度
  double currentAngle = _currentAngle;
  
  // 判断是否翻页
  bool shouldFlip = false;
  
  if (velocity.abs() > minVelocity) {
    // 速度足够快，按速度方向翻页
    shouldFlip = velocity > 0 ? _flipDirection == FlipDirection.right 
                               : _flipDirection == FlipDirection.left;
  } else {
    // 速度不够，按角度判断
    shouldFlip = currentAngle > pi / 2;
  }
  
  if (shouldFlip) {
    _animateFlip();
  } else {
    _animateBack();
  }
}
```

## 动画实现

### 1. 翻页动画

```dart
void _animateFlip() {
  _animationController = AnimationController(
    duration: Duration(milliseconds: 300),
    vsync: this,
  );
  
  Animation<double> animation = Tween<double>(
    begin: _currentAngle,
    end: pi,
  ).animate(CurvedAnimation(
    parent: _animationController,
    curve: Curves.easeInOut,
  ));
  
  animation.addListener(() {
    setState(() {
      _currentAngle = animation.value;
    });
  });
  
  _animationController.forward().then((_) {
    _onFlipComplete();
  });
}
```

### 2. 回弹动画

```dart
void _animateBack() {
  _animationController = AnimationController(
    duration: Duration(milliseconds: 200),
    vsync: this,
  );
  
  Animation<double> animation = Tween<double>(
    begin: _currentAngle,
    end: 0.0,
  ).animate(CurvedAnimation(
    parent: _animationController,
    curve: Curves.easeOut,
  ));
  
  animation.addListener(() {
    setState(() {
      _currentAngle = animation.value;
    });
  });
  
  _animationController.forward();
}
```

## 渲染优化

### 1. CustomPainter实现

```dart
class PageFlipPainter extends CustomPainter {
  final double angle;
  final Offset position;
  final Widget pageContent;
  
  PageFlipPainter({
    required this.angle,
    required this.position,
    required this.pageContent,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    // 1. 保存画布状态
    canvas.save();
    
    // 2. 应用变换矩阵
    final matrix = _calculateMatrix(angle, size);
    canvas.transform(matrix.storage);
    
    // 3. 绘制弯曲的页面
    _drawCurvedPage(canvas, size);
    
    // 4. 绘制阴影
    _drawShadow(canvas, size);
    
    // 5. 恢复画布状态
    canvas.restore();
  }
  
  Float64List _calculateMatrix(double angle, Size size) {
    // 计算3D变换矩阵
    // 包含：平移、旋转、透视投影
    final matrix = Matrix4.identity()
      ..translate(size.width / 2, size.height / 2)
      ..rotateY(angle)
      ..translate(-size.width / 2, -size.height / 2);
    
    return matrix.storage;
  }
}
```

### 2. 性能优化策略

#### 策略一：内容预渲染

```dart
// 将页面内容渲染到图片
Future<ui.Image> _renderPageToImage(Widget page) async {
  RenderRepaintBoundary boundary = 
      _globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
  ui.Image image = await boundary.toImage(pixelRatio: 2.0);
  return image;
}
```

#### 策略二：RepaintBoundary

```dart
RepaintBoundary(
  child: PageFlipWidget(
    // ...
  ),
)
```

#### 策略三：分层渲染

```dart
Stack(
  children: [
    // 底层：下一页预览
    RepaintBoundary(child: _nextPagePreview),
    // 顶层：当前翻页
    RepaintBoundary(child: _currentPage),
  ],
)
```

## 点击翻页实现

```dart
void handleTap(TapUpDetails details) {
  // 左侧1/3区域：上一页
  if (details.localPosition.dx < screenWidth / 3) {
    _flipToPrevious();
  }
  // 右侧1/3区域：下一页
  else if (details.localPosition.dx > screenWidth * 2 / 3) {
    _flipToNext();
  }
  // 中间区域：显示菜单
  else {
    _toggleMenu();
  }
}

void _flipToNext() {
  _flipDirection = FlipDirection.right;
  _animateFlip().then((_) {
    widget.onPageChanged?.call(_currentPageIndex + 1);
  });
}
```

## 边界条件处理

```dart
bool canFlipToNext() {
  return _currentPageIndex < widget.pages.length - 1;
}

bool canFlipToPrevious() {
  return _currentPageIndex > 0;
}

void handleDragStart(DragStartDetails details) {
  if (_flipDirection == FlipDirection.right && !canFlipToNext()) {
    return; // 禁止向右翻页
  }
  if (_flipDirection == FlipDirection.left && !canFlipToPrevious()) {
    return; // 禁止向左翻页
  }
  // 继续处理...
}
```

## 高级效果

### 1. 多页翻动

```dart
// 同时显示多页翻动效果
Stack(
  children: [
    PageFlipWidget(pageIndex: 2, angle: angle2),
    PageFlipWidget(pageIndex: 1, angle: angle1),
    PageFlipWidget(pageIndex: 0, angle: angle0),
  ],
)
```

### 2. 自定义弯曲曲线

```dart
// 三次贝塞尔曲线，更精细的弯曲控制
Path buildCurvedPath(Rect pageRect, double angle) {
  double curvature = sin(angle) * 0.5;
  
  Offset p0 = pageRect.topLeft;
  Offset p1 = pageRect.topRight;
  Offset p2 = pageRect.bottomRight;
  Offset p3 = pageRect.bottomLeft;
  
  Offset c1 = Offset(p1.dx - curvature * 50, p1.dy);
  Offset c2 = Offset(p2.dx - curvature * 50, p2.dy);
  
  Path path = Path()
    ..moveTo(p0.dx, p0.dy)
    ..lineTo(p1.dx, p1.dy)
    ..cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, p2.dx, p2.dy)
    ..lineTo(p3.dx, p3.dy)
    ..close();
  
  return path;
}
```

### 3. 光照效果

```dart
// 根据翻页角度调整页面亮度
ColorFilter adjustBrightness(double angle) {
  double brightness = cos(angle) * 0.3 + 0.7;
  return ColorFilter.matrix(<double>[
    brightness, 0, 0, 0, 0,
    0, brightness, 0, 0, 0,
    0, 0, brightness, 0, 0,
    0, 0, 0, 1, 0,
  ]);
}
```

## 数学公式总结

### 翻页角度与触摸位置关系

```
θ = (dx / screenWidth) × π

其中：
- θ: 翻页角度
- dx: 触摸点水平位移
- screenWidth: 屏幕宽度
```

### 阴影强度公式

```
S = max(0, cos(θ) × (1 - d/D) × Imax)

其中：
- S: 阴影强度 (0-1)
- θ: 翻页角度
- d: 到翻页轴的距离
- D: 页面宽度
- Imax: 最大阴影强度
```

### 速度阈值判断

```
v_threshold = screenWidth / t_min

其中：
- v_threshold: 速度阈值
- t_min: 最小翻页时间（通常 200-300ms）
```
