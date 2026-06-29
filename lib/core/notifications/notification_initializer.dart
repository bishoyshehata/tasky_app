import 'local_notification_service.dart';
import 'notification_logger.dart';

/// Single entry-point called from [main()] before [runApp()].
class NotificationInitializer {
  NotificationInitializer._();

  static Future<void> init() async {
    try {
      await LocalNotificationService.instance.initialize();
    } catch (e) {
      NotificationLogger.logError('NotificationInitializer.init', e);
    }
  }
}
