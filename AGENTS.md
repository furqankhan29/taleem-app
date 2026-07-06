# Taleem AI Tuition Manager

A Flutter-based educational management platform with AI-powered analytics built using GetX architecture.

## Architecture

```
lib/
├── app/                  # App-level configuration
│   ├── app.dart                     # MaterialApp with theme, routing, bindings
│   ├── app_bindings.dart            # Global DI bindings
│   ├── config/app_config.dart       # Environment-specific config
│   ├── routes/app_pages.dart        # Route definitions (GetPages)
│   └── routes/app_routes.dart       # Route name constants
├── core/                 # Shared infrastructure
│   ├── constants/                   # App constants, asset paths, firestore paths
│   ├── errors/                      # Exception classes, error handler
│   ├── middleware/                  # Auth guards (GetMiddleware)
│   ├── network/                    # Connectivity monitoring
│   ├── services/                   # Firebase, Auth, AI, Cache, Export, etc.
│   ├── theme/                      # Colors, typography, spacing, shadows
│   └── utils/                      # Extensions, formatters, helpers, validators
├── data/                 # Data layer
│   ├── models/                     # Dart model classes with toJson/fromJson
│   ├── providers/                  # FirebaseProvider (wraps Firestore operations)
│   └── repositories/              # Abstracted data access (extends BaseRepository)
├── modules/              # Feature modules (each is a GetX package)
│   ├── ai/                         # AI chat, suggestions, history
│   ├── attendance/                 # Attendance marking & history
│   ├── auth/                       # Login, signup, email verification, splash
│   ├── batches/                    # Batch management (CRUD + detail)
│   ├── calendar/                   # Academic calendar & events
│   ├── dashboard/                  # Overview with KPIs, charts, insights
│   ├── exams/                      # Exam scheduling & results
│   ├── fees/                       # Fee collection, receipts, management
│   ├── homework/                   # Homework assignment & tracking
│   ├── notifications/              # Push notification inbox
│   ├── parents/                    # Parent management
│   ├── reports/                    # Analytics, export, KPIs
│   ├── settings/                   # Profile, settings, theme switching
│   ├── students/                   # Student CRUD, detail, performance
│   ├── subjects/                   # Subject management
│   ├── teachers/                   # Teacher management
│   ├── timetable/                  # Timetable calendar view
│   └── whatsapp/                   # WhatsApp reminder drafting
└── shared/               # Shared widgets
    └── widgets/                    # GlassCard, BottomNavBar, AvatarWidget, etc.
```

## Coding Standards

### Dart Conventions
- Use `const` constructors wherever possible (reduces rebuilds)
- Prefer `final` over `var` for local variables
- Use `if (list.isNotEmpty)` instead of `if (list.length > 0)`
- Use string interpolation: `'Hello $name'` not `'Hello ' + name`
- Avoid `print()` — use `Logger.info()` from `core/utils/logger.dart`
- Use `DateTime.now().toIso8601String()` for Firestore timestamps
- Use `Timestamp.fromDate()` when writing to Firestore

### Naming Conventions
| Element | Convention | Example |
|---------|-----------|---------|
| Files | `snake_case` | `attendance_history_screen.dart` |
| Classes | `PascalCase` | `AttendanceHistoryScreen` |
| Variables | `camelCase` | `selectedBatchId` |
| Private | `_camelCase` | `_formKey`, `_handleLogin()` |
| Controllers | `XxxController` | `AttendanceHistoryController` |
| Bindings | `XxxBinding` | `AttendanceBinding` |
| Models | `XxxModel` | `AttendanceModel` |
| Repositories | `XxxRepository` | `AttendanceRepository` |
| Services | `XxxService` | `AuthService` |
| Routes | `snake_case` | `/attendance/history` |

### Preferred Patterns
- Controller logic in GetX controllers, not widgets
- Business logic in services/repositories, not controllers
- UI is composed of small StatelessWidgets where possible
- Use `Obx()` / `Rx` types for reactive state
- Use `Get.find<T>()` for dependency resolution

## Dependencies

### State Management: GetX
- Controllers extend `GetxController` with `Rx` fields
- Bindings are lazy-loaded on route entry
- Use `Get.toNamed()`, `Get.back()`, `Get.find()` for navigation/DI
- Services extend `GetxService` and are initialized in `AppBindings`

### Firebase Collections
| Collection | Model | Path Constant |
|-----------|-------|---------------|
| `attendance` | `AttendanceModel` | `FirebasePaths.attendance` |
| `batches` | `BatchModel` | `FirebasePaths.batches` |
| `calendar_events` | `CalendarEventModel` | `FirebasePaths.calendarEvents` |
| `exams` | `ExamModel` | `FirebasePaths.exams` |
| `fees` | `FeeModel` | `FirebasePaths.fees` |
| `homework` | `HomeworkModel` | `FirebasePaths.homework` |
| `notifications` | `NotificationModel` | `FirebasePaths.notifications` |
| `parents` | `ParentModel` | `FirebasePaths.parents` |
| `students` | `StudentModel` | `FirebasePaths.students` |
| `subjects` | `SubjectModel` | `FirebasePaths.subjects` |
| `teachers` | `TeacherModel` | `FirebasePaths.teachers` |
| `timetables` | `TimetableModel` | `FirebasePaths.timetables` |
| `whatsapp_reminders` | `WhatsappReminderModel` | `FirebasePaths.whatsappReminders` |
| `users` | `UserModel` | `FirebasePaths.users` |
| `ai_conversations` | `AIConversationModel` | `FirebasePaths.aiConversations` |
| `ai_messages` | `AIChatMessageModel` | `FirebasePaths.aiMessages` |
| `reports` | `ReportModel` | `FirebasePaths.reports` |

