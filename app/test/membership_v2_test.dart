import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:likenovel/core/mock/mock_data.dart';
import 'package:likenovel/features/reader/reader_screen.dart';
import 'package:likenovel/shared/widgets/sheets.dart';

void main() {
  testWidgets('paywall promotes membership and hides coins behind secondary flow',
      (tester) async {
    final book = kBooks.first;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PaywallSheet(
            book: book,
            chapterId: 6,
            coins: 0,
            onClose: () {},
            onCoinUnlock: () {},
            onTopUp: () {},
            onMembership: () {},
          ),
        ),
      ),
    );

    expect(find.text('Read free with VIP'), findsOneWidget);
    expect(find.text('Watch an ad to unlock'), findsNothing);
    expect(find.text('Coming soon'), findsNothing);
    expect(find.text('Top up to unlock'), findsNothing);

    await tester.tap(find.text('Other ways to continue'));
    await tester.pumpAndSettle();

    expect(find.text('Top up to unlock'), findsOneWidget);
  });

  testWidgets('coin unlock pays directly when balance is enough',
      (tester) async {
    final book = kBooks.first;
    var coinPaid = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PaywallSheet(
            book: book,
            chapterId: 6,
            coins: book.chapterPrice,
            onClose: () {},
            onCoinUnlock: () => coinPaid = true,
            onTopUp: () {},
            onMembership: () {},
          ),
        ),
      ),
    );

    await tester.tap(find.text('Other ways to continue'));
    await tester.pumpAndSettle();
    expect(find.text('Pay ${book.chapterPrice} coins'), findsOneWidget);

    await tester.tap(find.text('Pay ${book.chapterPrice} coins'));

    expect(coinPaid, isTrue);
  });

  testWidgets('coin unlock asks for top-up when balance is short',
      (tester) async {
    final book = kBooks.first;
    var rechargeOpened = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PaywallSheet(
            book: book,
            chapterId: 6,
            coins: 0,
            onClose: () {},
            onCoinUnlock: () {},
            onTopUp: () => rechargeOpened = true,
            onMembership: () {},
          ),
        ),
      ),
    );

    await tester.tap(find.text('Other ways to continue'));
    await tester.pumpAndSettle();
    expect(find.text('Top up to unlock'), findsOneWidget);

    await tester.tap(find.text('Top up to unlock'));

    expect(rechargeOpened, isTrue);
  });

  testWidgets('recharge sheet explains chapter price and coin unlock benefits',
      (tester) async {
    final book = kBooks.first;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RechargeSheet(
            coins: 0,
            unlockOffer: CoinUnlockOffer(
              bookTitle: book.title,
              chapterId: 6,
              chapterCost: book.chapterPrice,
              currentBalance: 0,
            ),
            onClose: () {},
            onPurchase: (_) {},
          ),
        ),
      ),
    );

    expect(find.text('Unlock Chapter 6'), findsOneWidget);
    expect(find.text('${book.chapterPrice} coins · ${book.title}'),
        findsOneWidget);
    expect(find.text('One-time chapter unlock'), findsOneWidget);
    expect(find.text('Keep this chapter after purchase'), findsOneWidget);
    expect(find.text('Coins never auto-renew'), findsOneWidget);
    expect(find.text('Need ${book.chapterPrice} more coins to unlock'),
        findsOneWidget);
    expect(find.text(r'$0.99'), findsOneWidget);
    expect(find.text(r'$9.99'), findsOneWidget);
  });

  testWidgets('reader next button shows VIP marker for members', (tester) async {
    final book = kBooks.first;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ReaderScreen(
            book: book,
            chapterId: 1,
            onBack: () {},
            onPaywall: (book, chapterId) {},
            coins: 0,
            isMember: true,
            unlockedChapters: const {},
            isFavorite: false,
            onToggleFavorite: () {},
          ),
        ),
      ),
    );

    await tester.tap(find.byType(ReaderScreen));
    await tester.pumpAndSettle();

    expect(find.text('Next · Chapter 2'), findsOneWidget);
    expect(find.text('VIP'), findsNWidgets(2));
  });

  test('membership V2 uses whole-library perks and subscription-first pricing',
      () {
    expect(kMembershipPerks, contains('Read everything. No limits.'));
    expect(kMembershipPerks.join(' '), isNot(contains('VIP-tagged')));
    expect(kMembershipPerks.join(' '), isNot(contains('Daily bonus')));

    final weekly = kMembershipPlans.firstWhere((plan) => plan.id == 'm_weekly');
    final monthly =
        kMembershipPlans.firstWhere((plan) => plan.id == 'm_monthly');
    final yearly = kMembershipPlans.firstWhere((plan) => plan.id == 'm_yearly');

    expect(weekly.price, r'$4.99');
    expect(monthly.price, r'$9.99');
    expect(monthly.originalPrice, r'$14.99');
    expect(yearly.price, r'$79.99');
  });
}
