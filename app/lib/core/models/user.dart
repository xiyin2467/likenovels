class AppUser {
  final String id;
  final String nickname;
  final int level;
  final int streak;
  final int booksCount;
  final int chaptersCount;

  const AppUser({
    required this.id,
    required this.nickname,
    required this.level,
    required this.streak,
    required this.booksCount,
    required this.chaptersCount,
  });
}

class WalletState {
  final int coins;
  final int bonus;

  const WalletState({
    required this.coins,
    required this.bonus,
  });

  int get total => coins + bonus;
}
