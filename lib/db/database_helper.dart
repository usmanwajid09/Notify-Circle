// lib/db/database_helper.dart

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import '../models/task.dart';
import '../models/subtask.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _db;

  // ─── Open / create database ───────────────────────────────────────────────

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, 'task_manager.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Tasks table
    await db.execute('''
      CREATE TABLE tasks (
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        title       TEXT    NOT NULL,
        description TEXT,
        date        TEXT    NOT NULL,
        startTime   TEXT    NOT NULL,
        endTime     TEXT,
        isCompleted INTEGER DEFAULT 0,
        color       TEXT    DEFAULT '0',
        isRepeated  INTEGER DEFAULT 0,
        repeatDays  TEXT    DEFAULT '',
        category    TEXT    DEFAULT 'Personal',
        remind      INTEGER DEFAULT 5
      )
    ''');

    // Subtasks table
    await db.execute('''
      CREATE TABLE subtasks (
        id     INTEGER PRIMARY KEY AUTOINCREMENT,
        taskId INTEGER NOT NULL,
        title  TEXT    NOT NULL,
        isDone INTEGER DEFAULT 0,
        FOREIGN KEY (taskId) REFERENCES tasks(id) ON DELETE CASCADE
      )
    ''');
  }

  // ─── Task CRUD ────────────────────────────────────────────────────────────

  Future<int> insertTask(Task task) async {
    final db = await database;
    return await db.insert('tasks', task.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Task>> getAllTasks() async {
    final db = await database;
    final rows = await db.query('tasks', orderBy: 'date ASC, startTime ASC');
    return rows.map((r) => Task.fromJson(r)).toList();
  }

  /// Tasks for a specific date (yyyy-MM-dd)
  Future<List<Task>> getTasksByDate(String date) async {
    final db = await database;
    final rows = await db.query(
      'tasks',
      where: 'date = ? AND isCompleted = 0',
      whereArgs: [date],
      orderBy: 'startTime ASC',
    );
    return rows.map((r) => Task.fromJson(r)).toList();
  }

  Future<List<Task>> getCompletedTasks() async {
    final db = await database;
    final rows = await db.query(
      'tasks',
      where: 'isCompleted = 1',
      orderBy: 'date DESC',
    );
    return rows.map((r) => Task.fromJson(r)).toList();
  }

  Future<List<Task>> getRepeatedTasks() async {
    final db = await database;
    final rows = await db.query(
      'tasks',
      where: 'isRepeated = 1',
      orderBy: 'startTime ASC',
    );
    return rows.map((r) => Task.fromJson(r)).toList();
  }

  Future<int> updateTask(Task task) async {
    final db = await database;
    return await db.update(
      'tasks',
      task.toJson(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  Future<int> markCompleted(int id, int value) async {
    final db = await database;
    return await db.update(
      'tasks',
      {'isCompleted': value},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteTask(int id) async {
    final db = await database;
    await db.delete('subtasks', where: 'taskId = ?', whereArgs: [id]);
    return await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteAllCompleted() async {
    final db = await database;
    final completed = await getCompletedTasks();
    for (final t in completed) {
      await db.delete('subtasks', where: 'taskId = ?', whereArgs: [t.id]);
    }
    await db.delete('tasks', where: 'isCompleted = 1');
  }

  // ─── Subtask CRUD ─────────────────────────────────────────────────────────

  Future<int> insertSubtask(Subtask subtask) async {
    final db = await database;
    return await db.insert('subtasks', subtask.toJson());
  }

  Future<List<Subtask>> getSubtasks(int taskId) async {
    final db = await database;
    final rows = await db.query(
      'subtasks',
      where: 'taskId = ?',
      whereArgs: [taskId],
    );
    return rows.map((r) => Subtask.fromJson(r)).toList();
  }

  Future<int> toggleSubtask(int id, int value) async {
    final db = await database;
    return await db.update(
      'subtasks',
      {'isDone': value},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteSubtask(int id) async {
    final db = await database;
    return await db.delete('subtasks', where: 'id = ?', whereArgs: [id]);
  }
}
