## Project Overview

**Quizdy** is a Flutter/Dart cross-platform interactive quiz application (Android, iOS, macOS, Windows, Linux, Web).
It uses Material Design 3, BLoC/Cubit state management, GoRouter navigation, Clean Architecture, and integrates AI-powered question generation.

---

## Agent Strategy

As an AI agent, your primary mission is to maintain the architectural integrity of the project while delivering feature updates.

### 1. Research First
Always use `find_by_name` or `grep_search` to find existing patterns before creating something new. The project likely already has a pattern for what you are doing.

### 2. Follow Workflows
Before performing an action, check `.agents/workflows/`. If a workflow exists for your task (e.g., `check-theme-compliance`, `implement-pencil-design`), you **MUST** follow it rigorously.

### 3. Proactive Static Analysis
Never consider a task "done" without running `flutter analyze`. Fix all warnings immediately.

---

## Commands

All commands use the standard `flutter` CLI — there is no npm/yarn/package.json.

### Dependencies
```bash
flutter pub get          # install / restore dependencies
flutter pub upgrade      # upgrade packages
```

### Development
```bash
flutter run              # run in debug mode with hot reload
flutter run --release    # run in release mode
```

### Lint & Static Analysis
```bash
flutter analyze          # run the Dart analyzer (analogous to eslint)
```

### Tests
```bash
flutter test                                  # run all tests
flutter test test/widget_test.dart            # run a single test file
flutter test --name "my test description"     # run a single test by name
flutter test --tags smoke                     # run tests with a specific tag
```

### Build
```bash
flutter build apk        # Android
flutter build ios         # iOS
flutter build macos       # macOS
flutter build windows     # Windows
flutter build linux       # Linux
flutter build web         # Web
```

### Localizations (code generation)
```bash
flutter gen-l10n         # regenerate lib/core/l10n/app_localizations*.dart from ARB files
```

The CI pipeline runs: `flutter pub get` → `flutter analyze` → `flutter test` → `flutter gen-l10n` → translation completeness check → GPL-3.0 license header check.

---

## Workflow & Commits

- **Never commit any change without explicit user review and approval.**
- Before committing, always present a summary of the changes and, if requested, the full diff to the user. Note: all commit messages and descriptions must be in **English**.
- Ensure all tests pass (`flutter test`) and the analyzer is clean (`flutter analyze`) before proposing a commit.
- Follow the commit message convention: `type(scope): description` (e.g., `feat(ui): add difficulty toggle`).
- Do not push to remote or create PRs without explicit user approval (see `create-github-issue-or-pr` workflow).

---

## Architecture

The project follows **Clean Architecture** with these layers:

```
lib/
├── core/              # Shared infrastructure: theme, localizations, service locator, security, constants, extensions
│   ├── l10n/          # ARB files + generated AppLocalizations (14 locales)
│   ├── theme/         # AppTheme + ThemeExtensions (CustomColors, HomeTheme, FileLoadedTheme, etc.)
│   ├── security/      # Security utilities
│   ├── constants/     # App-wide constants
│   └── extensions/    # Dart/Flutter extension methods
├── data/              # Implementations: services, repositories, interceptors
│   ├── services/
│   │   ├── ai/        # AI integrations: OpenAI, Gemini, question generation, document chunking, JIT processing
│   │   ├── file_service/  # Platform-specific file I/O (mobile/desktop vs web)
│   │   ├── configuration_service.dart
│   │   └── quiz_service.dart
│   ├── repositories/  # QuizFileRepository
│   └── interceptors/  # Dio interceptors (AI logging)
├── domain/            # Pure Dart models and use cases
│   ├── models/
│   │   ├── quiz/      # QuizFile, Question, QuizConfig, QuizMetadata, Slide, Study, StudyChunk, etc.
│   │   ├── ai/        # AiFileAttachment, AiGenerationConfig, AiDifficultyLevel, ChatMessage, etc.
│   │   └── custom_exceptions/
│   └── use_cases/     # CheckFileChangesUseCase, InitializeQuizChunksUseCase, ValidateQuestionUseCase
├── presentation/      # BLoC/Cubits, screens, and widgets
│   ├── blocs/         # Logic layer (Events/States)
│   ├── screens/       # Main navigation targets
│   │   ├── widgets/   # Screen-specific widgets
│   │   └── ...
│   ├── widgets/       # Global/Reusable widgets
│   │   ├── common/    # Base generic widgets
│   │   ├── study/     # Components for Study Mode
│   │   └── ...
│   └── utils/         # UI-only utilities
└── routes/            # GoRouter definition
```