### Repository Pattern
Each data entity follows:
```dart
class XxxRepository extends BaseRepository<XxxModel> {
  XxxRepository({required super.firebaseProvider})
      : super(collectionPath: FirebasePaths.xxx);

  @override XxxModel fromJson(Map<String, dynamic> json) => XxxModel.fromJson(json);
  @override Map<String, dynamic> toJson(XxxModel model) => model.toJson();
  @override String getModelId(XxxModel model) => model.id;

  // Custom query methods (paginated, filtered)
}
```

### Dependency Injection
- **Global services** registered permanently in `AppBindings`:
  - `CacheService`, `FirebaseService`, `AuthService`, `CrashlyticsService`
  - `ConnectivityService`, `AnalyticsService`, `RemoteConfigService`
  - `FirebaseProvider`, `LocalAIService`, `ReportService`
- **Repository instances** provided via binding factories
- **Controller instances** created per-route via `Get.lazyPut()` in bindings

## Widget Guidelines

### Reusable Widgets (in `shared/widgets/`)
| Widget | Purpose |
|--------|---------|
| `GlassCard` | Frosted-glass container for forms/cards |
| `BottomNavBar` | Persistent bottom navigation |
| `CustomAppBar` | Sliver-friendly app bar |
| `AvatarWidget` | User avatar with fallback |
| `EmptyState` | Empty-state placeholder |
| `ErrorState` | Error-state with retry |
| `LoadingOverlay` | Fullscreen loading spinner |
| `ShimmerLoading` | Skeleton loading effect |
| `SearchField` | Debounced text search field |
| `StatusChip` | Color-coded status indicator |
| `ConfirmDialog` | Reusable confirmation dialog |
| `SectionHeader` | Section title with optional action |
| `ResponsiveLayout` | Adaptive layout wrapper |
| `CustomFab` | Floating action button |
| `SideNavigationDrawer` | Navigation drawer |

### State Management in Widgets
```dart
// Binding setup (in binding file)
class XxxBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<XxxController>(() => XxxController());
    Get.lazyPut<XxxRepository>(() => XxxRepository(firebaseProvider: Get.find()));
  }
}

// Controller usage in screen
class XxxScreen extends StatelessWidget {
  const XxxScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<XxxController>();
    return Obx(() => Text('${ctrl.someRx.value}'));
  }
}
```

## Testing

### Unit Tests
```bash
flutter test test/path/to/test.dart
```
- Test models (fromJson/toJson roundtrip)
- Test controllers (mock repositories)
- Test services (mock Firebase)

### Integration Tests
```bash
flutter test integration_test/
```

## Performance

### Optimization Checklist
- [x] `const` constructors on all widgets
- [x] `cached_network_image` for remote images
- [x] `shimmer` for loading skeletons
- [x] Lazy loading via Firestore pagination (`queryStudents` with `startAfterDoc`)
- [x] `Obx()` only wraps reactive values, not entire trees
- [x] Stream subscriptions disposed in `onClose()`
- [x] No `print()` statements in production (use `Logger`)
- [x] `withOpacity()` replaced with `withValues(alpha:)` throughout
- [x] `background`/`onBackground`/`surfaceVariant` removed from ColorScheme
- [x] ProGuard/R8 enabled in release builds

### Build Configuration
- Android: minSdk = flutter.minSdkVersion (default 21+), targetSdk = flutter.targetSdkVersion
- Android: ProGuard at `android/app/proguard-rules.pro` with R8 full mode
- Android: Release signing via `android/key.properties` (fill before release)
- iOS: Portrait-only orientation (matching app behavior)
- iOS: Release mode with bitcode disabled by default

## Firebase Setup
1. Create Firebase project at https://console.firebase.google.com
2. Register Android app with package `com.taleem.taleem`
3. Download `google-services.json` → `android/app/google-services.json`
4. Register iOS app with bundle identifier (default from Xcode project)
5. Download `GoogleService-Info.plist` → `ios/Runner/GoogleService-Info.plist`
6. Enable Authentication (Email/Password + Google)
7. Enable Firestore Database
8. Enable Crashlytics, Analytics, Remote Config, App Check as needed

## Build Commands

```bash
# Development
flutter run
flutter run --debug

# Android Release
flutter build apk --release
flutter build appbundle --release

# iOS Release
flutter build ios --release
flutter build ipa --release

# Analysis & Tests
flutter analyze
flutter test

# Clean
flutter clean
flutter pub get
```

## Git Workflow

### Branch Strategy
- `main` — production-ready, protected
- `develop` — integration branch
- `feature/*` — new features
- `fix/*` — bug fixes
- `release/*` — release candidates

### Commit Messages
```
type(scope): brief description

Types: feat, fix, refactor, chore, docs, style, test
Scope: module or file affected
```

### PR Checklist
- [ ] `flutter analyze` passes with zero issues
- [ ] No debug prints, TODOs, or commented-out code
- [ ] No hardcoded secrets or API keys
- [ ] Models have round-trip (fromJson/toJson) tests
- [ ] UI tested on both light/dark themes
- [ ] Firebase collections follow path constants

## Pre-Launch Checklist
- [ ] `google-services.json` added to `android/app/`
- [ ] `GoogleService-Info.plist` added to `ios/Runner/`
- [ ] Keystore generated and `key.properties` filled
- [ ] App icons updated (mipmap for Android, Assets.xcassets for iOS)
- [ ] App name/localized strings verified
- [ ] Firebase App Check enabled in production
- [ ] Crashlytics enabled in production (non-debug)
- [ ] Privacy policy URL set in App Store/Play Store
- [ ] Test accounts removed from seed data
- [ ] `flutter build appbundle --release` succeeds
- [ ] `flutter build ios --release --no-codesign` succeeds
