import 'dart:async';

import 'package:flutter/material.dart';
import 'package:likenovel/app/fonts.dart';

import 'package:likenovel/app/theme.dart';
import 'package:likenovel/core/models/book.dart';
import 'package:likenovel/core/mock/mock_data.dart';

class PaywallSheet extends StatefulWidget {
  final Book book;
  final int chapterId;
  final int coins;
  final VoidCallback onClose;
  final VoidCallback onUnlock;
  final VoidCallback onTopUp;

  const PaywallSheet({
    super.key,
    required this.book,
    required this.chapterId,
    required this.coins,
    required this.onClose,
    required this.onUnlock,
    required this.onTopUp,
  });

  @override
  State<PaywallSheet> createState() => _PaywallSheetState();
}

class _PaywallSheetState extends State<PaywallSheet> {
  bool _adLoading = false;

  static const int _chapterCost = 38;

  bool get _hasEnough => widget.coins >= _chapterCost;
  int get _deficit => _chapterCost - widget.coins;

  void _simulateAd() {
    setState(() => _adLoading = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _adLoading = false);
        widget.onUnlock();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: ElTheme.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(ElRadius.sheet),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            ElSpacing.s20,
            ElSpacing.s8,
            ElSpacing.s20,
            ElSpacing.s24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildGrabHandle(),
              const SizedBox(height: ElSpacing.s16),
              Text(
                'Unlock Chapter ${widget.chapterId}',
                style: AppFont.newsreader(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: ElTheme.ink,
                ),
              ),
              const SizedBox(height: ElSpacing.s20),
              _buildCoinOption(),
              const SizedBox(height: ElSpacing.s12),
              _buildAdOption(),
              if (!_hasEnough) ...[
                const SizedBox(height: ElSpacing.s16),
                GestureDetector(
                  onTap: widget.onTopUp,
                  child: Text.rich(
                    TextSpan(
                      text: 'Need more coins? ',
                      style: AppFont.inter(
                        fontSize: 13,
                        color: ElTheme.muted,
                      ),
                      children: [
                        TextSpan(
                          text: 'Top up →',
                          style: AppFont.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: ElTheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGrabHandle() {
    return Center(
      child: Container(
        width: 36,
        height: 4,
        decoration: BoxDecoration(
          color: ElTheme.line,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildCoinOption() {
    return _OptionCard(
      onTap: _hasEnough ? widget.onUnlock : null,
      icon: Container(
        width: 40,
        height: 40,
        decoration: const BoxDecoration(
          color: ElTheme.goldSoft,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.monetization_on_rounded,
            color: ElTheme.gold, size: 22),
      ),
      title: 'Unlock with $_chapterCost coins',
      subtitle: _hasEnough
          ? Row(
              children: [
                const Icon(Icons.check_circle, color: ElTheme.success, size: 14),
                const SizedBox(width: 4),
                Text(
                  'Balance: ${widget.coins} coins',
                  style: AppFont.inter(
                    fontSize: 12,
                    color: ElTheme.success,
                  ),
                ),
              ],
            )
          : Text(
              'Need $_deficit more coins',
              style: AppFont.inter(
                fontSize: 12,
                color: ElTheme.muted,
              ),
            ),
    );
  }

  Widget _buildAdOption() {
    return _OptionCard(
      onTap: _adLoading ? null : _simulateAd,
      icon: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: ElTheme.primarySoft,
          shape: BoxShape.circle,
        ),
        child: _adLoading
            ? const Padding(
                padding: EdgeInsets.all(10),
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: ElTheme.primary,
                ),
              )
            : const Icon(Icons.play_circle_filled_rounded,
                color: ElTheme.primary, size: 22),
      ),
      title: 'Watch a short ad',
      subtitle: Text(
        _adLoading ? 'Loading ad…' : 'About 30 seconds, free',
        style: AppFont.inter(fontSize: 12, color: ElTheme.muted),
      ),
    );
  }

}

class _OptionCard extends StatelessWidget {
  final VoidCallback? onTap;
  final Widget icon;
  final String title;
  final Widget subtitle;

  const _OptionCard({
    required this.onTap,
    required this.icon,
    required this.title,
    required this.subtitle,
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
        child: Row(
          children: [
            icon,
            const SizedBox(width: ElSpacing.s12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppFont.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: ElTheme.ink,
                    ),
                  ),
                  const SizedBox(height: 2),
                  subtitle,
                ],
              ),
            ),
            if (onTap != null)
              const Icon(Icons.chevron_right_rounded,
                  color: ElTheme.muted, size: 20),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// RechargeSheet
// ---------------------------------------------------------------------------

class RechargeSheet extends StatefulWidget {
  final int coins;
  final VoidCallback onClose;
  final Function(int) onPurchase;

  const RechargeSheet({
    super.key,
    required this.coins,
    required this.onClose,
    required this.onPurchase,
  });

  @override
  State<RechargeSheet> createState() => _RechargeSheetState();
}

class _RechargeSheetState extends State<RechargeSheet> {
  int _selectedIndex = 2;

  RechargePackage get _selected => kRechargePackages[_selectedIndex];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: ElTheme.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(ElRadius.sheet),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            ElSpacing.s20,
            ElSpacing.s8,
            ElSpacing.s20,
            ElSpacing.s24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildGrabHandle(),
              const SizedBox(height: ElSpacing.s16),
              Text(
                'Top up coins',
                style: AppFont.newsreader(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: ElTheme.ink,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Secure checkout via Google Play',
                style: AppFont.inter(fontSize: 13, color: ElTheme.muted),
              ),
              const SizedBox(height: ElSpacing.s16),
              _buildBalancePill(),
              const SizedBox(height: ElSpacing.s20),
              ...List.generate(kRechargePackages.length, (i) {
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: i < kRechargePackages.length - 1
                        ? ElSpacing.s12
                        : 0,
                  ),
                  child: _buildPackageCard(i),
                );
              }),
              const SizedBox(height: ElSpacing.s20),
              _buildPayButton(),
              const SizedBox(height: ElSpacing.s12),
              Text(
                'Coins are non-refundable. Purchases are handled by Google Play '
                'and subject to their terms of service.',
                textAlign: TextAlign.center,
                style: AppFont.inter(
                  fontSize: 11,
                  color: ElTheme.faint,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGrabHandle() {
    return Center(
      child: Container(
        width: 36,
        height: 4,
        decoration: BoxDecoration(
          color: ElTheme.line,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildBalancePill() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: ElTheme.goldSoft,
        borderRadius: ElRadius.controlR,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.monetization_on_rounded,
              color: ElTheme.gold, size: 16),
          const SizedBox(width: 6),
          Text(
            '${widget.coins} coins',
            style: AppFont.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: ElTheme.ink,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPackageCard(int index) {
    final pkg = kRechargePackages[index];
    final selected = index == _selectedIndex;

    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(ElSpacing.s16),
        decoration: BoxDecoration(
          color: selected ? ElTheme.primarySoft : ElTheme.surface,
          borderRadius: ElRadius.cardR,
          border: Border.all(
            color: selected ? ElTheme.primary : ElTheme.line,
            width: selected ? 1.5 : 0.5,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '${pkg.coins} coins',
                        style: AppFont.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: ElTheme.ink,
                        ),
                      ),
                      if (pkg.tag != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: ElTheme.gold.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            pkg.tag!,
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
                    pkg.bonusLabel,
                    style: AppFont.inter(
                        fontSize: 12, color: ElTheme.muted),
                  ),
                ],
              ),
            ),
            Text(
              pkg.price,
              style: AppFont.inter(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: selected ? ElTheme.primary : ElTheme.ink,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPayButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => widget.onPurchase(_selected.coins + _selected.bonus),
        style: ElevatedButton.styleFrom(
          backgroundColor: ElTheme.primary,
          foregroundColor: ElTheme.onPrimary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: ElRadius.controlR),
        ),
        child: Text(
          'Pay with Google Play · ${_selected.price}',
          style: AppFont.inter(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// MembershipSheet —— 会员订阅（第二套变现体系）
// ---------------------------------------------------------------------------

class MembershipSheet extends StatefulWidget {
  final VoidCallback onClose;
  final void Function(MembershipPlan plan) onSubscribe;

  const MembershipSheet({
    super.key,
    required this.onClose,
    required this.onSubscribe,
  });

  @override
  State<MembershipSheet> createState() => _MembershipSheetState();
}

class _MembershipSheetState extends State<MembershipSheet> {
  int _selectedIndex = 1; // 默认选中 Monthly

  MembershipPlan get _selected => kMembershipPlans[_selectedIndex];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: ElTheme.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(ElRadius.sheet),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            ElSpacing.s20,
            ElSpacing.s8,
            ElSpacing.s20,
            ElSpacing.s24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(child: _buildGrabHandle()),
              const SizedBox(height: ElSpacing.s16),
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [ElTheme.gold, Color(0xFFE0B84A)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.workspace_premium_rounded,
                        color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: ElSpacing.s12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Become a VIP member',
                          style: AppFont.newsreader(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: ElTheme.ink,
                          ),
                        ),
                        Text(
                          'Read more, pay less',
                          style: AppFont.inter(
                              fontSize: 13, color: ElTheme.muted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: ElSpacing.s20),
              ...kMembershipPerks.map(_buildPerkRow),
              const SizedBox(height: ElSpacing.s20),
              Row(
                children: List.generate(kMembershipPlans.length, (i) {
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: i < kMembershipPlans.length - 1
                            ? ElSpacing.s12
                            : 0,
                      ),
                      child: _buildPlanCard(i),
                    ),
                  );
                }),
              ),
              const SizedBox(height: ElSpacing.s20),
              _buildSubscribeButton(),
              const SizedBox(height: ElSpacing.s12),
              Text(
                'Subscription auto-renews until cancelled. Manage or cancel '
                'anytime in Google Play. Subject to their terms of service.',
                textAlign: TextAlign.center,
                style: AppFont.inter(
                  fontSize: 11,
                  color: ElTheme.faint,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGrabHandle() {
    return Container(
      width: 36,
      height: 4,
      decoration: BoxDecoration(
        color: ElTheme.line,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildPerkRow(String perk) {
    return Padding(
      padding: const EdgeInsets.only(bottom: ElSpacing.s8),
      child: Row(
        children: [
          const Icon(Icons.check_circle_rounded,
              color: ElTheme.success, size: 18),
          const SizedBox(width: ElSpacing.s8),
          Expanded(
            child: Text(
              perk,
              style: AppFont.inter(fontSize: 13, color: ElTheme.ink),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard(int index) {
    final plan = kMembershipPlans[index];
    final selected = index == _selectedIndex;

    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(
            horizontal: ElSpacing.s8, vertical: ElSpacing.s16),
        decoration: BoxDecoration(
          color: selected ? ElTheme.primarySoft : ElTheme.surface,
          borderRadius: ElRadius.cardR,
          border: Border.all(
            color: selected ? ElTheme.primary : ElTheme.line,
            width: selected ? 1.5 : 0.5,
          ),
        ),
        child: Column(
          children: [
            if (plan.tag != null)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: ElTheme.gold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  plan.tag!,
                  textAlign: TextAlign.center,
                  style: AppFont.inter(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: ElTheme.gold,
                  ),
                ),
              )
            else
              const SizedBox(height: 16),
            const SizedBox(height: 6),
            Text(
              plan.name,
              style: AppFont.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: ElTheme.ink,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              plan.price,
              style: AppFont.inter(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: selected ? ElTheme.primary : ElTheme.ink,
              ),
            ),
            Text(
              plan.period,
              style: AppFont.inter(fontSize: 11, color: ElTheme.muted),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubscribeButton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton(
          onPressed: () => widget.onSubscribe(_selected),
          style: ElevatedButton.styleFrom(
            backgroundColor: ElTheme.primary,
            foregroundColor: ElTheme.onPrimary,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: ElRadius.controlR),
          ),
          child: Text(
            'Subscribe · ${_selected.price}${_selected.period}',
            style: AppFont.inter(fontSize: 15, fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 6),
        Center(
          child: Text(
            '+${_selected.dailyCoins} bonus coins every day',
            style: AppFont.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: ElTheme.success,
            ),
          ),
        ),
      ],
    );
  }
}
