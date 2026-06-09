import 'package:flutter/material.dart';
import 'package:likenovel/app/fonts.dart';

import 'package:likenovel/app/theme.dart';

class ProfileScreen extends StatelessWidget {
  final int coins;
  final Function(String key) onNav;
  final VoidCallback onSettings;

  const ProfileScreen({
    super.key,
    required this.coins,
    required this.onNav,
    required this.onSettings,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ElTheme.bg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: ElSpacing.s20),
          children: [
            const SizedBox(height: ElSpacing.s16),
            _buildTopBar(),
            const SizedBox(height: ElSpacing.s24),
            _buildProfileCard(),
            const SizedBox(height: ElSpacing.s20),
            _buildStatsRow(),
            const SizedBox(height: ElSpacing.s16),
            _buildCoinBalance(),
            const SizedBox(height: ElSpacing.s20),
            _buildMenuList(),
            const SizedBox(height: ElSpacing.s24),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Account',
                style: AppFont.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: ElTheme.muted,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Me',
                style: AppFont.newsreader(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: ElTheme.ink,
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: onSettings,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: ElTheme.surface2,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.settings_outlined,
              size: 20,
              color: ElTheme.ink,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(ElSpacing.s20),
      decoration: BoxDecoration(
        color: ElTheme.surface,
        borderRadius: ElRadius.cardR,
        border: Border.all(color: ElTheme.line, width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              color: ElTheme.primarySoft,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              'A',
              style: AppFont.newsreader(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: ElTheme.primary,
              ),
            ),
          ),
          const SizedBox(width: ElSpacing.s16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Amelia R.',
                  style: AppFont.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: ElTheme.ink,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _LevelBadge(),
                    const SizedBox(width: 8),
                    Text(
                      '14 day streak',
                      style: AppFont.inter(
                        fontSize: 12,
                        color: ElTheme.muted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => onNav('edit_profile'),
            style: TextButton.styleFrom(
              foregroundColor: ElTheme.primary,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: const BorderSide(color: ElTheme.line),
              ),
              textStyle: AppFont.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            child: const Text('Edit'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: ElSpacing.s16,
        horizontal: ElSpacing.s8,
      ),
      decoration: BoxDecoration(
        color: ElTheme.surface,
        borderRadius: ElRadius.controlR,
        border: Border.all(color: ElTheme.line, width: 0.5),
      ),
      child: Row(
        children: [
          _buildStatItem('Books', '12'),
          _buildDivider(),
          _buildStatItem('Chapters', '847'),
          _buildDivider(),
          _buildStatItem('Streak', '14d'),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: AppFont.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: ElTheme.ink,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppFont.inter(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: ElTheme.muted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 28,
      color: ElTheme.line,
    );
  }

  Widget _buildCoinBalance() {
    return GestureDetector(
      onTap: () => onNav('wallet'),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: ElSpacing.s16,
          vertical: ElSpacing.s12,
        ),
        decoration: BoxDecoration(
          color: ElTheme.primarySoft,
          borderRadius: ElRadius.controlR,
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: ElTheme.gold.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.monetization_on_rounded,
                size: 18,
                color: ElTheme.gold,
              ),
            ),
            const SizedBox(width: ElSpacing.s12),
            Expanded(
              child: Text(
                'Coin balance',
                style: AppFont.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: ElTheme.ink,
                ),
              ),
            ),
            Text(
              '$coins',
              style: AppFont.inter(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: ElTheme.primary,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: ElTheme.muted,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuList() {
    final items = <_MenuItem>[
      _MenuItem(
        icon: Icons.account_balance_wallet_outlined,
        label: 'Wallet & purchases',
        value: '1,240',
        key: 'wallet',
      ),
      _MenuItem(
        icon: Icons.lock_outline_rounded,
        label: 'Transactions',
        key: 'transactions',
      ),
      _MenuItem(
        icon: Icons.notifications_outlined,
        label: 'Messages',
        badge: '3',
        key: 'messages',
      ),
      _MenuItem(
        icon: Icons.tune_rounded,
        label: 'Notifications',
        value: 'On',
        key: 'notifications',
      ),
      _MenuItem(
        icon: Icons.language_rounded,
        label: 'Language',
        value: 'English',
        key: 'language',
      ),
      _MenuItem(
        icon: Icons.shield_outlined,
        label: 'Push management',
        key: 'push',
      ),
      _MenuItem(
        icon: Icons.lock_outline_rounded,
        label: 'Privacy & data',
        key: 'privacy',
      ),
      _MenuItem(
        icon: Icons.delete_outline_rounded,
        label: 'Delete account',
        key: 'delete_account',
        isDanger: true,
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: ElTheme.surface,
        borderRadius: ElRadius.cardR,
        border: Border.all(color: ElTheme.line, width: 0.5),
      ),
      child: Column(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            _buildMenuRow(items[i]),
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
    );
  }

  Widget _buildMenuRow(_MenuItem item) {
    final iconColor = item.isDanger ? const Color(0xFFB3261E) : ElTheme.muted;
    final labelColor = item.isDanger ? const Color(0xFFB3261E) : ElTheme.ink;

    return GestureDetector(
      onTap: () => onNav(item.key),
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
              decoration: BoxDecoration(
                color: item.isDanger
                    ? const Color(0xFFB3261E).withValues(alpha: 0.08)
                    : ElTheme.surface2,
                shape: BoxShape.circle,
              ),
              child: Icon(item.icon, size: 17, color: iconColor),
            ),
            const SizedBox(width: ElSpacing.s12),
            Expanded(
              child: Text(
                item.label,
                style: AppFont.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: labelColor,
                ),
              ),
            ),
            if (item.value != null)
              Text(
                item.value!,
                style: AppFont.inter(
                  fontSize: 13,
                  color: ElTheme.faint,
                ),
              ),
            if (item.badge != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFB3261E),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  item.badge!,
                  style: AppFont.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            const SizedBox(width: 4),
            Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: item.isDanger
                  ? const Color(0xFFB3261E).withValues(alpha: 0.5)
                  : ElTheme.faint,
            ),
          ],
        ),
      ),
    );
  }
}

class _LevelBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: ElTheme.gold.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        'Level 7',
        style: AppFont.inter(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: ElTheme.gold,
        ),
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final String? value;
  final String? badge;
  final String key;
  final bool isDanger;

  const _MenuItem({
    required this.icon,
    required this.label,
    this.value,
    this.badge,
    required this.key,
    this.isDanger = false,
  });
}
