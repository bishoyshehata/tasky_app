import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'core/l10n/app_locale_notifier.dart';
import 'core/notifications/notification_initializer.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_theme_notifier.dart';
import 'l10n/app_localizations.dart';
import 'presentation/screens/splash_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppThemeNotifier.instance.load();
  await AppLocaleNotifier.instance.load();
  await NotificationInitializer.init();

  runApp(const EngezApp());
}

class EngezApp extends StatelessWidget {
  const EngezApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return ValueListenableBuilder<Locale>(
          valueListenable: AppLocaleNotifier.instance,
          builder: (context, locale, _) {
            return ValueListenableBuilder<ThemeMode>(
              valueListenable: AppThemeNotifier.instance,
              builder: (context, themeMode, _) {
                return MaterialApp(
                  navigatorKey: navigatorKey,
                  debugShowCheckedModeBanner: false,
                  title: 'Engez',

                  // ── Localisation ──────────────────────────────
                  locale: locale,
                  supportedLocales: AppLocalizations.supportedLocales,
                  localizationsDelegates: const [
                    AppLocalizations.delegate,
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                    GlobalCupertinoLocalizations.delegate,
                  ],

                  // ── Theme ─────────────────────────────────────
                  theme: AppTheme.light,
                  darkTheme: AppTheme.dark,
                  themeMode: themeMode,

                  home: const SplashScreen(),
                );
              },
            );
          },
        );
      },
    );
  }
}
