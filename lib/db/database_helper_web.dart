// lib/db/database_helper_web.dart
// In-memory database for web platform (sqflite is not available on web)

import '../models/task.dart';
import '../models/subtask.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  // In-memory storage
  final List<Task> _tasks = [];
  final List<Subtask> _subtasks = [];
  int _taskIdCounter = 1;
  int _subtaskIdCounter = 1;

  // ─── Task CRUD ───────────────────────────────────────────────────────────

  Future<int> insertTask(Task task) async {
    task.id = _taskIdCounter++;
    _tasks.add(task);
    return task.id!;
  }

  Future<List<Task>> getAllTasks() async {
    return List.from(_tasks);
  }

  Future<List<Task>> getTasksByDate(String date) async {
    return _tasks
        .where((t) => t.date == date && t.isCompleted == 0)
        .toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  Future<List<Task>> getCompletedTasks() async {
    return _tasks.where((t) => t.isCompleted == 1).toList();
  }

  Future<List<Task>> getRepeatedTasks() async {
    return _tasks.where((t) => t.isRepeated == 1).toList();
  }

  Future<int> updateTask(Task task) async {
    final idx = _tasks.indexWhere((t) => t.id == task.id);
    if (idx != -1) _tasks[idx] = task;
    return idx != -1 ? 1 : 0;
  }

  Future<int> markCompleted(int id, int value) async {
    final idx = _tasks.indexWhere((t) => t.id == id);
    if (idx != -1) _tasks[idx].isCompleted = value;
    return idx != -1 ? 1 : 0;
  }

  Future<int> deleteTask(int id) async {
    _subtasks.removeWhere((s) => s.taskId == id);
    final before = _tasks.length;
    _tasks.removeWhere((t) => t.id == id);
    return before - _tasks.length;
  }

  Future<void> deleteAllCompleted() async {
    final completedIds = _tasks.where((t) => t.isCompleted == 1).map((t) => t.id!).toList();
    for (final id in completedIds) {
      _subtasks.removeWhere((s) => s.taskId == id);
    }
    _tasks.removeWhere((t) => t.isCompleted == 1);
  }

  // ─── Subtask CRUD ─────────────────────────────────────────────────────────

  Future<int> insertSubtask(Subtask subtask) async {
    subtask.id = _subtaskIdCounter++;
    _subtasks.add(subtask);
    return subtask.id!;
  }

  Future<List<Subtask>> getSubtasks(int taskId) async {
    return _subtasks.where((s) => s.taskId == taskId).toList();
  }

  Future<int> toggleSubtask(int id, int value) async {
    final idx = _subtasks.indexWhere((s) => s.id == id);
    if (idx != -1) _subtasks[idx].isDone = value;
    return idx != -1 ? 1 : 0;
  }

  Future<int> deleteSubtask(int id) async {
    final before = _subtasks.length;
    _subtasks.removeWhere((s) => s.id == id);
    return before - _subtasks.length;
  }
}
