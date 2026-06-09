import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:likenovel/app/theme.dart';
import 'package:likenovel/app/router.dart';
import 'package:likenovel/core/i18n/app_localizations.dart';
import 'package:likenovel/core/i18n/locale_controller.dart';

class likenovelApp extends ConsumerWidget {
  const likenovelApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      title: 'likenovel',
      theme: ElTheme.lightTheme(),
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
      locale: locale,
      supportedLocales: AppLocales.supported,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
