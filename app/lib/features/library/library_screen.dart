import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:likenovel/app/fonts.dart';

import 'package:likenovel/app/theme.dart';
import 'package:likenovel/app/providers.dart';
import 'package:likenovel/core/models/book.dart';
import 'package:likenovel/core/mock/mock_data.dart';
import 'package:likenovel/shared/widgets/book_cover.dart';

class LibraryScreen extends ConsumerStatefulWidget {
  final Function(Book) onBook;
  final Function(Book) onRead;

  const LibraryScreen({
    super.key,
    required this.onBook,
    required this.onRead,
  });

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<LibraryBook> get _readingBooks =>
      kLibraryBooks.where((b) => b.progress < 100).toList();

  /// 已解锁：预置书目 + 本次会话内消费解锁过章节的书（联动解锁账本）。
  List<LibraryBook> get _unlockedBooks {
    final unlockedMap = ref.watch(unlockedChaptersProvider);
    final extra = kBooks
        .where((b) =>
            unlockedMap.containsKey(b.id) &&
            !kLibraryBooks.any((lb) => lb.book.id == b.id))
        .map((b) {
      final chapters = unlockedMap[b.id]!;
      final latest = chapters.reduce((a, c) => a > c ? a : c);
      return LibraryBook(
        book: b,
        progress: (latest / b.chapters * 100).clamp(0, 99),
        currentChapter: latest,
      );
    });
    return [...kLibraryBooks, ...extra];
  }

  List<LibraryBook> get _finishedBooks =>
      kLibraryBooks.where((b) => b.progress >= 100).toList();

