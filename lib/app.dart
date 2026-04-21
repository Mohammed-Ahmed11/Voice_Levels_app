import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:voice_levels_app/l10n/app_localizations.dart';
import 'routes.dart';

class LocaleController extends ChangeNotifier {
  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  void changeLocale(String code) {
    _locale = Locale(code);
    notifyListeners();
  }
}

class MyApp extends StatelessWidget {
  final LocaleController controller;

  const MyApp({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return MaterialApp(
          locale: controller.locale,
          supportedLocales: const [
            Locale('en'),
            Locale('ar'),
          ],
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          debugShowCheckedModeBanner: false,
          title: 'Voice Levels',
          theme: ThemeData(useMaterial3: true),
          initialRoute: AppRoutes.loading,
          routes: AppRoutes.map,
        );
      },
    );
  }
}
