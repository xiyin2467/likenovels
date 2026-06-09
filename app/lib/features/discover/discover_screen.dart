import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:likenovel/app/fonts.dart';
import 'package:shimmer/shimmer.dart';

import 'package:likenovel/app/theme.dart';
import 'package:likenovel/app/providers.dart';
import 'package:likenovel/core/models/book.dart';
import 'package:likenovel/core/mock/mock_data.dart';
import 'package:likenovel/shared/widgets/book_cover.dart';

class DiscoverScreen extends ConsumerStatefulWidget {
  final ValueChanged<Book> onBook;
  final VoidCallback onWallet;
  final VoidCallback onMessages;
  final VoidCallback onSearch;

  const DiscoverScreen({
    super.key,
    required this.onBook,
    required this.onWallet,
    required this.onMessages,
    required this.onSearch,
  });

  @override
  ConsumerState<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends ConsumerState<DiscoverScreen> {
  bool _loading = true;
  int _selectedGenre = 0;

  @override
  void initState() {
    super.initState();
    Timer(const Duration(milliseconds: 900), () {
      if (mounted) setState(() => _loading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final coins = ref.watch(coinsProvider);

    return Scaffold(
      backgroundColor: ElTheme.bg,
      body: SafeArea(
        bottom: false,
        child: _loading ? _buildSkeleton() : _buildContent(coins),
      ),
    );
  }

  Widget _buildContent(int coins) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _TopBar(coins: coins, onWallet: widget.onWallet, onMessages: widget.onMessages)),
        SliverToBoxAdapter(child: _SearchBar(onTap: widget.onSearch)),
        SliverToBoxAdapter(child: _GenreChips(selected: _selectedGenre, onChanged: (i) => setState(() => _selectedGenre = i))),
        SliverToBoxAdapter(child: _HeroCarousel(onBook: widget.onBook, genre: kGenreTabValues[_selectedGenre])),
        SliverToBoxAdapter(child: _SectionHeader(title: 'Top charts', onMore: () {})),
        SliverToBoxAdapter(child: _TopChartsRow(onBook: widget.onBook)),
        SliverToBoxAdapter(child: _SectionHeader(title: 'New & rising', onMore: () {})),
        SliverToBoxAdapter(child: _NewRisingRow(onBook: widget.onBook)),
        SliverToBoxAdapter(child: _SectionHeader(title: 'For you', onMore: () {})),
        _ForYouGrid(onBook: widget.onBook),
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Skeleton / shimmer
  // ---------------------------------------------------------------------------
  Widget _buildSkeleton() {
    return Shimmer.fromColors(
      baseColor: ElTheme.surface2,
      highlightColor: ElTheme.surface,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: ElSpacing.s16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: ElSpacing.s16),
            // top bar skeleton
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _skeletonBox(60, 12),
                    const SizedBox(height: 6),
                    _skeletonBox(110, 22),
                  ],
                ),
                Row(children: [_skeletonBox(72, 32, radius: 99), const SizedBox(width: 8), _skeletonCircle(36)]),
              ],
            ),
            const SizedBox(height: ElSpacing.s16),
            // search skeleton
            _skeletonBox(double.infinity, 48, radius: ElRadius.control),
            const SizedBox(height: ElSpacing.s16),
            // genre chips skeleton
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              child: Row(children: List.generate(4, (i) => Padding(padding: const EdgeInsets.only(right: 8), child: _skeletonBox(64, 32, radius: 99)))),
            ),
            const SizedBox(height: ElSpacing.s24),
            // hero card skeleton
            _skeletonBox(288, 200, radius: ElRadius.card),
            const SizedBox(height: ElSpacing.s24),
            // section skeleton
            _skeletonBox(100, 18),
            const SizedBox(height: ElSpacing.s12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              child: Row(children: List.generate(3, (i) => Padding(padding: const EdgeInsets.only(right: 12), child: _skeletonBox(140, 196, radius: ElRadius.control)))),
            ),
            const SizedBox(height: ElSpacing.s24),
            _skeletonBox(100, 18),
            const SizedBox(height: ElSpacing.s12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              child: Row(children: List.generate(3, (i) => Padding(padding: const EdgeInsets.only(right: 12), child: _skeletonBox(108, 152, radius: ElRadius.control)))),
            ),
          ],
        ),
      ),
    );
  }

  Widget _skeletonBox(double w, double h, {double radius = 8}) {
    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(radius)),
    );
  }

  Widget _skeletonCircle(double d) {
    return Container(width: d, height: d, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle));
  }
}

// =============================================================================
// Top bar
// =============================================================================
class _TopBar extends StatelessWidget {
  final int coins;
  final VoidCallback onWallet;
  final VoidCallback onMessages;

