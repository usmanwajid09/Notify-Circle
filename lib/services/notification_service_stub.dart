// lib/services/notification_service_stub.dart
// Web/unsupported platform stub — all methods are no-ops

import '../models/task.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  Future<void> init() async {}
  Future<void> scheduleTaskNotification(Task task) async {}
  Future<void> scheduleRepeatingNotification(Task task) async {}
  Future<void> cancelNotification(int id) async {}
  Future<void> cancelAllNotifications() async {}
  Future<void> showTestNotification() async {}
}
