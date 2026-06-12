import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';
import 'package:likenovel/app/fonts.dart';

import 'package:likenovel/app/theme.dart';
import 'package:likenovel/core/models/book.dart';
import 'package:likenovel/core/mock/mock_data.dart';

// ---------------------------------------------------------------------------
// Reader themes
// ---------------------------------------------------------------------------

enum ReaderTheme { paper, sepia, dark, black }

/// 翻页方式：上下滚动 / 仿真书页（3D 翻页）/ 横向翻页（覆盖平移）。
enum PageTurnMode { scroll, simulation, slide }

const _pageTurnLabels = <PageTurnMode, String>{
  PageTurnMode.scroll: 'Scroll',
  PageTurnMode.simulation: 'Page curl',
  PageTurnMode.slide: 'Slide',
};

const _pageTurnIcons = <PageTurnMode, IconData>{
  PageTurnMode.scroll: Icons.swap_vert_rounded,
  PageTurnMode.simulation: Icons.auto_stories_rounded,
  PageTurnMode.slide: Icons.view_carousel_rounded,
};

class _ReaderColors {
  final Color bg;
  final Color text;
  final Color muted;

  const _ReaderColors({
    required this.bg,
    required this.text,
    required this.muted,
  });
}

const _themeColors = <ReaderTheme, _ReaderColors>{
  ReaderTheme.paper: _ReaderColors(
    bg: Color(0xFFF8F2E6),
    text: Color(0xFF3D3228),
    muted: Color(0xFF7A6E62),
  ),
  ReaderTheme.sepia: _ReaderColors(
    bg: Color(0xFFE8D5B8),
    text: Color(0xFF4A3A2A),
    muted: Color(0xFF7A6858),
  ),
  ReaderTheme.dark: _ReaderColors(
    bg: Color(0xFF2E2838),
    text: Color(0xFFDDD8D0),
    muted: Color(0xFF9890A0),
  ),
  ReaderTheme.black: _ReaderColors(
    bg: Color(0xFF0D0D0D),
    text: Color(0xFFC8C0C0),
    muted: Color(0xFF888080),
  ),
};

bool _isDarkTheme(ReaderTheme t) =>
    t == ReaderTheme.dark || t == ReaderTheme.black;

// ---------------------------------------------------------------------------
// Font size presets
// ---------------------------------------------------------------------------

const _fontSizes = [14.0, 16.0, 18.0];

// ---------------------------------------------------------------------------
// ReaderScreen
// ---------------------------------------------------------------------------

class ReaderScreen extends StatefulWidget {
  final Book book;
  final int chapterId;
  final VoidCallback onBack;

  /// 打开付费墙，参数为待解锁的章节号。
  final void Function(Book book, int chapterId) onPaywall;

  /// 本书是否已选择过金币按章解锁。
  final bool prefersCoinUnlock;

  /// 直接使用金币解锁章节，不打开付费墙。
  final void Function(Book book, int chapterId) onCoinUnlock;

  final int coins;

  /// 会员是否生效（全场畅读）。
  final bool isMember;

  /// 本书已消费解锁的章节号集合。
  final Set<int> unlockedChapters;

  /// 是否已收藏（加入书架）。
  final bool isFavorite;
  final VoidCallback onToggleFavorite;

  /// 初始翻页模式（全局记忆的用户偏好）。
  final PageTurnMode initialPageMode;

  /// 翻页模式变更回调（写回全局偏好，之后默认沿用）。
  final ValueChanged<PageTurnMode>? onPageModeChanged;

