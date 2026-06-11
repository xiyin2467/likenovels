import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:likenovel/app/fonts.dart';

import 'package:likenovel/app/theme.dart';
import 'package:likenovel/app/providers.dart';
import 'package:likenovel/core/i18n/app_localizations.dart';
import 'package:likenovel/core/i18n/locale_controller.dart';
import 'package:likenovel/shared/widgets/toast_overlay.dart';
import 'package:likenovel/core/models/book.dart';
import 'package:likenovel/core/mock/mock_data.dart';
import 'package:likenovel/features/common/account_pages.dart';
import 'package:likenovel/shared/widgets/book_cover.dart';

// ---------------------------------------------------------------------------
// SubShell — shared layout container for all sub-pages
// ---------------------------------------------------------------------------

class SubShell extends StatelessWidget {
  final String eyebrow;
  final String title;
  final VoidCallback onBack;
  final Widget child;
  final Widget? trailing;

  const SubShell({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.onBack,
    required this.child,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ElTheme.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                ElSpacing.s16, ElSpacing.s12, ElSpacing.s16, 0,
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: onBack,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: ElTheme.surface2,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back_rounded,
                        size: 20,
                        color: ElTheme.ink,
                      ),
                    ),
                  ),
                  const Spacer(),
                  ?trailing,
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                ElSpacing.s20, ElSpacing.s16, ElSpacing.s20, ElSpacing.s4,
              ),
              child: Text(
                eyebrow,
                style: AppFont.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: ElTheme.muted,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: ElSpacing.s20),
              child: Text(
                title,
                style: AppFont.newsreader(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: ElTheme.ink,
                ),
              ),
            ),
            const SizedBox(height: ElSpacing.s16),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// TopChartsPage — book list for "More" navigation from Discover
// ---------------------------------------------------------------------------

class TopChartsPage extends StatelessWidget {
  final VoidCallback onBack;
  final void Function(Book book)? onBook;
  final bool reversed;

  const TopChartsPage({
    super.key,
    required this.onBack,
    this.onBook,
    this.reversed = false,
  });

  List<Book> get _books {
    final source = List<Book>.from(kBooks);
    if (reversed) source.sort((a, b) => b.rating.compareTo(a.rating));
    return source;
  }

