import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:likenovel/app/fonts.dart';

import 'package:likenovel/app/theme.dart';
import 'package:likenovel/app/providers.dart';
import 'package:likenovel/core/i18n/app_localizations.dart';
import 'package:likenovel/core/models/book.dart';
import 'package:likenovel/core/mock/mock_data.dart';
import 'package:likenovel/features/onboarding/onboarding_screen.dart';
import 'package:likenovel/features/guide/guide_screen.dart';
import 'package:likenovel/features/discover/discover_screen.dart';
import 'package:likenovel/features/category/category_screen.dart';
import 'package:likenovel/features/book_detail/book_detail_screen.dart';
import 'package:likenovel/features/reader/reader_screen.dart';
import 'package:likenovel/features/library/library_screen.dart';
import 'package:likenovel/features/wallet/wallet_screen.dart';
import 'package:likenovel/features/profile/profile_screen.dart';
import 'package:likenovel/features/common/sub_pages.dart';
import 'package:likenovel/shared/widgets/sheets.dart';

final appRouter = GoRouter(
  initialLocation: '/onboarding',
  routes: [
    GoRoute(
      path: '/onboarding',
      pageBuilder: (context, state) => CustomTransitionPage(
        child: OnboardingScreen(
          onContinue: () => context.go('/guide'),
        ),
        transitionsBuilder: _fadeTransition,
        transitionDuration: const Duration(milliseconds: 300),
      ),
    ),
    GoRoute(
      path: '/guide',
      pageBuilder: (context, state) => CustomTransitionPage(
        child: GuideScreen(
          onBack: () => context.go('/onboarding'),
          onContinue: () => context.go('/discover'),
        ),
        transitionsBuilder: _slideRightTransition,
        transitionDuration: const Duration(milliseconds: 220),
      ),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return AppShell(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/discover',
              builder: (context, state) => const _DiscoverWrapper(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/category',
              builder: (context, state) => const _CategoryWrapper(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/library',
              builder: (context, state) => const _LibraryWrapper(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/me',
              builder: (context, state) => const _ProfileWrapper(),
            ),
          ],
        ),
      ],
    ),
    // 钱包改为从「我的」内进入的独立页（不再占用底部 Tab）
    GoRoute(
      path: '/wallet',
      pageBuilder: (context, state) => CustomTransitionPage(
        child: Consumer(
          builder: (context, ref, _) => WalletScreen(
            coins: ref.watch(coinsProvider),
            onTopUp: () =>
                _showRecharge(context, ProviderScope.containerOf(context)),
            onMembership: () =>
                _showMembership(context, ProviderScope.containerOf(context)),
            onCheckin: () => context.push('/subpage/daily-checkin'),
            onBack: () => context.pop(),
          ),
        ),
        transitionsBuilder: _slideRightTransition,
        transitionDuration: const Duration(milliseconds: 220),
      ),
    ),
    GoRoute(
      path: '/book/:id',
      pageBuilder: (context, state) {
        final id = state.pathParameters['id']!;
        final book = kBooks.firstWhere(
          (b) => b.id == id,
          orElse: () => kBooks.first,
        );
        return CustomTransitionPage(
          child: BookDetailScreen(
            book: book,
            onBack: () => context.pop(),
            onRead: (b, chapterId) =>
                context.push('/reader/${b.id}/${chapterId ?? 1}'),
          ),
          transitionsBuilder: _slideUpTransition,
          transitionDuration: const Duration(milliseconds: 260),
        );
      },
    ),
    GoRoute(
      path: '/reader/:bookId/:chapterId',
      pageBuilder: (context, state) {
        final bookId = state.pathParameters['bookId']!;
        final chapterId =
            int.tryParse(state.pathParameters['chapterId'] ?? '1') ?? 1;
        final book = kBooks.firstWhere(
          (b) => b.id == bookId,
          orElse: () => kBooks.first,
        );
        return CustomTransitionPage(
          child: Consumer(
            builder: (context, ref, _) => ReaderScreen(
              book: book,
              chapterId: chapterId,
              onBack: () => context.pop(),
              onPaywall: (b) => _showPaywall(context, ref, b, chapterId + 1),
              coins: ref.watch(coinsProvider),
            ),
          ),
          transitionsBuilder: _slideRightTransition,
          transitionDuration: const Duration(milliseconds: 220),
        );
      },
    ),
    GoRoute(
      path: '/subpage/:key',
      pageBuilder: (context, state) {
        final key = state.pathParameters['key']!;
        return CustomTransitionPage(
          child: SubPage(
            pageKey: key,
            onBack: () => context.pop(),
            onBook: (b) => context.push('/book/${b.id}'),
            onTopUp: () => _showRecharge(context, ProviderScope.containerOf(context)),
          ),
          transitionsBuilder: _slideRightTransition,
          transitionDuration: const Duration(milliseconds: 220),
        );
      },
    ),
  ],
);