  const ReaderScreen({
    super.key,
    required this.book,
    required this.chapterId,
    required this.onBack,
    required this.onPaywall,
    required this.prefersCoinUnlock,
    required this.onCoinUnlock,
    required this.coins,
    required this.isMember,
    required this.unlockedChapters,
    required this.isFavorite,
    required this.onToggleFavorite,
    this.initialPageMode = PageTurnMode.scroll,
    this.onPageModeChanged,
  });

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {
  ReaderTheme _theme = ReaderTheme.paper;
  int _fontSizeIdx = 1;
  bool _showChrome = false;
  bool _showSettings = false;
  late PageTurnMode _pageMode = widget.initialPageMode;

  _ReaderColors get _colors => _themeColors[_theme]!;
  double get _fontSize => _fontSizes[_fontSizeIdx];
  bool get _dark => _isDarkTheme(_theme);

  late final List<String> _paragraphs;
  late final String _bodyText;
  late final List<Chapter> _chapters;
  late int _chapterId;
  late Chapter _chapter;
  late double _progress;

  final PageController _pageController = PageController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    final raw = kChapterSampleText.split('\n\n');
    _paragraphs = [...raw, ...raw];
    _bodyText = _paragraphs.join('\n\n');
    _chapters = getChapters(widget.book.id, sourceBook: widget.book);
    _chapterId = widget.chapterId;
    _applyChapter(_chapterId);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _applyChapter(int chapterId) {
    _chapterId = chapterId;
    _chapter = _chapters.firstWhere(
      (c) => c.id == chapterId,
      orElse: () => _chapters.first,
    );
    _progress = (chapterId / widget.book.chapters).clamp(0.0, 1.0);
  }

  // ── 章节可读性 ──

  /// 章节是否可直接阅读：
  /// 免费章节 + 已金币购买 + 会员全场畅读。
  bool _canRead(int chapterId) {
    final ch = _chapters.where((c) => c.id == chapterId).firstOrNull;
    if (ch?.free ?? false) return true;
    if (widget.isMember) return true;
    if (widget.unlockedChapters.contains(chapterId)) return true;
    return false;
  }

  bool get _hasNext => _chapterId < _chapters.length;
  bool get _hasPrev => _chapterId > 1;
  int get _nextChapterId => _chapterId + 1;
  bool get _nextReadable => _hasNext && _canRead(_nextChapterId);

  void _goToChapter(int chapterId) {
    setState(() => _applyChapter(chapterId));
    if (_pageController.hasClients) _pageController.jumpToPage(0);
    if (_scrollController.hasClients) _scrollController.jumpTo(0);
  }

  /// 下一章：可读则直接跳转，否则弹付费墙。
  void _onNextChapter() {
    if (!_hasNext) return;
    if (_canRead(_nextChapterId)) {
      _goToChapter(_nextChapterId);
    } else {
      _requestLockedChapter(_nextChapterId);
    }
  }

  void _requestLockedChapter(int chapterId) {
    if (widget.prefersCoinUnlock && widget.coins >= widget.book.chapterPrice) {
      widget.onCoinUnlock(widget.book, chapterId);
      _goToChapter(chapterId);
      return;
    }
    widget.onPaywall(widget.book, chapterId);
  }

  void _toggleChrome() => setState(() {
        _showChrome = !_showChrome;
        if (!_showChrome) _showSettings = false;
      });

  void _openSettings() => setState(() => _showSettings = true);
  void _closeSettings() => setState(() => _showSettings = false);

  Future<void> _openChapters() async {
    final selected = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _ChaptersSheet(
        bookTitle: widget.book.title,
        chapters: _chapters,
        currentChapterId: _chapterId,
        colors: _colors,
        dark: _dark,
      ),
    );
    if (selected != null && selected != _chapterId && mounted) {
      if (_canRead(selected)) {
        _goToChapter(selected);
      } else {
        _requestLockedChapter(selected);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final topPad = mq.padding.top;
    final bottomPad = mq.padding.bottom;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: _dark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: _colors.bg,
        body: Stack(
          children: [
            // ── Scrollable content ──
            GestureDetector(
              onTap: _toggleChrome,
              behavior: HitTestBehavior.translucent,
              child: _pageMode == PageTurnMode.scroll
                  ? _buildContent(topPad, bottomPad)
                  : _buildPagedContent(topPad, bottomPad),
            ),

            // ── Top chrome ──
            _buildTopChrome(topPad),

            // ── Bottom chrome ──
            _buildBottomChrome(bottomPad),

            // ── Settings sheet ──
            if (_showSettings) _buildSettingsOverlay(bottomPad),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // Content
  // =========================================================================

  Widget _buildContent(double topPad, double bottomPad) {
    return ListView(
      controller: _scrollController,
      padding: EdgeInsets.fromLTRB(24, topPad + 64, 24, bottomPad + 80),
      children: [
        const SizedBox(height: 32),

        // Chapter kicker
        Text(
          'CHAPTER $_chapterId',
          style: AppFont.inter(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 2.0,
            color: _colors.muted,
          ),
        ),
        const SizedBox(height: 8),

        // Chapter title
        Text(
          _chapter.title,
          style: AppFont.newsreader(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: _colors.text,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 28),

        // Body paragraphs
        ..._paragraphs.map(
          (p) => Padding(
            padding: const EdgeInsets.only(bottom: 22),
            child: Text(
              p,
              style: AppFont.newsreader(
                fontSize: _fontSize,
                fontWeight: FontWeight.w400,
                color: _colors.text,
                height: 1.85,
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Inline paywall card
        _buildPaywallCard(),

        const SizedBox(height: 40),
      ],
    );
  }

  // =========================================================================
  // Paged content (仿真书页 / 横向翻页)
  // =========================================================================

  Widget _buildPagedContent(double topPad, double bottomPad) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const sidePad = 24.0;
        final maxWidth = constraints.maxWidth - sidePad * 2;
        final topInset = topPad + 64;
        final bottomInset = bottomPad + 56;
        // 首页需为「章节标记 + 标题」预留空间。
        const headerHeight = 8 + 22 * 1.3 + 28 + 16;
        final fullHeight =
            (constraints.maxHeight - topInset - bottomInset).clamp(80.0, 4000.0);
        final firstHeight =
            (fullHeight - headerHeight).clamp(60.0, fullHeight);

        final style = AppFont.newsreader(
          fontSize: _fontSize,
          fontWeight: FontWeight.w400,
          color: _colors.text,
          height: 1.85,
        );

        final pages =
            _paginate(_bodyText, style, maxWidth, firstHeight, fullHeight);
        final total = pages.length + 1; // 末页为付费墙

        Widget buildPage(BuildContext context, int index) {
          final isPaywall = index == pages.length;
          return Container(
            // 仿真翻页时每页需要不透明底色，否则翻页过程会透出下层页面
            color: _colors.bg,
            padding: EdgeInsets.fromLTRB(
                sidePad, topInset, sidePad, bottomInset),
            child: isPaywall
                ? Center(
                    child: SingleChildScrollView(child: _buildPaywallCard()),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (index == 0) ...[
                        Text(
                          'CHAPTER $_chapterId',
                          style: AppFont.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 2.0,
                            color: _colors.muted,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _chapter.title,
                          style: AppFont.newsreader(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: _colors.text,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 28),
                      ],
                      Expanded(
                        child: Text(pages[index], style: style),
                      ),
                      // 页码
                      Center(
                        child: Text(
                          '${index + 1} / ${pages.length}',
                          style: AppFont.inter(
                            fontSize: 11,
                            color: _colors.muted,
                          ),
                        ),
                      ),
                    ],
                  ),
          );
        }

        if (_pageMode == PageTurnMode.simulation) {
          // 仿真书页：当前页像真实书页一样绕左侧书脊翻走
          return _BookFlipView(
            // 章节/字号/分页数变化时重建，避免页索引越界
            key: ValueKey('flip-$_chapterId-$_fontSizeIdx-${pages.length}'),
            itemCount: total,
            itemBuilder: buildPage,
            pageColor: _colors.bg,
            dark: _dark,
            // 左/右热区点击翻页，中间点击呼出阅读菜单
            onCenterTap: _toggleChrome,
          );
        }

        return PageView.builder(
          controller: _pageController,
          itemCount: total,
          itemBuilder: buildPage,
        );
      },
    );
  }

  /// 将整段正文按可用高度切分为多页（贪心 + 二分查找最大可容纳前缀）。
  List<String> _paginate(
    String text,
    TextStyle style,
    double maxWidth,
    double firstHeight,
    double otherHeight,
  ) {
    final pages = <String>[];
    var remaining = text;
    var first = true;
    var guard = 0;
    while (remaining.trim().isNotEmpty && guard < 500) {
      guard++;
      final h = first ? firstHeight : otherHeight;
      final cut = _fitChars(remaining, style, maxWidth, h);
      if (cut <= 0) {
        pages.add(remaining.trim());
        break;
      }
      pages.add(remaining.substring(0, cut).trim());
      remaining = remaining.substring(cut);
      first = false;
    }
    if (pages.isEmpty) pages.add('');
    return pages;
  }

  int _fitChars(
      String text, TextStyle style, double maxWidth, double maxHeight) {
    if (maxHeight <= 0 || text.isEmpty) return 0;
    var lo = 1;
    var hi = text.length;
    var best = 0;
    while (lo <= hi) {
      final mid = (lo + hi) >> 1;
      final tp = TextPainter(
        text: TextSpan(text: text.substring(0, mid), style: style),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: maxWidth);
      if (tp.height <= maxHeight) {
        best = mid;
        lo = mid + 1;
      } else {
        hi = mid - 1;
      }
    }
    // 尽量在空白处断开，避免截断单词。
    if (best > 0 && best < text.length) {
      final slice = text.substring(0, best);
      final lastSpace = slice.lastIndexOf(RegExp(r'[\s\n]'));
      if (lastSpace > best * 0.5) best = lastSpace + 1;
    }
    return best;
  }

  // =========================================================================
  // Paywall card
  // =========================================================================

  Widget _buildPaywallCard() {
    final nextChapter = _nextChapterId;
    final readable = _nextReadable;
    final cardBg = _dark
        ? _colors.text.withValues(alpha: 0.06)
        : _colors.text.withValues(alpha: 0.04);
    final borderColor = _dark
        ? _colors.text.withValues(alpha: 0.10)
        : _colors.text.withValues(alpha: 0.08);

    if (!_hasNext) {
      // 已是最后一章：显示完结提示。
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(ElRadius.card),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          children: [
            Icon(Icons.auto_stories_rounded, size: 28, color: _colors.muted),
            const SizedBox(height: 12),
            Text(
              "You're all caught up",
              style: AppFont.newsreader(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: _colors.text,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'New chapters are on the way',
              style: AppFont.inter(fontSize: 13, color: _colors.muted),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(ElRadius.card),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: readable
                  ? ElTheme.gold.withValues(alpha: 0.14)
                  : ElTheme.primary.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(
              readable
                  ? (widget.isMember
                      ? Icons.workspace_premium_rounded
                      : Icons.lock_open_rounded)
                  : Icons.lock_rounded,
              size: 20,
              color: readable ? ElTheme.gold : ElTheme.primary,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Continue Chapter $nextChapter',
            style: AppFont.newsreader(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: _colors.text,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            readable
                ? (widget.isMember
                    ? 'Included with your VIP membership'
                    : 'Already unlocked — enjoy!')
                : 'Read free with VIP, or unlock this chapter',
            style: AppFont.inter(
              fontSize: 13,
              color: _colors.muted,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _onNextChapter,
              style: ElevatedButton.styleFrom(
                backgroundColor: !readable ? ElTheme.gold : ElTheme.primary,
                foregroundColor: !readable ? Colors.white : ElTheme.onPrimary,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(ElRadius.control),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    readable
                        ? Icons.arrow_forward_rounded
                        : Icons.workspace_premium_rounded,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    readable
                        ? 'Continue reading'
                        : 'Unlock',
                    style: AppFont.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // Top chrome
  // =========================================================================

  Widget _buildTopChrome(double topPad) {
    final chromeBg = _colors.bg.withValues(alpha: 0.95);

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: AnimatedOpacity(
        opacity: _showChrome ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        child: IgnorePointer(
          ignoring: !_showChrome,
          child: Container(
            padding: EdgeInsets.only(top: topPad),
            decoration: BoxDecoration(
              color: chromeBg,
              border: Border(
                bottom: BorderSide(
                  color: _colors.text.withValues(alpha: 0.08),
                ),
              ),
            ),
            child: SizedBox(
              height: 52,
              child: Row(
                children: [
                  const SizedBox(width: 4),
                  IconButton(
                    onPressed: widget.onBack,
                    icon: Icon(
                      Icons.arrow_back_rounded,
                      color: _colors.text,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      widget.book.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppFont.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: _colors.text,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _openChapters,
                    icon: Icon(
                      Icons.list_rounded,
                      color: _colors.text,
                    ),
                    tooltip: 'Chapters',
                  ),
                  IconButton(
                    onPressed: _openSettings,
                    icon: Icon(
                      Icons.text_fields_rounded,
                      color: _colors.text,
                    ),
                    tooltip: 'Settings',
                  ),
                  const SizedBox(width: 4),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // =========================================================================
  // Bottom chrome
  // =========================================================================

  Widget _buildBottomChrome(double bottomPad) {
    final chromeBg = _colors.bg.withValues(alpha: 0.95);
    final pct = (_progress * 100).round();

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: AnimatedOpacity(
        opacity: _showChrome ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        child: IgnorePointer(
          ignoring: !_showChrome,
          child: Container(
            decoration: BoxDecoration(
              color: chromeBg,
              border: Border(
                top: BorderSide(
                  color: _colors.text.withValues(alpha: 0.08),
                ),
              ),
            ),
            padding: EdgeInsets.fromLTRB(20, 12, 20, bottomPad + 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Progress row
                Row(
                  children: [
                    Text(
                      '$pct%',
                      style: AppFont.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _colors.muted,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: LinearProgressIndicator(
                          value: _progress,
                          minHeight: 3,
                          backgroundColor: _colors.text.withValues(alpha: 0.08),
                          valueColor: AlwaysStoppedAnimation(ElTheme.primary),
                        ),
                      ),
                    ),
                    if (widget.isMember) ...[
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: ElTheme.gold.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.workspace_premium_rounded,
                                size: 12, color: ElTheme.gold),
                            const SizedBox(width: 3),
                            Text(
                              'VIP',
                              style: AppFont.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: ElTheme.gold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 12),

                // Action row: 收藏 + 章节导航 / 解锁
                Row(
                  children: [
                    _FavoriteButton(
                      isFavorite: widget.isFavorite,
                      colors: _colors,
                      onTap: widget.onToggleFavorite,
                    ),
                    const SizedBox(width: 10),
                    if (_nextReadable || !_hasNext) ...[
                      // 已解锁/会员畅读：显示上一章 / 下一章导航
                      _ChapterNavButton(
                        icon: Icons.chevron_left_rounded,
                        enabled: _hasPrev,
                        colors: _colors,
                        onTap: () {
                          if (_hasPrev) _goToChapter(_chapterId - 1);
                        },
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _hasNext ? _onNextChapter : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ElTheme.primary,
                            foregroundColor: ElTheme.onPrimary,
                            disabledBackgroundColor:
                                _colors.text.withValues(alpha: 0.08),
                            disabledForegroundColor: _colors.muted,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 13),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(ElRadius.control),
                            ),
                            elevation: 0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _hasNext
                                    ? 'Next · Chapter $_nextChapterId'
                                    : 'Latest chapter',
                                style: AppFont.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (widget.isMember && _hasNext) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 7, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: ElTheme.gold.withValues(alpha: 0.18),
                                    borderRadius: BorderRadius.circular(99),
                                  ),
                                  child: Text(
                                    'VIP',
                                    style: AppFont.inter(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: ElTheme.gold,
                                    ),
                                  ),
                                ),
                              ],
                              if (_hasNext) ...[
                                const SizedBox(width: 6),
                                const Icon(Icons.arrow_forward_rounded,
                                    size: 16),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ] else
                      // 下一章未解锁：付费墙主推会员，金币仅为次选项。
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () =>
                              _requestLockedChapter(_nextChapterId),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ElTheme.gold,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 13),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(ElRadius.control),
                            ),
                            elevation: 0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.workspace_premium_rounded,
                                size: 15,
                              ),
                              const SizedBox(width: 7),
                              Text(
                                'Unlock',
                                style: AppFont.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // =========================================================================
  // Settings overlay
  // =========================================================================

  Widget _buildSettingsOverlay(double bottomPad) {
    return Positioned.fill(
      child: Stack(
        children: [
          // Scrim
          GestureDetector(
            onTap: _closeSettings,
            child: Container(color: Colors.black.withValues(alpha: 0.35)),
          ),

          // Sheet
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _SettingsSheet(
              theme: _theme,
              fontSizeIdx: _fontSizeIdx,
              pageMode: _pageMode,
              bottomPad: bottomPad,
              colors: _colors,
              dark: _dark,
              onThemeChanged: (t) => setState(() => _theme = t),
              onFontSizeChanged: (i) => setState(() => _fontSizeIdx = i),
              onPageModeChanged: (m) {
                setState(() => _pageMode = m);
                // 写回全局偏好：之后进入阅读器默认沿用本次选择
                widget.onPageModeChanged?.call(m);
                if (_pageController.hasClients) _pageController.jumpToPage(0);
              },
              onClose: _closeSettings,
            ),
          ),
        ],
      ),
    );
  }
}

// ===========================================================================
// _BookFlipView — 仿真书页翻页
//
// 手指左右拖动时，当前页绕屏幕左缘（书脊）做带透视的 3D 翻转：
// 向左滑动，当前页像真实书页一样从右向左「翻走」，越过 90° 后露出纸张
// 背面（带渐变阴影），松手按进度/速度决定补完或回弹；向右滑动则把上
// 一页从左侧「翻回来」。
// ===========================================================================

class _BookFlipView extends StatefulWidget {
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;

  /// 纸张底色：用于翻转过半后显示的页背。
  final Color pageColor;
  final bool dark;

  /// 点击中部区域回调（呼出阅读器菜单）。
  final VoidCallback? onCenterTap;

  /// 点击翻页热区宽度占比 0..0.5（左侧上一页 / 右侧下一页）。
  static const double tapAreaRatio = 0.3;

  const _BookFlipView({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    required this.pageColor,
    required this.dark,
    this.onCenterTap,
  });

  @override
  State<_BookFlipView> createState() => _BookFlipViewState();
}

class _BookFlipViewState extends State<_BookFlipView>
    with SingleTickerProviderStateMixin {
  int _index = 0;

  /// 1 = 向前翻（当前页翻走），-1 = 向后翻（上一页翻回），0 = 静止。
  int _direction = 0;

  /// 翻页进度 0..1（0 = 未翻动，1 = 翻完）。
  late final AnimationController _progress;

  /// 补完/回弹弹簧：过阻尼（无过冲），尾段由公差截断，约 0.3s 收敛。
  static const _spring = SpringDescription(
    mass: 1,
    stiffness: 250,
    damping: 32,
  );

  @override
  void initState() {
    super.initState();
    _progress = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _progress.dispose();
    super.dispose();
  }

  /// 已构建页面缓存：动画/拖拽期间每帧复用同一 Widget 实例，
  /// 配合 RepaintBoundary 让文本排版层只栅格化一次（丝滑关键）。
  final Map<int, Widget> _pageCache = {};

  Widget _page(BuildContext context, int index) => _pageCache[index] ??=
      RepaintBoundary(child: widget.itemBuilder(context, index));

  @override
  void didUpdateWidget(covariant _BookFlipView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.itemCount != widget.itemCount ||
        oldWidget.pageColor != widget.pageColor ||
        oldWidget.dark != widget.dark) {
      _pageCache.clear();
    }
  }

  /// 手指按下：截停飞行中的补完动画，可在页面飞行途中重新捏住它。
  void _onDragStart(DragStartDetails details) {
    if (_progress.isAnimating) _progress.stop();
  }

  void _onDragUpdate(DragUpdateDetails details) {
    final width = context.size?.width ?? 1;
    final delta = (details.primaryDelta ?? 0) / width;

    if (_direction == 0) {
      // 根据首次位移方向锁定翻页方向
      if (delta < 0 && _index < widget.itemCount - 1) {
        _direction = 1;
      } else if (delta > 0 && _index > 0) {
        _direction = -1;
      } else {
        return;
      }
    }

    // 页角行程为 2W（从右缘划到左缘外），进度增量 = 手指位移 / 2W：
    // 这样页角移动速度与手指 1:1，完全跟手。
    final advance = (_direction == 1 ? -delta : delta) / 2;
    _progress.value = (_progress.value + advance).clamp(0.0, 1.0);
  }

  void _onDragEnd(DragEndDetails details) {
    if (_direction == 0) return;
    final width = context.size?.width ?? 1;
    final vx = details.primaryVelocity ?? 0;
    // 手指速度 → 进度速度（同一映射：行程 2W），保持松手瞬间速度连续
    final vp = (_direction == 1 ? -vx : vx) / (2 * width);
    // 甩动（约 0.9 屏宽/秒）按方向决定；缓慢松手看页角是否越过屏幕中线
    const flingVp = 0.45;
    final shouldComplete =
        vp.abs() > flingVp ? vp > 0 : _progress.value > 0.25;
    _springTo(shouldComplete ? 1.0 : 0.0, vp);
  }

  /// 以当前进度与速度启动弹簧模拟：接续手指速度，无任何速度跳变。
  void _springTo(double target, double velocity) {
    final sim = SpringSimulation(
      _spring,
      _progress.value,
      target,
      velocity,
      tolerance: const Tolerance(distance: 0.0005, velocity: 0.005),
    );
    _progress.animateWith(sim).then((_) => _afterSettle());
  }

  /// 弹簧自然停止后提交/取消翻页（被手指截停时 Future 不会触发）。
  void _afterSettle() {
    if (!mounted || _direction == 0) return;
    final committed = _progress.value > 0.5;
    setState(() {
      if (committed) _index += _direction;
      _direction = 0;
      _progress.value = 0;
    });
  }

  bool get _isAnimating => _progress.isAnimating;

  /// 点击翻页：左右热区翻上/下一页，中间呼出菜单。
  void _onTapUp(TapUpDetails details) {
    if (_isAnimating || _direction != 0) return;
    final width = context.size?.width ?? 0;
    final x = details.localPosition.dx;
    if (x < width * _BookFlipView.tapAreaRatio) {
      _flip(-1);
    } else if (x > width * (1 - _BookFlipView.tapAreaRatio)) {
      _flip(1);
    } else {
      widget.onCenterTap?.call();
    }
  }

  /// 程序化翻页（点击热区触发）：带初速度的弹簧，起手干脆、落点柔和。
  void _flip(int direction) {
    if (direction == 1 && _index >= widget.itemCount - 1) return;
    if (direction == -1 && _index <= 0) return;
    setState(() => _direction = direction);
    _springTo(1.0, 3.5);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragStart: _onDragStart,
      onHorizontalDragUpdate: _onDragUpdate,
      onHorizontalDragEnd: _onDragEnd,
      onTapUp: _onTapUp,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _progress,
        builder: (context, _) {
          final p = _progress.value;

          // 静止：只渲染当前页
          if (_direction == 0) {
            return _page(context, _index);
          }

          final forward = _direction == 1;
          // 底层页：向前翻时是下一页，向后翻时是当前页
          final underIndex = forward ? _index + 1 : _index;
          // 卷曲页：向前翻时是当前页，向后翻时是上一页
          final flipIndex = forward ? _index : _index - 1;
          // 卷曲进度 0..1（两个方向统一）：0 = 平铺，1 = 完全翻过去
          final t = forward ? p : 1 - p;

          // 复用缓存的页面实例：每帧只变化裁剪路径与纸背绘制
          final flipPage = _page(context, flipIndex);
          final underPage = _page(context, underIndex);

          return LayoutBuilder(
            builder: (context, constraints) {
              final size =
                  Size(constraints.maxWidth, constraints.maxHeight);
              final geo = _PageCurl.compute(size, t);

              // 近乎平铺：直接显示卷曲页，避免退化几何
              if (geo == null) {
                return Stack(
                  fit: StackFit.expand,
                  children: [underPage, flipPage],
                );
              }

              return ClipRect(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // ── 底层页（被翻开后露出的下一页）──
                    underPage,
                    // ── 卷曲页的未翻起部分：沿折线裁剪 ──
                    ClipPath(
                      clipper: _CurlClipper(geo.keepPath),
                      child: flipPage,
                    ),
                    // ── 翻折到正面的纸背 + 投影 + 圆柱光影 ──
                    IgnorePointer(
                      child: CustomPaint(
                        painter: _PageCurlPainter(
                          geo: geo,
                          pageColor: widget.pageColor,
                          dark: widget.dark,
                        ),
                        size: Size.infinite,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ===========================================================================
// _PageCurl — 仿真卷页几何
//
// 物理模型：手指从右下角 C=(W,H) 捻起书页，把页角拖到 C'。折线是 CC' 的
// 垂直平分线（纸张不可拉伸的物理约束）；折线把页面分成「未翻起区」与
// 「翻折区」，翻折区沿折线镜像后盖在页面上方、露出纸背。C' 随进度沿一条
// 自然弧线移动：水平方向从右缘划到左缘外，垂直方向中段抬起——折线因此
// 呈对角斜线（先翻右下角，再整页卷过去）。
// ===========================================================================

class _PageCurl {
  /// 未翻起区域（裁剪卷曲页正面用）。
  final Path keepPath;

  /// 翻折到正面的纸背区域。
  final Path foldPath;

  /// 折线段中点与单位方向（由折线指向翻折片内部，即 C' 方向）。
  final Offset creaseMid;
  final Offset intoFold;

  /// 翻折片沿 [intoFold] 方向的最大深度（渐变范围）。
  final double foldDepth;

  /// 卷曲强度 0..1（中段最大，用于阴影/高光）。
  final double strength;

  const _PageCurl({
    required this.keepPath,
    required this.foldPath,
    required this.creaseMid,
    required this.intoFold,
    required this.foldDepth,
    required this.strength,
  });

  static _PageCurl? compute(Size size, double t) {
    if (t < 0.004) return null; // 平铺
    final w = size.width;
    final h = size.height;

    // 页角 C 与拖拽目标 C'：水平划过 2W，中段向上抬起形成斜折线
    final corner = Offset(w, h);
    final target = Offset(
      w - 2 * w * t,
      h - h * 0.38 * math.sin(t * math.pi),
    );

    final diff = corner - target;
    final dist = diff.distance;
    if (dist < 1) return null;
    // 单位法线：指向被翻走的一侧（页角 C 所在半平面）
    final n = diff / dist;
    final mid = Offset(
      (corner.dx + target.dx) / 2,
      (corner.dy + target.dy) / 2,
    );

    // 有符号距离：>0 在翻折侧，<0 在未翻侧
    double sideOf(Offset pt) =>
        (pt.dx - mid.dx) * n.dx + (pt.dy - mid.dy) * n.dy;

    final rect = [
      Offset.zero,
      Offset(w, 0),
      Offset(w, h),
      Offset(0, h),
    ];

    // 半平面裁剪（Sutherland–Hodgman），并记录折线与页缘的交点
    final creases = <Offset>[];
    final keepPoly = _clipPoly(rect, (pt) => -sideOf(pt), creases);
    final cutPoly = _clipPoly(rect, sideOf, <Offset>[]);
    if (cutPoly.length < 3) return null;

    // 翻折片 = 被翻走区域沿折线镜像（折线上的点保持不动）
    Offset reflect(Offset pt) {
      final d = sideOf(pt);
      return Offset(pt.dx - 2 * d * n.dx, pt.dy - 2 * d * n.dy);
    }

    final foldPoly = cutPoly.map(reflect).toList();

    final strength = math.sin(t * math.pi).clamp(0.0, 1.0).toDouble();
    // 折线段中点 + 微弯控制点：折线处轻微外凸，模拟纸张绕圆柱的弯曲
    final creaseMid = creases.length >= 2
        ? Offset((creases[0].dx + creases[1].dx) / 2,
            (creases[0].dy + creases[1].dy) / 2)
        : mid;
    final bulge = math.min(w, h) * 0.045 * strength;
    final control =
        Offset(creaseMid.dx + n.dx * bulge, creaseMid.dy + n.dy * bulge);

    final keepPath = _polyPath(keepPoly, creases, control);
    final foldPath = _polyPath(foldPoly, creases, control);

    // 渐变深度：翻折片各顶点到折线的最大距离
    var depth = 1.0;
    for (final pt in foldPoly) {
      depth = math.max(depth, -sideOf(pt));
    }

    return _PageCurl(
      keepPath: keepPath,
      foldPath: foldPath,
      creaseMid: creaseMid,
      intoFold: -n,
      foldDepth: depth,
      strength: strength,
    );
  }

  /// 用半平面 f(p) <= 0 裁剪多边形，交点追加进 [creases]。
  static List<Offset> _clipPoly(
    List<Offset> poly,
    double Function(Offset) f,
    List<Offset> creases,
  ) {
    final out = <Offset>[];
    for (var i = 0; i < poly.length; i++) {
      final a = poly[i];
      final b = poly[(i + 1) % poly.length];
      final fa = f(a);
      final fb = f(b);
      if (fa <= 0) out.add(a);
      if ((fa < 0 && fb > 0) || (fa > 0 && fb < 0)) {
        final u = fa / (fa - fb);
        final ip = Offset(
          a.dx + (b.dx - a.dx) * u,
          a.dy + (b.dy - a.dy) * u,
        );
        out.add(ip);
        creases.add(ip);
      }
    }
    return out;
  }

  /// 多边形 → Path；位于折线上的边用二次贝塞尔微弯（control 为控制点）。
  static Path _polyPath(
    List<Offset> poly,
    List<Offset> creases,
    Offset control,
  ) {
    final path = Path();
    if (poly.isEmpty) return path;
    bool isCrease(Offset pt) => creases.any(
        (c) => (c.dx - pt.dx).abs() < 0.5 && (c.dy - pt.dy).abs() < 0.5);
    path.moveTo(poly[0].dx, poly[0].dy);
    for (var i = 0; i < poly.length; i++) {
      final a = poly[i];
      final b = poly[(i + 1) % poly.length];
      if (creases.length >= 2 && isCrease(a) && isCrease(b)) {
        path.quadraticBezierTo(control.dx, control.dy, b.dx, b.dy);
      } else {
        path.lineTo(b.dx, b.dy);
      }
    }
    path.close();
    return path;
  }
}

class _CurlClipper extends CustomClipper<Path> {
  final Path path;

  const _CurlClipper(this.path);

  @override
  Path getClip(Size size) => path;

  @override
  bool shouldReclip(_CurlClipper oldClipper) => oldClipper.path != path;
}

/// 绘制翻折到正面的纸背：先投影（drawShadow），再沿折线法向铺
/// 「阴影 → 圆柱高光 → 纸色」渐变，最后沿折线压一条细暗线增强折痕。
class _PageCurlPainter extends CustomPainter {
  final _PageCurl geo;
  final Color pageColor;
  final bool dark;

  const _PageCurlPainter({
    required this.geo,
    required this.pageColor,
    required this.dark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final base = pageColor;

    // 1. 投影：翻折片悬空于页面之上，投出柔和阴影
    canvas.drawShadow(
      geo.foldPath,
      Colors.black.withValues(alpha: dark ? 0.8 : 0.55),
      6 + 10 * geo.strength,
      false,
    );

    // 2. 纸背填充：折线处为弯曲谷影，随后是圆柱高光带，再过渡到纸色
    final shadowEdge =
        Color.alphaBlend(Colors.black.withValues(alpha: 0.16), base);
    final highlight = Color.alphaBlend(
        Colors.white.withValues(alpha: dark ? 0.05 : 0.45), base);
    final body =
        Color.alphaBlend(Colors.black.withValues(alpha: 0.04), base);
    final to = Offset(
      geo.creaseMid.dx + geo.intoFold.dx * geo.foldDepth,
      geo.creaseMid.dy + geo.intoFold.dy * geo.foldDepth,
    );
    final paint = Paint()
      ..shader = ui.Gradient.linear(
        geo.creaseMid,
        to,
        [shadowEdge, highlight, body, body],
        [0.0, 0.12, 0.45, 1.0],
      );
    canvas.drawPath(geo.foldPath, paint);

    // 3. 折痕线：极细的暗描边强化「卷起」的边界
    final crease = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..color = Colors.black.withValues(alpha: 0.10 * geo.strength);
    canvas.drawPath(geo.foldPath, crease);
  }

  @override
  bool shouldRepaint(_PageCurlPainter oldDelegate) =>
      oldDelegate.geo != geo ||
      oldDelegate.pageColor != pageColor ||
      oldDelegate.dark != dark;
}

// ===========================================================================
// Favorite (加入书架) button — bottom chrome
// ===========================================================================

class _FavoriteButton extends StatelessWidget {
  final bool isFavorite;
  final _ReaderColors colors;
  final VoidCallback onTap;

  const _FavoriteButton({
    required this.isFavorite,
    required this.colors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 58,
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: isFavorite
              ? ElTheme.primary.withValues(alpha: 0.12)
              : colors.text.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(ElRadius.control),
          border: Border.all(
            color: isFavorite
                ? ElTheme.primary.withValues(alpha: 0.5)
                : colors.text.withValues(alpha: 0.10),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isFavorite
                  ? Icons.bookmark_added_rounded
                  : Icons.bookmark_add_outlined,
              size: 18,
              color: isFavorite ? ElTheme.primary : colors.muted,
            ),
            const SizedBox(height: 2),
            Text(
              isFavorite ? 'Saved' : 'Library',
              style: AppFont.inter(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: isFavorite ? ElTheme.primary : colors.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===========================================================================
// Chapter prev/next nav button — bottom chrome (解锁后形态)
// ===========================================================================

class _ChapterNavButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final _ReaderColors colors;
  final VoidCallback onTap;

  const _ChapterNavButton({
    required this.icon,
    required this.enabled,
    required this.colors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      behavior: HitTestBehavior.opaque,
      child: AnimatedOpacity(
        opacity: enabled ? 1.0 : 0.35,
        duration: const Duration(milliseconds: 160),
        child: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: colors.text.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(ElRadius.control),
            border: Border.all(color: colors.text.withValues(alpha: 0.10)),
          ),
          child: Icon(icon, size: 22, color: colors.text),
        ),
      ),
    );
  }
}

// ===========================================================================
// Settings sheet (extracted widget for clarity)
// ===========================================================================

class _SettingsSheet extends StatelessWidget {
  final ReaderTheme theme;
  final int fontSizeIdx;
  final PageTurnMode pageMode;
  final double bottomPad;
  final _ReaderColors colors;
  final bool dark;
  final ValueChanged<ReaderTheme> onThemeChanged;
  final ValueChanged<int> onFontSizeChanged;
  final ValueChanged<PageTurnMode> onPageModeChanged;
  final VoidCallback onClose;

  const _SettingsSheet({
    required this.theme,
    required this.fontSizeIdx,
    required this.pageMode,
    required this.bottomPad,
    required this.colors,
    required this.dark,
    required this.onThemeChanged,
    required this.onFontSizeChanged,
    required this.onPageModeChanged,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final sheetBg = dark
        ? colors.bg.withValues(alpha: 0.97)
        : colors.bg;
    final divider = colors.text.withValues(alpha: 0.08);

    return Container(
      decoration: BoxDecoration(
        color: sheetBg,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(ElRadius.sheet),
        ),
        border: Border(top: BorderSide(color: divider)),
      ),
      padding: EdgeInsets.fromLTRB(24, 20, 24, bottomPad + 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: colors.text.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // ── Font size stepper ──
          Text(
            'Font Size',
            style: AppFont.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.6,
              color: colors.muted,
            ),
          ),
          const SizedBox(height: 12),
          _FontSizeStepper(
            index: fontSizeIdx,
            colors: colors,
            dark: dark,
            onChanged: onFontSizeChanged,
          ),
          const SizedBox(height: 24),

          Divider(height: 1, color: divider),
          const SizedBox(height: 24),

          // ── Theme swatches ──
          Text(
            'Theme',
            style: AppFont.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.6,
              color: colors.muted,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: ReaderTheme.values.map((t) {
              final c = _themeColors[t]!;
              final selected = t == theme;
              return GestureDetector(
                onTap: () => onThemeChanged(t),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: c.bg,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected
                          ? ElTheme.primary
                          : colors.text.withValues(alpha: 0.12),
                      width: selected ? 2.5 : 1,
                    ),
                    boxShadow: selected
                        ? [
                            BoxShadow(
                              color: ElTheme.primary.withValues(alpha: 0.25),
                              blurRadius: 8,
                            ),
                          ]
                        : null,
                  ),
                  child: selected
                      ? Center(
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: ElTheme.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                        )
                      : null,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          Divider(height: 1, color: divider),
          const SizedBox(height: 24),

          // ── Page turn mode ──
          Text(
            'Page turn',
            style: AppFont.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.6,
              color: colors.muted,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: PageTurnMode.values.map((m) {
              final selected = m == pageMode;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: GestureDetector(
                    onTap: () => onPageModeChanged(m),
                    behavior: HitTestBehavior.opaque,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: selected
                            ? ElTheme.primary.withValues(alpha: 0.12)
                            : colors.text.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(ElRadius.control),
                        border: Border.all(
                          color: selected
                              ? ElTheme.primary
                              : colors.text.withValues(alpha: 0.10),
                          width: selected ? 1.5 : 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            _pageTurnIcons[m],
                            size: 20,
                            color: selected ? ElTheme.primary : colors.muted,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _pageTurnLabels[m]!,
                            style: AppFont.inter(
                              fontSize: 11,
                              fontWeight: selected
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              color:
                                  selected ? ElTheme.primary : colors.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ===========================================================================
// Font size stepper
// ===========================================================================

class _FontSizeStepper extends StatelessWidget {
  final int index;
  final _ReaderColors colors;
  final bool dark;
  final ValueChanged<int> onChanged;

  const _FontSizeStepper({
    required this.index,
    required this.colors,
    required this.dark,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final canDecrease = index > 0;
    final canIncrease = index < _fontSizes.length - 1;

    final controlBg = dark
        ? colors.text.withValues(alpha: 0.08)
        : colors.text.withValues(alpha: 0.05);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // A- button
        _StepButton(
          label: 'A–',
          enabled: canDecrease,
          colors: colors,
          controlBg: controlBg,
          onTap: () => onChanged(index - 1),
        ),
        const SizedBox(width: 16),

        // Current size display
        Container(
          width: 48,
          alignment: Alignment.center,
          child: Text(
            '${_fontSizes[index].toInt()}',
            style: AppFont.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: colors.text,
            ),
          ),
        ),
        const SizedBox(width: 16),

        // A+ button
        _StepButton(
          label: 'A+',
          enabled: canIncrease,
          colors: colors,
          controlBg: controlBg,
          onTap: () => onChanged(index + 1),
        ),
      ],
    );
  }
}

class _StepButton extends StatelessWidget {
  final String label;
  final bool enabled;
  final _ReaderColors colors;
  final Color controlBg;
  final VoidCallback onTap;

  const _StepButton({
    required this.label,
    required this.enabled,
    required this.colors,
    required this.controlBg,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedOpacity(
        opacity: enabled ? 1.0 : 0.35,
        duration: const Duration(milliseconds: 160),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: controlBg,
            borderRadius: BorderRadius.circular(ElRadius.control),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: AppFont.inter(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: colors.text,
            ),
          ),
        ),
      ),
    );
  }
}

// ===========================================================================
// Chapters sheet (table of contents)
// ===========================================================================

class _ChaptersSheet extends StatelessWidget {
  final String bookTitle;
  final List<Chapter> chapters;
  final int currentChapterId;
  final _ReaderColors colors;
  final bool dark;

  const _ChaptersSheet({
    required this.bookTitle,
    required this.chapters,
    required this.currentChapterId,
    required this.colors,
    required this.dark,
  });

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final sheetBg = dark ? colors.bg.withValues(alpha: 0.98) : colors.bg;
    final divider = colors.text.withValues(alpha: 0.08);

    return Container(
      constraints: BoxConstraints(maxHeight: mq.size.height * 0.78),
      decoration: BoxDecoration(
        color: sheetBg,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(ElRadius.sheet),
        ),
        border: Border(top: BorderSide(color: divider)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          // Drag handle
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: colors.text.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Chapters',
                        style: AppFont.inter(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: colors.text,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${chapters.length} chapters',
                        style: AppFont.inter(
                          fontSize: 12,
                          color: colors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(Icons.close_rounded, color: colors.muted),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Divider(height: 1, color: divider),

          // List
          Flexible(
            child: ListView.builder(
              padding: EdgeInsets.fromLTRB(8, 8, 8, mq.padding.bottom + 16),
              itemCount: chapters.length,
              itemBuilder: (context, i) {
                final ch = chapters[i];
                final selected = ch.id == currentChapterId;
                return _ChapterTile(
                  chapter: ch,
                  selected: selected,
                  colors: colors,
                  onTap: () => Navigator.of(context).pop(ch.id),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ChapterTile extends StatelessWidget {
  final Chapter chapter;
  final bool selected;
  final _ReaderColors colors;
  final VoidCallback onTap;

  const _ChapterTile({
    required this.chapter,
    required this.selected,
    required this.colors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(ElRadius.control),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: selected
                ? ElTheme.primary.withValues(alpha: 0.10)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(ElRadius.control),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 36,
                child: Text(
                  '${chapter.id}',
                  style: AppFont.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: selected ? ElTheme.primary : colors.muted,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  chapter.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppFont.inter(
                    fontSize: 14,
                    fontWeight:
                        selected ? FontWeight.w600 : FontWeight.w500,
                    color: selected ? ElTheme.primary : colors.text,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (selected)
                Icon(Icons.menu_book_rounded,
                    size: 16, color: ElTheme.primary)
              else if (!chapter.free)
                Icon(Icons.lock_rounded,
                    size: 14, color: colors.muted.withValues(alpha: 0.7)),
            ],
          ),
        ),
      ),
    );
  }
}
