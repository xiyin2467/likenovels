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

// ---------------------------------------------------------------------------
// 收藏：收藏的书籍 ID 集合（全局，跨页面共享）
// ---------------------------------------------------------------------------
final favoritesProvider =
    NotifierProvider<FavoritesNotifier, Set<String>>(FavoritesNotifier.new);

class FavoritesNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => <String>{};

  void toggle(String bookId) {
    final next = {...state};
    if (next.contains(bookId)) {
      next.remove(bookId);
    } else {
      next.add(bookId);
    }
    state = next;
  }

  bool contains(String bookId) => state.contains(bookId);
}

// ---------------------------------------------------------------------------
// 阅读偏好：用户在引导页选择的题材/标签，用于个性化排序
// ---------------------------------------------------------------------------
final preferencesProvider =
    NotifierProvider<PreferencesNotifier, Set<String>>(PreferencesNotifier.new);

class PreferencesNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => <String>{};

  void setAll(Set<String> tags) => state = {...tags};
}

// ---------------------------------------------------------------------------
// 会员：当前会员状态（含到期日）。null 表示非会员。
// ---------------------------------------------------------------------------
class MembershipState {
  final String planId;
  final String planName;
  final DateTime expiry;

  const MembershipState({
    required this.planId,
    required this.planName,
    required this.expiry,
  });

  bool get isActive => expiry.isAfter(DateTime.now());
}

final membershipProvider =
    NotifierProvider<MembershipNotifier, MembershipState?>(
        MembershipNotifier.new);

class MembershipNotifier extends Notifier<MembershipState?> {
  @override
  MembershipState? build() => null;

  /// 订阅/续费：在现有到期日（若未过期）基础上叠加时长。
  void subscribe(String planId, String planName, Duration duration) {
    final now = DateTime.now();
    final base = (state != null && state!.expiry.isAfter(now))
        ? state!.expiry
        : now;
    state = MembershipState(
      planId: planId,
      planName: planName,
      expiry: base.add(duration),
    );
  }
}