  const _TopBar({required this.coins, required this.onWallet, required this.onMessages});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(ElSpacing.s16, ElSpacing.s12, ElSpacing.s16, ElSpacing.s4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Discover',
                  style: AppFont.inter(fontSize: 12, fontWeight: FontWeight.w500, color: ElTheme.muted, letterSpacing: 0.6),
                ),
                const SizedBox(height: 2),
                Text(
                  'likenovel',
                  style: AppFont.newsreader(fontSize: 26, fontWeight: FontWeight.w700, color: ElTheme.ink, height: 1.15),
                ),
              ],
            ),
          ),
          _CoinsPill(coins: coins, onTap: onWallet),
          const SizedBox(width: 8),
          _NotificationBell(onTap: onMessages),
        ],
      ),
    );
  }
}

class _CoinsPill extends StatelessWidget {
  final int coins;
  final VoidCallback onTap;

  const _CoinsPill({required this.coins, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: ElTheme.goldSoft,
          borderRadius: BorderRadius.circular(99),
          border: Border.all(color: ElTheme.gold.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.monetization_on_rounded, size: 18, color: ElTheme.gold),
            const SizedBox(width: 4),
            Text(
              '$coins',
              style: AppFont.inter(fontSize: 13, fontWeight: FontWeight.w600, color: ElTheme.ink),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationBell extends StatelessWidget {
  final VoidCallback onTap;

  const _NotificationBell({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 40,
        height: 40,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: ElTheme.surface,
                shape: BoxShape.circle,
                border: Border.all(color: ElTheme.line, width: 0.5),
              ),
              child: const Icon(Icons.notifications_outlined, size: 20, color: ElTheme.ink),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: ElTheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// Search bar
// =============================================================================
class _SearchBar extends StatelessWidget {
  final VoidCallback onTap;

  const _SearchBar({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(ElSpacing.s16, ElSpacing.s8, ElSpacing.s16, ElSpacing.s4),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: ElTheme.surface2,
            borderRadius: ElRadius.controlR,
          ),
          child: Row(
            children: [
              const Icon(Icons.search_rounded, size: 20, color: ElTheme.faint),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Search titles, authors, tropes',
                  style: AppFont.inter(fontSize: 14, color: ElTheme.faint),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// Genre chips
// =============================================================================
class _GenreChips extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onChanged;

  const _GenreChips({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: ElSpacing.s16, vertical: ElSpacing.s8),
        itemCount: kGenreTabs.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final isSelected = i == selected;
          return GestureDetector(
            onTap: () => onChanged(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
              decoration: BoxDecoration(
                color: isSelected ? ElTheme.primarySoft : ElTheme.surface,
                borderRadius: BorderRadius.circular(99),
                border: Border.all(color: isSelected ? ElTheme.primary.withValues(alpha: 0.25) : ElTheme.line),
              ),
              child: Text(
                kGenreTabs[i],
                style: AppFont.inter(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? ElTheme.primaryInk : ElTheme.muted,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// =============================================================================
// Hero carousel
// =============================================================================
class _HeroCarousel extends StatelessWidget {
  final ValueChanged<Book> onBook;
  final Genre genre;

  const _HeroCarousel({required this.onBook, required this.genre});

  @override
  Widget build(BuildContext context) {
    // 按选中分类筛选；该题材暂无书时回退到全部，避免空白。
    final heroBooks = kBooks.where((b) => b.genre == genre).toList();
    if (heroBooks.isEmpty) heroBooks.addAll(kBooks.take(4));
    return SizedBox(
      height: 220,
      child: ListView.separated(
        key: ValueKey('hero_${genre.name}'),
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: ElSpacing.s16, vertical: ElSpacing.s4),
        itemCount: heroBooks.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (_, i) => _HeroCard(book: heroBooks[i], onTap: () => onBook(heroBooks[i])),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  final Book book;
  final VoidCallback onTap;

  const _HeroCard({required this.book, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 288,
        decoration: BoxDecoration(
          color: ElTheme.surface,
          borderRadius: ElRadius.cardR,
          border: Border.all(color: ElTheme.line, width: 0.5),
        ),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: HeroCover(genre: book.genre, title: book.title, author: book.author, badge: book.badge),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 14, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Trope tags
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: book.tropes.take(2).map((t) => _TropeTag(label: t)).toList(),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      book.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppFont.newsreader(fontSize: 16, fontWeight: FontWeight.w600, color: ElTheme.ink, height: 1.2),
                    ),
                    const SizedBox(height: 4),
                    Expanded(
                      child: Text(
                        book.blurb,
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                        style: AppFont.inter(fontSize: 11.5, color: ElTheme.muted, height: 1.4),
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Stats row
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Row(
                        children: [
                          const Icon(Icons.star_rounded, size: 14, color: ElTheme.gold),
                          const SizedBox(width: 2),
                          Text(book.rating.toString(), style: AppFont.inter(fontSize: 11, fontWeight: FontWeight.w600, color: ElTheme.ink)),
                          const SizedBox(width: 10),
                          Icon(Icons.visibility_outlined, size: 13, color: ElTheme.faint),
                          const SizedBox(width: 2),
                          Text(book.reads, style: AppFont.inter(fontSize: 11, color: ElTheme.faint)),
                          const SizedBox(width: 10),
                          Icon(Icons.menu_book_rounded, size: 13, color: ElTheme.faint),
                          const SizedBox(width: 2),
                          Text('${book.chapters} ch', style: AppFont.inter(fontSize: 11, color: ElTheme.faint)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TropeTag extends StatelessWidget {
  final String label;

  const _TropeTag({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: ElTheme.primarySoft,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        label,
        style: AppFont.inter(fontSize: 10, fontWeight: FontWeight.w500, color: ElTheme.primaryInk),
      ),
    );
  }
}

// =============================================================================
// Section header
// =============================================================================
class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onMore;

  const _SectionHeader({required this.title, required this.onMore});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(ElSpacing.s16, ElSpacing.s20, ElSpacing.s16, ElSpacing.s8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: AppFont.newsreader(fontSize: 20, fontWeight: FontWeight.w600, color: ElTheme.ink),
          ),
          GestureDetector(
            onTap: onMore,
            child: Text(
              'More >',
              style: AppFont.inter(fontSize: 13, fontWeight: FontWeight.w500, color: ElTheme.primaryInk),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Top charts row
// =============================================================================
class _TopChartsRow extends StatelessWidget {
  final ValueChanged<Book> onBook;

  const _TopChartsRow({required this.onBook});

  @override
  Widget build(BuildContext context) {
    final ranked = kBooks.where((b) => b.rank != null).toList()..sort((a, b) => a.rank!.compareTo(b.rank!));

    return SizedBox(
      height: 230,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: ElSpacing.s16),
        itemCount: ranked.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (_, i) {
          final book = ranked[i];
          return GestureDetector(
            onTap: () => onBook(book),
            child: SizedBox(
              width: 140,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      BookCover(genre: book.genre, title: book.title, author: book.author, badge: book.badge, size: CoverSize.lg),
                      Positioned(
                        left: -6,
                        bottom: -6,
                        child: _RankBadge(rank: book.rank!),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _RankBadge extends StatelessWidget {
  final int rank;

  const _RankBadge({required this.rank});

  @override
  Widget build(BuildContext context) {
    final isFirst = rank == 1;
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isFirst ? ElTheme.gold : ElTheme.surface,
        border: isFirst ? null : Border.all(color: ElTheme.line),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        '$rank',
        style: AppFont.inter(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: isFirst ? const Color(0xFF1A1200) : ElTheme.ink,
        ),
      ),
    );
  }
}

// =============================================================================
// New & rising row
// =============================================================================
class _NewRisingRow extends StatelessWidget {
  final ValueChanged<Book> onBook;

  const _NewRisingRow({required this.onBook});

  @override
  Widget build(BuildContext context) {
    final books = kBooks.reversed.take(5).toList();
    return SizedBox(
      height: 192,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: ElSpacing.s16),
        itemCount: books.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) {
          final book = books[i];
          return GestureDetector(
            onTap: () => onBook(book),
            child: SizedBox(
              width: 108,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BookCover(genre: book.genre, title: book.title, author: book.author, badge: book.badge, size: CoverSize.md),
                  const SizedBox(height: 6),
                  Text(
                    book.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppFont.newsreader(fontSize: 12, fontWeight: FontWeight.w600, color: ElTheme.ink),
                  ),
                  Text(
                    book.author,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppFont.inter(fontSize: 10, color: ElTheme.faint),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// =============================================================================
// For-you grid (瀑布流，放在发现页最底部)
// =============================================================================
class _ForYouGrid extends StatelessWidget {
  final ValueChanged<Book> onBook;

  const _ForYouGrid({required this.onBook});

  @override
  Widget build(BuildContext context) {
    final books = kBooks;
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: ElSpacing.s16),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 14,
          childAspectRatio: 0.52,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, i) {
            final book = books[i];
            return GestureDetector(
              onTap: () => onBook(book),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: FluidCover(genre: book.genre, title: book.title, author: book.author, badge: book.badge),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    book.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppFont.newsreader(fontSize: 14, fontWeight: FontWeight.w600, color: ElTheme.ink),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, size: 13, color: ElTheme.gold),
                      const SizedBox(width: 3),
                      Text(
                        book.rating.toString(),
                        style: AppFont.inter(fontSize: 12, fontWeight: FontWeight.w500, color: ElTheme.ink),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        book.reads,
                        style: AppFont.inter(fontSize: 11, color: ElTheme.faint),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
          childCount: books.length,
        ),
      ),
    );
  }
}

