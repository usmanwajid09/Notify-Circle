// lib/screens/completed_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/task_controller.dart';
import '../widgets/task_tile.dart';

class CompletedScreen extends StatelessWidget {
  const CompletedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<TaskController>();

    return Obx(() {
      if (ctrl.completedTasks.isEmpty) {
        return Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.done_all, size: 72, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text('No completed tasks yet.',
                style: TextStyle(
                    color: Colors.grey.shade500, fontSize: 15)),
          ]),
        );
      }

      return Column(children: [
        // Clear all button
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${ctrl.completedTasks.length} completed task(s)',
                style: const TextStyle(
                    fontSize: 13, color: Colors.grey),
              ),
              TextButton.icon(
                icon: const Icon(Icons.delete_sweep, size: 16),
                label: const Text('Clear All'),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                onPressed: () => _confirmClearAll(context, ctrl),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(top: 4, bottom: 80),
            itemCount: ctrl.completedTasks.length,
            itemBuilder: (_, i) => TaskTile(
              task: ctrl.completedTasks[i],
              showComplete: false,
            ),
          ),
        ),
      ]);
    });
  }

  void _confirmClearAll(BuildContext ctx, TaskController ctrl) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        title: const Text('Clear All Completed'),
        content: const Text(
            'This will permanently delete all completed tasks. Continue?'),
        actions: [
          TextButton(
              onPressed: () => Get.back(),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              ctrl.deleteAllCompleted();
              Get.back();
            },
            child: const Text('Delete All',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
