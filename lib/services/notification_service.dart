import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

class NotificationService {
  NotificationService._();

  static final FlutterLocalNotificationsPlugin
  _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings();

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _flutterLocalNotificationsPlugin.initialize(initSettings);

    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }

    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  static void cancel(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
  }

  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    final tz.TZDateTime tzScheduled = tz.TZDateTime.from(
      scheduledTime,
      tz.local,
    );

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tzScheduled,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'todo_channel4353eR3',
          'todo channel',
          channelDescription: 'todo todo',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexact,
    );
  }

  static Future<void> notificationNow({
    required int id,
    required String title,
    required String body,
  }) async {
    await _flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'todo_channel4353eR3',
          'todo channel',
          channelDescription: 'todo todo',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
    );
  }

  static DateTime getNotificationDateTime(DateTime deadline) {
    DateTime now = DateTime.now();
    Duration difference = deadline.difference(now);
    Duration duration;
    if (difference.isNegative == false) {
      duration = Duration(seconds: (difference.inSeconds * 0.7).round());
    } else {
      duration = Duration(seconds: 1);
    }
    return now.add(duration);
  }
}
