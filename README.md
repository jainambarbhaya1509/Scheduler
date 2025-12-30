# Scheduler - Faculty Timetable Management System

A comprehensive Flutter application for managing faculty schedules, class timetables, and administrative operations. This app provides role-based access for Super Admins, HODs (Heads of Department), Admins, and Faculty members.

## 📋 Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Project Structure](#project-structure)
- [Prerequisites](#prerequisites)
- [Getting Started](#getting-started)
- [Architecture](#architecture)
- [Key Features by Role](#key-features-by-role)
- [Database Schema](#database-schema)
- [Building & Deployment](#building--deployment)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)

## 🎯 Overview

The Schedule application is a role-based timetable management system built with Flutter that enables institutions to efficiently manage faculty schedules, class availability, and department timetables. The app integrates with Firebase for real-time data synchronization and authentication.

**App Name:** Scheduler  
**Version:** 1.0.0+1  
**Flutter SDK:** ^3.9.2  
**Platform Support:** iOS, Android, Web

## ✨ Features

### Core Functionality
- **Role-Based Access Control:** Super Admin, HOD, Admin, and Faculty roles
- **Real-Time Data Sync:** Cloud Firestore integration for instant updates
- **Timetable Management:** Create, view, and manage faculty schedules
- **Class Availability Tracking:** Track class timing and availability
- **Request Management:** Handle faculty requests with approval workflow
- **Department Management:** Manage department-level scheduling
- **Status Tracking:** Monitor scheduling status and conflicts
- **Excel Import/Export:** Import and export timetables in Excel format
- **Notification System:** Real-time notifications for approvals and changes

### Admin Features
- User management and permission control
- Department and faculty management
- Timetable approval and validation
- Analytics and reporting

### Faculty Features
- View assigned schedules
- Request schedule changes
- Manage class availability
- View request status
- Download schedules

## 📁 Project Structure

```
schedule/
├── lib/
│   ├── main.dart                 # App entry point
│   ├── firebase_options.dart     # Firebase configuration
│   ├── initializations.dart      # App initialization
│   ├── imports.dart              # Central imports file
│   ├── .env                      # Environment variables
│   │
│   ├── controller/               # Business logic & state management
│   │   ├── auth/                 # Authentication controller
│   │   ├── session/              # User session controller
│   │   ├── schedule/             # Schedule management controller
│   │   ├── requests/             # Request handling controller
│   │   └── superadmin/           # Super admin operations
│   │
│   ├── pages/                    # UI Pages
│   │   ├── splash_page.dart      # App splash screen
│   │   ├── home.dart             # Main home page with role-based navigation
│   │   ├── login/                # Login page and authentication
│   │   ├── profile/              # User profile management
│   │   ├── schedule/             # Schedule viewing and management
│   │   ├── manage_timetable/     # Timetable creation and editing
│   │   ├── requests/             # Request management interface
│   │   ├── status/               # Status tracking page
│   │   └── superadmin/           # Super admin dashboard
│   │
│   ├── models/                   # Data models
│   │   ├── faculty_model.dart
│   │   ├── class_timing_model.dart
│   │   ├── class_avalability_model.dart
│   │   ├── dept_availability_model.dart
│   │   └── users_applied_model.dart
│   │
│   ├── services/                 # Backend services
│   │   ├── firestore_service.dart
│   │   ├── session_service.dart
│   │   └── error_handler.dart
│   │
│   ├── helper/                   # Helper utilities
│   ├── utils/                    # Utility functions
│   └── widgets/                  # Reusable UI components
│
├── android/                      # Android native code
├── ios/                          # iOS native code
├── web/                          # Web platform code
├── assets/
│   ├── icon.png
│   └── template.xlsx
├── pubspec.yaml                  # Flutter dependencies
└── firebase.json                 # Firebase config
```

## 📦 Prerequisites

Before you begin, ensure you have the following installed:

- **Flutter SDK:** Version 3.9.2 or higher
  ```bash
  flutter --version
  ```
- **Dart SDK:** ^3.9.2 (comes with Flutter)
- **Android Studio** or **Xcode** for mobile development
- **Firebase Account:** For Firestore and authentication
- **Git:** For version control
- **macOS 11+, Windows 10+, or Linux:** For development machine

## 🚀 Getting Started

### 1. Clone the Repository

```bash
git clone <repository-url>
cd schedule
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Configure Firebase

Follow the Firebase setup instructions in the [Firebase Setup](#firebase-setup) section.

### 4. Set Environment Variables

Create a `.env` file in the `lib/` directory with necessary variables.

### 5. Run the App

```bash
# Run on default device/emulator
flutter run

# Run on specific device
flutter run -d <device-id>

# Run in debug mode with verbose logging
flutter run -v

# Run release build
flutter run --release
```

## 🏗️ Architecture

### State Management: GetX

The app uses **GetX** (GetIt alternative) for state management, dependency injection, and navigation:

```dart
// Register controller
Get.put(SessionController());

// Access controller
final controller = Get.find<SessionController>();

// Navigation
Get.to(() => HomePage());
```

### Service Layer

- **FirestoreService:** Handles all Firestore CRUD operations
- **SessionService:** Manages user session and authentication state
- **ErrorHandler:** Centralized error handling and user feedback

### Data Flow

```
UI (Pages) → Controllers (GetX) → Services (Firestore) → Firebase
                    ↓
              Reactive Updates via RxDart
```

## 👥 Key Features by Role

### Super Admin
- Manage all users and roles
- Manage faculty and departments
- Approve/reject timetables
- Generate reports
- System configuration
- View analytics

### HOD (Head of Department)
- Manage department faculty
- Create and approve department timetables
- Monitor schedule conflicts
- Request approvals
- View department reports

### Admin
- Manage users within scope
- Create/edit timetables
- Process requests
- View schedules and status
- Export data

### Faculty
- View assigned schedule
- Request schedule changes
- Manage availability
- Track request status
- Download schedules

## 💾 Database Schema

### Firestore Collections

#### Slots Collection (Main Scheduling Data)
```
slots/
├── {day} (e.g., "Monday", "Tuesday")
│   ├── departments/
│   │   ├── {deptId}
│   │   │   ├── Classrooms/
│   │   │   │   ├── {roomId}: {room details}
│   │   │   │   └── _meta: {metadata}
│   │   │   └── Labs/
│   │   │       ├── {labId}: {lab details}
│   │   │       └── _meta: {metadata}
```

**Data Structure Example:**
```json
{
  "timing": "09:00-10:00",
  "applications": {
    "17-11-2025": [
      {
        "username": "Dr. Smith",
        "status": "Pending|Approved|Rejected",
        "reason": "Regular class"
      }
    ]
  }
}
```

#### Key Collections Used
- **slots/**: Hierarchical storage for daily classroom/lab availability
  - By Day: Monday, Tuesday, Wednesday, etc.
  - By Department: Different departments
  - By Section: Classrooms, Labs
  - By Room/Lab ID: Specific room details

#### Timetable Collection
```
timetables/
├── {deptId}_semester_{semesterNo}
│   ├── department: string
│   ├── semester: string
│   ├── schedule: map (structured schedule data)
│   ├── status: string (draft, pending, approved)
│   └── metadata: map
```

#### Requests Collection
```
requests/
├── {requestId}
│   ├── username: string
│   ├── department: string
│   ├── type: string (ClassroomChange, TimeSlotChange, etc.)
│   ├── status: string (pending, approved, rejected)
│   ├── reason: string
│   └── createdAt: timestamp
```

#### Users/Faculty Collection
```
users/ or faculty/
├── {email}
│   ├── username: string
│   ├── email: string
│   ├── department: string
│   ├── isHOD: boolean
│   ├── isAdmin: boolean
│   ├── isSuperAdmin: boolean
│   └── createdAt: timestamp
```

## 🏗️ Building & Deployment

### Build APK (Android)

```bash
# Debug APK
flutter build apk --debug

# Release APK
flutter build apk --release

# Split APKs by architecture
flutter build apk --release --split-per-abi
```

### Build App Bundle (Google Play)

```bash
flutter build appbundle --release
```

### Build IPA (iOS)

```bash
# Build for physical device
flutter build ios --release

# Build for simulator
flutter build ios --simulator
```

### Build for Web

```bash
# Build web app
flutter build web --release

# Serve locally
flutter run -d chrome
```

### Deployment Checklist

- [ ] Update version in `pubspec.yaml`
- [ ] Update Firebase configuration for production
- [ ] Set up production Firestore rules
- [ ] Configure Android signing keys
- [ ] Configure iOS provisioning profiles
- [ ] Run `flutter test` to ensure all tests pass
- [ ] Perform manual QA testing
- [ ] Enable crash reporting and analytics
- [ ] Set up monitoring and logging
- [ ] Document any breaking changes

## 🐛 Troubleshooting

### Common Issues

#### "Firebase not initialized"
**Solution:** Ensure `Firebase.initializeApp()` is called before running the app in `main.dart`.

#### "Plugin not found" errors
```bash
flutter pub get
flutter pub upgrade
flutter clean
flutter pub get
```

#### Firestore permission denied
**Solution:** Check Firestore rules. For development:
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if true;
    }
  }
}
```

#### Build failing on iOS
```bash
cd ios
pod deintegrate
pod install
cd ..
flutter clean
flutter pub get
flutter run
```

#### Android build issues
```bash
flutter clean
cd android
./gradlew clean
cd ..
flutter pub get
flutter run
```

#### Hot reload not working
- Ensure app is running in debug mode
- Try hot restart: `R` key
- If persistent, restart the app

## 📊 Key Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| `get` | ^4.7.2 | State management & navigation |
| `firebase_core` | ^3.13.0 | Firebase initialization |
| `cloud_firestore` | ^5.6.12 | Cloud database |
| `excel` | ^4.0.6 | Excel file handling |
| `file_picker` | ^10.3.6 | File selection |
| `shared_preferences` | ^2.5.3 | Local storage |
| `intl` | ^0.20.2 | Internationalization |
| `mailer` | ^6.6.0 | Email functionality |
| `permission_handler` | ^12.0.1 | App permissions |
| `device_preview` | ^1.2.0 | Device preview (dev) |


### Running Tests

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/unit/test_name.dart

# Run with coverage
flutter test --coverage
```

### Code Analysis

```bash
# Analyze code
flutter analyze

# Format code
dart format lib/

# Fix issues automatically
dart fix --apply
```

### Debug Logging

The app uses the `logger` package:

```dart
import 'package:schedule/initializations.dart';

logger.d('Debug message');
logger.i('Info message');
logger.w('Warning message');
logger.e('Error message');
```

### 8. **Compiled Code Optimization**

#### Enable Dart AOT Compilation:
```bash
# Build with optimizations
flutter build apk --release --split-per-abi

flutter build appbundle --release

flutter build ios --release
```

#### Use `--obfuscate` and `--split-debug-info`:
```bash
flutter build apk --release --obfuscate --split-debug-info=./symbols/
```

## 📈 Performance Optimization

### Performance Benchmarks (Target)

| Metric | Target | Current |
|--------|--------|---------|
| First Load | < 3s | Monitor |
| Schedule Fetch | < 2s | Optimize queries |
| Page Transition | < 300ms | Reduce rebuilds |
| Memory Usage | < 150MB | Monitor profiles |
| Firebase RTD | < 100ms | Add caching |
| App Size | < 100MB | Remove unused deps |

### Performance Checklist

- [ ] Add Firestore composite indexes
- [ ] Implement pagination for large lists
- [ ] Add image caching and compression
- [ ] Enable offline persistence
- [ ] Implement batch operations
- [ ] Use const constructors throughout
- [ ] Profile with DevTools regularly
- [ ] Monitor Firestore read/write operations
- [ ] Optimize build sizes with `--split-per-abi`
- [ ] Add analytics and crash reporting
- [ ] Set up automated performance testing
- [ ] Reduce unnecessary widget rebuilds with Obx scoping
- [ ] Implement lazy loading for lists

## 📱 Supported Platforms

- ✅ **Android:** 5.1+ (API level 22+)
- ✅ **iOS:** 11.0+
- ✅ **Web:** Chrome, Firefox, Safari, Edge

## 📄 License

This project is proprietary and confidential.

## 👥 Support & Contact

For issues, questions, or contributions:
- Create an issue in the repository
- Contact the development team
- Review Firebase documentation at [firebase.google.com](https://firebase.google.com)
- Check Flutter docs at [flutter.dev](https://flutter.dev)


**Last Updated:** December 30, 2025  
**Maintained by:** Development Team
