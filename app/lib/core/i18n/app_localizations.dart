import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

/// 轻量级 JSON 多语言方案，结构对标公司短剧 App 的 `assets/i18n/`：
/// - `manifest.json`：登记支持的语言、默认语言与回退语言。
/// - `<code>.json`：按「功能.键」嵌套组织的文案。
///
/// 用法：`AppLocalizations.of(context).tr('nav.discover')`，
/// 支持点号路径与 `{placeholder}` 占位符插值；缺失键自动回退到
/// fallback 语言（默认 en），再缺失则原样返回 key，便于排查。
class AppLocalizations {
  AppLocalizations(this.locale, this._values, this._fallback);

  final Locale locale;
  final Map<String, dynamic> _values;
  final Map<String, dynamic> _fallback;

  static const String _basePath = 'assets/i18n';

  static AppLocalizations of(BuildContext context) {
    final l10n = Localizations.of<AppLocalizations>(context, AppLocalizations);
    assert(l10n != null, 'AppLocalizations 未注入，请检查 localizationsDelegates。');
    return l10n!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// 翻译查找：`key` 为点号路径（如 `paywall.title`）。
  /// `args` 用于替换 `{name}` 形式的占位符。
  String tr(String key, {Map<String, Object?>? args}) {
    final raw = _lookup(_values, key) ?? _lookup(_fallback, key) ?? key;
    if (args == null || args.isEmpty) return raw;
    var result = raw;
    args.forEach((k, v) {
      result = result.replaceAll('{$k}', '${v ?? ''}');
    });
    return result;
  }

  static String? _lookup(Map<String, dynamic> map, String key) {
    dynamic node = map;
    for (final part in key.split('.')) {
      if (node is Map<String, dynamic> && node.containsKey(part)) {
        node = node[part];
      } else {
        return null;
      }
    }
    return node is String ? node : null;
  }

  static Future<Map<String, dynamic>> _load(String code) async {
    try {
      final jsonStr = await rootBundle.loadString('$_basePath/$code.json');
      return jsonDecode(jsonStr) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('[i18n] 加载 $code.json 失败：$e');
      return <String, dynamic>{};
    }
  }

  static Future<AppLocalizations> _resolve(Locale locale) async {
    final code = _localeToCode(locale);
    final fallback = await _load(AppLocales.fallbackCode);
    final values = code == AppLocales.fallbackCode
        ? fallback
        : await _load(code);
    return AppLocalizations(locale, values, fallback);
  }

  static String _localeToCode(Locale locale) {
    if (locale.countryCode != null && locale.countryCode!.isNotEmpty) {
      return '${locale.languageCode}-${locale.countryCode}';
    }
    return locale.languageCode;
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => AppLocales.isSupported(locale);

  @override
  Future<AppLocalizations> load(Locale locale) =>
      AppLocalizations._resolve(locale);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

/// 支持的语言清单，与 `assets/i18n/manifest.json` 保持一致。
/// 新增语言：放入 `<code>.json` 并在此登记对应 [Locale]。
class AppLocales {
  AppLocales._();

  static const String fallbackCode = 'en';

  static const List<Locale> supported = <Locale>[
    Locale('en'),
    Locale('zh', 'CN'),
  ];

  static bool isSupported(Locale locale) {
    return supported.any((l) =>
        l.languageCode == locale.languageCode &&
        (l.countryCode == null || l.countryCode == locale.countryCode));
  }
}
