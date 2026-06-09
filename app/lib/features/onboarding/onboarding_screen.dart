import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:likenovel/app/fonts.dart';

import 'package:likenovel/app/theme.dart';
import 'package:likenovel/core/models/book.dart';
import 'package:likenovel/core/mock/mock_data.dart';
import 'package:likenovel/shared/widgets/book_cover.dart';

const _kGenreGlow = <Genre, Color>{
  Genre.werewolf: Color(0xFF3B6FA8),
  Genre.ceo: Color(0xFFD4AF37),
  Genre.reborn: Color(0xFFD9705C),
  Genre.vampire: Color(0xFF901838),
  Genre.romantasy: Color(0xFF8B5CF6),
  Genre.modern: Color(0xFFE06090),
};

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onContinue;

  const OnboardingScreen({super.key, required this.onContinue});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  static final _books = kBooks.sublist(0, 4);

  int _active = 0;
  int _previous = 0;
  late final AnimationController _ctrl;
  late final Timer _timer;

  /// (dx, dy, angleDeg, scale, opacity) per relative slot around the fan.
  /// 加大左右展开（±112）让两侧卡明显露出，形成清晰扇形。
  static const _fan = <int, (double, double, double, double, double)>{
    0: (0, -6, 0, 1.0, 1.0), // 中心（最前）
    1: (112, 18, 12, 0.82, 0.95), // 右侧，顺时针旋转
    2: (0, 30, 0, 0.6, 0.0), // 后方（隐藏，承接进出）
    3: (-112, 18, -12, 0.82, 0.95), // 左侧，逆时针旋转
  };

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 620),
      value: 1.0, // 初始即静止态，避免首帧动画/白屏
    );
    _timer = Timer.periodic(const Duration(seconds: 3), (_) => _advance());
  }

  void _advance() {
    if (!mounted) return;
    setState(() {
      _previous = _active;
      _active = (_active + 1) % _books.length;
    });
    _ctrl.forward(from: 0.0);
  }

  @override
  void dispose() {
    _timer.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  /// 在「上一帧槽位」与「目标槽位」之间按 t 插值，直接对数值插值可避免
  /// rel 索引环绕造成的跳变。
  (double, double, double, double, double) _slotAt(int i, double t) {
    final relPrev = (i - _previous + _books.length) % _books.length;
    final relNext = (i - _active + _books.length) % _books.length;
    final a = _fan[relPrev]!;
    final b = _fan[relNext]!;
    double lp(double x, double y) => x + (y - x) * t;
    return (lp(a.$1, b.$1), lp(a.$2, b.$2), lp(a.$3, b.$3), lp(a.$4, b.$4),
        lp(a.$5, b.$5));
  }

  /// 显式 [AnimationController] 驱动的扇形轮播：单一动画源 + 固定时长插值 +
  /// 每张卡 [RepaintBoundary] 隔离重绘，保留卡牌旋转/重叠的扇形观感，
  /// 同时避免老方案（隐式动画 + 每帧重排）在 Web 上的卡顿与白屏。
  List<Widget> _buildFanCards() {
    final indices = List.generate(_books.length, (i) => i);
    // z 序：后方 → 两侧 → 中心（中心最后绘制，位于最前）。每次切换只重排一次。
    const zOrder = {0: 10, 1: 5, 2: 0, 3: 5};
    indices.sort((x, y) {
      final rx = (x - _active + _books.length) % _books.length;
      final ry = (y - _active + _books.length) % _books.length;
      return zOrder[rx]!.compareTo(zOrder[ry]!);
    });

    return indices.map((i) {
      final book = _books[i];
      // 用 Align 显式把每张卡钉在中心，再由 Transform 偏移，避免依赖 Stack
      // 居中规则导致的布局歧义（这是之前「看不到扇形」的根因）。
      return Align(
        key: ValueKey('fan_$i'),
        alignment: Alignment.center,
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (context, child) {
            final t = Curves.easeInOutCubic.transform(_ctrl.value);
            final (dx, dy, deg, sc, op) = _slotAt(i, t);
            return Opacity(
              opacity: op.clamp(0.0, 1.0),
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..translateByDouble(dx, dy, 0, 0)
                  ..rotateZ(deg * pi / 180)
                  ..scaleByDouble(sc, sc, 1, 1),
                child: child,
              ),
            );
          },
          child: RepaintBoundary(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: ElRadius.controlR,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.22),
                    blurRadius: 28,
                    offset: const Offset(0, 14),
                  ),
                ],
              ),
              child: BookCover(
                genre: book.genre,
                title: book.title,
                author: book.author,
                badge: book.badge,
                size: CoverSize.lg,
              ),
            ),
          ),
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final glow =
        _kGenreGlow[_books[_active].genre] ?? ElTheme.primary;

    return Scaffold(
      backgroundColor: ElTheme.bg,
      body: SafeArea(
        child: Column(
          children: [
            // ── Carousel ──
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  // Radial glow matching active genre
                  Positioned.fill(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeInOut,
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          radius: 0.7,
                          colors: [
                            glow.withValues(alpha: 0.13),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),

                  ..._buildFanCards(),

                  // Bottom fade
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    height: 72,
                    child: IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              ElTheme.bg,
                              ElTheme.bg.withValues(alpha: 0),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Dot indicators
                  Positioned(
                    bottom: 16,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(_books.length, (i) {
                        final on = i == _active;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: on ? 20 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: on ? ElTheme.primary : ElTheme.line,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),

            // ── Branding + auth buttons ──
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 4, 24, 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.auto_awesome_rounded,
                        size: 22,
                        color: ElTheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'likenovel',
                        style: AppFont.newsreader(
                          fontSize: 28,
                          fontWeight: FontWeight.w600,
                          color: ElTheme.ink,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Romance you won\u2019t put down.',
                    style: AppFont.newsreader(
                      fontSize: 17,
                      fontStyle: FontStyle.italic,
                      color: ElTheme.muted,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'First 3 chapters free on every story.\nUnlock more with coins.',
                    textAlign: TextAlign.center,
                    style: AppFont.inter(
                      fontSize: 13,
                      color: ElTheme.faint,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 18),

                  // 1 ▸ Google (primary filled)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: widget.onContinue,
                      icon: Container(
                        width: 20,
                        height: 20,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'G',
                          style: AppFont.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF4285F4),
                          ),
                        ),
                      ),
                      label: const Text('Continue with Google'),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // 2 ▸ Facebook (outlined)
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: widget.onContinue,
                      icon: const Text(
                        'f',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1877F2),
                        ),
                      ),
                      label: const Text('Continue with Facebook'),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // 3 ▸ Email (outlined)
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: widget.onContinue,
                      icon: const Icon(Icons.email_outlined, size: 20),
                      label: const Text('Continue with email'),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // 4 ▸ Guest (text)
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: widget.onContinue,
                      child: Text(
                        'Browse as guest',
                        style: AppFont.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: ElTheme.muted,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Terms & Privacy
                  Text.rich(
                    TextSpan(
                      style: AppFont.inter(
                        fontSize: 11,
                        color: ElTheme.faint,
                        height: 1.4,
                      ),
                      children: const [
                        TextSpan(text: 'By continuing you agree to the '),
                        TextSpan(
                          text: 'Terms of Service',
                          style: TextStyle(
                            color: ElTheme.primaryInk,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                        TextSpan(text: ' and '),
                        TextSpan(
                          text: 'Privacy Policy',
                          style: TextStyle(
                            color: ElTheme.primaryInk,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                        TextSpan(text: '.'),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
