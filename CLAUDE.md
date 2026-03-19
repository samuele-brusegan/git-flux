# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**FluxGit** is a Flutter-based Git client targeting Linux desktop and Android. It uses libgit2 via FFI (`git2dart`) for Git operations, BLoC for state management, and Isar for local data persistence.

## Architecture

```
lib/
├── main.dart                          # App entry point
├── app.dart                           # Root widget with BLoC providers
├── core/
│   ├── bloc_observer.dart             # BLoC debugging observer
│   ├── theme/app_theme.dart           # Dark theme configuration
│   ├── router/app_router.dart         # GoRouter setup
│   ├── errors/ffi_error_handler.dart  # libgit2 error handling
│   └── utils/                         # Shared utilities
├── data/
│   ├── models/                        # Isar schemas (Account, RepositoryMeta)
│   ├── services/
│   │   ├── auth_service.dart          # OAuth2 + secure storage
│   │   ├── database_service.dart      # Isar initialization
│   │   └── git_service.dart           # libgit2dart wrapper
│   └── providers/                     # API clients (GitHub, GitLab, Gitea)
├── features/
│   ├── auth/                          # Multi-account authentication
│   │   ├── bloc/
│   │   ├── views/
│   │   └── widgets/
│   ├── repository/                    # Git operations UI
│   │   ├── bloc/
│   │   ├── views/
│   │   └── widgets/
│   ├── terminal/                      # Embedded terminal (xterm)
│   │   └── views/
│   └── academy/                       # Educational content
│       └── views/
└── widgets/                           # Shared UI components
```

## Key Dependencies

| Package | Purpose |
|---------|---------|
| `flutter_bloc` | State management (BLoC pattern) |
| `git2dart` + `git2dart_binaries` | libgit2 FFI bindings |
| `isar_community` + `isar_community_flutter_libs` | Local database |
| `flutter_secure_storage` | OAuth token storage |
| `go_router` | Declarative routing |
| `xterm` | Terminal emulator |
| `equatable` | Value equality for BLoC states |
| `freezed` + `json_serializable` | Code generation |

## Development Commands

### Build & Run
```bash
flutter run                    # Run on default device
flutter run -d linux           # Run on Linux desktop
flutter run -d android         # Run on Android
flutter build linux            # Build Linux release
flutter build apk              # Build Android APK
```

### Code Quality
```bash
flutter analyze                # Static analysis
flutter test                   # Run all tests
flutter test test/features/    # Run feature-specific tests
```

### Code Generation
```bash
dart run build_runner build --delete-conflicting-outputs     # Generate freezed/isar/json files
dart run build_runner watch --delete-conflicting-outputs     # Watch mode
```

### Dependency Management
```bash
flutter pub get              # Install dependencies
flutter pub upgrade          # Upgrade dependencies
flutter pub outdated         # Check for outdated packages
```

## Implementation Status

The codebase is actively being developed following an implementation plan (`implementation_plan.md`). Core features implemented:
- Phase 0: Environment setup complete (Flutter project initialized)
- Phase 1: Theme, router, and error handling foundation
- Phase 2: Multi-account auth (GitHub, GitLab, Gitea)
- Phase 3: Repository management (staging, diff, commit graph)
- Phase 4-5: Terminal and Academy features in progress

## Important Notes

- **Database**: Uses `isar_community` fork (v3.3.0) instead of unmaintained `isar` package
- **Git operations**: All libgit2 calls wrapped through `FfiErrorHandler` to prevent crashes
- **State management**: BLoC pattern with `Equatable` for value equality
- **Models**: Generated via `freezed` (immutable) and `isar_generator` (database schemas)
