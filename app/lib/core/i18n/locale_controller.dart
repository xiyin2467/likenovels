import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 当前 App 语言。`null` 表示跟随系统（由 MaterialApp 在支持列表内解析）。
///
/// 目前为内存态；后续接入 `shared_preferences` 后，可在 [build] 中读取持久化值、
/// 在 [setLocale] 中写回，实现重启保留用户选择。
final localeProvider = NotifierProvider<LocaleController, Locale?>(
  LocaleController.new,
);

class LocaleController extends Notifier<Locale?> {
  /// 默认强制英文，不跟随系统语言（海外 App 以英文为基线）。
  /// 后续接入持久化后，可改为读取用户保存的语言、缺省回落到 en。
  @override
  Locale? build() => const Locale('en');

  /// 切换语言；传入 `null` 恢复跟随系统。
  void setLocale(Locale? locale) => state = locale;
}
