// lib/widgets/task_tile.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/task.dart';
import '../models/subtask.dart';
import '../controllers/task_controller.dart';
import '../utils/theme_controller.dart';

class TaskTile extends StatefulWidget {
  final Task task;
  final bool showComplete;

  const TaskTile({super.key, required this.task, this.showComplete = true});

  @override
  State<TaskTile> createState() => _TaskTileState();
}

class _TaskTileState extends State<TaskTile> {
  final TaskController _ctrl = Get.find<TaskController>();
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final color = taskColorFromIndex(widget.task.color);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dismissible(
      key: Key('task_${widget.task.id}'),
      background: _swipeBg(Colors.green, Icons.check, Alignment.centerLeft),
      secondaryBackground:
          _swipeBg(Colors.red, Icons.delete, Alignment.centerRight),
      confirmDismiss: (dir) async {
        if (dir == DismissDirection.startToEnd) {
          _ctrl.markCompleted(widget.task);
          return false; // handled manually
        } else {
          return await _confirmDelete(context);
        }
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Column(
          children: [
            ListTile(
              leading: Container(
                width: 6,
                height: 60,
                decoration: BoxDecoration(
                    color: color, borderRadius: BorderRadius.circular(4)),
              ),
              title: Text(
                widget.task.title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  decoration: widget.task.isCompleted == 1
                      ? TextDecoration.lineThrough
                      : null,
                  color: widget.task.isCompleted == 1
                      ? Colors.grey
                      : isDark ? Colors.white : Colors.black87,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 2),
                  Row(children: [
                    const Icon(Icons.access_time, size: 13, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      '${widget.task.startTime}'
                      '${widget.task.endTime.isNotEmpty ? " → ${widget.task.endTime}" : ""}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        widget.task.category,
                        style: TextStyle(
                            fontSize: 10,
                            color: color,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ]),
                  if (widget.task.description.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        widget.task.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 12, color: Colors.grey),
                      ),
                    ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.task.isRepeated == 1)
                    const Icon(Icons.repeat,
                        size: 16, color: Colors.blueGrey),
                  const SizedBox(width: 4),
                  IconButton(
                    icon: Icon(
                      _expanded
                          ? Icons.expand_less
                          : Icons.expand_more,
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() => _expanded = !_expanded);
                      if (_expanded) {
                        _ctrl.getSubtasks(widget.task.id!);
                      }
                    },
                  ),
                ],
              ),
            ),

            // ── Subtask progress section ─────────────────────────────────
            if (_expanded)
              Obx(() {
                final subs = _ctrl.subtasks
                    .where((s) => s.taskId == widget.task.id)
                    .toList();
                final progress = _ctrl.getProgress(widget.task.id!);

                return Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 16, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Progress bar
                      Row(children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: progress,
                              minHeight: 8,
                              backgroundColor:
                                  color.withOpacity(0.2),
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(color),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${(progress * 100).toInt()}%',
                          style: TextStyle(
                              fontSize: 12, color: color),
                        ),
                      ]),
                      const SizedBox(height: 8),

                      // Subtask list
                      ...subs.map((sub) => _subtaskRow(sub)),

                      // Add subtask field
                      _AddSubtaskField(taskId: widget.task.id!),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _subtaskRow(Subtask sub) {
    return Row(
      children: [
        Checkbox(
          value: sub.isDone == 1,
          onChanged: (_) => _ctrl.toggleSubtask(sub),
        ),
        Expanded(
          child: Text(
            sub.title,
            style: TextStyle(
              decoration:
                  sub.isDone == 1 ? TextDecoration.lineThrough : null,
              color: sub.isDone == 1 ? Colors.grey : null,
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close, size: 16),
          onPressed: () => _ctrl.deleteSubtask(sub),
        ),
      ],
    );
  }

  Widget _swipeBg(Color color, IconData icon, Alignment align) {
    return Container(
      color: color.withOpacity(0.8),
      alignment: align,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Icon(icon, color: Colors.white, size: 28),
    );
  }

  Future<bool> _confirmDelete(BuildContext ctx) async {
    return await showDialog<bool>(
          context: ctx,
          builder: (_) => AlertDialog(
            title: const Text('Delete Task'),
            content: const Text('Are you sure you want to delete this task?'),
            actions: [
              TextButton(
                  onPressed: () => Get.back(result: false),
                  child: const Text('Cancel')),
              TextButton(
                onPressed: () {
                  _ctrl.deleteTask(widget.task);
                  Get.back(result: false);
                },
                child: const Text('Delete',
                    style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ) ??
        false;
  }
}

// ─── Add subtask inline field ─────────────────────────────────────────────────

class _AddSubtaskField extends StatefulWidget {
  final int taskId;
  const _AddSubtaskField({required this.taskId});

  @override
  State<_AddSubtaskField> createState() => _AddSubtaskFieldState();
}

class _AddSubtaskFieldState extends State<_AddSubtaskField> {
  final _ctrl = Get.find<TaskController>();
  final _textCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _textCtrl,
            decoration: const InputDecoration(
              hintText: 'Add subtask…',
              hintStyle: TextStyle(fontSize: 13),
              isDense: true,
              border: InputBorder.none,
            ),
            style: const TextStyle(fontSize: 13),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.add_circle_outline, size: 20),
          onPressed: () {
            if (_textCtrl.text.trim().isEmpty) return;
            _ctrl.addSubtask(Subtask(
              taskId: widget.taskId,
              title: _textCtrl.text.trim(),
            ));
            _textCtrl.clear();
          },
        ),
      ],
    );
  }
}
