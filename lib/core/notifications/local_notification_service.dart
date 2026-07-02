import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:engez/data/models/task_model.dart';
import 'package:engez/data/models/alarm_sound_model.dart';
import 'package:engez/main.dart';
import 'package:engez/presentation/screens/alarm_screen.dart';
import 'package:engez/presentation/screens/main_navigation_Screen.dart';
import 'package:flutter/services.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'dart:io';

import 'notification_logger.dart';
import 'notification_permission.dart';
import 'notification_service.dart';

const _pickerChannel = MethodChannel('com.bsh.tasky/ringtone_picker');

@pragma('vm:entry-point')
void _onBackgroundNotificationResponse(NotificationResponse response) async {
  WidgetsFlutterBinding.ensureInitialized();
  if (response.payload == null) return;

  Map<String, dynamic> data;
  try {
    data = jsonDecode(response.payload!) as Map<String, dynamic>;
  } catch (e) {
    final parts = response.payload!.split('|');
    if (parts.length < 3) return;
    data = {
      'id': parts[0],
      'title': parts[1],
      'desc': parts[2],
      'sound': parts.length > 3 ? parts[3] : 'default',
      'snooze': 10,
    };
  }

  final taskId = data['id'] as String;
  final notifId = taskId.hashCode.abs() % 2147483647;

  final plugin = FlutterLocalNotificationsPlugin();

  if (response.actionId == 'stop') {
    if (Platform.isAndroid) {
      await _pickerChannel.invokeMethod('stopRingtone');
    }
    await plugin.cancel(notifId);
    return;
  }

  if (response.actionId == 'snooze') {
    if (Platform.isAndroid) {
      await _pickerChannel.invokeMethod('stopRingtone');
    }
    await plugin.cancel(notifId);
    await LocalNotificationService.snoozeTaskInStorage(taskId);
  }
}

/// Concrete implementation of [NotificationService] using
/// flutter_local_notifications + timezone.
class LocalNotificationService implements NotificationService {
  LocalNotificationService._();
  static final LocalNotificationService instance = LocalNotificationService._();

  static const _channelIdBase = 'tasky_alarms_v3';
  static const _channelName = 'Task Reminders';
  static const _channelDescription = 'Scheduled reminders for your tasks';

  final _plugin = FlutterLocalNotificationsPlugin();

  // ─── Helpers ─────────────────────────────────────────────────
  static int _notificationId(String taskId) =>
      taskId.hashCode.abs() % 2147483647;

  tz.TZDateTime _toTZ(DateTime dt) => tz.TZDateTime.from(dt, tz.local);

  Future<NotificationDetails> _getDetails(String alarmSoundData) async {
    final soundModel = AlarmSoundModel.fromKey(alarmSoundData);

    String channelId = '${_channelIdBase}_${soundModel.uri.hashCode}';

    AndroidNotificationSound? sound;
    bool playSound = true;

    if (soundModel.type == AlarmSoundType.system) {
      sound = UriAndroidNotificationSound(soundModel.uri);
    } else if (soundModel.type == AlarmSoundType.custom) {
      String contentUri = soundModel.uri;
      if (soundModel.uri.contains('/files/')) {
        final relativePath = soundModel.uri.split('/files/').last;
        contentUri = 'content://com.bsh.tasky.fileprovider/files/$relativePath';
      }
      sound = UriAndroidNotificationSound(contentUri);
    }

    // Dynamically create this specific channel to bypass Android limits
    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(
        AndroidNotificationChannel(
          channelId,
          _channelName,
          description: _channelDescription,
          importance: Importance.high,
          enableVibration: true,
          sound: sound,
          playSound: playSound,
        ),
      );
    }


