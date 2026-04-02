# 📋 Task Manager App — Flutter + SQLite

> **Course:** Mobile Application Development  
> **Instructor:** Muhammad Abrar Saddique  
> **Submission Date:** 30/03/2026  
> **Total Marks:** 100

---

## ⚠️ IMPORTANT: Notifications Require a Physical Device

> Local push notifications **DO NOT work** in Chrome, Edge, or most Android emulators.  
> You **must** connect a real Android phone via USB to see them.

---

## 📁 Project Structure

```
task_manager/
├── lib/
│   ├── main.dart                         ← App entry point + GetX setup
│   ├── models/
│   │   ├── task.dart                     ← Task data model
│   │   └── subtask.dart                  ← Subtask model (progress tracking)
│   ├── db/
│   │   └── database_helper.dart          ← SQLite CRUD operations
│   ├── controllers/
│   │   └── task_controller.dart          ← GetX state management
│   ├── services/
│   │   └── notification_service.dart     ← Local notification scheduling
│   ├── utils/
│   │   ├── theme_controller.dart         ← Light/dark theme + color palette
│   │   └── export_helper.dart            ← CSV, PDF, Email export
│   ├── screens/
│   │   ├── home_screen.dart              ← Main screen with date picker + tabs
│   │   ├── add_task_screen.dart          ← Add / Edit task form
│   │   ├── completed_screen.dart         ← Completed tasks tab
│   │   ├── repeated_screen.dart          ← Repeated tasks tab
│   │   └── settings_screen.dart          ← Theme + notification settings
│   └── widgets/
│       └── task_tile.dart                ← Task card with swipe + subtasks
├── android/
│   └── app/
│       ├── build.gradle                  ← minSdk, desugaring config
│       └── src/main/
│           └── AndroidManifest.xml       ← Notification permissions
├── assets/
│   ├── images/                           ← App images
│   └── sounds/                           ← Custom notification sounds
└── pubspec.yaml                          ← All dependencies
```

---

## 🚀 Setup & Run Instructions

### Step 1 — Prerequisites

- Flutter SDK installed (`flutter doctor` should show ✅)
- Android Studio or VS Code with Flutter plugin
- A real Android phone (for notifications)
- USB cable + USB Debugging enabled on your phone

### Step 2 — Clone & Install

```bash
git clone <your-repo-url>
cd task_manager
flutter pub get
```

### Step 3 — Connect Your Android Device

1. On your phone: **Settings → Developer Options → Enable USB Debugging**
2. Plug in via USB
3. Verify your device is detected:
   ```bash
   flutter devices
   ```
   You should see your phone listed, e.g.:
   ```
   SM-A525F (mobile) • R5CR... • android-arm64
   ```

### Step 4 — Run on Device

```bash
flutter run -d <device-id>
# Example:
flutter run -d R5CR20XXXXX
```

### Step 5 — Build APK

```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

---

## 🔔 How Local Notifications Work

| What                   | How                                                          |
|------------------------|--------------------------------------------------------------|
| **Library**            | `flutter_local_notifications` v17+                          |
| **Trigger**            | Scheduled via `zonedSchedule()` using device timezone        |
| **When fires**         | X minutes before task `startTime` (user-configured: 5–60 min)|
| **Repeat tasks**       | Uses `matchDateTimeComponents: DateTimeComponents.time` for daily repeat |
| **After reboot**       | `RECEIVE_BOOT_COMPLETED` permission reschedules alarms       |
| **Android 12+**        | `SCHEDULE_EXACT_ALARM` + `USE_EXACT_ALARM` permissions granted |
| **Physical device**    | ✅ Notifications appear in status bar                        |
| **Chrome/Edge/Emulator** | ❌ Will not work                                           |

### Notification Flow

```
User adds task → task saved to SQLite → NotificationService.scheduleTaskNotification()
    → flutter_local_notifications → Android AlarmManager
    → [At reminder time] → Notification appears in device status bar