  List<Book> get _favoriteBooks {
    final ids = ref.watch(favoritesProvider);
    return kBooks.where((b) => ids.contains(b.id)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ElTheme.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTopBar(),
            const SizedBox(height: ElSpacing.s16),
            _buildTabBar(),
            Expanded(child: _buildTabContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        ElSpacing.s20,
        ElSpacing.s16,
        ElSpacing.s20,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Library',
                      style: AppFont.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: ElTheme.muted,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'My books',
                      style: AppFont.newsreader(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        color: ElTheme.ink,
                      ),
                    ),
                  ],
                ),
              ),
              _SyncedBadge(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: ElSpacing.s20),
      child: Container(
        height: 38,
        decoration: BoxDecoration(
          color: ElTheme.surface2,
          borderRadius: ElRadius.controlR,
        ),
        child: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(
            color: ElTheme.surface,
            borderRadius: ElRadius.controlR,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          dividerHeight: 0,
          labelColor: ElTheme.ink,
          unselectedLabelColor: ElTheme.muted,
          labelStyle: AppFont.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: AppFont.inter(
            fontSize: 13,
            fontWeight: FontWeight.w400,
          ),
          tabs: const [
            Tab(text: 'Reading'),
            Tab(text: 'Favorites'),
            Tab(text: 'Unlocked'),
            Tab(text: 'Finished'),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildReadingTab(),
        _buildFavoritesTab(),
        _buildBookList(_unlockedBooks),
        _buildFinishedTab(),
      ],
    );
  }

  Widget _buildFavoritesTab() {
    final books = _favoriteBooks;
    if (books.isEmpty) {
      return _buildEmptyState(
        icon: Icons.favorite_border_rounded,
        title: 'No favorites yet',
        description: 'Tap the heart on any book to save it here.',
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(ElSpacing.s20),
      itemCount: books.length,
      separatorBuilder: (_, _) => const SizedBox(height: ElSpacing.s12),
      itemBuilder: (_, i) => _buildFavoriteRow(books[i]),
    );
  }

  Widget _buildFavoriteRow(Book book) {
    return GestureDetector(
      onTap: () => widget.onBook(book),
      child: Container(
        padding: const EdgeInsets.all(ElSpacing.s12),
        decoration: BoxDecoration(
          color: ElTheme.surface,
          borderRadius: ElRadius.controlR,
          border: Border.all(color: ElTheme.line, width: 0.5),
        ),
        child: Row(
          children: [
            BookCover(
              genre: book.genre,
              title: book.title,
              author: book.author,
              size: CoverSize.sm,
            ),
            const SizedBox(width: ElSpacing.s12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppFont.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: ElTheme.ink,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    book.author,
                    style: AppFont.inter(fontSize: 12, color: ElTheme.muted),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded,
                          size: 13, color: ElTheme.gold),
                      const SizedBox(width: 3),
                      Text('${book.rating}',
                          style: AppFont.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: ElTheme.ink)),
                      const SizedBox(width: 10),
                      Text('${book.chapters} ch',
                          style:
                              AppFont.inter(fontSize: 11, color: ElTheme.faint)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: ElSpacing.s8),
            GestureDetector(
              onTap: () => ref.read(favoritesProvider.notifier).toggle(book.id),
              behavior: HitTestBehavior.opaque,
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(Icons.favorite_rounded,
                    size: 20, color: ElTheme.primary),
              ),
            ),
            const SizedBox(width: ElSpacing.s8),
            SizedBox(
              height: 32,
              child: TextButton(
                onPressed: () => widget.onRead(book),
                style: TextButton.styleFrom(
                  backgroundColor: ElTheme.primary,
                  foregroundColor: ElTheme.onPrimary,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  textStyle: AppFont.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                child: const Text('Read'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReadingTab() {
    final books = _readingBooks;
    if (books.isEmpty) {
      return _buildEmptyState(
        icon: Icons.menu_book_rounded,
        title: 'No books yet',
        description: 'Start reading to see your progress here.',
      );
    }

    return ListView(
      padding: const EdgeInsets.all(ElSpacing.s20),
      children: [
        _buildContinueReadingCard(books.first),
        const SizedBox(height: ElSpacing.s20),
        if (books.length > 1) ...[
          Text(
            'In progress',
            style: AppFont.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: ElTheme.ink,
            ),
          ),
          const SizedBox(height: ElSpacing.s12),
          ...books.skip(1).map((b) => _buildBookRow(b)),
        ],
      ],
    );
  }

  Widget _buildFinishedTab() {
    final books = _finishedBooks;
    if (books.isEmpty) {
      return _buildEmptyState(
        icon: Icons.auto_stories_rounded,
        title: 'Nothing finished yet',
        description:
            'Complete a book and it will appear here. Keep reading!',
      );
    }
    return _buildBookList(books);
  }

  Widget _buildBookList(List<LibraryBook> books) {
    return ListView.separated(
      padding: const EdgeInsets.all(ElSpacing.s20),
      itemCount: books.length,
      separatorBuilder: (_, _) => const SizedBox(height: ElSpacing.s12),
      itemBuilder: (_, i) => _buildBookRow(books[i]),
    );
  }

  Widget _buildContinueReadingCard(LibraryBook item) {
    final book = item.book;
    // 中间区域点击进入详情；封面与右侧箭头点击直接进入阅读内容。
    return GestureDetector(
      onTap: () => widget.onBook(book),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(ElSpacing.s16),
        decoration: BoxDecoration(
          color: ElTheme.surface,
          borderRadius: ElRadius.cardR,
          border: Border.all(color: ElTheme.line, width: 0.5),
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => widget.onRead(book),
              behavior: HitTestBehavior.opaque,
              child: BookCover(
                genre: book.genre,
                title: book.title,
                author: book.author,
                badge: book.badge,
                size: CoverSize.md,
              ),
            ),
            const SizedBox(width: ElSpacing.s16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Continue reading',
                    style: AppFont.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: ElTheme.primary,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    book.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppFont.newsreader(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: ElTheme.ink,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Chapter ${item.currentChapter} of ${book.chapters}',
                    style: AppFont.inter(
                      fontSize: 12,
                      color: ElTheme.muted,
                    ),
                  ),
                  const SizedBox(height: ElSpacing.s12),
                  _ProgressBar(progress: item.progress / 100),
                  const SizedBox(height: 4),
                  Text(
                    '${item.progress.toInt()}% complete',
                    style: AppFont.inter(
                      fontSize: 11,
                      color: ElTheme.faint,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: ElSpacing.s8),
            GestureDetector(
              onTap: () => widget.onRead(book),
              behavior: HitTestBehavior.opaque,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: ElTheme.primarySoft,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.chevron_right_rounded,
                  color: ElTheme.primary,
                  size: 22,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookRow(LibraryBook item) {
    final book = item.book;
    return GestureDetector(
      onTap: () => widget.onBook(book),
      child: Container(
        padding: const EdgeInsets.all(ElSpacing.s12),
        decoration: BoxDecoration(
          color: ElTheme.surface,
          borderRadius: ElRadius.controlR,
          border: Border.all(color: ElTheme.line, width: 0.5),
        ),
        child: Row(
          children: [
            BookCover(
              genre: book.genre,
              title: book.title,
              author: book.author,
              size: CoverSize.sm,
            ),
            const SizedBox(width: ElSpacing.s12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppFont.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: ElTheme.ink,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    book.author,
                    style: AppFont.inter(
                      fontSize: 12,
                      color: ElTheme.muted,
                    ),
                  ),
                  if (item.progress < 100) ...[
                    const SizedBox(height: 8),
                    _ProgressBar(progress: item.progress / 100),
                  ],
                ],
              ),
            ),
            const SizedBox(width: ElSpacing.s12),
            SizedBox(
              height: 32,
              child: TextButton(
                onPressed: () => widget.onRead(book),
                style: TextButton.styleFrom(
                  backgroundColor: ElTheme.primary,
                  foregroundColor: ElTheme.onPrimary,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  textStyle: AppFont.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                child: const Text('Read'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(ElSpacing.s24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: ElTheme.surface2,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 28, color: ElTheme.muted),
            ),
            const SizedBox(height: ElSpacing.s16),
            Text(
              title,
              style: AppFont.newsreader(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: ElTheme.ink,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              description,
              textAlign: TextAlign.center,
              style: AppFont.inter(
                fontSize: 13,
                color: ElTheme.muted,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SyncedBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: ElTheme.success.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: ElTheme.success,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            'Synced',
            style: AppFont.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: ElTheme.success,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final double progress;

  const _ProgressBar({required this.progress});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 4,
      decoration: BoxDecoration(
        color: ElTheme.surface2,
        borderRadius: BorderRadius.circular(2),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress.clamp(0.0, 1.0),
        child: Container(
          decoration: BoxDecoration(
            color: ElTheme.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }
}
