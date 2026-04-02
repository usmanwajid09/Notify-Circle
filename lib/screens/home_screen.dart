// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:date_picker_timeline/date_picker_timeline.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:intl/intl.dart';
import '../controllers/task_controller.dart';
import '../db/database_helper.dart';
import '../utils/theme_controller.dart';
import '../utils/export_helper.dart';
import '../widgets/task_tile.dart';
import 'add_task_screen.dart';
import 'completed_screen.dart';
import 'repeated_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TaskController _ctrl   = Get.find<TaskController>();
  final ThemeController _theme = Get.find<ThemeController>();
  final DatabaseHelper  _db    = DatabaseHelper();
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildDrawer(context),
      appBar: AppBar(
        title: const Text('Notify Circle'),
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        actions: [
          Obx(() => IconButton(
                icon: Icon(_theme.isDarkMode.value ? Icons.light_mode : Icons.dark_mode),
                onPressed: _theme.toggleTheme,
                tooltip: 'Toggle Theme',
              )),
          PopupMenuButton<String>(
            onSelected: _export,
            icon: const Icon(Icons.more_vert),
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'csv',   child: Text('Export CSV')),
              PopupMenuItem(value: 'pdf',   child: Text('Export PDF')),
              PopupMenuItem(value: 'email', child: Text('Share via Email')),
            ],
          ),
        ],
      ),
      body: Column(children: [
        _dateHeader(),
        _tabBar(),
        Expanded(
          child: IndexedStack(index: _tab, children: const [
            _TodayTab(),
            CompletedScreen(),
            RepeatedScreen(),
          ]),
        ),
      ]),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.to(() => const AddTaskScreen()),
        icon: const Icon(Icons.add),
        label: const Text('New Task'),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(padding: EdgeInsets.zero, children: [
        DrawerHeader(
          decoration: BoxDecoration(color: Theme.of(context).primaryColor),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 40),
              const SizedBox(height: 8),
              const Text('Notify Circle',
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              Obx(() => Text(
                    DateFormat('EEEE, MMMM d y').format(_ctrl.selectedDate.value),
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  )),
            ],
          ),
        ),
        _drawerItem(Icons.today,     'Today Tasks',     () { _setTab(0); Get.back(); }),
        _drawerItem(Icons.done_all,  'Completed Tasks', () { _setTab(1); Get.back(); }),
        _drawerItem(Icons.repeat,    'Repeated Tasks',  () { _setTab(2); Get.back(); }),
        const Divider(),
        _drawerItem(Icons.settings,  'Settings', () { Get.back(); Get.to(() => const SettingsScreen()); }),
        Obx(() => _drawerItem(
              _theme.isDarkMode.value ? Icons.light_mode : Icons.dark_mode,
              _theme.isDarkMode.value ? 'Light Mode' : 'Dark Mode',
              _theme.toggleTheme,
            )),
      ]),
    );
  }

  Widget _drawerItem(IconData icon, String label, VoidCallback onTap) =>
      ListTile(
        leading: Icon(icon, color: Theme.of(context).primaryColor),
        title: Text(label),
        onTap: onTap,
      );

  void _setTab(int i) => setState(() => _tab = i);

  Widget _dateHeader() => Container(
        color: Theme.of(context).appBarTheme.backgroundColor,
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Obx(() => Text(
                DateFormat('EEEE, MMMM d').format(_ctrl.selectedDate.value),
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              )),
          const SizedBox(height: 6),
          SizedBox(
            height: 80,
            child: Obx(() => DatePicker(
                  DateTime.now().subtract(const Duration(days: 3)),
                  height: 80, width: 60,
                  initialSelectedDate: _ctrl.selectedDate.value,
                  selectionColor: Colors.white,
                  selectedTextColor: Theme.of(context).primaryColor,
                  dateTextStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  dayTextStyle:   const TextStyle(fontSize: 10, color: Colors.white70),
                  monthTextStyle: const TextStyle(fontSize: 10, color: Colors.white70),
                  onDateChange: _ctrl.changeDate,
                )),
          ),
        ]),
      );

  Widget _tabBar() => Row(children: [
        _tabBtn(0, 'Today',     Icons.today),
        _tabBtn(1, 'Completed', Icons.done_all),
        _tabBtn(2, 'Repeated',  Icons.repeat),
      ]);

  Widget _tabBtn(int i, String label, IconData icon) {
    final sel   = _tab == i;
    final color = Theme.of(context).primaryColor;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _tab = i),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: sel ? color : Colors.transparent, width: 2.5)),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon, size: 15, color: sel ? color : Colors.grey),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(fontSize: 12,
                fontWeight: sel ? FontWeight.bold : FontWeight.normal,
                color: sel ? color : Colors.grey)),
          ]),
        ),
      ),
    );
  }

  void _export(String v) async {
    final tasks = await _db.getAllTasks();
    if (tasks.isEmpty) {
      Get.snackbar('No Tasks', 'Add some tasks first to export.',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    if (v == 'csv')      ExportHelper.exportToCSV(tasks);
    else if (v == 'pdf') ExportHelper.exportToPDF(tasks);
    else                 ExportHelper.exportViaEmail(tasks);
  }
}

class _TodayTab extends StatelessWidget {
  const _TodayTab();
  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<TaskController>();
    return Obx(() {
      if (ctrl.todayTasks.isEmpty) {
        return const _EmptyState(icon: Icons.task_alt, msg: 'No tasks for today!\nTap + to add a new task.');
      }
      return AnimationLimiter(
        child: ListView.builder(
          padding: const EdgeInsets.only(top: 8, bottom: 100),
          itemCount: ctrl.todayTasks.length,
          itemBuilder: (_, i) => AnimationConfiguration.staggeredList(
            position: i, duration: const Duration(milliseconds: 375),
            child: SlideAnimation(verticalOffset: 50,
              child: FadeInAnimation(child: TaskTile(task: ctrl.todayTasks[i]))),
          ),
        ),
      );
    });
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String   msg;
  const _EmptyState({required this.icon, required this.msg});
  @override
  Widget build(BuildContext context) => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(icon, size: 72, color: Colors.grey.shade300),
      const SizedBox(height: 16),
      Text(msg, textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey.shade500, fontSize: 15, height: 1.5)),
    ]),
  );
}
