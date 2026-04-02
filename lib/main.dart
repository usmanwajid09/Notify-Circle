// lib/main.dart
//
// Task Manager App
// Course: Mobile Application Development
// Uses: Flutter + SQLite (native) / In-Memory (web) + Local Notifications
//
// ⚠️  RUN ON A PHYSICAL ANDROID DEVICE for push notifications to work.
//    Connect phone via USB → Enable USB Debugging → run: flutter run
//    For quick UI check, run: flutter run -d chrome

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'controllers/task_controller.dart';
import 'utils/theme_controller.dart';
import 'screens/home_screen.dart';

// Conditional imports for web vs native
import 'services/notification_service_stub.dart'
    if (dart.library.io) 'services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize persistent storage (for theme setting)
  await GetStorage.init();

  // Initialize local notifications (no-op on web)
  if (!kIsWeb) {
    await NotificationService().init();
  }

  runApp(const TaskManagerApp());
}

class TaskManagerApp extends StatelessWidget {
  const TaskManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Register controllers
    Get.put(ThemeController());
    Get.put(TaskController());

    final themeCtrl = Get.find<ThemeController>();

    return Obx(() => GetMaterialApp(
          title: 'Notify Circle',
          debugShowCheckedModeBanner: false,
          theme: ThemeController.lightTheme,
          darkTheme: ThemeController.darkTheme,
          themeMode: themeCtrl.isDarkMode.value
              ? ThemeMode.dark
              : ThemeMode.light,
          home: const HomeScreen(),
        ));
  }
}
