import 'package:engez/core/notifications/notification_service.dart';
import 'package:engez/data/models/task_model.dart';

/// Schedules a reminder notification for the given [task].
/// Only runs if [task.reminderEnabled] is true and the reminder date is in
/// the future. The task is already saved before this UseCase is called.
class ScheduleTaskReminderUseCase {
  final NotificationService _notificationService;

  const ScheduleTaskReminderUseCase(this._notificationService);

  Future<void> execute(TaskModel task) async {
    if (!task.reminderEnabled) return;
    if (task.reminderDate == null) return;
    if (task.reminderDate!.isBefore(DateTime.now())) return;
    await _notificationService.schedule(task);
  }

  /// Re-schedules all pending reminders (called on app start / device reboot).
  Future<void> rescheduleAll(List<TaskModel> tasks) async {
    await _notificationService.rescheduleAll(tasks);
  }
}
