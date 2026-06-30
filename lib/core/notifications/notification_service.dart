import 'package:engez/data/models/task_model.dart';

/// Abstract contract for the notification system.
/// Any feature in the project interacts ONLY with this interface.
abstract class NotificationService {
  Future<void> initialize();
  Future<void> schedule(TaskModel task);
  Future<void> cancel(String taskId);
  Future<void> update(TaskModel task);
  Future<void> cancelAll();
  Future<void> rescheduleAll(List<TaskModel> tasks);
}
