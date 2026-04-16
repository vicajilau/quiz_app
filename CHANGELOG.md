# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.12.0]

- feat: Added a final onboarding page that lets users generate QR codes for the mobile app store links.
- feat: Added a changelog viewer in Settings that reads CHANGELOG.md and shows only the entries for the current app version.
- fix: Updated AI study component type selector behavior so enabling it selects all component types by default, and it auto-disables when all types are deselected.
- ui: The app now looks correct regardless of the font size set in your device's accessibility settings — text no longer overflows or breaks layouts when a larger system font is configured.
- fix: Prevented a crash when opening Study Mode from Quiz Preview after generating questions with AI by handling missing study chunks safely.
- fix: Fixed file picker behaviour on web loading files.
- fix: Navigation and UI refactor: Mode switching flow between Study and Quiz.
- feat: Added `QuizdyLoading` widget and implemened in whole app.
- feat: Implemented index, cover page, and new look to the extracted pdf.
- feat: Implemented pdf preview dialog in order to save or share it.

## [1.11.0] - 2026-04-01

- fix: Improved Study section editing flow by opening edit directly on page 0, allowing chunk editing before downloading, blocking empty/invalid saves, and marking manually edited created sections as `downloaded` when saved with content.
- feat: Added "Delete Duplicates" button to quiz editor bottom bar, using the same deletion confirmation logic and banner color styling.
- ux: Renamed "Study Mode" button on home screen to "Generate Study with AI" for better clarity, adding the new localization key across all 18 supported languages.
- feat: Added component type filter to the AI study generation dialog, allowing users to select which of the 13 component types the AI should use when generating study content from the component editor.
- feat: Added a new Privacy Policy acceptance screen shown before entering the app.
- feat: Added Study Editor with support for 13 component types, including section titles, paragraphs, key definitions, timelines, comparison tables, and more.
- feat: Added component picker screen in Study Editor, accessible as a full-screen view on mobile and as an inline sidebar panel on desktop.
- feat: Added individual component edit forms that open immediately upon selecting a component type or tapping an existing card.
- ui: Improved Study Editor navigation with a redesigned app bar showing the chapter name and consistent back/close behavior across mobile and desktop.
- ux: Added unsaved changes confirmation dialog when leaving the component editor without saving.
- feat: Added multi-selection mode to the component editor, allowing bulk delete and drag-to-reorder of multiple components at once.
- feat: Added export Study into PDF feature.
- fix: Implemented `Edit` and `Generate` buttons in `Study Sections`.

## [1.10.0] - 2026-03-17

- ui: Added divider to quiz navigation footer, visible only when card content overflows below the footer.
- refactor: Extracted empty state into a reusable `EmptyStateView` widget and applied it to the Quiz Preview and Study Mode index screens.
- feat: Added "Study Mode" button to the Quiz Preview header for direct navigation to Study Mode from the quiz editor.
- ui: Improved dialog footer layout with consistent padding, theme-aware colors, and text overflow handling across multiple dialogs.
- feat: Added support for generating study sections from selected quiz questions in the AI study generation flow, including a dedicated question selector and localized UI text in all supported languages.
- fix: Show AI study generation errors in a persistent confirmation dialog instead of a transient snackbar so network and service errors remain readable.
- feat: Added app version display in Settings appending `-debug` to the version label in non-release builds.
- feat: Added support action in Settings to open GitHub Issues prefilled with app version and platform details.
- ui: Added "Study Your Content" onboarding page (position 2) explaining study sections, AI generation, and material import, with responsive mobile and desktop layouts.

## [1.9.0] - 2026-03-12

