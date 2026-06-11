import 'package:flutter/material.dart';
import 'package:likenovel/app/fonts.dart';

import 'package:likenovel/app/theme.dart';
import 'package:likenovel/core/models/book.dart';
import 'package:likenovel/core/mock/mock_data.dart';
import 'package:likenovel/features/common/sub_pages.dart';
import 'package:likenovel/shared/widgets/book_cover.dart';
import 'package:likenovel/shared/widgets/toast_overlay.dart';

// ===========================================================================
// 「我的」相关细化子页面：编辑资料 / 推送管理 / 隐私与数据 / 购买记录 /
// 阅读历史 / 帮助中心 / 关于
// ===========================================================================

// ---------------------------------------------------------------------------
// 共享小组件
// ---------------------------------------------------------------------------

/// 设置卡片容器：圆角卡 + 分隔线的行列表。
class SettingCard extends StatelessWidget {
  final List<Widget> children;

  const SettingCard({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ElTheme.surface,
        borderRadius: ElRadius.cardR,
        border: Border.all(color: ElTheme.line, width: 0.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 0; i < children.length; i++) ...[
            children[i],
            if (i < children.length - 1)
              const Divider(
                height: 0.5,
                thickness: 0.5,
                color: ElTheme.line,
                indent: ElSpacing.s16,
                endIndent: ElSpacing.s16,
              ),
          ],
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, ElSpacing.s20, 0, ElSpacing.s8),
      child: Text(
        text.toUpperCase(),
        style: AppFont.inter(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
          color: ElTheme.faint,
        ),
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final String label;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleRow({
    required this.label,
    this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: ElSpacing.s16,
        vertical: ElSpacing.s4,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppFont.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: ElTheme.ink,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: AppFont.inter(fontSize: 12, color: ElTheme.muted),
                  ),
                ],
              ],
            ),
          ),
          Switch(
            value: value,
            activeTrackColor: ElTheme.primary,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// EditProfilePage — 编辑资料
// ---------------------------------------------------------------------------

class EditProfilePage extends StatefulWidget {
  final VoidCallback onBack;

  const EditProfilePage({super.key, required this.onBack});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _nameController = TextEditingController(text: 'Amelia R.');
  final _bioController =
      TextEditingController(text: 'Werewolf romance addict 🌙');

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Widget _fieldLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: ElSpacing.s8),
      child: Text(
        text,
        style: AppFont.inter(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: ElTheme.muted,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SubShell(
      eyebrow: 'Account',
      title: 'Edit profile',
      onBack: widget.onBack,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: ElSpacing.s20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: ElSpacing.s8),
            // 头像
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 88,
                    height: 88,
                    decoration: const BoxDecoration(
                      color: ElTheme.primarySoft,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'A',
                      style: AppFont.newsreader(
                        fontSize: 36,
                        fontWeight: FontWeight.w700,
                        color: ElTheme.primary,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: GestureDetector(
                      onTap: () =>
                          ToastOverlay.show(context, 'Photo picker (demo)'),
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: ElTheme.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: ElTheme.bg, width: 2),
                        ),
                        child: const Icon(
                          Icons.photo_camera_rounded,
                          size: 14,
                          color: ElTheme.onPrimary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: ElSpacing.s24),
            _fieldLabel('Display name'),
            TextField(
              controller: _nameController,
              style: AppFont.inter(fontSize: 15, color: ElTheme.ink),
              decoration: const InputDecoration(hintText: 'Your name'),
            ),
            const SizedBox(height: ElSpacing.s16),
            _fieldLabel('Bio'),
            TextField(
              controller: _bioController,
              maxLines: 3,
              maxLength: 120,
              style: AppFont.inter(fontSize: 15, color: ElTheme.ink),
              decoration: const InputDecoration(
                hintText: 'Tell other readers about yourself…',
              ),
            ),
            const SizedBox(height: ElSpacing.s8),
            _fieldLabel('Email'),
            // 邮箱由登录账号决定，不可在此修改
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: ElSpacing.s16,
                vertical: 14,
              ),
              decoration: BoxDecoration(
                color: ElTheme.surface2,
                borderRadius: ElRadius.controlR,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'amelia.r@gmail.com',
                      style:
                          AppFont.inter(fontSize: 15, color: ElTheme.muted),
                    ),
                  ),
                  const Icon(Icons.lock_outline_rounded,
                      size: 16, color: ElTheme.faint),
                ],
              ),
            ),
            const SizedBox(height: ElSpacing.s24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ToastOverlay.show(context, 'Profile saved');
                  widget.onBack();
                },
                child: Text(
                  'Save changes',
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
// PushManagementPage — 推送管理（分类开关 + 免打扰时段）
// ---------------------------------------------------------------------------

class PushManagementPage extends StatefulWidget {
  final VoidCallback onBack;

  const PushManagementPage({super.key, required this.onBack});

  @override
  State<PushManagementPage> createState() => _PushManagementPageState();
}

class _PushManagementPageState extends State<PushManagementPage> {
  bool _master = true;
  bool _newChapters = true;
  bool _rewards = true;
  bool _offers = false;
  bool _recommendations = true;
  bool _quietHours = true;

  @override
  Widget build(BuildContext context) {
    return SubShell(
      eyebrow: 'Settings',
      title: 'Push management',
      onBack: widget.onBack,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: ElSpacing.s20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SettingCard(children: [
              _ToggleRow(
                label: 'Allow push notifications',
                subtitle: 'Master switch for all pushes',
                value: _master,
                onChanged: (v) => setState(() => _master = v),
              ),
            ]),
            const _SectionLabel('Categories'),
            // 主开关关闭时分类置灰
            Opacity(
              opacity: _master ? 1 : 0.45,
              child: IgnorePointer(
                ignoring: !_master,
                child: SettingCard(children: [
                  _ToggleRow(
                    label: 'New chapter updates',
                    subtitle: 'Books in your library',
                    value: _newChapters,
                    onChanged: (v) => setState(() => _newChapters = v),
                  ),
                  _ToggleRow(
                    label: 'Check-in & rewards',
                    subtitle: 'Daily coins, streak reminders',
                    value: _rewards,
                    onChanged: (v) => setState(() => _rewards = v),
                  ),
                  _ToggleRow(
                    label: 'Deals & offers',
                    subtitle: 'Coin sales, limited-time discounts',
                    value: _offers,
                    onChanged: (v) => setState(() => _offers = v),
                  ),
                  _ToggleRow(
                    label: 'Recommendations',
                    subtitle: 'Stories picked for you',
                    value: _recommendations,
                    onChanged: (v) => setState(() => _recommendations = v),
                  ),
                ]),
              ),
            ),
            const _SectionLabel('Quiet hours'),
            SettingCard(children: [
              _ToggleRow(
                label: 'Do not disturb',
                subtitle: '22:00 – 08:00, local time',
                value: _quietHours,
                onChanged: (v) => setState(() => _quietHours = v),
              ),
            ]),
            const SizedBox(height: ElSpacing.s24),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// PrivacyPage — 隐私与数据
// ---------------------------------------------------------------------------

class PrivacyPage extends StatefulWidget {
  final VoidCallback onBack;
  final VoidCallback? onDeleteAccount;

  const PrivacyPage({super.key, required this.onBack, this.onDeleteAccount});

  @override
  State<PrivacyPage> createState() => _PrivacyPageState();
}

class _PrivacyPageState extends State<PrivacyPage> {
  bool _personalized = true;
  bool _analytics = true;
  bool _adTracking = false;

  Widget _actionRow({
    required IconData icon,
    required String label,
    String? subtitle,
    Color? color,
    required VoidCallback onTap,
  }) {
    final c = color ?? ElTheme.ink;
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
            Icon(icon, size: 18, color: color ?? ElTheme.muted),
            const SizedBox(width: ElSpacing.s12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppFont.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: c,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style:
                          AppFont.inter(fontSize: 12, color: ElTheme.muted),
                    ),
                  ],
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                size: 18, color: color ?? ElTheme.faint),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SubShell(
      eyebrow: 'Settings',
      title: 'Privacy & data',
      onBack: widget.onBack,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: ElSpacing.s20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SettingCard(children: [
              _ToggleRow(
                label: 'Personalized recommendations',
                subtitle: 'Use reading history to suggest stories',
                value: _personalized,
                onChanged: (v) => setState(() => _personalized = v),
              ),
              _ToggleRow(
                label: 'Usage analytics',
                subtitle: 'Help us improve the app',
                value: _analytics,
                onChanged: (v) => setState(() => _analytics = v),
              ),
              _ToggleRow(
                label: 'Ad tracking',
                subtitle: 'Allow personalized ads',
                value: _adTracking,
                onChanged: (v) => setState(() => _adTracking = v),
              ),
            ]),
            const _SectionLabel('Your data'),
            SettingCard(children: [
              _actionRow(
                icon: Icons.download_outlined,
                label: 'Request my data',
                subtitle: 'Export a copy of your account data (GDPR)',
                onTap: () => ToastOverlay.show(
                    context, 'Request submitted — check your email'),
              ),
              _actionRow(
                icon: Icons.cleaning_services_outlined,
                label: 'Clear local cache',
                subtitle: 'Downloaded chapters & images · 36 MB',
                onTap: () => ToastOverlay.show(context, 'Cache cleared'),
              ),
              _actionRow(
                icon: Icons.delete_outline_rounded,
                label: 'Delete account',
                subtitle: 'Permanently remove account & data',
                color: const Color(0xFFB3261E),
                onTap: widget.onDeleteAccount ?? () {},
              ),
            ]),
            const _SectionLabel('Legal'),
            SettingCard(children: [
              _actionRow(
                icon: Icons.description_outlined,
                label: 'Privacy policy',
                onTap: () => ToastOverlay.show(context, 'Opens in browser'),
              ),
              _actionRow(
                icon: Icons.gavel_outlined,
                label: 'Terms of service',
                onTap: () => ToastOverlay.show(context, 'Opens in browser'),
              ),
            ]),
            const SizedBox(height: ElSpacing.s24),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// PurchaseHistoryPage — 购买记录（真实货币订单，区别于金币流水）
// ---------------------------------------------------------------------------

class _PurchaseItem {
  final String title;
  final String detail;
  final String date;
  final String price;
  final bool isSubscription;

  const _PurchaseItem({
    required this.title,
    required this.detail,
    required this.date,
    required this.price,
    this.isSubscription = false,
  });
}

const _kPurchases = <_PurchaseItem>[
  _PurchaseItem(
    title: 'VIP Monthly',
    detail: 'Auto-renews Jul 8 · Google Play',
    date: 'Jun 8',
    price: r'$9.99',
    isSubscription: true,
  ),
  _PurchaseItem(
    title: '1,400 + 240 coins',
    detail: 'Best value pack · Google Play',
    date: 'Jun 5',
    price: r'$9.99',
  ),
  _PurchaseItem(
    title: '600 + 60 coins',
    detail: 'Google Play',
    date: 'May 28',
    price: r'$4.99',
  ),
  _PurchaseItem(
    title: '300 coins',
    detail: 'First-time offer · Google Play',
    date: 'May 21',
    price: r'$0.99',
  ),
];

class PurchaseHistoryPage extends StatelessWidget {
  final VoidCallback onBack;

  const PurchaseHistoryPage({super.key, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return SubShell(
      eyebrow: 'Wallet',
      title: 'Purchase history',
      onBack: onBack,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: ElSpacing.s20),
        itemCount: _kPurchases.length,
        separatorBuilder: (_, _) => const Divider(
          height: 1,
          thickness: 0.5,
          color: ElTheme.line,
          indent: 56,
        ),
        itemBuilder: (context, i) {
          final p = _kPurchases[i];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: ElSpacing.s12),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: p.isSubscription
                        ? ElTheme.goldSoft
                        : ElTheme.primarySoft,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    p.isSubscription
                        ? Icons.workspace_premium_rounded
                        : Icons.monetization_on_rounded,
                    size: 18,
                    color: p.isSubscription ? ElTheme.gold : ElTheme.primary,
                  ),
                ),
                const SizedBox(width: ElSpacing.s12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p.title,
                        style: AppFont.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: ElTheme.ink,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        p.detail,
                        style:
                            AppFont.inter(fontSize: 12, color: ElTheme.muted),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: ElSpacing.s8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      p.price,
                      style: AppFont.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: ElTheme.ink,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      p.date,
                      style: AppFont.inter(fontSize: 11, color: ElTheme.faint),
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
// ReadingHistoryPage — 阅读历史
// ---------------------------------------------------------------------------

class ReadingHistoryPage extends StatelessWidget {
  final VoidCallback onBack;
  final void Function(Book book)? onBook;

  const ReadingHistoryPage({super.key, required this.onBack, this.onBook});

  @override
  Widget build(BuildContext context) {
    return SubShell(
      eyebrow: 'Account',
      title: 'Reading history',
      onBack: onBack,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: ElSpacing.s20),
        itemCount: kLibraryBooks.length,
        separatorBuilder: (_, _) => const SizedBox(height: ElSpacing.s16),
        itemBuilder: (context, i) {
          final lb = kLibraryBooks[i];
          return GestureDetector(
            onTap: () => onBook?.call(lb.book),
            behavior: HitTestBehavior.opaque,
            child: Row(
              children: [
                BookCover(
                  genre: lb.book.genre,
                  title: lb.book.title,
                  author: lb.book.author,
                  badge: lb.book.badge,
                  size: CoverSize.sm,
                ),
                const SizedBox(width: ElSpacing.s12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lb.book.title,
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
                        'Chapter ${lb.currentChapter} of ${lb.book.chapters}',
                        style:
                            AppFont.inter(fontSize: 12, color: ElTheme.muted),
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: LinearProgressIndicator(
                          value: lb.progress / 100,
                          minHeight: 3,
                          backgroundColor: ElTheme.surface2,
                          valueColor:
                              const AlwaysStoppedAnimation(ElTheme.primary),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: ElSpacing.s12),
                const Icon(Icons.chevron_right_rounded,
                    size: 18, color: ElTheme.faint),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// HelpCenterPage — 帮助中心（FAQ + 联系客服）
// ---------------------------------------------------------------------------

const _kFaqs = <(String, String)>[
  (
    'How do coins work?',
    'Coins unlock paid chapters. A standard chapter costs about 38 coins. '
        'You can top up, earn coins from daily check-in, or watch ads.',
  ),
  (
    'What does VIP membership include?',
    'VIP gives unlimited access to every story, ad-free reading, '
        'offline full-book downloads, and an exclusive member badge.',
  ),
  (
    'How do I cancel my subscription?',
    'Subscriptions are managed through Google Play. Open Play Store → '
        'Payments & subscriptions → Subscriptions → likenovel → Cancel.',
  ),
  (
    'Can I read offline?',
    'Chapters you have opened are cached for offline reading. '
        'Locked chapters require a connection to unlock.',
  ),
  (
    'I paid but coins did not arrive',
    'Most purchases arrive within a minute. If not, check Transactions, '
        'then contact support with your order ID — we will make it right.',
  ),
];

class HelpCenterPage extends StatefulWidget {
  final VoidCallback onBack;

  const HelpCenterPage({super.key, required this.onBack});

  @override
  State<HelpCenterPage> createState() => _HelpCenterPageState();
}

class _HelpCenterPageState extends State<HelpCenterPage> {
  int? _expanded;

  @override
  Widget build(BuildContext context) {
    return SubShell(
      eyebrow: 'Support',
      title: 'Help center',
      onBack: widget.onBack,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: ElSpacing.s20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SettingCard(children: [
              for (int i = 0; i < _kFaqs.length; i++)
                _FaqTile(
                  question: _kFaqs[i].$1,
                  answer: _kFaqs[i].$2,
                  expanded: _expanded == i,
                  onTap: () =>
                      setState(() => _expanded = _expanded == i ? null : i),
                ),
            ]),
            const SizedBox(height: ElSpacing.s20),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () =>
                    ToastOverlay.show(context, 'Support chat (demo)'),
                icon: const Icon(Icons.support_agent_rounded, size: 18),
                label: Text(
                  'Contact support',
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

class _FaqTile extends StatelessWidget {
  final String question;
  final String answer;
  final bool expanded;
  final VoidCallback onTap;

  const _FaqTile({
    required this.question,
    required this.answer,
    required this.expanded,
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    question,
                    style: AppFont.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: ElTheme.ink,
                    ),
                  ),
                ),
                AnimatedRotation(
                  turns: expanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: const Icon(Icons.expand_more_rounded,
                      size: 20, color: ElTheme.faint),
                ),
              ],
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox(width: double.infinity),
              secondChild: Padding(
                padding: const EdgeInsets.only(top: ElSpacing.s8),
                child: Text(
                  answer,
                  style: AppFont.inter(
                    fontSize: 13,
                    color: ElTheme.muted,
                    height: 1.5,
                  ),
                ),
              ),
              crossFadeState: expanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 200),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// AboutPage — 关于
// ---------------------------------------------------------------------------

class AboutPage extends StatelessWidget {
  final VoidCallback onBack;

  const AboutPage({super.key, required this.onBack});

  Widget _linkRow(BuildContext context, IconData icon, String label) {
    return GestureDetector(
      onTap: () => ToastOverlay.show(context, 'Opens in browser'),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: ElSpacing.s16,
          vertical: ElSpacing.s12,
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: ElTheme.muted),
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
            const Icon(Icons.open_in_new_rounded,
                size: 15, color: ElTheme.faint),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SubShell(
      eyebrow: 'Support',
      title: 'About',
      onBack: onBack,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: ElSpacing.s20),
        child: Column(
          children: [
            const SizedBox(height: ElSpacing.s16),
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: ElTheme.primary,
                borderRadius: BorderRadius.circular(18),
              ),
              alignment: Alignment.center,
              child: Text(
                'L',
                style: AppFont.newsreader(
                  fontSize: 34,
                  fontWeight: FontWeight.w700,
                  color: ElTheme.onPrimary,
                ),
              ),
            ),
            const SizedBox(height: ElSpacing.s12),
            Text(
              'likenovel',
              style: AppFont.newsreader(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: ElTheme.ink,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Version 0.1.0 (prototype)',
              style: AppFont.inter(fontSize: 12, color: ElTheme.muted),
            ),
            const SizedBox(height: ElSpacing.s24),
            SettingCard(children: [
              _linkRow(context, Icons.star_outline_rounded, 'Rate us on Google Play'),
              _linkRow(context, Icons.description_outlined, 'Terms of service'),
              _linkRow(context, Icons.privacy_tip_outlined, 'Privacy policy'),
              _linkRow(context, Icons.code_rounded, 'Open-source licenses'),
            ]),
            const SizedBox(height: ElSpacing.s24),
            Text(
              '© 2026 likenovel. All rights reserved.',
              style: AppFont.inter(fontSize: 11, color: ElTheme.faint),
            ),
            const SizedBox(height: ElSpacing.s24),
          ],
        ),
      ),
    );
  }
}
