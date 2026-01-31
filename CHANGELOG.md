# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.5.0] - 2026-01-31

- refactor: Decoupled `QuizQuestionResultCard` into smaller, manageable widgets (`QuizQuestionImage`, `QuizQuestionOptionsResult`, `QuizQuestionEssayResult`, `QuizQuestionExplanation`).
- fix: AI Essay Evaluation now respects the student's answer language instead of defaulting to the system language.
- fix: Updated all 14 supported languages to include dynamic language instructions for AI evaluation.

## [1.4.0] - 2026-01-29

- ui: Refined light/dark theme styles for consistency, enhanced AI icon visibility, and optimized theme configuration.
- ui: Improved "AI Study Assistant" window scrolling to allow scrolling the entire dialog content.

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
