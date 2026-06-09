import 'package:flutter/material.dart';
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
  final Function(Book) onPaywall;
  final int coins;

  const ReaderScreen({
    super.key,
    required this.book,
    required this.chapterId,
    required this.onBack,
    required this.onPaywall,
    required this.coins,
  });

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {
  ReaderTheme _theme = ReaderTheme.paper;
  int _fontSizeIdx = 1;
  bool _showChrome = false;
  bool _showSettings = false;
  PageTurnMode _pageMode = PageTurnMode.scroll;

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

  @override
  void initState() {
    super.initState();
    final raw = kChapterSampleText.split('\n\n');
    _paragraphs = [...raw, ...raw];
    _bodyText = _paragraphs.join('\n\n');
    _chapters = getChapters(widget.book.id);
    _chapterId = widget.chapterId;
    _applyChapter(_chapterId);
  }

  @override
  void dispose() {
    _pageController.dispose();
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
      setState(() => _applyChapter(selected));
      if (_pageController.hasClients) _pageController.jumpToPage(0);
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

        return PageView.builder(
          controller: _pageController,
          itemCount: total,
          itemBuilder: (context, index) {
            final isPaywall = index == pages.length;
            Widget content = Padding(
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
            if (_pageMode == PageTurnMode.simulation) {
              content = _curlWrap(index, content);
            }
            return content;
          },
        );
      },
    );
  }

  /// 仿真书页：根据 PageView 偏移对页面施加 Y 轴 3D 旋转，营造翻书质感。
  Widget _curlWrap(int index, Widget child) {
    return AnimatedBuilder(
      animation: _pageController,
      builder: (context, inner) {
        double page = index.toDouble();
        if (_pageController.hasClients &&
            _pageController.position.haveDimensions) {
          page = _pageController.page ?? index.toDouble();
        }
        final delta = (index - page).clamp(-1.0, 1.0);
        final transform = Matrix4.identity()
          ..setEntry(3, 2, 0.0012)
          ..rotateY(-delta * 1.05);
        return Transform(
          alignment:
              delta >= 0 ? Alignment.centerLeft : Alignment.centerRight,
          transform: transform,
          child: inner,
        );
      },
      child: child,
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
    final nextChapter = _chapterId + 1;
    final cardBg = _dark
        ? _colors.text.withValues(alpha: 0.06)
        : _colors.text.withValues(alpha: 0.04);
    final borderColor = _dark
        ? _colors.text.withValues(alpha: 0.10)
        : _colors.text.withValues(alpha: 0.08);

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
              color: ElTheme.primary.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.lock_rounded,
              size: 20,
              color: ElTheme.primary,
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
            'Unlock to keep reading',
            style: AppFont.inter(
              fontSize: 13,
              color: _colors.muted,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => widget.onPaywall(widget.book),
              style: ElevatedButton.styleFrom(
                backgroundColor: ElTheme.primary,
                foregroundColor: ElTheme.onPrimary,
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
                  Icon(Icons.lock_open_rounded, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Unlock · ${widget.coins} coins',
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
    final nextChapter = _chapterId + 1;

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
                  ],
                ),
                const SizedBox(height: 12),

                // Unlock button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => widget.onPaywall(widget.book),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ElTheme.primary,
                      foregroundColor: ElTheme.onPrimary,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(ElRadius.control),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Unlock chapter $nextChapter · ${widget.coins} coins',
                      style: AppFont.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
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
