import 'package:engez/core/notifications/notification_service.dart';
import 'package:engez/data/models/task_model.dart';

/// Cancels the old reminder and schedules a new one when a task is updated.
class UpdateTaskReminderUseCase {
  final NotificationService _notificationService;

  const UpdateTaskReminderUseCase(this._notificationService);

  Future<void> execute(TaskModel task) async {
    // Always cancel the old one first (even if reminder was disabled)
    await _notificationService.cancel(task.id);

    if (!task.reminderEnabled) return;
    if (task.reminderDate == null) return;
    if (task.reminderDate!.isBefore(DateTime.now())) return;

    await _notificationService.schedule(task);
  }
}
