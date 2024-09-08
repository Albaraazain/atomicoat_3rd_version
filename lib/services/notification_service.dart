import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../models/maintenance_task.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  NotificationService() {
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    tz.initializeTimeZones();
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('app_icon');
    final DarwinInitializationSettings initializationSettingsDarwin =
    DarwinInitializationSettings();
    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
      macOS: initializationSettingsDarwin,
    );
    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> scheduleNotification(MaintenanceTask task) async {
    final scheduledDate = tz.TZDateTime.from(task.dueDate, tz.local);
    await _flutterLocalNotificationsPlugin.zonedSchedule(
      task.id.hashCode,
      'Maintenance Task Due',
      '${task.name} is due today',
      scheduledDate,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'maintenance_channel',
          'Maintenance Notifications',
          channelDescription: 'Notifications for due maintenance tasks',
          importance: Importance.high,
          priority: Priority.high,
          // Removing ambiguous usage by not setting bigLargeIcon at all
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancelNotification(MaintenanceTask task) async {
    await _flutterLocalNotificationsPlugin.cancel(task.id.hashCode);
  }
}
