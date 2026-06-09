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
  @override
  Locale? build() => null;

  /// 切换语言；传入 `null` 恢复跟随系统。
  void setLocale(Locale? locale) => state = locale;
}
