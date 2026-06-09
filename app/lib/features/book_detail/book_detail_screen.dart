import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:likenovel/app/fonts.dart';

import 'package:likenovel/app/theme.dart';
import 'package:likenovel/core/models/book.dart';
import 'package:likenovel/core/mock/mock_data.dart';
import 'package:likenovel/shared/widgets/book_cover.dart';

const _genreGradients = <Genre, List<Color>>{
  Genre.werewolf: [Color(0xFF0C1425), Color(0xFF1B2D50), ElTheme.bg],
  Genre.ceo: [Color(0xFF141414), Color(0xFF282828), ElTheme.bg],
  Genre.reborn: [Color(0xFF5C1A18), Color(0xFFA83232), ElTheme.bg],
  Genre.vampire: [Color(0xFF07000A), Color(0xFF160010), ElTheme.bg],
  Genre.romantasy: [Color(0xFF170826), Color(0xFF2B1252), ElTheme.bg],
  Genre.modern: [Color(0xFF250C15), Color(0xFF3C1525), ElTheme.bg],
};

class BookDetailScreen extends ConsumerStatefulWidget {
  final Book book;
  final VoidCallback onBack;
  final void Function(Book book, int? chapterId) onRead;

  const BookDetailScreen({
    super.key,
    required this.book,
    required this.onBack,
    required this.onRead,
  });

