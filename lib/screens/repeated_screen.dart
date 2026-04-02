// lib/screens/repeated_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/task_controller.dart';
import '../widgets/task_tile.dart';

class RepeatedScreen extends StatelessWidget {
  const RepeatedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<TaskController>();

    return Obx(() {
      if (ctrl.repeatedTasks.isEmpty) {
        return Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.repeat, size: 72, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'No repeating tasks.\nAdd one with the repeat option!',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.grey.shade500, fontSize: 15, height: 1.5),
            ),
          ]),
        );
      }

      return Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Row(children: [
            const Icon(Icons.info_outline, size: 14, color: Colors.grey),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                'These tasks repeat automatically. '
                'Swipe right to mark done, left to delete.',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ),
          ]),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(top: 4, bottom: 80),
            itemCount: ctrl.repeatedTasks.length,
            itemBuilder: (_, i) {
              final task = ctrl.repeatedTasks[i];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (task.repeatDays.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 16, 0),
                      child: _DayChips(days: task.repeatDays),
                    ),
                  TaskTile(task: task),
                ],
              );
            },
          ),
        ),
      ]);
    });
  }
}

class _DayChips extends StatelessWidget {
  final String days;
  const _DayChips({required this.days});

  @override
  Widget build(BuildContext context) {
    final list = days.split(',').where((d) => d.isNotEmpty).toList();
    return Wrap(
      spacing: 4,
      children: list.map((d) => Chip(
            label: Text(d,
                style: const TextStyle(
                    fontSize: 10, fontWeight: FontWeight.w600)),
            padding: EdgeInsets.zero,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
            backgroundColor:
                Theme.of(context).primaryColor.withOpacity(0.15),
          )).toList(),
    );
  }
}
