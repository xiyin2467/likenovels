import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:likenovel/core/models/app_user.dart';

final coinsProvider = NotifierProvider<CoinsNotifier, int>(CoinsNotifier.new);

class CoinsNotifier extends Notifier<int> {
  @override
  int build() => 640;

  void add(int amount) => state = state + amount;
  void spend(int amount) => state = state - amount;
}

final userProvider = Provider<AppUser>((ref) => AppUser.defaultUser);