- feat: Added section selector in AI generation dialog to generate questions from specific study chunks.
- ui: Redesigned import dialogs (questions and chunks) for mobile — replaced overflowing horizontal actions with a vertical column layout and added directional arrow icons.
- fix: Collapse sidebar by default on mobile when entering a study section.
- feat: Added AI Chat panel to Study Mode, allowing users to ask the AI about the current chapter's content via a sidebar (desktop) or full-screen overlay (mobile).
- feat: Added section import from .quiz files in Study Mode index view, with position selection dialog (beginning/end) and drag & drop support.
- ui: Implemented "New" and "Modified" banner ribbon tags for questions and study sections to visually indicate unsaved changes with a premium aesthetic.
- i18n: Added 5 new languages (Russian, Ukrainian, Georgian, Korean, and Greek) to the supported list, bringing the total to 18.
- feat: Added mode selection dialog (Study/Quiz) when opening .quiz files, with dual-zone drag & drop overlay and deeplink support.
- fix: Migrated deprecated `gemini-3-pro-preview` and `gemini-3-flash-preview` models to their respective `3.1` updates to ensure uninterrupted service.
- ui: Updated option indicator icons to use distinct visual shapes (e.g. rounded square for multiple-choice) instead of generic checkmarks.
- feat: Unified Answer Option styling in Study Mode with Quiz Completed summary, bringing color-coded visual feedback for instant result clarification.
- fix: Expanded click area to include the question title for expanding and collapsing the `QuestionPreviewCard`.
- feat: Added "Paste" button to API key text fields in settings for quicker setup.
- fix: AI Generation dialog now properly saves and restores attached file paths across sessions.
- feat: Enhanced Study Mode with just-in-time AI content generation, lazy loading of chapters, and robust handling of large PDF/document files for a seamless learning experience.
- fix: Allow saving settings even when the AI Assistant is disabled and no API keys are provided.
- feat: Seamless cross-mode navigation between Quiz and Study screens, preserving the back-stack so pressing Back returns to the previous mode.

## [1.8.1] - 2026-02-26

- ui: Updated app icon for all platforms.
- feat: Renamed the application across all platforms to "Quizdy" for consistent branding.

## [1.8.0] - 2026-02-24

- fix: Use proportional essay AI scores and delegate evaluation to bloc for correct JSON parsing.
- fix: Disable/lock essay answer textarea after "Check answer" in Study Mode to prevent modifications during review.
- feat: Renamed the application across all platforms to "QuizLab AI" for consistent branding.
- feat: Defined and replaced all the buttons in order to follow the proper design guidelines.
- feat: Added onboarding flow with 4 screens (Welcome, Start Quiz, Create Questions, AI Features) shown on first launch, with responsive mobile/desktop layouts, skip/back/next navigation, and re-open option from Settings.

## [1.7.0] - 2026-02-23

- feat: Automated AI evaluation for essay questions in Study Mode with automated trigger, persistence across navigation, and navigation locking during processing.
- ui: Fixed error state styling for the "Maximum allowed errors" input field to match other inputs.
- feat: Restructured settings by moving quiz-related options into the quiz start section.
- refactor: Refactored AI Assistant UI to use `AiAssistantTheme` extension and implemented Shift + Enter shortcuts for better multi-line input handling.
- refactor: Removed all Raffle Mode functionality (screens, blocs, models, and routes) as it has been migrated to a separate repository.
- feat: Added initial window size (1024x800) and minimum window size (500x500) for desktop platforms to ensure proper visibility and resizing.
- ui: Improved adaptability of quiz completion buttons "Try Again" and "Retry Errors" on mobile devices to prevent text overflow.
- feat: Added "Paste from clipboard" image attachment support in manual question creation and AI generation dialogs using the `pasteboard` package.
- feat: Disable penalty in Study Mode and add max incorrect answers limit for Exam Mode with auto-termination.
- ui: Added branded loading screen with animated spinner in `index.html` to replace blank white screen during app initialization, with light/dark theme support.
- feat: Allow manual editing of the number of questions in the AI generation dialog via a text field.
- feat: Added "Content Mode" selection (Theory, Exercises,Mixed) to AI generation to refine results and avoid unwanted generic exercises.
- fix: Prevent collapsing a `QuestionPreviewCard` when tapping collapsible content.
- feat: Allow execute a quiz with only-selected questions.
- feat: Set default question count to 5 in AI generation dialog when no preferences exist.
- fix: Ensured "All" (Random) question type is selected by default in the AI generation dialog when no preferences exist.
- feature: Add drag & drop file support for the AI question generation and manual question creation dialogs, with a guard to prevent conflicts with the global .quiz file drop handler.
- fix: Resolved a crash on iOS when saving a new quiz file by ensuring a valid default filename is generated.
- refactor: Upgraded project to Flutter 3.41.0.
- refactor: Migrated iOS app to UIScene lifecycle to ensure compatibility with future iOS versions.
- ui: Auto-scroll bottom action bar to the start when selecting or modifying questions.
- feat: Added AI chat guardrails to keep the study assistant focused on quiz content and prevent off-topic or system-revealing responses.
- feat: Replaced AI Study Assistant modal dialog with a persistent sidebar panel on desktop (collapsible, 400px) and a full-screen slide-in panel on mobile, preserving chat history across questions and layout changes.

