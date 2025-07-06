import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    // Initialize time zone data
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Kuala_Lumpur')); // or your region

    // Android initialization
    const AndroidInitializationSettings androidInitSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings = InitializationSettings(
      android: androidInitSettings,
    );

    await _flutterLocalNotificationsPlugin.initialize(initSettings);

    // Request notification permission (Android 13+)
    if (Platform.isAndroid) {
      final status = await Permission.notification.status;
      if (!status.isGranted) {
        await Permission.notification.request();
      }
    }
  }

  Future<void> showImmediateNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'workout_channel', // channel ID
      'Workout Notifications', // channel name
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
    );

    await _flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      platformDetails,
    );
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'workout_channel',
      'Workout Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    // ✅ Convert DateTime to TZDateTime
    final tz.TZDateTime tzScheduledDate =
        tz.TZDateTime.from(scheduledDate, tz.local);

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tzScheduledDate, // ✅ Use TZDateTime here
      notificationDetails,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.wallClockTime,
      matchDateTimeComponents: DateTimeComponents.dateAndTime,
    );
  }
}
