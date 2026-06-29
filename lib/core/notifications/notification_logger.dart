import 'package:flutter/foundation.dart';

/// Debug-only logger for notification events.
/// All calls are no-ops in release mode.
class NotificationLogger {
  NotificationLogger._();

  static void logScheduled(String taskName, DateTime reminderDate) {
    if (kDebugMode) {
      debugPrint('🔔 [Notification] Scheduled: "$taskName" @ $reminderDate');
    }
  }

  static void logCancelled(String taskId) {
    if (kDebugMode) {
      debugPrint('🚫 [Notification] Cancelled for taskId: $taskId');
    }
  }

  static void logUpdated(String taskName, DateTime reminderDate) {
    if (kDebugMode) {
      debugPrint('🔄 [Notification] Updated: "$taskName" @ $reminderDate');
    }
  }

  static void logRescheduled(int count) {
    if (kDebugMode) {
      debugPrint('♻️ [Notification] Rescheduled $count reminder(s) on app start');
    }
  }

  static void logError(String operation, Object error) {
    if (kDebugMode) {
      debugPrint('❌ [Notification] Error during "$operation": $error');
    }
  }
}