## [1.6.0] - 2026-02-11

- feat: Added "Generate questions with AI" button to the home screen for a more direct creation flow.
- feat: Made the home screen scrollable to prevent overflows on small screens and improved overall layout.
- feat: Improved AI generation UX with a centered loading overlay and better button hierarchy.
- fix: Standardized capitalization to "Sentence case" in Portuguese, Italian, French, Catalan, and Galician localizations for a more modern UI.
- fix: Updated "Mixed" question type label to "All" (e.g., "Todos", "Tutti", "Tous") across all languages for better clarity.
- refactor: Changed `FileBloc` to a Singleton to preserve state across screens and resolve navigation issues.
- ui: Complete redesign of the application UI.
- feat: Added multi-selection support for moving and deleting files.
- fix: Improved network error messages by distinguishing between OpenAI and Gemini connection failures and localizing them.
- feat: Added "Resolve Questions" button to the quiz submission dialog for quick access to unanswered questions.
- ui: Made dialog buttons responsive and fixed dialog sizing issues on larger screens.

## [1.5.0] - 2026-02-06

- feat: Added support for Gemini 3 models by refactoring `AiQuestionGenerationService`.
- fix: Resolved Web localization issue where browser language was not being detected correctly.
- feat: Implemented auto-scroll to explanation in Study Mode when checking an answer.
- fix: Improved AI assistant responses to be more focused and concise, avoiding structured sections and self-references.
- feat: Implemented retry button for unexpected error AI Study Mode questions.
- feat: Retrieved exact MIME type from attached file.
- fix: Fixed navigation on web platform.
- fix: Added project analysis rules.

## [1.4.0] - 2026-02-02

- feat: Implemented "Study Mode" with instant feedback and no timer.
- feat: Added visibility toggle for API keys in Settings.
- refactor: Decoupled `SettingsDialog` into smaller components for better maintainability.
- fix: AI Essay Evaluation now respects the student's answer language instead of defaulting to the system language.
- fix: Updated all 14 supported languages to include dynamic language instructions for AI evaluation.
- feat: Refined light/dark theme styles for consistency, enhanced AI icon visibility, and optimized theme configuration.
- feat: Refactored "AI Study Assistant" into a conversational chat interface with history.

## [1.3.0] - 2026-01-29

- feat: Added delete button to questions (in list and edit dialog).
- fix: Hidden delete button in list on mobile devices.
- fix: Visual improvements and corrections.
- fix: Corrected AI behavior for Greek language.
- feat: Added more granularity for AI model selection.
- feat: Added "Keep AI Draft" feature to automatically save text in the AI generation dialog.
- feat: Added configuration option to enable/disable draft persistence in Settings.
- ui: Added "Clear" button to the AI generation text field.
- i18n: Added translations for new feature in all supported languages.

## [1.2.1] - 2026-01-25

- feat: Added LatexText widget for rendering LaTeX equations in questions.
- fix: Resolved responsive layout issues when rendering LaTeX equations.
- test: Added reproduction test for LatexText.
- feat: Upgraded Android Gradle Plugin to 8.13.2.

## [1.2.0] - 2026-01-20

- feat: Added support for Latex rendering in questions (thanks to @emnik)
- feat: Added Greek language support
- fix: Fixed default language fallback issue (preventing Arabic from being the default on unsupported locales)

## [1.1.3] - 2025-10-21

- fix: Preserve participant text during raffle reset and improve text field initialization
- feat: Implement reset and clear winners dialogs in raffle screen.

## [1.1.2] - 2025-09-30

- Updated all platform versions to maintain consistency across stores

## [1.1.1] - 2025-09-29

- Added local image support with file picker for JPG, PNG, GIF, WebP, and SVG formats
- Implemented persistent logo storage using SharedPreferences with base64 encoding
- Enhanced AppBar with clickable title for intuitive logo selection (replaced separate button)
- Added automatic file size validation with user warnings for oversized images
- Integrated flutter_svg for dedicated SVG rendering support
- Improved logo management with unified LogoWidget for consistent rendering
- Added tooltip guidance for logo selection functionality
- Simplified RaffleStorageService API with cleaner method naming
- Enhanced RaffleLogo model with automatic format detection
- Removed deprecated NetworkImageWidget in favor of unified approach

