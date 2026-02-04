import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:flutter_timezone/flutter_timezone.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz_data.initializeTimeZones();
    final String timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        // Handle notification tap
      },
    );
  }

  Future<void> scheduleDailyReminder(DateTime lastLearningTime) async {
    await _notificationsPlugin.cancelAll();

    final scheduledDate = tz.TZDateTime.from(
      lastLearningTime.add(const Duration(days: 1)),
      tz.local,
    );

    // If for some reason the scheduled date is in the past, don't schedule
    if (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) {
      return;
    }

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'daily_learning_reminder',
      'Daily Learning Reminder',
      channelDescription: 'Reminds you to continue your learning journey',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    await _notificationsPlugin.zonedSchedule(
      0,
      'Continuue Learning!',
      "It's time for your daily skill build. You started learning at this time yesterday!",
      scheduledDate,
      platformDetails,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }
}
