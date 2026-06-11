import 'dart:math' as math;
import 'package:flutter/material.dart';

/// 翻页方向枚举
enum FlipDirection {
  left,  // 向左翻页（上一页）
  right, // 向右翻页（下一页）
}

/// 翻页控制器
class FlipBookController {
  _PageFlipWidgetState? _state;
  
  /// 翻到下一页
  Future<void> flipToNext() async {
    if (_state != null) {
      await _state!._flipToNext();
    }
  }
  
  /// 翻到上一页
  Future<void> flipToPrevious() async {
    if (_state != null) {
      await _state!._flipToPrevious();
    }
  }
  
  /// 翻到指定页
  Future<void> flipToPage(int page) async {
    if (_state != null) {
      await _state!._flipToPage(page);
    }
  }
  
  /// 获取当前页码
  int get currentPage {
    return _state?._currentPageIndex ?? 0;
  }
}

/// 仿真翻页主组件
class PageFlipWidget extends StatefulWidget {
  /// 页面列表
  final List<Widget> pages;
  
  /// 控制器
  final FlipBookController? controller;
  
  /// 页面切换回调
  final ValueChanged<int>? onPageChanged;
  
  /// 翻页速度 (0-1)
  final double flipSpeed;
  
  /// 阴影强度 (0-1)
  final double shadowIntensity;
  
  /// 拖拽灵敏度
  final double dragSensitivity;
  
  /// 页面圆角
  final double cornerRadius;
  
  /// 是否启用点击翻页
  final bool enableTapFlip;
  
  /// 点击区域宽度比例 (0-0.5)
  final double tapAreaRatio;

  const PageFlipWidget({
    Key? key,
    required this.pages,
    this.controller,
    this.onPageChanged,
    this.flipSpeed = 0.5,
    this.shadowIntensity = 0.5,
    this.dragSensitivity = 1.0,
    this.cornerRadius = 8.0,
    this.enableTapFlip = true,
    this.tapAreaRatio = 0.3,
  }) : super(key: key);

  @override
  _PageFlipWidgetState createState() => _PageFlipWidgetState();
}

