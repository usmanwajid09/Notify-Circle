// lib/models/task.dart

class Task {
  int? id;
  String title;
  String description;
  String date;       // yyyy-MM-dd
  String startTime;  // HH:mm
  String endTime;    // HH:mm
  int isCompleted;   // 0 = pending, 1 = done
  String color;      // hex color string index
  int isRepeated;    // 0 = no, 1 = yes
  String repeatDays; // comma-separated: "Mon,Tue,Wed"
  String category;   // Work, Personal, Shopping, etc.
  int remind;        // minutes before task (5, 10, 15, 30)

  Task({
    this.id,
    required this.title,
    this.description = '',
    required this.date,
    required this.startTime,
    this.endTime = '',
    this.isCompleted = 0,
    this.color = '0',
    this.isRepeated = 0,
    this.repeatDays = '',
    this.category = 'Personal',
    this.remind = 5,
  });

  /// Convert a Task to a Map for DB insertion
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date,
      'startTime': startTime,
      'endTime': endTime,
      'isCompleted': isCompleted,
      'color': color,
      'isRepeated': isRepeated,
      'repeatDays': repeatDays,
      'category': category,
      'remind': remind,
    };
  }

  /// Create a Task from a DB row Map
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'] ?? '',
      date: json['date'],
      startTime: json['startTime'],
      endTime: json['endTime'] ?? '',
      isCompleted: json['isCompleted'] ?? 0,
      color: json['color'] ?? '0',
      isRepeated: json['isRepeated'] ?? 0,
      repeatDays: json['repeatDays'] ?? '',
      category: json['category'] ?? 'Personal',
      remind: json['remind'] ?? 5,
    );
  }

  @override
  String toString() => 'Task(id=$id, title=$title, date=$date)';
}
