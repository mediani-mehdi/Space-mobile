import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import '../models/task.dart';

class NotificationService {
  NotificationService._privateConstructor();
  static final NotificationService _instance = NotificationService._privateConstructor();
  factory NotificationService() => _instance;

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tzdata.initializeTimeZones();
    final String timeZoneName = await FlutterNativeTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));

    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings settings = InitializationSettings(android: androidSettings);

    await _flutterLocalNotificationsPlugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // handle notification tapped logic if needed
      },
    );
  }

  int _idForTask(Task task) => task.id.hashCode;

  Future<void> scheduleNotification(Task task) async {
    if (!task.reminder || task.reminderDate == null) return;

    final scheduledDate = tz.TZDateTime.from(task.reminderDate!, tz.local);

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      _idForTask(task),
      task.title,
      task.description ?? '',
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'task_reminders',
          'Task Reminders',
          channelDescription: 'Reminders for tasks',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dateAndTime,
    );
  }

  Future<void> cancelNotification(String taskId) async {
    await _flutterLocalNotificationsPlugin.cancel(taskId.hashCode);
  }
}
