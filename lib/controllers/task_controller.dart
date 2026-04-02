// lib/controllers/task_controller.dart

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../models/subtask.dart';

// Conditional imports: use in-memory DB on web, SQLite on native
import '../db/database_helper_web.dart'
    if (dart.library.io) '../db/database_helper.dart';

// Conditional import for notifications
import '../services/notification_service_stub.dart'
    if (dart.library.io) '../services/notification_service.dart';

class TaskController extends GetxController {
  final DatabaseHelper _db = DatabaseHelper();
  final NotificationService _notif = NotificationService();

  // Observable lists
  final RxList<Task> todayTasks = <Task>[].obs;
  final RxList<Task> completedTasks = <Task>[].obs;
  final RxList<Task> repeatedTasks = <Task>[].obs;
  final RxList<Subtask> subtasks = <Subtask>[].obs;

  // Selected date for the date picker (defaults to today)
  final Rx<DateTime> selectedDate = DateTime.now().obs;

  @override
  void onReady() {
    super.onReady();
    getTodayTasks();
    getCompletedTasks();
    getRepeatedTasks();
  }

  // ─── Fetch helpers ──────────────────────────────────────────────────────

  String get _selectedDateStr =>
      DateFormat('yyyy-MM-dd').format(selectedDate.value);

  Future<void> getTodayTasks() async {
    final tasks = await _db.getTasksByDate(_selectedDateStr);
    todayTasks.assignAll(tasks);
  }

  Future<void> getCompletedTasks() async {
    final tasks = await _db.getCompletedTasks();
    completedTasks.assignAll(tasks);
  }

  Future<void> getRepeatedTasks() async {
    final tasks = await _db.getRepeatedTasks();
    repeatedTasks.assignAll(tasks);
  }

  Future<void> getSubtasks(int taskId) async {
    final subs = await _db.getSubtasks(taskId);
    subtasks.assignAll(subs);
  }

  // ─── Task CRUD ──────────────────────────────────────────────────────────

  Future<void> addTask(Task task) async {
    final id = await _db.insertTask(task);
    task.id = id;

    // Schedule local notification (no-op on web)
    if (!kIsWeb) {
      if (task.isRepeated == 1) {
        await _notif.scheduleRepeatingNotification(task);
      } else {
        await _notif.scheduleTaskNotification(task);
      }
    }

    _refreshAll();
  }

  Future<void> updateTask(Task task) async {
    await _db.updateTask(task);

    // Re-schedule notification (no-op on web)
    if (!kIsWeb) {
      await _notif.cancelNotification(task.id!);
      if (task.isRepeated == 1) {
        await _notif.scheduleRepeatingNotification(task);
      } else {
        await _notif.scheduleTaskNotification(task);
      }
    }

    _refreshAll();
  }

  Future<void> deleteTask(Task task) async {
    await _db.deleteTask(task.id!);
    if (!kIsWeb) await _notif.cancelNotification(task.id!);
    _refreshAll();
  }

  Future<void> markCompleted(Task task) async {
    await _db.markCompleted(task.id!, 1);
    if (!kIsWeb) await _notif.cancelNotification(task.id!);
    _refreshAll();
  }

  Future<void> markPending(Task task) async {
    await _db.markCompleted(task.id!, 0);
    _refreshAll();
  }

  Future<void> deleteAllCompleted() async {
    await _db.deleteAllCompleted();
    _refreshAll();
  }

  // ─── Subtask helpers ─────────────────────────────────────────────────────

  Future<void> addSubtask(Subtask sub) async {
    await _db.insertSubtask(sub);
    await getSubtasks(sub.taskId);
  }

  Future<void> toggleSubtask(Subtask sub) async {
    await _db.toggleSubtask(sub.id!, sub.isDone == 0 ? 1 : 0);
    await getSubtasks(sub.taskId);
  }

  Future<void> deleteSubtask(Subtask sub) async {
    await _db.deleteSubtask(sub.id!);
    await getSubtasks(sub.taskId);
  }

  /// Returns progress 0.0–1.0 for a task
  double getProgress(int taskId) {
    final subs = subtasks.where((s) => s.taskId == taskId).toList();
    if (subs.isEmpty) return 0.0;
    final done = subs.where((s) => s.isDone == 1).length;
    return done / subs.length;
  }

  // ─── Date picker ─────────────────────────────────────────────────────────

  void changeDate(DateTime date) {
    selectedDate.value = date;
    getTodayTasks();
  }

  // ─── Internal ────────────────────────────────────────────────────────────

  void _refreshAll() {
    getTodayTasks();
    getCompletedTasks();
    getRepeatedTasks();
  }
}
