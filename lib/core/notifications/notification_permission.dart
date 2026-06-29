import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'notification_logger.dart';

/// Handles runtime notification permission requests for Android & iOS.
class NotificationPermission {
  NotificationPermission._();

  static Future<void> request(
    FlutterLocalNotificationsPlugin plugin,
  ) async {
    if (Platform.isAndroid) {
      await _requestAndroid(plugin);
    } else if (Platform.isIOS) {
      await _requestIOS(plugin);
    }
  }

  static Future<void> _requestAndroid(
    FlutterLocalNotificationsPlugin plugin,
  ) async {
    final android = plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (android == null) return;

    // POST_NOTIFICATIONS (Android 13+)
    final notifGranted = await android.requestNotificationsPermission();
    NotificationLogger.logError(
      'POST_NOTIFICATIONS',
      'granted: $notifGranted',
    );

    // SCHEDULE_EXACT_ALARM (Android 12+)
    final exactGranted = await android.requestExactAlarmsPermission();
    NotificationLogger.logError(
      'SCHEDULE_EXACT_ALARM',
      'granted: $exactGranted',
    );
  }

  static Future<void> _requestIOS(
    FlutterLocalNotificationsPlugin plugin,
  ) async {
    final ios = plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();

    if (ios == null) return;

    final granted = await ios.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
    NotificationLogger.logError('iOS permission', 'granted: $granted');
  }
}
