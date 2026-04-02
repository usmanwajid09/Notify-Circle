<div align="center">
  <img src="https://img.icons8.com/color/96/000000/appointment-reminders--v1.png" alt="Notify Circle Logo" width="80" />
  <h1>Notify Circle</h1>
  <p><em>A frictionless, high-utility Personal Reminder & Notification System</em></p>

  <p>
    <a href="https://flutter.dev"><img src="https://img.shields.io/badge/Built_with-Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter" /></a>
    <img src="https://img.shields.io/badge/State-GetX-FF5722?style=for-the-badge&logo=dart" alt="GetX" />
    <img src="https://img.shields.io/badge/Database-SQLite-003B57?style=for-the-badge&logo=sqlite&logoColor=white" alt="SQLite" />
  </p>
</div>

---

## 📖 Overview

**Notify Circle** is designed with a core purpose: to provide users with a streamlined, frictionless interface for creating, managing, and receiving time-sensitive alerts. Moving away from bloated productivity apps, it focuses on task clarity, urgency visualization, and a "get-in-get-out" user flow that minimizes cognitive load while maximizing task completion.

### 🎨 Design Philosophy : Clinical Minimalism
The UI follows a strict Clinical Minimalism aesthetic inspired by top-tier productivity apps:
* **High-Contrast & Airy:** Prioritizing readability and immediate focus on active tasks.
* **Color Palette:** 
  * 🔵 **Primary:** `#007AFF` (Action Blue)
  * ⚪ **Background:** `#FFFFFF` (Pure White)
  * 🔴 **Accent/Urgent:** `#FF3B30` 
  * 🟢 **Success:** `#34C759`
* **Typography:** Clean, generous line-heights utilizing system Sans-Serif (Inter/SF Pro).

---

## ✨ Key Features

* **Smart Dashboard:** A sticky "Today" header with horizontal quick-toggle chips (All, Work, Personal, Urgent).
* **Frictionless Creation:** A bottom-sheet modal overlay with autofocusing text inputs and quick-selection pills for rapid task entry.
* **Persistent Reminders:** Highly reliable local notifications on Android utilizing precise timing (`flutter_local_notifications` + `AlarmManager` permissions).
* **Cross-Platform Readiness:** Runs natively on Android/iOS with data persistence, and gracefully downgrades to in-memory stubs for flawless web deployment.
* **Rich Interactions:** Staggered list animations, swipe-to-delete/complete gestures, and a slick Light/Dark mode toggle.
* **Exporting & Sharing:** One-tap compilation of tasks to **PDF, CSV**, or direct Email sharing.

---

## 🛠️ Architecture & Tech Stack

* **Framework:** Flutter (v3.19+)
* **State Management:** GetX (Reactive programming, route management, dependency injection)
* **Local Storage:** `sqflite` (relational SQL database for Android/iOS) and `get_storage` (theme preservation)
* **Web Compatibility Engine:** Utilizes dart's conditional imports (`dart.library.io`) to seamlessly switch between deep native APIs and web-safe mock stubs without crashing.

---

## 🚀 Getting Started

### Prerequisites
* Flutter SDK (3.19.5 or compatible)
* A physical Android/iOS device (Highly recommended for testing push notifications. Emulators/web browsers do not support local device notifications).

### Local Execution

1. **Clone the repository:**
   ```bash
   git clone https://github.com/usmanwajid09/Notify-Circle.git
   cd Notify-Circle
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run on a physical device:**
   Ensure USB Debugging is on.
   ```bash
   flutter run
   ```

4. **Run on Local Web (UI testing):**
   ```bash
   flutter run -d chrome
   ```
   *Note: Push notifications and persistent SQLite databases are simulated gracefully in the web environment.*

---

## 📦 Deployment (Vercel / GitHub Pages)

Because Notify Circle utilizes robust cross-platform fallback stubs, the app can be easily hosted statically on the web.

**To build for the Web:**
```bash
flutter build web --release
```
You can safely deploy the resulting `build/web/` folder directly to **Vercel**, **Netlify**, or **GitHub Pages**.

---
##  Vercel Link

https://notify-circle.vercel.app/

<div align="center">
  <i>Built meticulously with 💙 using Flutter</i>
</div>
