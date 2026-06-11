import 'package:flutter/material.dart';
import 'package:likenovel/app/fonts.dart';

import 'package:likenovel/app/theme.dart';
import 'package:likenovel/core/models/book.dart';
import 'package:likenovel/core/mock/mock_data.dart';

/// 章节付费墙：会员全场畅读是主 CTA，金币仅作为非会员按章出口。
class PaywallSheet extends StatefulWidget {
  final Book book;
  final int chapterId;
  final int coins;
  final VoidCallback onClose;
  final VoidCallback onCoinUnlock;
  final VoidCallback onTopUp;

  /// 开通 VIP 会员后全场畅读。
  final VoidCallback onMembership;

  const PaywallSheet({
    super.key,
    required this.book,
    required this.chapterId,
    required this.coins,
    required this.onClose,
    required this.onCoinUnlock,
    required this.onTopUp,
    required this.onMembership,
  });

  @override
  State<PaywallSheet> createState() => _PaywallSheetState();
}

class _PaywallSheetState extends State<PaywallSheet> {
  bool _showOtherWays = false;

  /// 单章价格随书走（每本书不同）。
  int get _chapterCost => widget.book.chapterPrice;

  bool get _hasEnough => widget.coins >= _chapterCost;
  int get _deficit => _chapterCost - widget.coins;

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
              _buildMembershipOption(),
              const SizedBox(height: ElSpacing.s12),
              TextButton(
                onPressed: () =>
                    setState(() => _showOtherWays = !_showOtherWays),
                child: Text(
                  _showOtherWays
                      ? 'Hide other ways'
                      : 'Other ways to continue',
                  style: AppFont.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: ElTheme.muted,
                  ),
                ),
              ),
              if (_showOtherWays) ...[
                const SizedBox(height: ElSpacing.s8),
                _buildCoinOption(),
                if (!_hasEnough) ...[
                  const SizedBox(height: ElSpacing.s12),
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
      onTap: _hasEnough ? widget.onCoinUnlock : widget.onTopUp,
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
      title: _hasEnough ? 'Pay $_chapterCost coins' : 'Top up to unlock',
      subtitle: _hasEnough
          ? Row(
              children: [
                const Icon(Icons.check_circle, color: ElTheme.success, size: 14),
                const SizedBox(width: 4),
                Text(
                  'Balance covers this chapter',
                  style: AppFont.inter(
                    fontSize: 12,
                    color: ElTheme.success,
                  ),
                ),
              ],
            )
          : Text(
              'Need $_deficit more coins · Balance: ${widget.coins}',
              style: AppFont.inter(
                fontSize: 12,
                color: ElTheme.muted,
              ),
            ),
    );
  }

  /// 会员畅读：开通后全库章节直接放行。
  Widget _buildMembershipOption() {
    return _OptionCard(
      onTap: widget.onMembership,
      icon: Container(
        width: 40,
        height: 40,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [ElTheme.gold, Color(0xFFE0B84A)],
          ),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.workspace_premium_rounded,
            color: Colors.white, size: 22),
      ),
      title: 'Read free with VIP',
      subtitle: Text(
        'Read everything. No limits. First month \$5.99',
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
    final enabled = onTap != null;
    return Opacity(
      opacity: enabled ? 1 : 0.58,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(ElSpacing.s16),
          decoration: BoxDecoration(
            color: enabled ? ElTheme.surface : ElTheme.surface2,
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
                        color: enabled ? ElTheme.ink : ElTheme.muted,
                      ),
                    ),
                    const SizedBox(height: 2),
                    subtitle,
                  ],
                ),
              ),
              if (enabled)
                const Icon(Icons.chevron_right_rounded,
                    color: ElTheme.muted, size: 20),
            ],
          ),
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
  final CoinUnlockOffer? unlockOffer;

  const RechargeSheet({
    super.key,
    required this.coins,
    required this.onClose,
    required this.onPurchase,
    this.unlockOffer,
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
        child: SingleChildScrollView(
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
                widget.unlockOffer == null
                    ? 'Secure checkout via Google Play'
                    : 'Choose a coin pack to continue reading',
                style: AppFont.inter(fontSize: 13, color: ElTheme.muted),
              ),
              if (widget.unlockOffer != null) ...[
                const SizedBox(height: ElSpacing.s16),
                _buildUnlockSummary(widget.unlockOffer!),
              ],
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

  Widget _buildUnlockSummary(CoinUnlockOffer offer) {
    return Container(
      padding: const EdgeInsets.all(ElSpacing.s16),
      decoration: BoxDecoration(
        color: ElTheme.goldSoft,
        borderRadius: ElRadius.cardR,
        border: Border.all(color: ElTheme.gold.withValues(alpha: 0.28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: const BoxDecoration(
                  color: ElTheme.surface,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lock_open_rounded,
                  color: ElTheme.gold,
                  size: 20,
                ),
              ),
              const SizedBox(width: ElSpacing.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Unlock Chapter ${offer.chapterId}',
                      style: AppFont.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: ElTheme.ink,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${offer.chapterCost} coins · ${offer.bookTitle}',
                      style: AppFont.inter(
                        fontSize: 12,
                        color: ElTheme.muted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: ElSpacing.s12),
          _buildUnlockPerk('One-time chapter unlock'),
          _buildUnlockPerk('Keep this chapter after purchase'),
          _buildUnlockPerk('Coins never auto-renew'),
          const SizedBox(height: ElSpacing.s8),
          Text(
            offer.deficit > 0
                ? 'Need ${offer.deficit} more coins to unlock'
                : 'Your current balance can cover this chapter',
            style: AppFont.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: ElTheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnlockPerk(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          const Icon(Icons.check_circle_rounded,
              color: ElTheme.success, size: 15),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: AppFont.inter(fontSize: 12, color: ElTheme.ink),
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

class CoinUnlockOffer {
  final String bookTitle;
  final int chapterId;
  final int chapterCost;
  final int currentBalance;

  const CoinUnlockOffer({
    required this.bookTitle,
    required this.chapterId,
    required this.chapterCost,
    required this.currentBalance,
  });

  int get deficit {
    final remaining = chapterCost - currentBalance;
    return remaining > 0 ? remaining : 0;
  }
}

// ---------------------------------------------------------------------------
// MembershipSheet —— 会员订阅（主付费产品）
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
                          'Read everything. No limits.',
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
            if (plan.perMonthNote != null) ...[
              const SizedBox(height: 4),
              Text(
                plan.perMonthNote!,
                textAlign: TextAlign.center,
                style: AppFont.inter(fontSize: 10, color: ElTheme.muted),
              ),
            ],
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
        if (_selected.introOffer != null)
          Center(
            child: Text(
              _selected.introOffer!,
              style: AppFont.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: ElTheme.success,
              ),
            ),
          ),
      ],
    );
  }
}
