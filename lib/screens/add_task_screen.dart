// lib/screens/add_task_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/task_controller.dart';
import '../models/task.dart';
import '../utils/theme_controller.dart';

class AddTaskScreen extends StatefulWidget {
  final Task? task; // null = add, non-null = edit

  const AddTaskScreen({super.key, this.task});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _ctrl = Get.find<TaskController>();
  final _formKey = GlobalKey<FormState>();

  // Form fields
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  late DateTime _selectedDate;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  late int _colorIndex;
  late bool _isRepeated;
  late List<bool> _repeatDays; // Mon–Sun
  late String _category;
  late int _remind;

  static const _categories = [
    'Personal', 'Work', 'Shopping', 'Health', 'Study', 'Other'
  ];
  static const _dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const _remindOptions = [5, 10, 15, 30, 60];

  @override
  void initState() {
    super.initState();
    final t = widget.task;
    _titleCtrl = TextEditingController(text: t?.title ?? '');
    _descCtrl  = TextEditingController(text: t?.description ?? '');
    _selectedDate = t != null
        ? DateFormat('yyyy-MM-dd').parse(t.date)
        : _ctrl.selectedDate.value;
    _startTime = t != null
        ? _timeFromStr(t.startTime)
        : TimeOfDay.now();
    _endTime = t != null && t.endTime.isNotEmpty
        ? _timeFromStr(t.endTime)
        : TimeOfDay(hour: TimeOfDay.now().hour + 1, minute: 0);
    _colorIndex = int.tryParse(t?.color ?? '0') ?? 0;
    _isRepeated = t?.isRepeated == 1;
    _category   = t?.category ?? 'Personal';
    _remind     = t?.remind ?? 5;

    // Parse repeatDays
    _repeatDays = List.filled(7, false);
    if (t != null && t.repeatDays.isNotEmpty) {
      final stored = t.repeatDays.split(',');
      for (int i = 0; i < _dayLabels.length; i++) {
        _repeatDays[i] = stored.contains(_dayLabels[i]);
      }
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  TimeOfDay _timeFromStr(String s) {
    final p = s.split(':');
    return TimeOfDay(
        hour: int.tryParse(p[0]) ?? 0,
        minute: int.tryParse(p.length > 1 ? p[1] : '0') ?? 0);
  }

  String _formatTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  // ─── Build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.task != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Task' : 'Add Task'),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text('SAVE',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionLabel('Task Title *'),
              _buildTextField(
                controller: _titleCtrl,
                hint: 'e.g. Morning workout',
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Title is required' : null,
              ),
              const SizedBox(height: 16),

              _sectionLabel('Description'),
              _buildTextField(
                controller: _descCtrl,
                hint: 'Add details…',
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              _sectionLabel('Date'),
              _datePicker(),
              const SizedBox(height: 16),

              Row(children: [
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionLabel('Start Time'),
                    _timePicker(
                        label: _formatTime(_startTime),
                        onTap: () async {
                          final t = await showTimePicker(
                              context: context, initialTime: _startTime);
                          if (t != null) setState(() => _startTime = t);
                        }),
                  ],
                )),
                const SizedBox(width: 12),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionLabel('End Time'),
                    _timePicker(
                        label: _formatTime(_endTime),
                        onTap: () async {
                          final t = await showTimePicker(
                              context: context, initialTime: _endTime);
                          if (t != null) setState(() => _endTime = t);
                        }),
                  ],
                )),
              ]),
              const SizedBox(height: 16),

              _sectionLabel('Category'),
              _categorySelector(),
              const SizedBox(height: 16),

              _sectionLabel('Remind me'),
              _remindSelector(),
              const SizedBox(height: 16),

              _sectionLabel('Color'),
              _colorPicker(),
              const SizedBox(height: 16),

              // ── Repeat ─────────────────────────────────────────────────
              _sectionLabel('Repeat Task'),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Enable repeat'),
                value: _isRepeated,
                onChanged: (v) => setState(() => _isRepeated = v),
              ),
              if (_isRepeated) ...[
                const Text('Repeat on:', style: TextStyle(fontSize: 13)),
                const SizedBox(height: 6),
                _repeatDaySelector(),
              ],

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    isEdit ? 'UPDATE TASK' : 'CREATE TASK',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Form field helpers ──────────────────────────────────────────────────

  Widget _sectionLabel(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(text,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.grey)),
      );

  Widget _buildTextField({
    required TextEditingController controller,
    String? hint,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) =>
      TextFormField(
        controller: controller,
        maxLines: maxLines,
        validator: validator,
        decoration: InputDecoration(
          hintText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
      );

  Widget _datePicker() => InkWell(
        onTap: () async {
          final d = await showDatePicker(
            context: context,
            initialDate: _selectedDate,
            firstDate: DateTime.now(),
            lastDate: DateTime.now().add(const Duration(days: 365)),
          );
          if (d != null) setState(() => _selectedDate = d);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(children: [
            const Icon(Icons.calendar_today, size: 18, color: Colors.grey),
            const SizedBox(width: 8),
            Text(DateFormat('EEE, MMM d yyyy').format(_selectedDate)),
          ]),
        ),
      );

  Widget _timePicker({required String label, required VoidCallback onTap}) =>
      InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(children: [
            const Icon(Icons.access_time, size: 18, color: Colors.grey),
            const SizedBox(width: 8),
            Text(label),
          ]),
        ),
      );

  Widget _categorySelector() => Wrap(
        spacing: 8,
        children: _categories.map((cat) {
          final selected = _category == cat;
          return ChoiceChip(
            label: Text(cat),
            selected: selected,
            onSelected: (_) => setState(() => _category = cat),
          );
        }).toList(),
      );

  Widget _remindSelector() => Wrap(
        spacing: 8,
        children: _remindOptions.map((min) {
          final selected = _remind == min;
          return ChoiceChip(
            label: Text('$min min'),
            selected: selected,
            onSelected: (_) => setState(() => _remind = min),
          );
        }).toList(),
      );

  Widget _colorPicker() => Row(
        children: List.generate(taskColors.length, (i) {
          return GestureDetector(
            onTap: () => setState(() => _colorIndex = i),
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: taskColors[i],
                shape: BoxShape.circle,
                border: _colorIndex == i
                    ? Border.all(
                        color: Colors.black54, width: 3)
                    : null,
              ),
            ),
          );
        }),
      );

  Widget _repeatDaySelector() => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(7, (i) {
          return GestureDetector(
            onTap: () => setState(() => _repeatDays[i] = !_repeatDays[i]),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: _repeatDays[i]
                    ? Theme.of(context).primaryColor
                    : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Text(
                _dayLabels[i],
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _repeatDays[i] ? Colors.white : Colors.black54),
              ),
            ),
          );
        }),
      );

  // ─── Save ────────────────────────────────────────────────────────────────

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final repeatDaysStr = _isRepeated
        ? _dayLabels
            .asMap()
            .entries
            .where((e) => _repeatDays[e.key])
            .map((e) => e.value)
            .join(',')
        : '';

    final task = Task(
      id: widget.task?.id,
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      date: DateFormat('yyyy-MM-dd').format(_selectedDate),
      startTime: _formatTime(_startTime),
      endTime: _formatTime(_endTime),
      color: _colorIndex.toString(),
      isRepeated: _isRepeated ? 1 : 0,
      repeatDays: repeatDaysStr,
      category: _category,
      remind: _remind,
    );

    if (widget.task == null) {
      _ctrl.addTask(task);
      Get.snackbar('Created', '${task.title} has been added.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.8),
          colorText: Colors.white);
    } else {
      _ctrl.updateTask(task);
      Get.snackbar('Updated', '${task.title} has been updated.',
          snackPosition: SnackPosition.BOTTOM);
    }

    Get.back();
  }
}
