// lib/services/notification_service.dart
//
// ⚠️  IMPORTANT: Local notifications ONLY work on a PHYSICAL Android/iOS device.
//    They do NOT work reliably in Chrome/Edge (web) or most emulators.
//    Connect your real Android phone via USB and run:  flutter run -d <device-id>

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:intl/intl.dart';
import '../models/task.dart';

class NotificationService {
  // Singleton
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  // ─── Initialise ──────────────────────────────────────────────────────────

  Future<void> init() async {
    // Set up timezone
    tz.initializeTimeZones();
    final String timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));

    // Android init settings
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS init settings
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings =
        InitializationSettings(android: androidInit, iOS: iosInit);

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Request Android 13+ permission
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    // Request exact alarm permission (Android 12+)
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestExactAlarmsPermission();
  }

  void _onNotificationTap(NotificationResponse response) {
    // Navigation can be handled here via GetX routing if needed
  }

  // ─── Schedule a notification for a task ──────────────────────────────────

  Future<void> scheduleTaskNotification(Task task) async {
    if (task.id == null) return;

    // Parse task date + startTime → DateTime
    final dateStr = '${task.date} ${task.startTime}';
    DateTime taskDateTime;
    try {
      taskDateTime = DateFormat('yyyy-MM-dd HH:mm').parse(dateStr);
    } catch (_) {
      return;
    }

    // Subtract remind minutes
    final notifyAt = taskDateTime.subtract(Duration(minutes: task.remind));

    // Skip if already past
    if (notifyAt.isBefore(DateTime.now())) return;

    final scheduledDate = tz.TZDateTime.from(notifyAt, tz.local);

    final androidDetails = AndroidNotificationDetails(
      'task_channel',
      'Task Reminders',
      channelDescription: 'Notifications for upcoming tasks',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      styleInformation: BigTextStyleInformation(task.description),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details =
        NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _plugin.zonedSchedule(
      task.id!,
      '⏰ Reminder: ${task.title}',
      task.description.isNotEmpty
          ? task.description
          : 'Starts at ${task.startTime}',
      scheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // ─── Schedule a DAILY repeating notification ─────────────────────────────

  Future<void> scheduleRepeatingNotification(Task task) async {
    if (task.id == null) return;

    final timeParts = task.startTime.split(':');
    if (timeParts.length < 2) return;

    final hour = int.tryParse(timeParts[0]) ?? 8;
    final minute = int.tryParse(timeParts[1]) ?? 0;

    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
        tz.local, now.year, now.month, now.day, hour, minute);

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    final androidDetails = AndroidNotificationDetails(
      'repeat_channel',
      'Repeat Task Reminders',
      channelDescription: 'Daily repeating task reminders',
      importance: Importance.high,
      priority: Priority.high,
    );

    final details = NotificationDetails(android: androidDetails);

    await _plugin.zonedSchedule(
      task.id! + 10000, // offset to avoid ID collision
      '🔁 Repeat: ${task.title}',
      'Daily task at ${task.startTime}',
      scheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // repeats daily
    );
  }

  // ─── Cancel ───────────────────────────────────────────────────────────────

  Future<void> cancelNotification(int id) async {
    await _plugin.cancel(id);
    await _plugin.cancel(id + 10000); // also cancel repeat
  }

  Future<void> cancelAllNotifications() async {
    await _plugin.cancelAll();
  }

  // ─── Show an immediate test notification ──────────────────────────────────

  Future<void> showTestNotification() async {
    const androidDetails = AndroidNotificationDetails(
      'test_channel',
      'Test',
      channelDescription: 'Test notification',
      importance: Importance.max,
      priority: Priority.high,
    );
    const details = NotificationDetails(android: androidDetails);
    await _plugin.show(
        9999, '✅ Notifications Working!', 'Local notifications are set up correctly.', details);
  }
}
