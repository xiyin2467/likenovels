import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:likenovel/app/fonts.dart';

import 'package:likenovel/app/theme.dart';
import 'package:likenovel/app/providers.dart';
import 'package:likenovel/core/models/book.dart';
import 'package:likenovel/core/mock/mock_data.dart';
import 'package:likenovel/shared/widgets/book_cover.dart';

const _kGenreLabels = <Genre, String>{
  Genre.werewolf: 'Werewolf',
  Genre.ceo: 'CEO & Billionaire',
  Genre.reborn: 'Reborn',
  Genre.vampire: 'Vampire',
  Genre.romantasy: 'Romantasy',
  Genre.modern: 'Modern',
};

/// 分类页：顶部题材筛选 + 书籍网格，点击进入详情。
class CategoryScreen extends ConsumerStatefulWidget {
  final ValueChanged<Book> onBook;

  const CategoryScreen({super.key, required this.onBook});

  @override
  ConsumerState<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends ConsumerState<CategoryScreen> {
  Genre? _selected; // null = 全部

  @override
  Widget build(BuildContext context) {
    final prefs = ref.watch(preferencesProvider);
    final filtered = _selected == null
        ? kBooks
        : kBooks.where((b) => b.genre == _selected).toList();
    // 全部视图按偏好排序；选定具体题材时保持原序。
    final books =
        _selected == null ? sortByPreference(filtered, prefs) : filtered;

    return Scaffold(
      backgroundColor: ElTheme.bg,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  ElSpacing.s20, ElSpacing.s16, ElSpacing.s20, ElSpacing.s8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Browse',
                    style: AppFont.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: ElTheme.muted,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Categories',
                    style: AppFont.newsreader(
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      color: ElTheme.ink,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding:
                    const EdgeInsets.symmetric(horizontal: ElSpacing.s16),
                children: [
                  _chip('All', _selected == null,
                      () => setState(() => _selected = null)),
                  for (final g in Genre.values)
                    _chip(_kGenreLabels[g] ?? g.name, _selected == g,
                        () => setState(() => _selected = g)),
                ],
              ),
            ),
            const SizedBox(height: ElSpacing.s12),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.fromLTRB(
                    ElSpacing.s16, 0, ElSpacing.s16, ElSpacing.s24),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 5 / 7,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 16,
                ),
                itemCount: books.length,
                itemBuilder: (_, i) {
                  final b = books[i];
                  return GestureDetector(
                    onTap: () => widget.onBook(b),
                    child: FluidCover(
                      genre: b.genre,
                      title: b.title,
                      author: b.author,
                      badge: b.badge,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String label, bool active, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Center(
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
            decoration: BoxDecoration(
              color: active ? ElTheme.primary : ElTheme.surface,
              borderRadius: BorderRadius.circular(99),
              border: Border.all(
                color: active ? ElTheme.primary : ElTheme.line,
                width: 0.5,
              ),
            ),
            child: Text(
              label,
              style: AppFont.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: active ? ElColors.onPrimary : ElTheme.muted,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
