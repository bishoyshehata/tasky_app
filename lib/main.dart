import 'package:flutter/material.dart';
import 'core/notifications/notification_initializer.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_theme_notifier.dart';
import 'presentation/screens/splash_screen.dart';
import 'data/models/task_model.dart';
import 'core/notifications/local_notification_service.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'presentation/screens/alarm_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppThemeNotifier.instance.load();
  await NotificationInitializer.init();

  runApp(const MyApp());

  // Check if app was launched via full-screen intent or notification tap
  // _handleInitialNotificationLaunch();
}

Future<void> _handleInitialNotificationLaunch() async {
  final plugin = FlutterLocalNotificationsPlugin();
  final details = await plugin.getNotificationAppLaunchDetails();

  if (details != null && details.didNotificationLaunchApp) {
    final response = details.notificationResponse;
    if (response != null && response.payload != null) {
      final parts = response.payload!.split('|');
      if (parts.length >= 3) {
        Future.delayed(const Duration(milliseconds: 500), () {
          navigatorKey.currentState?.push(
            MaterialPageRoute(
              builder: (_) => AlarmScreen(
                title: parts[1],
                description: parts[2],
                alarmSound: parts.length > 3 ? parts[3] : 'default',
                onStop: () {},
                onSnooze: () {
                  // Manual snooze from main launch
                  LocalNotificationService.snoozeTaskInStorage(parts[0]);
                },
              ),
            ),
          );
        });
      }
    }
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: AppThemeNotifier.instance,
      builder: (context, themeMode, _) {
        return MaterialApp(
          navigatorKey: navigatorKey,
          debugShowCheckedModeBanner: false,
          title: 'Tasky',
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: themeMode,
          home: const SplashScreen(),
        );
      },
    );
  }
}
