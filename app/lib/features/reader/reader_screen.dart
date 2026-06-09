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

  _ReaderColors get _colors => _themeColors[_theme]!;
  double get _fontSize => _fontSizes[_fontSizeIdx];
  bool get _dark => _isDarkTheme(_theme);

  late final List<String> _paragraphs;
  late final List<Chapter> _chapters;
  late final Chapter _chapter;
  late final double _progress;

  @override
  void initState() {
    super.initState();
    final raw = kChapterSampleText.split('\n\n');
    _paragraphs = [...raw, ...raw];
    _chapters = getChapters(widget.book.id);
    _chapter = _chapters.firstWhere(
      (c) => c.id == widget.chapterId,
      orElse: () => _chapters.first,
    );
    _progress = (widget.chapterId / widget.book.chapters).clamp(0.0, 1.0);
  }

  void _toggleChrome() => setState(() {
        _showChrome = !_showChrome;
        if (!_showChrome) _showSettings = false;
      });

  void _openSettings() => setState(() => _showSettings = true);
  void _closeSettings() => setState(() => _showSettings = false);

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
              child: _buildContent(topPad, bottomPad),
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
          'CHAPTER ${widget.chapterId}',
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
  // Paywall card
  // =========================================================================

  Widget _buildPaywallCard() {
    final nextChapter = widget.chapterId + 1;
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
                    onPressed: () {},
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
    final nextChapter = widget.chapterId + 1;

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
              bottomPad: bottomPad,
              colors: _colors,
              dark: _dark,
              onThemeChanged: (t) => setState(() => _theme = t),
              onFontSizeChanged: (i) => setState(() => _fontSizeIdx = i),
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
  final double bottomPad;
  final _ReaderColors colors;
  final bool dark;
  final ValueChanged<ReaderTheme> onThemeChanged;
  final ValueChanged<int> onFontSizeChanged;
  final VoidCallback onClose;

  const _SettingsSheet({
    required this.theme,
    required this.fontSizeIdx,
    required this.bottomPad,
    required this.colors,
    required this.dark,
    required this.onThemeChanged,
    required this.onFontSizeChanged,
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
