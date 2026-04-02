// lib/models/subtask.dart

class Subtask {
  int? id;
  int taskId;
  String title;
  int isDone; // 0 = pending, 1 = done

  Subtask({
    this.id,
    required this.taskId,
    required this.title,
    this.isDone = 0,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'taskId': taskId,
        'title': title,
        'isDone': isDone,
      };

  factory Subtask.fromJson(Map<String, dynamic> json) => Subtask(
        id: json['id'],
        taskId: json['taskId'],
        title: json['title'],
        isDone: json['isDone'] ?? 0,
      );
}