```

---

## 🗄️ Database Schema (SQLite)

### `tasks` table

| Column      | Type    | Description                        |
|-------------|---------|------------------------------------|
| id          | INTEGER | Primary key (auto-increment)       |
| title       | TEXT    | Task title (required)              |
| description | TEXT    | Optional details                   |
| date        | TEXT    | `yyyy-MM-dd` format                |
| startTime   | TEXT    | `HH:mm` format                     |
| endTime     | TEXT    | `HH:mm` format                     |
| isCompleted | INTEGER | 0 = pending, 1 = done              |
| color       | TEXT    | Color index (0–5)                  |
| isRepeated  | INTEGER | 0 = no, 1 = yes                    |
| repeatDays  | TEXT    | `"Mon,Tue,Wed"` comma-separated    |
| category    | TEXT    | Personal / Work / Shopping / etc.  |
| remind      | INTEGER | Minutes before task (5,10,15,30,60)|

### `subtasks` table

| Column | Type    | Description                      |
|--------|---------|----------------------------------|
| id     | INTEGER | Primary key                      |
| taskId | INTEGER | FK → tasks.id (CASCADE DELETE)   |
| title  | TEXT    | Subtask label                    |
| isDone | INTEGER | 0 = pending, 1 = done            |

---

## ✅ Marks Coverage

| Component                    | Implementation                                              | Marks |
|------------------------------|-------------------------------------------------------------|-------|
| **1. Project Setup & Design**| Flutter project, GetX, Google Fonts, themed UI              | 10    |
| **2. Database Integration**  | SQLite via `sqflite`, tasks + subtasks tables, full CRUD    | 10    |
| **3. Task Management**       | Add, Edit, Delete, Mark Complete (swipe gestures)           | 20    |
| **4. Advanced Features**     | Subtask progress bars, CSV/PDF/Email export, color themes   | 20    |
| **5. Repeat Functionality**  | Daily repeat with day-of-week selection, auto re-schedule   | 10    |
| **6. Notifications**         | `flutter_local_notifications`, scheduled + exact alarms     | 10    |
| **7. User Interface**        | Material 3, dark/light mode, date picker, animated lists    | 10    |
| **8. Docs & GitHub**         | README, inline code comments, video demo                    | 10    |
| **TOTAL**                    |                                                             | **100** |

---

## 📦 Key Dependencies

```yaml
sqflite: ^2.3.3                    # SQLite database
flutter_local_notifications: ^17   # Push notifications (local)
timezone: ^0.9.4                   # Timezone support for scheduling
flutter_timezone: ^2.0.0           # Get device timezone
get: ^4.6.6                        # State management + navigation
get_storage: ^2.1.1               # Persist theme setting
date_picker_timeline: ^1.2.5       # Horizontal date picker
google_fonts: ^6.2.1               # Typography
flutter_staggered_animations        # Animated list entries
csv: ^6.0.0                        # CSV export
pdf: ^3.11.1                       # PDF export
share_plus: ^10.0.2               # Share/email files
intl: ^0.19.0                      # Date formatting
permission_handler: ^11.3.1        # Runtime permissions
```

---

## 🎮 App Features Summary

- **Today View** — Tasks filtered to selected date via horizontal date picker
- **Completed View** — All marked-done tasks with "Clear All" option
- **Repeated View** — Tasks with daily/weekly recurrence shown with day chips
- **Add / Edit Task** — Full form with: title, description, date, time, category, color, repeat, remind
- **Subtasks + Progress** — Expand any task to add subtasks, see % progress bar
- **Swipe Gestures** — Swipe right = mark complete, Swipe left = delete
- **Dark / Light Mode** — Persists across app restarts via GetStorage
- **Export** — CSV, PDF, or Email share with full task list
- **Settings Screen** — Test notification button, sound picker, app info

---

## 📹 Video Demo Checklist

Record your screen showing:

1. [ ] App launch on physical Android device
2. [ ] Add a new task with a reminder (e.g., 5 minutes from now)
3. [ ] Add subtasks + see progress bar update
4. [ ] Mark task as complete via swipe
5. [ ] Navigate to Completed tab
6. [ ] Add a repeating task (select days Mon–Fri)
7. [ ] Navigate to Repeated tab
8. [ ] Toggle dark mode
9. [ ] Export tasks as PDF
10. [ ] Wait for the scheduled notification to appear in the status bar

---

## 🐛 Troubleshooting

| Problem | Fix |
|---------|-----|
| Notifications not showing | Run on a **physical device**, not emulator |
| `SCHEDULE_EXACT_ALARM` denied | Go to phone Settings → Apps → Task Manager → Permissions → Alarms & Reminders → Allow |
| `flutter pub get` fails | Run `flutter clean` first, then `flutter pub get` |
| Build error about desugaring | Make sure `coreLibraryDesugaringEnabled true` is in `android/app/build.gradle` |
| SQLite data lost | Normal on first install; data persists across app restarts after that |

---

*Built with ❤️ using Flutter × SQLite × GetX*
