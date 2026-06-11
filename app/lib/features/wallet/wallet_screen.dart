import 'package:flutter/material.dart';
import 'package:likenovel/app/fonts.dart';

import 'package:likenovel/app/theme.dart';
import 'package:likenovel/app/providers.dart';

class WalletScreen extends StatelessWidget {
  final int coins;
  final MembershipState? membership;
  final VoidCallback onTopUp;
  final VoidCallback onMembership;
  final VoidCallback onCheckin;
  final VoidCallback? onWatchAd;
  final VoidCallback? onBack;

  const WalletScreen({
    super.key,
    required this.coins,
    this.membership,
    required this.onTopUp,
    required this.onMembership,
    required this.onCheckin,
    this.onWatchAd,
    this.onBack,
  });

  bool get _isMember => membership != null && membership!.isActive;

  int get _chaptersEstimate => (coins / 38).floor();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ElTheme.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: ElSpacing.s20,
            vertical: ElSpacing.s24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: ElSpacing.s20),
              // 会员置顶（订阅 LTV 更高，优先曝光），金币余额在下
              _buildMembershipCard(),
              const SizedBox(height: ElSpacing.s24),
              _buildBalanceCard(),
              const SizedBox(height: ElSpacing.s24),
              _buildDailyRewards(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (onBack != null)
          Padding(
            padding: const EdgeInsets.only(bottom: ElSpacing.s8),
            child: GestureDetector(
              onTap: onBack,
              behavior: HitTestBehavior.opaque,
              child: Container(
                width: 38,
                height: 38,
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
          ),
        Text(
          'Wallet',
          style: AppFont.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: ElTheme.muted,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Coins & rewards',
          style: AppFont.newsreader(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            color: ElTheme.ink,
          ),
        ),
      ],
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(ElSpacing.s24),
      decoration: BoxDecoration(
        borderRadius: ElRadius.cardR,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF8B2252),
            Color(0xFFA83267),
            Color(0xFF6E1A41),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: ElTheme.primary.withValues(alpha: 0.3),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Glow orbs
          Positioned(
            top: -20,
            right: -20,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            bottom: -10,
            left: 30,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Available balance',
                style: AppFont.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Icon(Icons.monetization_on_rounded,
                      color: ElTheme.gold, size: 28),
                  const SizedBox(width: 8),
                  Text(
                    '$coins',
                    style: AppFont.newsreader(
                      fontSize: 42,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'About $_chaptersEstimate standard chapters',
                style: AppFont.inter(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: ElSpacing.s20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onTopUp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: ElTheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: ElRadius.controlR,
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Top up coins',
                    style: AppFont.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDailyRewards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Daily rewards',
          style: AppFont.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: ElTheme.ink,
          ),
        ),
        const SizedBox(height: ElSpacing.s12),
        Row(
          children: [
            Expanded(
              child: _RewardCard(
                icon: Icons.calendar_today_rounded,
                iconColor: ElTheme.primary,
                iconBg: ElTheme.primarySoft,
                title: 'Daily check-in',
                subtitle: '+20 coins',
                onTap: onCheckin,
              ),
            ),
            const SizedBox(width: ElSpacing.s12),
            Expanded(
              child: _RewardCard(
                icon: Icons.play_circle_filled_rounded,
                iconColor: ElTheme.gold,
                iconBg: ElTheme.goldSoft,
                title: 'Watch & earn',
                subtitle: '+12 coins',
                onTap: onWatchAd ?? () {},
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 会员（VIP）入口卡片——第二套变现体系，放在显眼位置。
  Widget _buildMembershipCard() {
    final expiry = membership?.expiry;
    final expiryText = expiry == null
        ? ''
        : '${expiry.year}-${expiry.month.toString().padLeft(2, '0')}-${expiry.day.toString().padLeft(2, '0')}';

    return GestureDetector(
      onTap: onMembership,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(ElSpacing.s20),
        decoration: BoxDecoration(
          borderRadius: ElRadius.cardR,
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2A2118), Color(0xFF3D2F1C), Color(0xFF1C160F)],
          ),
          boxShadow: [
            BoxShadow(
              color: ElTheme.gold.withValues(alpha: 0.22),
              blurRadius: 22,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [ElTheme.gold, Color(0xFFE0B84A)],
                    ),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: const Icon(Icons.workspace_premium_rounded,
                      color: Colors.white, size: 20),
                ),
                const SizedBox(width: ElSpacing.s12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'VIP Membership',
                            style: AppFont.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFFF5E6C8),
                            ),
                          ),
                          if (_isMember) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 1),
                              decoration: BoxDecoration(
                                color: ElTheme.gold.withValues(alpha: 0.25),
                                borderRadius: BorderRadius.circular(99),
                              ),
                              child: Text(
                                'ACTIVE',
                                style: AppFont.inter(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.8,
                                  color: ElTheme.gold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _isMember
                            ? '${membership!.planName} plan · expires $expiryText'
                            : 'Unlimited stories · Ad-free · Daily coins',
                        style: AppFont.inter(
                          fontSize: 12,
                          color: const Color(0xFFF5E6C8).withValues(alpha: 0.65),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded,
                    color: ElTheme.gold, size: 22),
              ],
            ),
            const SizedBox(height: ElSpacing.s16),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: ElTheme.gold,
                borderRadius: ElRadius.controlR,
              ),
              alignment: Alignment.center,
              child: Text(
                _isMember
                    ? 'Manage plan · Renew or upgrade'
                    : 'View plans · from \$2.99',
                style: AppFont.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A1200),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RewardCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _RewardCard({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(ElSpacing.s16),
        decoration: BoxDecoration(
          color: ElTheme.surface,
          borderRadius: ElRadius.cardR,
          border: Border.all(color: ElTheme.line, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(height: ElSpacing.s12),
            Text(
              title,
              style: AppFont.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: ElTheme.ink,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: AppFont.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: ElTheme.success,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

