import 'package:engez/core/notifications/notification_service.dart';

/// Cancels the scheduled reminder for the given [taskId].
/// Used when a task is deleted or marked as completed.
class CancelTaskReminderUseCase {
  final NotificationService _notificationService;

  const CancelTaskReminderUseCase(this._notificationService);

  Future<void> execute(String taskId) async {
    await _notificationService.cancel(taskId);
  }
}