void _showPaywall(
    BuildContext context, WidgetRef ref, Book book, int chapterId) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => PaywallSheet(
      book: book,
      chapterId: chapterId,
      coins: ref.read(coinsProvider),
      onClose: () => Navigator.pop(context),
      onUnlock: () {
        ref.read(coinsProvider.notifier).spend(38);
        Navigator.pop(context);
      },
      onTopUp: () {
        Navigator.pop(context);
        _showRecharge(context, ProviderScope.containerOf(context));
      },
    ),
  );
}

void _showRecharge(BuildContext context, ProviderContainer container) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => RechargeSheet(
      coins: container.read(coinsProvider),
      onClose: () => Navigator.pop(context),
      onPurchase: (added) {
        container.read(coinsProvider.notifier).add(added);
        Navigator.pop(context);
      },
    ),
  );
}

void _showMembership(BuildContext context, ProviderContainer container) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => MembershipSheet(
      onClose: () => Navigator.pop(context),
      onSubscribe: (plan) {
        // MVP：订阅成功后先按权益发放每日金币，便于演示
        container.read(coinsProvider.notifier).add(plan.dailyCoins);
        Navigator.pop(context);
      },
    ),
  );
}

class AppShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const AppShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: ElTheme.surface,
          border: Border(top: BorderSide(color: ElTheme.line, width: 0.5)),
        ),
        child: SafeArea(
          child: SizedBox(
            height: 58,
            child: Row(
              children: [
                _TabItem(
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home,
                  label: l.tr('nav.home'),
                  isActive: navigationShell.currentIndex == 0,
                  onTap: () => navigationShell.goBranch(0,
                      initialLocation: navigationShell.currentIndex == 0),
                ),
                _TabItem(
                  icon: Icons.grid_view_outlined,
                  activeIcon: Icons.grid_view_rounded,
                  label: l.tr('nav.category'),
                  isActive: navigationShell.currentIndex == 1,
                  onTap: () => navigationShell.goBranch(1,
                      initialLocation: navigationShell.currentIndex == 1),
                ),
                _TabItem(
                  icon: Icons.menu_book_outlined,
                  activeIcon: Icons.menu_book,
                  label: l.tr('nav.library'),
                  isActive: navigationShell.currentIndex == 2,
                  onTap: () => navigationShell.goBranch(2,
                      initialLocation: navigationShell.currentIndex == 2),
                ),
                _TabItem(
                  icon: Icons.person_outline,
                  activeIcon: Icons.person,
                  label: l.tr('nav.me'),
                  isActive: navigationShell.currentIndex == 3,
                  onTap: () => navigationShell.goBranch(3,
                      initialLocation: navigationShell.currentIndex == 3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _TabItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          decoration: BoxDecoration(
            color: isActive
                ? ElTheme.primarySoft
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isActive ? activeIcon : icon,
                size: 22,
                color: isActive ? ElTheme.primary : ElTheme.faint,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: AppFont.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: isActive ? ElTheme.primaryInk : ElTheme.faint,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DiscoverWrapper extends ConsumerWidget {
  const _DiscoverWrapper();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DiscoverScreen(
      onBook: (book) => context.push('/book/${book.id}'),
      onWallet: () => context.push('/wallet'),
      onMessages: () => context.push('/subpage/messages'),
      onSearch: () => context.push('/subpage/search'),
    );
  }
}

class _CategoryWrapper extends StatelessWidget {
  const _CategoryWrapper();

  @override
  Widget build(BuildContext context) {
    return CategoryScreen(
      onBook: (book) => context.push('/book/${book.id}'),
    );
  }
}

class _LibraryWrapper extends StatelessWidget {
  const _LibraryWrapper();

  @override
  Widget build(BuildContext context) {
    return LibraryScreen(
      onBook: (book) => context.push('/book/${book.id}'),
      onRead: (book) => context.push('/reader/${book.id}/1'),
    );
  }
}

class _ProfileWrapper extends ConsumerWidget {
  const _ProfileWrapper();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ProfileScreen(
      coins: ref.watch(coinsProvider),
      onNav: (key) {
        // 钱包入口指向独立钱包页，其余走通用子页
        if (key == 'wallet') {
          context.push('/wallet');
        } else {
          context.push('/subpage/$key');
        }
      },
      onSettings: () => context.push('/subpage/settings'),
    );
  }
}

Widget _slideRightTransition(
    BuildContext ctx, Animation<double> anim, Animation<double> sec, Widget child) {
  return SlideTransition(
    position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
        .animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
    child: child,
  );
}

Widget _slideUpTransition(
    BuildContext ctx, Animation<double> anim, Animation<double> sec, Widget child) {
  return SlideTransition(
    position: Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero)
        .animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
    child: FadeTransition(opacity: anim, child: child),
  );
}

Widget _fadeTransition(
    BuildContext ctx, Animation<double> anim, Animation<double> sec, Widget child) {
  return FadeTransition(
    opacity: CurvedAnimation(parent: anim, curve: Curves.easeIn),
    child: child,
  );
}
