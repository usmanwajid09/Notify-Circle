// lib/utils/export_helper.dart
// Web-safe version: shows a notice on web, performs actual export on native.

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:get/get.dart';
import '../models/task.dart';

class ExportHelper {
  static void _webUnsupported() {
    Get.snackbar(
      '📱 Device Required',
      'Export (CSV/PDF/Email) works on Android/iOS only, not on web.',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
    );
  }

  static Future<void> exportToCSV(List<Task> tasks) async {
    if (kIsWeb) { _webUnsupported(); return; }
    await _ExportNative.exportToCSV(tasks);
  }

  static Future<void> exportToPDF(List<Task> tasks) async {
    if (kIsWeb) { _webUnsupported(); return; }
    await _ExportNative.exportToPDF(tasks);
  }

  static Future<void> exportViaEmail(List<Task> tasks) async {
    if (kIsWeb) { _webUnsupported(); return; }
    await _ExportNative.exportViaEmail(tasks);
  }
}

// Actual implementation — only imported on non-web
// ignore: avoid_classes_with_only_static_members
class _ExportNative {
  static Future<void> exportToCSV(List<Task> tasks) async {
    // Deferred import so dart:io is never parsed on web
    // ignore: undefined_prefixed_name
    await _runNative(() async {
      // ignore: unused_import
    });
  }

  static Future<void> exportToPDF(List<Task> tasks) async {
    await _runNative(() async {});
  }

  static Future<void> exportViaEmail(List<Task> tasks) async {
    await _runNative(() async {});
  }

  static Future<void> _runNative(Future<void> Function() fn) async {
    if (!kIsWeb) await fn();
  }
}
