# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
make setup          # Install deps, run build_runner, generate localizations
make analyze        # flutter analyze --no-fatal-infos
make test           # Run all unit and widget tests
make clean          # flutter clean
make clean-l10n     # Remove duplicate keys from .arb files

# Android
make apk            # Release APK
make aab            # App Bundle for Play Store

# iOS
make ipa            # Release IPA (requires Xcode)
```

To run a single test file:
```bash
flutter test test/features/sessions/cubit/session_cubit_test.dart
```

After modifying any model with `@JsonSerializable` or `@freezed`:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## Architecture

**Playing Tracker** is a musical practice tracking app for students and teachers, backed by Firebase.

### Layers (Clean Architecture, feature-first)

```
lib/
├── config/routes/       # GoRouter with reactive role-based guards (Student vs Teacher)
├── config/theme/        # Material Design 3 theme (light/dark, ColorScheme.fromSeed)
├── core/                # Constants, extensions, validators, Firebase error mapper
├── features/            # Feature modules (auth, classes, home, sessions, tasks, statistics, settings)
├── shared/widgets/      # Reusable UI components (CustomAppBar, CustomButton, CustomCard, etc.)
├── l10n/                # ARB localization files (English + Spanish)
└── main.dart            # Entry point, DI setup
```

Each feature follows:
```
feature/
├── data/repositories/   # Firebase-backed implementations
├── domain/              # Models, abstract repository interfaces, enums
└── presentation/
    ├── cubit/           # State management
    ├── screens/
    └── widgets/
```

### State Management

- **Cubit** (from `flutter_bloc`) is the primary pattern — avoid raw BLoC unless complex event mapping is needed.
- **HydratedBloc** is used for Cubits that need automatic persistence across app restarts.
- `AppBlocObserver` in `core/config/` handles logging.

### Navigation

GoRouter (`config/routes/`) with route guards based on auth state and user role (student vs. teacher). The router refreshes reactively via a `RouterRefreshStream` when auth/role state changes.

### Firebase

Firestore is the primary database. Repository interfaces live in `domain/repositories/`; Firebase implementations live in `data/repositories/`. Firebase errors are mapped to domain-level errors via `core/utils/firebase_error_mapper.dart`.

## Key Conventions

- **Colors:** Use Material Design 3 tokens (`Theme.of(context).colorScheme.*`). Never hardcode hex colors. Use `.withValues(alpha: X)` instead of deprecated `.withOpacity()`.
- **Spacing/Radius:** Use constants from `core/constants/` — do not hardcode numbers inline.
- **Localization:** All user-facing strings must use `context.l10n.*`. Keep `app_en.arb` and `app_es.arb` in sync.
- **Validation:** Form validation goes in `core/utils/validators.dart`; business rule validation in `core/utils/domain_validators.dart`.
- **Development plans:** Write in Spanish.
- **Testing instructions:** Each plan must include Android (student role) and iOS (teacher role) manual testing steps.