  @override
  Widget build(BuildContext context) {
    return SubShell(
      eyebrow: 'Discover',
      title: reversed ? 'New & rising' : 'Top charts',
      onBack: onBack,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: ElSpacing.s16, vertical: ElSpacing.s8),
        itemCount: _books.length,
        separatorBuilder: (_, _) => Divider(height: 1, thickness: 0.5, color: ElTheme.line),
        itemBuilder: (_, i) {
          final book = _books[i];
          return GestureDetector(
            onTap: () => onBook?.call(book),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: [
                  BookCover(
                    genre: book.genre,
                    title: book.title,
                    author: book.author,
                    badge: book.badge,
                    size: CoverSize.md,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          book.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppFont.newsreader(fontSize: 14, fontWeight: FontWeight.w600, color: ElTheme.ink),
                        ),
                        const SizedBox(height: 2),
                        Text(book.author, style: AppFont.inter(fontSize: 12, color: ElTheme.faint)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.star_rounded, size: 13, color: ElTheme.gold),
                            const SizedBox(width: 2),
                            Text('${book.rating}', style: AppFont.inter(fontSize: 11, fontWeight: FontWeight.w600, color: ElTheme.ink)),
                            const SizedBox(width: 10),
                            Text(book.blurb, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppFont.inter(fontSize: 11, color: ElTheme.muted)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.chevron_right, size: 18, color: ElTheme.faint),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// SubPage — router widget that delegates to the correct sub-page
// ---------------------------------------------------------------------------

class SubPage extends StatelessWidget {
  final String pageKey;
  final VoidCallback onBack;
  final void Function(Book book)? onBook;
  final VoidCallback? onTopUp;

  /// 跳转到其他子页面（如设置 → 通知）。
  final void Function(String key)? onNav;
  final int coins;

  const SubPage({
    super.key,
    required this.pageKey,
    required this.onBack,
    this.onBook,
    this.onTopUp,
    this.onNav,
    this.coins = 1240,
  });

  @override
  Widget build(BuildContext context) {
    return switch (pageKey) {
      'transactions' => TransactionsPage(onBack: onBack),
      'checkin' || 'daily-checkin' => DailyCheckinPage(onBack: onBack),
      'messages' => MessagesPage(onBack: onBack),
      'settings' => SettingsPage(
          onBack: onBack,
          onNav: (key) => onNav?.call(key),
        ),
      'notifications' => NotificationsPage(onBack: onBack),
      'language' => LanguagePage(onBack: onBack),
      'delete_account' => DeleteAccountPage(onBack: onBack),
      'search' => SearchResultsPage(onBack: onBack, onBook: onBook),
      'top-charts' => TopChartsPage(onBack: onBack, onBook: onBook),
      'new-rising' => TopChartsPage(onBack: onBack, onBook: onBook, reversed: true),
      'for-you' => TopChartsPage(onBack: onBack, onBook: onBook),
      'edit_profile' => EditProfilePage(onBack: onBack),
      'push' => PushManagementPage(onBack: onBack),
      'privacy' => PrivacyPage(
          onBack: onBack,
          onDeleteAccount: () => onNav?.call('delete_account'),
        ),
      'purchase_history' => PurchaseHistoryPage(onBack: onBack),
      'reading_history' => ReadingHistoryPage(onBack: onBack, onBook: onBook),
      'help' => HelpCenterPage(onBack: onBack),
      'about' => AboutPage(onBack: onBack),
      _ => GenericListPage(onBack: onBack, pageKey: pageKey),
    };
  }
}

// ---------------------------------------------------------------------------
// TransactionsPage
// ---------------------------------------------------------------------------

class _TxnItem {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String label;
  final String subtitle;
  final String date;
  final int amount;

  const _TxnItem({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.label,
    required this.subtitle,
    required this.date,
    required this.amount,
  });
}

const _kTransactions = <_TxnItem>[
  _TxnItem(
    icon: Icons.calendar_today_rounded,
    iconBg: ElTheme.success,
    iconColor: Colors.white,
    label: 'Daily check-in',
    subtitle: 'Reward',
    date: 'Today',
    amount: 20,
  ),
  _TxnItem(
    icon: Icons.lock_open_rounded,
    iconBg: ElTheme.primarySoft,
    iconColor: ElTheme.primary,
    label: 'Chapter unlock',
    subtitle: 'Claimed by the Moon · Ch 48',
    date: 'Today',
    amount: -38,
  ),
  _TxnItem(
    icon: Icons.lock_open_rounded,
    iconBg: ElTheme.primarySoft,
    iconColor: ElTheme.primary,
    label: 'Chapter unlock',
    subtitle: 'Claimed by the Moon · Ch 47',
    date: 'Yesterday',
    amount: -38,
  ),
  _TxnItem(
    icon: Icons.play_circle_filled_rounded,
    iconBg: ElTheme.success,
    iconColor: Colors.white,
    label: 'Watch & earn',
    subtitle: 'Ad reward',
    date: 'Yesterday',
    amount: 12,
  ),
  _TxnItem(
    icon: Icons.shopping_bag_outlined,
    iconBg: ElTheme.primarySoft,
    iconColor: ElTheme.primary,
    label: 'Coin purchase',
    subtitle: '600 + 60 bonus',
    date: 'Jun 5',
    amount: 660,
  ),
  _TxnItem(
    icon: Icons.lock_open_rounded,
    iconBg: ElTheme.primarySoft,
    iconColor: ElTheme.primary,
    label: 'Chapter unlock',
    subtitle: "The Billionaire's Secret Wife · Ch 12",
    date: 'Jun 4',
    amount: -38,
  ),
  _TxnItem(
    icon: Icons.card_giftcard_rounded,
    iconBg: ElTheme.success,
    iconColor: Colors.white,
    label: 'Welcome bonus',
    subtitle: 'New user gift',
    date: 'Jun 1',
    amount: 300,
  ),
];

class TransactionsPage extends StatelessWidget {
  final VoidCallback onBack;

  const TransactionsPage({super.key, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return SubShell(
      eyebrow: 'Wallet',
      title: 'Transactions',
      onBack: onBack,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: ElSpacing.s20),
        itemCount: _kTransactions.length,
        separatorBuilder: (_, _) => Divider(
          height: 1,
          thickness: 0.5,
          color: ElTheme.line,
          indent: 56,
        ),
        itemBuilder: (context, i) {
          final tx = _kTransactions[i];
          final isEarn = tx.amount > 0;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: ElSpacing.s12),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isEarn
                        ? ElTheme.success.withValues(alpha: 0.12)
                        : ElTheme.primarySoft,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(tx.icon, size: 18, color: isEarn
                      ? ElTheme.success
                      : ElTheme.primary),
                ),
                const SizedBox(width: ElSpacing.s12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tx.label,
                        style: AppFont.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: ElTheme.ink,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        tx.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppFont.inter(
                          fontSize: 12,
                          color: ElTheme.muted,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: ElSpacing.s8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${isEarn ? '+' : ''}${tx.amount}',
                      style: AppFont.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: isEarn ? ElTheme.success : ElTheme.ink,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      tx.date,
                      style: AppFont.inter(
                        fontSize: 11,
                        color: ElTheme.faint,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// DailyCheckinPage
// ---------------------------------------------------------------------------

class DailyCheckinPage extends ConsumerStatefulWidget {
  final VoidCallback onBack;

  const DailyCheckinPage({super.key, required this.onBack});

  @override
  ConsumerState<DailyCheckinPage> createState() => _DailyCheckinPageState();
}

class _DailyCheckinPageState extends ConsumerState<DailyCheckinPage> {
  int _checked = 3;

  static const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const _rewards = [20, 20, 20, 30, 20, 20, 50];

  void _checkin() {
    if (_checked < 7) {
      final reward = _rewards[_checked];
      setState(() => _checked++);
      // 签到奖励入账（数据闭环：签到 → 金币余额）
      ref.read(coinsProvider.notifier).add(reward);
      ToastOverlay.show(context, '+$reward coins added to your wallet');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SubShell(
      eyebrow: 'Rewards',
      title: 'Daily check-in',
      onBack: widget.onBack,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: ElSpacing.s20),
        child: Column(
          children: [
            const SizedBox(height: ElSpacing.s8),
            Container(
              padding: const EdgeInsets.all(ElSpacing.s16),
              decoration: BoxDecoration(
                color: ElTheme.surface,
                borderRadius: ElRadius.cardR,
                border: Border.all(color: ElTheme.line, width: 0.5),
              ),
              child: Column(
                children: [
                  Text(
                    'Check in every day to earn free coins!',
                    style: AppFont.inter(
                      fontSize: 13,
                      color: ElTheme.muted,
                    ),
                  ),
                  const SizedBox(height: ElSpacing.s20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(7, (i) {
                      final isDone = i < _checked;
                      final isToday = i == _checked;

                      return Column(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: isDone
                                  ? ElTheme.primary
                                  : isToday
                                      ? ElTheme.primarySoft
                                      : ElTheme.surface2,
                              shape: BoxShape.circle,
                              border: isToday
                                  ? Border.all(
                                      color: ElTheme.primary, width: 2)
                                  : null,
                            ),
                            child: isDone
                                ? const Icon(Icons.check_rounded,
                                    size: 18, color: ElTheme.onPrimary)
                                : Center(
                                    child: Text(
                                      '+${_rewards[i]}',
                                      style: AppFont.inter(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: isToday
                                            ? ElTheme.primary
                                            : ElTheme.faint,
                                      ),
                                    ),
                                  ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _days[i],
                            style: AppFont.inter(
                              fontSize: 11,
                              fontWeight:
                                  isToday ? FontWeight.w700 : FontWeight.w500,
                              color: isDone
                                  ? ElTheme.primary
                                  : isToday
                                      ? ElTheme.ink
                                      : ElTheme.faint,
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                ],
              ),
            ),
            const SizedBox(height: ElSpacing.s24),
            if (_checked < 7)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _checkin,
                  child: Text(
                    'Check in  ·  +${_rewards[_checked]} coins',
                    style: AppFont.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            if (_checked >= 7)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: ElTheme.surface2,
                  borderRadius: ElRadius.controlR,
                ),
                alignment: Alignment.center,
                child: Text(
                  'All done this week!',
                  style: AppFont.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: ElTheme.muted,
                  ),
                ),
              ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// MessagesPage
// ---------------------------------------------------------------------------

class _MsgItem {
  final String title;
  final String body;
  final String time;
  final bool unread;

  const _MsgItem({
    required this.title,
    required this.body,
    required this.time,
    this.unread = false,
  });
}

const _kMessages = <_MsgItem>[
  _MsgItem(
    title: 'New chapter available!',
    body: 'Claimed by the Moon just released Chapter 143. Keep reading!',
    time: '2h ago',
    unread: true,
  ),
  _MsgItem(
    title: 'Daily bonus collected',
    body: 'You earned 20 coins from today\'s check-in. Come back tomorrow for more!',
    time: '5h ago',
    unread: true,
  ),
  _MsgItem(
    title: 'Weekend special offer',
    body: 'Top up this weekend and get 2× bonus coins on all packages.',
    time: '1d ago',
    unread: true,
  ),
  _MsgItem(
    title: 'Welcome to likenovel!',
    body: 'Thanks for joining. Here\'s 300 bonus coins to start your reading journey.',
    time: '3d ago',
  ),
];

class MessagesPage extends StatelessWidget {
  final VoidCallback onBack;

  const MessagesPage({super.key, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return SubShell(
      eyebrow: 'Inbox',
      title: 'Messages',
      onBack: onBack,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: ElSpacing.s20),
        itemCount: _kMessages.length,
        separatorBuilder: (_, _) => Divider(
          height: 1,
          thickness: 0.5,
          color: ElTheme.line,
        ),
        itemBuilder: (context, i) {
          final msg = _kMessages[i];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: ElSpacing.s16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (msg.unread)
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.only(top: 6, right: 10),
                    decoration: const BoxDecoration(
                      color: ElTheme.primary,
                      shape: BoxShape.circle,
                    ),
                  )
                else
                  const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              msg.title,
                              style: AppFont.inter(
                                fontSize: 14,
                                fontWeight: msg.unread
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: ElTheme.ink,
                              ),
                            ),
                          ),
                          Text(
                            msg.time,
                            style: AppFont.inter(
                              fontSize: 11,
                              color: ElTheme.faint,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        msg.body,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppFont.inter(
                          fontSize: 13,
                          color: ElTheme.muted,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// SettingsPage
// ---------------------------------------------------------------------------

class SettingsPage extends StatelessWidget {
  final VoidCallback onBack;
  final void Function(String key) onNav;

  const SettingsPage({
    super.key,
    required this.onBack,
    required this.onNav,
  });

  @override
  Widget build(BuildContext context) {
    final items = <(IconData, String, String)>[
      (Icons.notifications_outlined, 'Notifications', 'notifications'),
      (Icons.language_rounded, 'Language', 'language'),
      (Icons.shield_outlined, 'Push management', 'push'),
      (Icons.lock_outline_rounded, 'Privacy & data', 'privacy'),
    ];

    return SubShell(
      eyebrow: 'Account',
      title: 'Settings',
      onBack: onBack,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: ElSpacing.s20),
        child: Container(
          decoration: BoxDecoration(
            color: ElTheme.surface,
            borderRadius: ElRadius.cardR,
            border: Border.all(color: ElTheme.line, width: 0.5),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (int i = 0; i < items.length; i++) ...[
                _SettingsRow(
                  icon: items[i].$1,
                  label: items[i].$2,
                  onTap: () => onNav(items[i].$3),
                ),
                if (i < items.length - 1)
                  Divider(
                    height: 0.5,
                    thickness: 0.5,
                    color: ElTheme.line,
                    indent: 56,
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SettingsRow({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: ElSpacing.s16,
          vertical: ElSpacing.s12,
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: const BoxDecoration(
                color: ElTheme.surface2,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 17, color: ElTheme.muted),
            ),
            const SizedBox(width: ElSpacing.s12),
            Expanded(
              child: Text(
                label,
                style: AppFont.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: ElTheme.ink,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: ElTheme.faint,
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// NotificationsPage
// ---------------------------------------------------------------------------

class NotificationsPage extends StatefulWidget {
  final VoidCallback onBack;

  const NotificationsPage({super.key, required this.onBack});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final _toggles = <String, bool>{
    'New chapter alerts': true,
    'Reading reminders': true,
    'Unlock confirmations': false,
    'Coin deals & offers': true,
    'New story recommendations': true,
  };

  @override
  Widget build(BuildContext context) {
    final entries = _toggles.entries.toList();

    return SubShell(
      eyebrow: 'Settings',
      title: 'Notifications',
      onBack: widget.onBack,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: ElSpacing.s20),
        child: Container(
          decoration: BoxDecoration(
            color: ElTheme.surface,
            borderRadius: ElRadius.cardR,
            border: Border.all(color: ElTheme.line, width: 0.5),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (int i = 0; i < entries.length; i++) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: ElSpacing.s16,
                    vertical: ElSpacing.s4,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          entries[i].key,
                          style: AppFont.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: ElTheme.ink,
                          ),
                        ),
                      ),
                      Switch(
                        value: entries[i].value,
                        activeTrackColor: ElTheme.primary,
                        onChanged: (val) {
                          setState(() => _toggles[entries[i].key] = val);
                        },
                      ),
                    ],
                  ),
                ),
                if (i < entries.length - 1)
                  Divider(
                    height: 0.5,
                    thickness: 0.5,
                    color: ElTheme.line,
                    indent: ElSpacing.s16,
                    endIndent: ElSpacing.s16,
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// LanguagePage
// ---------------------------------------------------------------------------

class LanguagePage extends ConsumerWidget {
  final VoidCallback onBack;

  const LanguagePage({super.key, required this.onBack});

  bool _matches(Locale? current, Locale target) {
    if (current == null) return false;
    return current.languageCode == target.languageCode &&
        (current.countryCode ?? '') == (target.countryCode ?? '');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(localeProvider);
    // 语言清单由 AppLocales 统一驱动，与 assets/i18n/manifest.json 保持一致
    final languages = AppLocales.all;

    return SubShell(
      eyebrow: 'Settings',
      title: 'Language',
      onBack: onBack,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          ElSpacing.s20, 0, ElSpacing.s20, ElSpacing.s24,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: ElTheme.surface,
            borderRadius: ElRadius.cardR,
            border: Border.all(color: ElTheme.line, width: 0.5),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (int i = 0; i < languages.length; i++) ...[
                Builder(builder: (context) {
                  final info = languages[i];
                  final selected = _matches(current, info.locale);
                  return GestureDetector(
                    onTap: () => ref
                        .read(localeProvider.notifier)
                        .setLocale(info.locale),
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: ElSpacing.s16,
                        vertical: ElSpacing.s12,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              info.nativeName,
                              style: AppFont.inter(
                                fontSize: 14,
                                fontWeight: selected
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                                color:
                                    selected ? ElTheme.primary : ElTheme.ink,
                              ),
                            ),
                          ),
                          if (selected)
                            const Icon(
                              Icons.check_circle_rounded,
                              size: 20,
                              color: ElTheme.primary,
                            )
                          else
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: ElTheme.line,
                                  width: 1.5,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                }),
                if (i < languages.length - 1)
                  Divider(
                    height: 0.5,
                    thickness: 0.5,
                    color: ElTheme.line,
                    indent: ElSpacing.s16,
                    endIndent: ElSpacing.s16,
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// DeleteAccountPage
// ---------------------------------------------------------------------------

class DeleteAccountPage extends StatelessWidget {
  final VoidCallback onBack;

  const DeleteAccountPage({super.key, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return SubShell(
      eyebrow: 'Account',
      title: 'Delete account',
      onBack: onBack,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: ElSpacing.s20),
        child: Column(
          children: [
            const Spacer(flex: 2),
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFFB3261E).withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.warning_amber_rounded,
                size: 36,
                color: Color(0xFFB3261E),
              ),
            ),
            const SizedBox(height: ElSpacing.s20),
            Text(
              'Delete your account?',
              style: AppFont.newsreader(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: ElTheme.ink,
              ),
            ),
            const SizedBox(height: ElSpacing.s12),
            Text(
              'This will permanently remove all your data, purchased chapters, '
              'coin balance, and reading progress. This action cannot be undone.',
              textAlign: TextAlign.center,
              style: AppFont.inter(
                fontSize: 14,
                color: ElTheme.muted,
                height: 1.5,
              ),
            ),
            const Spacer(flex: 3),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB3261E),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: ElRadius.controlR,
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Yes, delete my account',
                  style: AppFont.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: ElSpacing.s12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onBack,
                child: Text(
                  'Cancel',
                  style: AppFont.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: ElSpacing.s24),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// SearchResultsPage
// ---------------------------------------------------------------------------

class SearchResultsPage extends StatefulWidget {
  final VoidCallback onBack;
  final void Function(Book book)? onBook;

  const SearchResultsPage({
    super.key,
    required this.onBack,
    this.onBook,
  });

  @override
  State<SearchResultsPage> createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends State<SearchResultsPage> {
  final _controller = TextEditingController();
  String _query = '';

  List<Book> get _results {
    if (_query.isEmpty) return [];
    final q = _query.toLowerCase();
    return kBooks.where((b) {
      return b.title.toLowerCase().contains(q) ||
          b.author.toLowerCase().contains(q) ||
          b.tropes.any((t) => t.toLowerCase().contains(q));
    }).toList();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ElTheme.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                ElSpacing.s16, ElSpacing.s12, ElSpacing.s16, ElSpacing.s12,
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: widget.onBack,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: ElTheme.surface2,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back_rounded,
                        size: 20,
                        color: ElTheme.ink,
                      ),
                    ),
                  ),
                  const SizedBox(width: ElSpacing.s12),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      autofocus: true,
                      onChanged: (v) => setState(() => _query = v),
                      style: AppFont.inter(
                        fontSize: 15,
                        color: ElTheme.ink,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search books, authors, tropes…',
                        hintStyle: AppFont.inter(
                          fontSize: 15,
                          color: ElTheme.faint,
                        ),
                        prefixIcon: const Icon(
                          Icons.search_rounded,
                          size: 20,
                          color: ElTheme.faint,
                        ),
                        suffixIcon: _query.isNotEmpty
                            ? GestureDetector(
                                onTap: () {
                                  _controller.clear();
                                  setState(() => _query = '');
                                },
                                child: const Icon(
                                  Icons.close_rounded,
                                  size: 18,
                                  color: ElTheme.faint,
                                ),
                              )
                            : null,
                        filled: true,
                        fillColor: ElTheme.surface2,
                        border: OutlineInputBorder(
                          borderRadius: ElRadius.controlR,
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 0,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (_query.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: ElSpacing.s20,
                ),
                child: Text(
                  '${_results.length} result${_results.length == 1 ? '' : 's'}',
                  style: AppFont.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: ElTheme.muted,
                  ),
                ),
              ),
            const SizedBox(height: ElSpacing.s8),
            Expanded(
              child: _results.isEmpty && _query.isNotEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.search_off_rounded,
                              size: 48, color: ElTheme.line),
                          const SizedBox(height: ElSpacing.s12),
                          Text(
                            'No results found.',
                            style: AppFont.inter(
                              fontSize: 14,
                              color: ElTheme.muted,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: ElSpacing.s20,
                      ),
                      itemCount: _results.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: ElSpacing.s12),
                      itemBuilder: (context, i) {
                        final book = _results[i];
                        return GestureDetector(
                          onTap: () => widget.onBook?.call(book),
                          behavior: HitTestBehavior.opaque,
                          child: Row(
                            children: [
                              BookCover(
                                genre: book.genre,
                                title: book.title,
                                author: book.author,
                                badge: book.badge,
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
                                      style: AppFont.newsreader(
                                        fontSize: 15,
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
                                    const SizedBox(height: 6),
                                    Wrap(
                                      spacing: 6,
                                      runSpacing: 4,
                                      children: book.tropes.take(3).map((t) {
                                        return Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 3,
                                          ),
                                          decoration: BoxDecoration(
                                            color: ElTheme.surface2,
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            t,
                                            style: AppFont.inter(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w500,
                                              color: ElTheme.muted,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ],
                                ),
                              ),
                            ],
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
}

// ---------------------------------------------------------------------------
// GenericListPage — empty-state placeholder for push, privacy, purchase-history
// ---------------------------------------------------------------------------

class GenericListPage extends StatelessWidget {
  final VoidCallback onBack;
  final String pageKey;

  const GenericListPage({
    super.key,
    required this.onBack,
    required this.pageKey,
  });

  String get _title => switch (pageKey) {
        'push' => 'Push management',
        'privacy' => 'Privacy & data',
        'purchase_history' => 'Purchase history',
        _ => pageKey.replaceAll('_', ' '),
      };

  String get _eyebrow => switch (pageKey) {
        'push' || 'privacy' => 'Settings',
        'purchase_history' => 'Wallet',
        _ => 'Account',
      };

  @override
  Widget build(BuildContext context) {
    return SubShell(
      eyebrow: _eyebrow,
      title: _title,
      onBack: onBack,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 56,
              color: ElTheme.line,
            ),
            const SizedBox(height: ElSpacing.s12),
            Text(
              'No items yet.',
              style: AppFont.inter(
                fontSize: 14,
                color: ElTheme.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