class _PageFlipWidgetState extends State<PageFlipWidget>
    with TickerProviderStateMixin {
  int _currentPageIndex = 0;
  
  // 翻页状态
  FlipDirection? _flipDirection;
  double _currentAngle = 0.0;
  Offset? _dragStartPosition;
  
  // 动画控制器
  AnimationController? _animationController;
  Animation<double>? _animation;
  
  @override
  void initState() {
    super.initState();
    widget.controller?._state = this;
  }
  
  @override
  void dispose() {
    _animationController?.dispose();
    widget.controller?._state = null;
    super.dispose();
  }
  
  // 手势处理：触摸开始
  void _handleDragStart(DragStartDetails details) {
    if (_isAnimating) return;
    
    _dragStartPosition = details.localPosition;
    
    // 判断翻页方向
    if (details.localPosition.dx < context.size!.width * widget.tapAreaRatio) {
      if (_currentPageIndex > 0) {
        _flipDirection = FlipDirection.left;
      }
    } else if (details.localPosition.dx > 
               context.size!.width * (1 - widget.tapAreaRatio)) {
      if (_currentPageIndex < widget.pages.length - 1) {
        _flipDirection = FlipDirection.right;
      }
    } else {
      _flipDirection = null;
    }
  }
  
  // 手势处理：触摸移动
  void _handleDragUpdate(DragUpdateDetails details) {
    if (_flipDirection == null || _dragStartPosition == null) return;
    
    // 计算拖拽距离
    double dx = (details.localPosition.dx - _dragStartPosition!.dx) * 
                widget.dragSensitivity;
    
    // 根据方向计算角度
    double angle;
    if (_flipDirection == FlipDirection.right) {
      angle = (dx.abs() / context.size!.width) * math.pi;
    } else {
      angle = (dx.abs() / context.size!.width) * math.pi;
    }
    
    setState(() {
      _currentAngle = angle.clamp(0.0, math.pi);
    });
  }
  
  // 手势处理：触摸结束
  void _handleDragEnd(DragEndDetails details) {
    if (_flipDirection == null) return;
    
    // 计算速度
    double velocity = details.velocity.pixelsPerSecond.dx;
    double velocityThreshold = context.size!.width / 0.3; // 300ms
    
    // 判断是否翻页
    bool shouldFlip;
    if (velocity.abs() > velocityThreshold) {
      shouldFlip = (_flipDirection == FlipDirection.right && velocity > 0) ||
                   (_flipDirection == FlipDirection.left && velocity < 0);
    } else {
      shouldFlip = _currentAngle > math.pi / 2;
    }
    
    if (shouldFlip) {
      _animateFlipToComplete();
    } else {
      _animateBack();
    }
  }
  
  // 手势处理：点击
  void _handleTap(TapUpDetails details) {
    if (!widget.enableTapFlip || _isAnimating) return;
    
    double width = context.size!.width;
    double tapArea = width * widget.tapAreaRatio;
    
    if (details.localPosition.dx < tapArea) {
      // 左侧区域：上一页
      _flipToPrevious();
    } else if (details.localPosition.dx > width - tapArea) {
      // 右侧区域：下一页
      _flipToNext();
    }
    // 中间区域：不做处理（用户可自行添加菜单逻辑）
  }
  
  // 翻到下一页
  Future<void> _flipToNext() async {
    if (_currentPageIndex >= widget.pages.length - 1) return;
    _flipDirection = FlipDirection.right;
    await _animateFlipToComplete();
  }
  
  // 翻到上一页
  Future<void> _flipToPrevious() async {
    if (_currentPageIndex <= 0) return;
    _flipDirection = FlipDirection.left;
    await _animateFlipToComplete();
  }
  
  // 翻到指定页
  Future<void> _flipToPage(int page) async {
    if (page < 0 || page >= widget.pages.length) return;
    if (page > _currentPageIndex) {
      _flipDirection = FlipDirection.right;
    } else if (page < _currentPageIndex) {
      _flipDirection = FlipDirection.left;
    }
    await _animateFlipToComplete();
  }
  
  // 执行翻页动画
  Future<void> _animateFlipToComplete() async {
    if (_flipDirection == null) return;
    
    _animationController?.dispose();
    _animationController = AnimationController(
      duration: Duration(milliseconds: (300 / widget.flipSpeed).round()),
      vsync: this,
    );
    
    _animation = Tween<double>(
      begin: _currentAngle,
      end: math.pi,
    ).animate(CurvedAnimation(
      parent: _animationController!,
      curve: Curves.easeInOut,
    ));
    
    _animation!.addListener(() {
      setState(() {
        _currentAngle = _animation!.value;
      });
    });
    
    await _animationController!.forward();
    
    // 翻页完成，更新页码
    if (_flipDirection == FlipDirection.right) {
      _currentPageIndex++;
    } else {
      _currentPageIndex--;
    }
    
    setState(() {
      _currentAngle = 0.0;
      _flipDirection = null;
    });
    
    widget.onPageChanged?.call(_currentPageIndex);
  }
  
  // 回弹动画
  Future<void> _animateBack() async {
    _animationController?.dispose();
    _animationController = AnimationController(
      duration: Duration(milliseconds: (200 / widget.flipSpeed).round()),
      vsync: this,
    );
    
    _animation = Tween<double>(
      begin: _currentAngle,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController!,
      curve: Curves.easeOut,
    ));
    
    _animation!.addListener(() {
      setState(() {
        _currentAngle = _animation!.value;
      });
    });
    
    await _animationController!.forward();
    
    setState(() {
      _flipDirection = null;
    });
  }
  
  bool get _isAnimating => _animationController?.isAnimating ?? false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragStart: _handleDragStart,
      onHorizontalDragUpdate: _handleDragUpdate,
      onHorizontalDragEnd: _handleDragEnd,
      onTapUp: _handleTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.cornerRadius),
        child: Stack(
          children: [
            // 底层：下一页预览
            if (_flipDirection == FlipDirection.right && 
                _currentPageIndex < widget.pages.length - 1)
              widget.pages[_currentPageIndex + 1],
            
            // 顶层：当前翻页
            if (_currentAngle > 0)
              _buildFlippingPage(),
            
            // 无翻页时显示当前页
            if (_currentAngle == 0)
              widget.pages[_currentPageIndex],
          ],
        ),
      ),
    );
  }
  
  Widget _buildFlippingPage() {
    return Transform(
      alignment: _flipDirection == FlipDirection.right 
          ? Alignment.centerRight 
          : Alignment.centerLeft,
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.001) // 透视效果
        ..rotateY(_flipDirection == FlipDirection.right 
            ? -_currentAngle 
            : _currentAngle),
      child: ShaderMask(
        shaderCallback: (Rect bounds) {
          double shadowOpacity = math.sin(_currentAngle) * widget.shadowIntensity;
          return LinearGradient(
            begin: _flipDirection == FlipDirection.right 
                ? Alignment.centerRight 
                : Alignment.centerLeft,
            end: _flipDirection == FlipDirection.right 
                ? Alignment.centerLeft 
                : Alignment.centerRight,
            colors: [
              Colors.black.withOpacity(0.0),
              Colors.black.withOpacity(shadowOpacity),
            ],
          ).createShader(bounds);
        },
        blendMode: BlendMode.multiply,
        child: widget.pages[_currentPageIndex],
      ),
    );
  }
}

/// 简化使用示例
class BookReaderExample extends StatefulWidget {
  @override
  _BookReaderExampleState createState() => _BookReaderExampleState();
}

class _BookReaderExampleState extends State<BookReaderExample> {
  final FlipBookController _controller = FlipBookController();
  int _currentPage = 0;
  
  // 示例页面数据
  final List<Widget> _pages = List.generate(
    10,
    (index) => Container(
      color: Colors.white,
      child: Center(
        child: Text(
          '第 ${index + 1} 页',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    ),
  );
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('小说阅读器'),
        actions: [
          IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => _controller.flipToPrevious(),
          ),
          IconButton(
            icon: Icon(Icons.arrow_forward),
            onPressed: () => _controller.flipToNext(),
          ),
        ],
      ),
      body: PageFlipWidget(
        controller: _controller,
        pages: _pages,
        flipSpeed: 0.6,
        shadowIntensity: 0.5,
        onPageChanged: (page) {
          setState(() {
            _currentPage = page;
          });
        },
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text('当前页: ${_currentPage + 1}/${_pages.length}'),
            ElevatedButton(
              onPressed: () => _controller.flipToPage(0),
              child: Text('返回首页'),
            ),
          ],
        ),
      ),
    );
  }
}
