class AppUser {
  final String id;
  final String name;
  final String email;
  final String avatarUrl;
  final int coins;

  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl = '',
    this.coins = 640,
  });

  static const AppUser defaultUser = AppUser(
    id: 'user_001',
    name: 'Reader',
    email: 'reader@likenovel.app',
    coins: 640,
  );
}
