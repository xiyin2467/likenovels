import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:likenovel/app/fonts.dart';

import 'package:likenovel/app/theme.dart';
import 'package:likenovel/app/providers.dart';
import 'package:likenovel/core/mock/mock_data.dart';

class GuideScreen extends ConsumerStatefulWidget {
  final VoidCallback onBack;
  final VoidCallback onContinue;

  const GuideScreen({
    super.key,
    required this.onBack,
    required this.onContinue,
  });

  @override
  ConsumerState<GuideScreen> createState() => _GuideScreenState();
}

class _GuideScreenState extends ConsumerState<GuideScreen> {
  final _selected = <String>{};

  void _finish() {
    ref.read(preferencesProvider.notifier).setAll(_selected);
    widget.onContinue();
  }

  @override
  Widget build(BuildContext context) {
    final count = _selected.length;
    final hasSelection = count > 0;
    final progress = count / kTasteTags.length;
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: ElTheme.bg,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            // ── Scrollable content ──
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Row(
                    children: [
                      Material(
                        color: ElTheme.surface2,
                        shape: const CircleBorder(),
                        clipBehavior: Clip.hardEdge,
                        child: InkWell(
                          onTap: widget.onBack,
                          child: const SizedBox(
                            width: 40,
                            height: 40,
                            child: Icon(
                              Icons.arrow_back_rounded,
                              size: 20,
                              color: ElTheme.ink,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: TweenAnimationBuilder<double>(
                            tween: Tween(end: progress),
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            builder: (_, value, __) => LinearProgressIndicator(
                              value: value,
                              minHeight: 6,
                              backgroundColor: ElTheme.surface3,
                              valueColor: AlwaysStoppedAnimation(
                                hasSelection
                                    ? ElTheme.primary
                                    : ElTheme.line,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 56),
                    ],
                  ),
                ),

                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
                  child: Column(
                    children: [
                      Text(
                        'What do you love?',
                        style: AppFont.newsreader(
                          fontSize: 26,
                          fontWeight: FontWeight.w600,
                          color: ElTheme.ink,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Pick a few tropes so we can personalise your '
                        'feed. You can always change these later.',
                        textAlign: TextAlign.center,
                        style: AppFont.inter(
                          fontSize: 14,
                          color: ElTheme.muted,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),

                // Tags
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      24,
                      20,
                      24,
                      80 + bottomPad,
                    ),
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: kTasteTags.map(_buildChip).toList(),
                    ),
                  ),
                ),
              ],
            ),

            // ── Bottom sticky CTA ──
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    stops: const [0.0, 0.55, 1.0],
                    colors: [
                      ElTheme.bg,
                      ElTheme.bg,
                      ElTheme.bg.withValues(alpha: 0),
                    ],
                  ),
                ),
                padding: EdgeInsets.fromLTRB(24, 24, 24, 16 + bottomPad),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _finish,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          hasSelection ? ElTheme.primary : ElTheme.surface3,
                      foregroundColor:
                          hasSelection ? ElTheme.onPrimary : ElTheme.muted,
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Text(
                        hasSelection
                            ? 'Continue ($count selected)'
                            : 'Skip for now',
                        key: ValueKey(hasSelection ? 'c$count' : 'skip'),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String tag) {
    final on = _selected.contains(tag);
    return GestureDetector(
      onTap: () => setState(() {
        on ? _selected.remove(tag) : _selected.add(tag);
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: on ? ElTheme.primary : ElTheme.surface,
          borderRadius: ElRadius.controlR,
          border: Border.all(
            color: on ? ElTheme.primary : ElTheme.line,
          ),
        ),
        child: Text(
          tag,
          style: AppFont.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: on ? ElTheme.onPrimary : ElTheme.ink,
          ),
        ),
      ),
    );
  }
}