    return NotificationDetails(
      android: AndroidNotificationDetails(
        channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.high,
        priority: Priority.high,
        enableVibration: true,
        sound: sound,
        playSound: playSound,
        icon: '@mipmap/ic_launcher',
        fullScreenIntent: true,
        category: AndroidNotificationCategory.alarm,
        audioAttributesUsage: AudioAttributesUsage.alarm,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        interruptionLevel: InterruptionLevel.active,
      ),
    );
  }

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
      onDidReceiveNotificationResponse: _onNotificationResponse,
      onDidReceiveBackgroundNotificationResponse:
          _onBackgroundNotificationResponse,
    );

    // Create base default channel
    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          '${_channelIdBase}_default',
          _channelName,
          description: _channelDescription,
          importance: Importance.high,
          enableVibration: true,
        ),
      );
    }

    // 4 — Runtime permissions
    await NotificationPermission.request(_plugin);
  }

  @override
  Future<void> schedule(TaskModel task) async {
    try {
      if (!task.reminderEnabled || task.reminderDate == null) return;
      if (task.reminderDate!.isBefore(DateTime.now())) {
        NotificationLogger.logError(
          'schedule',
          'Reminder date is in the past for "${task.taskName}"',
        );
        return;
      }

      final details = await _getDetails(task.alarmSound);

      await _plugin.zonedSchedule(
        _notificationId(task.id),
        task.taskName,
        task.taskName.isNotEmpty
            ? task.taskDescription
            : 'You have a task reminder!',
        _toTZ(task.reminderDate!),
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: jsonEncode({
          'id': task.id,
          'title': task.taskName,
          'desc': task.taskDescription,
          'sound': task.alarmSound,
          'snooze': task.snoozeDuration,
        }),
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
      final upcoming = tasks.where(
        (t) =>
            t.reminderEnabled &&
            t.reminderDate != null &&
            t.reminderDate!.isAfter(now) &&
            !t.isDone,
      );

      for (final task in upcoming) {
        await schedule(task);
      }

      NotificationLogger.logRescheduled(upcoming.length);
    } catch (e) {
      NotificationLogger.logError('rescheduleAll', e);
    }
  }

  static void _onNotificationResponse(NotificationResponse response) async {
    if (response.payload == null) return;

    Map<String, dynamic> data;
    try {
      data = jsonDecode(response.payload!) as Map<String, dynamic>;
    } catch (e) {
      final parts = response.payload!.split('|');
      if (parts.length < 3) return;
      data = {
        'id': parts[0],
        'title': parts[1],
        'desc': parts[2],
        'sound': parts.length > 3 ? parts[3] : 'default',
        'snooze': 10,
      };
    }

    final taskId = data['id'] as String;
    final title = data['title'] as String;
    final desc = data['desc'] as String;
    final alarmSound = data['sound'] as String? ?? 'default';
    final snoozeDuration = data['snooze'] as int? ?? 10;

    final notifId = _notificationId(taskId);
    final plugin = FlutterLocalNotificationsPlugin();

    if (response.actionId == 'stop') {
      if (Platform.isAndroid) {
        await _pickerChannel.invokeMethod('stopRingtone');
      }
      await plugin.cancel(notifId);
      return;
    }

    if (response.actionId == 'snooze') {
      if (Platform.isAndroid) {
        await _pickerChannel.invokeMethod('stopRingtone');
      }
      await plugin.cancel(notifId);
      await snoozeTaskInStorage(taskId);
      return;
    }

    // Default action (tap) -> push Alarm Screen
    navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (_) => AlarmScreen(
          taskId: taskId,
          title: title,
          description: desc,
          alarmSound: alarmSound,
          snoozeDuration: snoozeDuration,
          onStop: () async {
            await plugin.cancel(notifId);
            if (Platform.isAndroid) {
              await _pickerChannel.invokeMethod('stopRingtone');
            }
          },
          onSnooze: () async {
            await plugin.cancel(notifId);
            if (Platform.isAndroid) {
              await _pickerChannel.invokeMethod('stopRingtone');
            }
            await snoozeTaskInStorage(taskId);
          },
        ),
      ),
    );
  }

  static Future<void> snoozeTaskInStorage(String taskId) async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = prefs.getStringList('tasks');
    if (tasksJson == null) return;

    List<TaskModel> tasks = tasksJson
        .map((j) => TaskModel.fromJson(jsonDecode(j)))
        .toList();

    final index = tasks.indexWhere((t) => t.id == taskId);
    if (index != -1) {
      final task = tasks[index];
      final snoozeDate = DateTime.now().add(
        Duration(minutes: task.snoozeDuration),
      );

      final updatedTask = task.copyWith(
        reminderDate: snoozeDate,
        reminderEnabled: true,
        dateTime: snoozeDate.toIso8601String(),
      );

      tasks[index] = updatedTask;

      await prefs.setStringList(
        'tasks',
        tasks.map((t) => jsonEncode(t.toJson())).toList(),
      );

      // Reschedule
      await LocalNotificationService.instance.schedule(updatedTask);

      // Trigger global refresh so any open UI updates immediately
      MainNavigationScreen.refresh();
    }
  }
}
