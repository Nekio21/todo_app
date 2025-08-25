import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

class NotificationService {
  NotificationService._();

  static bool _initialized = false;

  static final FlutterLocalNotificationsPlugin
  _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    if(_initialized) return;
    tz.initializeTimeZones();
    final String currentTimeZone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(currentTimeZone));

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _flutterLocalNotificationsPlugin.initialize(initSettings);

    _initialized = true;
  }

  static void cancel(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
  }

  static NotificationDetails _notificationDetails(){
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'todo_channel_id',
        'todo notification',
        channelDescription: 'Todo Notification Channel',
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );
  }

  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {

    tz.TZDateTime  tzScheduled = tz.TZDateTime.from(scheduledTime, tz.local);

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tzScheduled,
      _notificationDetails(),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
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
      _notificationDetails(),
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