  @override
  ConsumerState<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends ConsumerState<BookDetailScreen> {
  bool _favorited = false;
  bool _chaptersExpanded = false;
  late final List<Chapter> _chapters;

  @override
  void initState() {
    super.initState();
    _chapters = getChapters(widget.book.id);
  }

  @override
  Widget build(BuildContext context) {
    final book = widget.book;
    final gradientColors = _genreGradients[book.genre]!;

    return Scaffold(
      backgroundColor: ElTheme.bg,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildHero(book, gradientColors)),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  ElSpacing.s20,
                  ElSpacing.s24,
                  ElSpacing.s20,
                  120,
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildTitle(book),
                    const SizedBox(height: 4),
                    _buildAuthor(book),
                    const SizedBox(height: ElSpacing.s16),
                    _buildStats(book),
                    const SizedBox(height: ElSpacing.s16),
                    _buildTropes(book),
                    const SizedBox(height: ElSpacing.s20),
                    _buildBlurb(book),
                    const SizedBox(height: ElSpacing.s24),
                    _buildChaptersHeader(),
                    const SizedBox(height: ElSpacing.s12),
                    _buildChapterList(),
                  ]),
                ),
              ),
            ],
          ),
          _buildBackButton(),
          _buildBottomBar(book),
        ],
      ),
    );
  }

  Widget _buildHero(Book book, List<Color> colors) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 80, bottom: 32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: colors,
        ),
      ),
      child: Center(
        child: HeroCover(
          genre: book.genre,
          title: book.title,
          author: book.author,
          badge: book.badge,
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 8,
      left: 12,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: GestureDetector(
            onTap: widget.onBack,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.85),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                size: 20,
                color: ElTheme.ink,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitle(Book book) {
    return Text(
      book.title,
      style: AppFont.newsreader(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: ElTheme.ink,
        height: 1.25,
      ),
    );
  }

  Widget _buildAuthor(Book book) {
    return Text(
      book.author,
      style: AppFont.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: ElTheme.muted,
      ),
    );
  }

  Widget _buildStats(Book book) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _StatPill(
          icon: Icons.star_rounded,
          iconColor: ElTheme.gold,
          label: book.rating.toString(),
        ),
        _StatPill(label: '${book.reads} reads'),
        _StatPill(label: '${book.chapters} ch'),
        _StatusPill(status: book.status),
      ],
    );
  }

  Widget _buildTropes(Book book) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: book.tropes.map((trope) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: ElTheme.surface2,
            borderRadius: BorderRadius.circular(99),
          ),
          child: Text(
            trope,
            style: AppFont.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: ElTheme.ink,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBlurb(Book book) {
    return Text(
      book.blurb,
      style: AppFont.newsreader(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: ElTheme.ink,
        height: 1.6,
      ),
    );
  }

  Widget _buildChaptersHeader() {
    return Row(
      children: [
        Text(
          'Chapters',
          style: AppFont.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: ElTheme.ink,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '${_chapters.length}',
          style: AppFont.inter(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: ElTheme.muted,
          ),
        ),
      ],
    );
  }

  Widget _buildChapterList() {
    final visibleCount =
        _chaptersExpanded ? _chapters.length : _chapters.length.clamp(0, 8);
    final showExpand = _chapters.length > 8 && !_chaptersExpanded;

    return Column(
      children: [
        ...List.generate(visibleCount, (i) {
          final chapter = _chapters[i];
          return _ChapterRow(
            chapter: chapter,
            onTap: () => widget.onRead(widget.book, chapter.id),
          );
        }),
        if (showExpand)
          Padding(
            padding: const EdgeInsets.only(top: ElSpacing.s12),
            child: GestureDetector(
              onTap: () => setState(() => _chaptersExpanded = true),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  border: Border.all(color: ElTheme.line),
                  borderRadius: ElRadius.controlR,
                ),
                child: Center(
                  child: Text(
                    'All ${_chapters.length} chapters',
                    style: AppFont.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: ElTheme.primary,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildBottomBar(Book book) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              ElTheme.bg.withValues(alpha: 0),
              ElTheme.bg.withValues(alpha: 0.85),
              ElTheme.bg,
            ],
            stops: const [0.0, 0.35, 0.6],
          ),
        ),
        padding: EdgeInsets.fromLTRB(
          ElSpacing.s20,
          28,
          ElSpacing.s20,
          MediaQuery.of(context).padding.bottom + 16,
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => setState(() => _favorited = !_favorited),
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: ElTheme.surface,
                  borderRadius: ElRadius.controlR,
                  border: Border.all(color: ElTheme.line),
                ),
                child: Icon(
                  _favorited ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  color: _favorited ? ElTheme.primary : ElTheme.muted,
                  size: 22,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: () => widget.onRead(book, null),
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    color: ElTheme.primary,
                    borderRadius: ElRadius.controlR,
                  ),
                  child: Center(
                    child: Text(
                      'Read chapter 1 free',
                      style: AppFont.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: ElTheme.onPrimary,
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
}

class _StatPill extends StatelessWidget {
  final IconData? icon;
  final Color? iconColor;
  final String label;

  const _StatPill({this.icon, this.iconColor, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: ElTheme.surface2,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: iconColor ?? ElTheme.muted),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: AppFont.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: ElTheme.ink,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final BookStatus status;

  const _StatusPill({required this.status});

  @override
  Widget build(BuildContext context) {
    final isComplete = status == BookStatus.complete;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isComplete
            ? ElTheme.success.withValues(alpha: 0.1)
            : ElTheme.primarySoft,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        isComplete ? 'Complete' : 'Ongoing',
        style: AppFont.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: isComplete ? ElTheme.success : ElTheme.primary,
        ),
      ),
    );
  }
}

class _ChapterRow extends StatelessWidget {
  final Chapter chapter;
  final VoidCallback onTap;

  const _ChapterRow({required this.chapter, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ch. ${chapter.id}',
                    style: AppFont.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: ElTheme.muted,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    chapter.title,
                    style: AppFont.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: ElTheme.ink,
                    ),
                  ),
                ],
              ),
            ),
            if (chapter.free)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: ElTheme.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  'Free',
                  style: AppFont.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: ElTheme.success,
                  ),
                ),
              )
            else
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.monetization_on_rounded,
                    size: 14,
                    color: ElTheme.gold,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    '${chapter.coins}',
                    style: AppFont.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: ElTheme.gold,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
