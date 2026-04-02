// lib/screens/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../services/notification_service_stub.dart'
    if (dart.library.io) '../services/notification_service.dart';
import '../utils/theme_controller.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final ThemeController _theme = Get.find<ThemeController>();
  final GetStorage _storage = GetStorage();

  // Notification sound options stored as a label (actual sound controlled via channel)
  static const _soundOptions = ['Default', 'Chime', 'Bell', 'Alert', 'None'];
  String _selectedSound = 'Default';

  @override
  void initState() {
    super.initState();
    _selectedSound = _storage.read('notifSound') ?? 'Default';
  }

  void _saveSound(String sound) {
    setState(() => _selectedSound = sound);
    _storage.write('notifSound', sound);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          // ── Appearance ─────────────────────────────────────────────────
          _sectionHeader('Appearance'),
          Obx(() => SwitchListTile(
                secondary: Icon(
                  _theme.isDarkMode.value ? Icons.dark_mode : Icons.light_mode,
                  color: Theme.of(context).primaryColor,
                ),
                title: const Text('Dark Mode'),
                subtitle: Text(_theme.isDarkMode.value
                    ? 'Dark theme active'
                    : 'Light theme active'),
                value: _theme.isDarkMode.value,
                onChanged: (_) => _theme.toggleTheme(),
              )),
          const Divider(height: 1),

          // ── Notifications ──────────────────────────────────────────────
          _sectionHeader('Notifications'),
          ListTile(
            leading: Icon(Icons.notifications_active,
                color: Theme.of(context).primaryColor),
            title: const Text('Test Notification'),
            subtitle: const Text('Send a test notification to your device'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              await NotificationService().showTestNotification();
              Get.snackbar(
                '✅ Sent!',
                'Check your status bar for the test notification.',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.green.withOpacity(0.85),
                colorText: Colors.white,
                duration: const Duration(seconds: 3),
              );
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: Icon(Icons.volume_up,
                color: Theme.of(context).primaryColor),
            title: const Text('Notification Sound'),
            subtitle: Text('Current: $_selectedSound'),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 8,
              children: _soundOptions.map((s) {
                return ChoiceChip(
                  label: Text(s),
                  selected: _selectedSound == s,
                  onSelected: (_) => _saveSound(s),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          const Divider(height: 1),

          // ── About ──────────────────────────────────────────────────────
          _sectionHeader('About'),
          ListTile(
            leading: Icon(Icons.info_outline,
                color: Theme.of(context).primaryColor),
            title: const Text('App Version'),
            trailing: const Text('1.0.0',
                style: TextStyle(color: Colors.grey)),
          ),
          ListTile(
            leading: Icon(Icons.school,
                color: Theme.of(context).primaryColor),
            title: const Text('Course'),
            trailing: const Text('Mobile App Dev',
                style: TextStyle(color: Colors.grey)),
          ),
          ListTile(
            leading: Icon(Icons.person,
                color: Theme.of(context).primaryColor),
            title: const Text('Instructor'),
            trailing: const Text('Muhammad Abrar Saddique',
                style: TextStyle(color: Colors.grey, fontSize: 12)),
          ),
          const SizedBox(height: 16),

          // ── Disclaimer ────────────────────────────────────────────────
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.amber.shade300),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.warning_amber, color: Colors.amber, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '⚠️  Local notifications require a physical Android device. '
                    'They do NOT work in Chrome, Edge, or most emulators.\n\n'
                    'Connect via USB, enable USB Debugging, then run:\n'
                    'flutter run -d <device-id>',
                    style: TextStyle(
                        fontSize: 12, color: Colors.amber.shade900),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
        child: Text(
          title.toUpperCase(),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            color: Theme.of(context).primaryColor,
          ),
        ),
      );
}