## [1.1.0+5] - 2025-09-21

### Added

- **Raffle System**: Complete raffle/lottery functionality for participant selection

  - Interactive participant management with add, edit, and delete capabilities
  - Animated winner selection with smooth transitions and visual effects
  - Multiple winner selection support with position tracking (1st, 2nd, 3rd place)
  - Winners history screen with elegant display and sharing functionality
  - Participant text input with real-time validation and duplicate detection

- **Custom Logo Support**: Brand personalization for raffle events

  - Logo URL input with real-time preview and validation
  - Dynamic AppBar integration showing logo or text based on configuration
  - Logo display across raffle and winners screens for consistent branding
  - Error handling with graceful fallback to text display

- **Comprehensive Localization**: Full internationalization for raffle features

  - Complete translations across 13 languages for all raffle functionality
  - Localized winner position labels (1st, 2nd, 3rd place)
  - Multilingual support for sharing and results export
  - Consistent terminology across all raffle-related features

- **Results Sharing**: Export and share raffle results
  - Clipboard integration for easy result copying
  - Formatted text output with winner positions and timestamps
  - Share dialog with preview of results before copying
  - Success feedback for user actions

## [1.0.1+4] - 2025-08-15

### Changed

- Localization: Removed "Google" prefix from Gemini references in all languages.
- Localization: Clarified OpenAI descriptions to explicitly mention OpenAI instead of general AI.
- Settings screen: Improved mobile readability by moving helper texts outside fields and allowing more lines for better display.
- Settings screen: Removed visual truncation; helper texts now display fully.
- File loading: Fixed issue with .quiz file filtering by removing the filter for correct file loading.
- Upgraded to Flutter 3.35.
- Fixed deprecation warnings related to Radio widget usage and other Flutter API changes.

## [1.0.0+3] - 2025-08-05

### Added

- **AI Question Generation with Word Count Validation**: Enhanced AI question generation dialog with minimum word requirements

  - Added 50-word minimum requirement for AI question generation
  - Visual word count feedback with color-coded indicators (red/orange/green)
  - Real-time word counting with progress display
  - Dynamic button state based on word count and AI service availability

- **Comprehensive Internationalization Support**: Added localization for AI features across 13 languages

  - New localization keys for word count validation messages
  - Support for dynamic text with placeholders (word counts, progress indicators)
  - Languages supported: English, Spanish, French, German, Italian, Portuguese, Catalan, Basque, Galician, Hindi, Chinese (Simplified), Arabic, Japanese

- **AI Service Status Integration**: Improved AI assistant status checking
  - AI assistant enablement validation before service loading
  - Proper handling of disabled AI assistant state
  - User-friendly messaging when AI features are unavailable

### Enhanced

- **Dialog User Experience**: Improved AI question generation dialog interface

  - Better visual feedback for content requirements
  - More intuitive button states and validation
  - Enhanced service selection with status indicators
  - Improved error messaging and user guidance

- **Code Documentation**: Updated all code comments to English
  - Standardized documentation language across the codebase
  - Improved code maintainability and readability
  - Better developer experience for international contributors

### Technical Improvements

- **Configuration Service**: Enhanced AI assistant configuration management

  - Better state management for AI enablement
  - Improved API key validation and storage
  - More robust service availability checking

- **Localization Infrastructure**: Strengthened internationalization framework
  - Added comprehensive .arb file translations
  - Proper placeholder handling for dynamic content
  - Consistent translation quality across all supported languages

### Fixed

- **Word Count Logic**: Resolved issues with minimum word requirements

  - Accurate word counting algorithm implementation
  - Proper validation before AI service calls
  - Consistent behavior across different content types

- **Service Integration**: Improved AI service connectivity
  - Better error handling for service unavailability
  - More reliable service status detection
  - Enhanced user feedback for service issues

### Developer Experience

- **Code Quality**: Improved codebase maintainability

  - Consistent code documentation in English
  - Better separation of concerns in dialog implementation
  - Enhanced error handling and validation

- **Internationalization**: Comprehensive localization support
  - Easy addition of new languages
  - Consistent translation patterns
  - Proper handling of pluralization and dynamic content
