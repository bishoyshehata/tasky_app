import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:tasky/data/models/task_model.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'notification_logger.dart';
import 'notification_permission.dart';
import 'notification_service.dart';

/// Concrete implementation of [NotificationService] using
/// flutter_local_notifications + timezone.
class LocalNotificationService implements NotificationService {
  LocalNotificationService._();
  static final LocalNotificationService instance = LocalNotificationService._();

  static const _channelId = 'tasky_reminders';
  static const _channelName = 'Task Reminders';
  static const _channelDescription = 'Scheduled reminders for your tasks';

  final _plugin = FlutterLocalNotificationsPlugin();

  // ─── Helpers ─────────────────────────────────────────────────
  int _notificationId(String taskId) =>
      taskId.hashCode.abs() % 2147483647;

  tz.TZDateTime _toTZ(DateTime dt) =>
      tz.TZDateTime.from(dt, tz.local);

  NotificationDetails get _details => const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.high,
          priority: Priority.high,
          enableVibration: true,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      );

  // ─── Public API ───────────────────────────────────────────────

  @override
  Future<void> initialize() async {
    // 1 — Timezone
    tz.initializeTimeZones();
    final localTz = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(localTz));

    // 2 — Plugin init settings
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );

    // 3 — Android notification channel
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(
          const AndroidNotificationChannel(
            _channelId,
            _channelName,
            description: _channelDescription,
            importance: Importance.high,
            enableVibration: true,
          ),
        );

    // 4 — Runtime permissions
    await NotificationPermission.request(_plugin);
  }

  @override
  Future<void> schedule(TaskModel task) async {
    try {
      if (!task.reminderEnabled || task.reminderDate == null) return;
      if (task.reminderDate!.isBefore(DateTime.now())) {
        NotificationLogger.logError(
            'schedule', 'Reminder date is in the past for "${task.taskName}"');
        return;
      }

      await _plugin.zonedSchedule(
        _notificationId(task.id),
        task.taskName,
        task.taskDescription.isNotEmpty
            ? task.taskDescription
            : 'You have a task reminder!',
        _toTZ(task.reminderDate!),
        _details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );

      NotificationLogger.logScheduled(task.taskName, task.reminderDate!);
    } catch (e) {
      NotificationLogger.logError('schedule', e);
    }
  }

  @override
  Future<void> cancel(String taskId) async {
    try {
      await _plugin.cancel(_notificationId(taskId));
      NotificationLogger.logCancelled(taskId);
    } catch (e) {
      NotificationLogger.logError('cancel', e);
    }
  }

  @override
  Future<void> update(TaskModel task) async {
    try {
      await cancel(task.id);
      await schedule(task);
      if (task.reminderDate != null) {
        NotificationLogger.logUpdated(task.taskName, task.reminderDate!);
      }
    } catch (e) {
      NotificationLogger.logError('update', e);
    }
  }

  @override
  Future<void> cancelAll() async {
    try {
      await _plugin.cancelAll();
      NotificationLogger.logCancelled('ALL');
    } catch (e) {
      NotificationLogger.logError('cancelAll', e);
    }
  }

  @override
  Future<void> rescheduleAll(List<TaskModel> tasks) async {
    try {
      final now = DateTime.now();
      final upcoming = tasks.where((t) =>
          t.reminderEnabled &&
          t.reminderDate != null &&
          t.reminderDate!.isAfter(now) &&
          !t.isDone);

      for (final task in upcoming) {
        await schedule(task);
      }

      NotificationLogger.logRescheduled(upcoming.length);
    } catch (e) {
      NotificationLogger.logError('rescheduleAll', e);
    }
  }
}
