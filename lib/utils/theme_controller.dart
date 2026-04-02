// lib/utils/theme_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';

class ThemeController extends GetxController {
  final GetStorage _storage = GetStorage();
  static const String _themeKey = 'isDarkMode';

  final RxBool isDarkMode = false.obs;

  @override
  void onInit() {
    super.onInit();
    isDarkMode.value = _storage.read(_themeKey) ?? false;
  }

  void toggleTheme() {
    isDarkMode.value = !isDarkMode.value;
    _storage.write(_themeKey, isDarkMode.value);
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
  }

  // ─── Light theme ────────────────────────────────────────────────────────

  static ThemeData get lightTheme => ThemeData(
        brightness: Brightness.light,
        primaryColor: const Color(0xFF6C63FF),
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF6C63FF),
          secondary: Color(0xFF03DAC6),
          background: Color(0xFFF5F5F5),
          surface: Colors.white,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFF6C63FF),
          foregroundColor: Colors.white,
          elevation: 0,
          titleTextStyle: GoogleFonts.lato(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        textTheme: GoogleFonts.latoTextTheme(),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF6C63FF),
          foregroundColor: Colors.white,
        ),
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
      );

  // ─── Dark theme ─────────────────────────────────────────────────────────

  static ThemeData get darkTheme => ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF6C63FF),
        scaffoldBackgroundColor: const Color(0xFF121212),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF6C63FF),
          secondary: Color(0xFF03DAC6),
          background: Color(0xFF121212),
          surface: Color(0xFF1E1E1E),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFF1E1E1E),
          foregroundColor: Colors.white,
          elevation: 0,
          titleTextStyle: GoogleFonts.lato(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        textTheme:
            GoogleFonts.latoTextTheme(ThemeData.dark().textTheme),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF6C63FF),
          foregroundColor: Colors.white,
        ),
        cardTheme: CardTheme(
          elevation: 2,
          color: const Color(0xFF1E1E1E),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
      );
}

// Task color palette
const List<Color> taskColors = [
  Color(0xFF6C63FF), // Purple
  Color(0xFF43A047), // Green
  Color(0xFFE53935), // Red
  Color(0xFF1E88E5), // Blue
  Color(0xFFFB8C00), // Orange
  Color(0xFF8E24AA), // Violet
];

Color taskColorFromIndex(String index) {
  final i = int.tryParse(index) ?? 0;
  return taskColors[i.clamp(0, taskColors.length - 1)];
}