---

## Code Style

### Dart Formatting
Dart formatting is handled by `dart format` (opinionated, not configurable). Run it before committing.
```bash
dart format lib/ test/
```

### Import Order
Follow the standard Dart import grouping, in this order:
1. `dart:` core libraries (`dart:math`, `dart:convert`, etc.)
2. `package:flutter/` framework imports
3. Third-party packages (`package:flutter_bloc/`, `package:go_router/`, etc.)
4. Internal project imports (`package:quizdy/...`) — ordered infrastructure-outward: core → data → domain → presentation

### Naming Conventions

| Element | Convention | Example |
|---------|-----------|---------|
| Classes | `UpperCamelCase` | `FileBloc`, `QuizExecutionBloc` |
| Files | `snake_case` | `quiz_file.dart`, `app_theme.dart` |
| Variables / params | `lowerCamelCase` | `isCorrect`, `quizFile` |
| Private members | `_lowerCamelCase` | `_questions`, `_configService` |
| Private widget subclasses (within a file) | `_UpperCamelCase` | `_QuestionCard`, `_TimerDisplay` |
| BLoC event classes | Imperative verb phrases | `LoadQuizFile`, `SubmitAnswer` |
| BLoC state classes | Past participles / adjectives | `FileLoaded`, `QuizExecutionInProgress` |
| Route path constants | `static const String` in `AppRoutes` class | `AppRoutes.home = '/'` |

### Widget Patterns
- Prefer `StatelessWidget`. Use `StatefulWidget` only when local widget lifecycle is needed (e.g., `AnimationController`, `TextEditingController`).
- Always use `const` constructors where possible: `const HomeScreen({super.key})`.
- Split large widgets into **private sub-widgets** within the same file using `_ClassName` naming.
- Use immutable models with `copyWith`.

### State Management (BLoC)
- **Prefer `Cubit` over full `Bloc`** when creating new state managers. Use `Bloc` (events + states) only when the added traceability of discrete events is genuinely needed (e.g., complex async flows, event debouncing/throttling, or event-to-event transformations). For straightforward state changes, `Cubit` is simpler and sufficient.
- `context.read<Bloc>()` for one-shot reads / dispatching events.
- `BlocBuilder` for reactive UI rebuilds.
- `BlocListener` for side effects (snackbars, navigation).
- `BlocConsumer` when both rebuild and side effects are needed.
- BLoCs/Cubits are provided at the top of the widget tree via `MultiBlocProvider` in `main.dart`.

### Dependency Injection
- Uses `get_it` via the `ServiceLocator` wrapper class (`lib/core/service_locator.dart`).
- Access services with `ServiceLocator.getIt<ServiceType>()`.
- Platform-specific services (e.g., file service) are resolved at compile time via conditional imports.

