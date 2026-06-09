import 'package:flutter/material.dart';
import 'package:likenovel/app/fonts.dart';

import 'package:likenovel/app/theme.dart';
import 'package:likenovel/core/models/book.dart';
import 'package:likenovel/core/mock/mock_data.dart';

class WalletScreen extends StatelessWidget {
  final int coins;
  final VoidCallback onTopUp;
  final VoidCallback onCheckin;

  const WalletScreen({
    super.key,
    required this.coins,
    required this.onTopUp,
    required this.onCheckin,
  });

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
              _buildBalanceCard(),
              const SizedBox(height: ElSpacing.s24),
              _buildDailyRewards(),
              const SizedBox(height: ElSpacing.s24),
              _buildRechargeSection(),
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
                onTap: () {},
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRechargeSection() {
    final featured = kRechargePackages.where((p) => p.tag != null).take(2);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recharge packages',
          style: AppFont.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: ElTheme.ink,
          ),
        ),
        const SizedBox(height: ElSpacing.s12),
        ...featured.map((pkg) => Padding(
              padding: const EdgeInsets.only(bottom: ElSpacing.s12),
              child: _PackageRow(package: pkg, onTap: onTopUp),
            )),
      ],
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

class _PackageRow extends StatelessWidget {
  final RechargePackage package;
  final VoidCallback onTap;

  const _PackageRow({required this.package, required this.onTap});

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
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: ElTheme.goldSoft,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.monetization_on_rounded,
                  color: ElTheme.gold, size: 20),
            ),
            const SizedBox(width: ElSpacing.s12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '${package.coins} coins',
                        style: AppFont.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: ElTheme.ink,
                        ),
                      ),
                      if (package.tag != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: ElTheme.gold.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            package.tag!,
                            style: AppFont.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: ElTheme.gold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    package.bonusLabel,
                    style:
                        AppFont.inter(fontSize: 12, color: ElTheme.muted),
                  ),
                ],
              ),
            ),
            Text(
              package.price,
              style: AppFont.inter(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: ElTheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