### Routing
- Use `context.go(AppRoutes.xxx)` (GoRouter's `BuildContext` extension).
- All route path strings live in `AppRoutes` static constants (`lib/routes/app_router.dart`).
- Routes: `/` (home), `/onboarding`, `/file_loaded_screen`, `/quiz_file_execution_screen`, `/study_screen`.

### Theme & Colors
- **ZERO TOLERANCE for hardcoded colors.** Never use hexadecimal codes (`0xFF...`) or standard `Colors.xxx` constants directly in widgets.
- **Always use `ThemeExtension`**. If a UI component needs specific colors not available in the standard `ColorScheme`, you **MUST** create a new `ThemeExtension` or update an existing one (e.g., `StudyThemeExtension`).
- **Use semantic tokens**: Access colors via context helper extensions like `context.appColors` or `context.studyTheme`.
- The color palette uses Zinc/violet naming (matching Tailwind CSS conventions) defined in `AppTheme`.
- Existing `ThemeExtension`s: `CustomColors`, `HomeTheme`, `FileLoadedTheme`, `QuestionDialogTheme`, `ExamTimerTheme`, `AiAssistantTheme`, `ConfirmDialogColorsExtension`, `StudyThemeExtension`.
- Theme-aware widgets must respond to both light and dark `ThemeData`.
- Typography: uses `google_fonts` (Inter).

### Localization
- All user-visible strings must use `AppLocalizations.of(context)!.someKey`.
- Never hardcode UI strings in widget code.
- Add new strings to `lib/core/l10n/app_en.arb` (the template), then run `flutter gen-l10n`.
- Translations for other locales live in `app_<locale>.arb` files in the same directory.
- Supported locales: ar, ca, de, el, en, es, eu, fr, gl, hi, it, ja, pt, zh.

### Error Handling
- BLoC event handlers: wrap in `try/catch` and emit an error state on failure.
- Storage operations: return `bool` or nullable types (`Future<T?>`) rather than throwing.
- Debug logging: use `printInDebug(...)` (project utility in `lib/core/debug_print.dart`).
- UI error surfacing: use `SnackBar` triggered by `BlocListener`.

### Common Agent Pitfalls (AVOID THESE)
- **Hardcoding Hex Colors**: Use `StudyThemeExtension` or `CustomColors` instead. Run `/check-theme-compliance` to verify.
- **Hardcoding Font Families in Widgets**: Do not add `fontFamily: 'Inter'` directly in UI widgets. Use `Theme.of(context).textTheme` (or theme extensions) and keep typography theme-driven.
- **Missing License Headers**: Check `Phase 5` of any implementation plan to ensure headers are added.
- **Inconsistent Imports**: Always order them: Dart -> Flutter -> Packages -> Project.
- **Large Widget Methods**: Split `build` methods into private sub-widgets (`_MySubPart`).
- **Ignoring Analysis**: `flutter analyze` is your source of truth for code quality.

### Pencil Design Implementation Rule
- For any implementation derived from `.pen` files, run the `implement-pencil-design` workflow first.
- If the design includes both light and dark variants, both variants must be implemented in the same change.

---

## License Headers

> [!CAUTION]
> **CRITICAL RULE FOR AI AGENTS:** Every SINGLE `.dart` file you create (except generated localization files) **MUST** begin with the GPL-3.0 license header. Do not skip this under any circumstances. If you create a new file, the very first lines must be this exact header. This is enforced by CI.

The header looks like exactly like this:

```dart
// Copyright (C) 2026 Víctor Carreras
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
```


---

## Key Dependencies

| Package | Purpose |
|---------|---------|
| `flutter_bloc` v9 | BLoC + Cubit state management |
| `go_router` v17 | Declarative routing |
| `get_it` v9 | Service locator / dependency injection |
| `shared_preferences` | Local persistence (settings, onboarding) |
| `dio` | HTTP client for AI API calls |
| `file_picker` + `path_provider` | File I/O |
| `desktop_drop` | Drag & drop file support |
| `flutter_svg` | SVG asset rendering |
| `google_fonts` | Inter typography |
| `lucide_icons` | Icon set |
| `gpt_markdown` + `flutter_math_fork` | Markdown & LaTeX rendering in study mode |
| `url_launcher` | Opening external URLs |
| `platform_detail` | Platform detection |
| `mime` | MIME type detection for file handling |
| `crypto` | Hashing utilities |
| `http` | HTTP client (secondary) |
| `pasteboard` | Clipboard image support |
| `cross_file` | Cross-platform file abstraction |
| `collection` | Advanced collection utilities |

---

## Testing

- Test files follow the `*_test.dart` naming pattern and live under `test/`.
- Test structure mirrors `lib/`: `test/data/`, `test/domain/`, `test/presentation/`, `test/helpers/`.
- Use `testWidgets(...)` with a `WidgetTester tester` parameter for Flutter widget tests.
- Dependencies: `flutter_test`, `bloc_test` v10, `mocktail` v1.
- Use `mocktail` for mocking services and repositories in tests.
- Use `blocTest(...)` from `bloc_test` for testing BLoC event → state transitions.
- Wrap tested widgets in `MultiBlocProvider` with mock BLoCs/Cubits when testing widgets that depend on state.

---

## Custom File Format

Quizdy uses a custom `.quiz` file format for saving and loading quiz data. The app registers as a handler for `.quiz` files on all platforms, supporting:
- File picker import
- Drag & drop (via `desktop_drop`)
- Deeplink / file association opening

---

## AI Integration

The app integrates with **OpenAI** and **Google Gemini** APIs for:
- Automatic question generation from documents
- Document chunking and processing
- Study content generation with configurable difficulty levels and generation modes

AI services are abstracted behind `AiServiceSelector` which routes to the appropriate provider (`OpenaiService` or `GeminiService`). API calls go through `Dio` with a custom `AiLoggingInterceptor`.
