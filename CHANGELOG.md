# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.1+3] - 2025-08-15

### Changed

- Localization: Removed "Google" prefix from Gemini references in all languages.
- Localization: Clarified OpenAI descriptions to explicitly mention OpenAI instead of general AI.
- Settings screen: Improved mobile readability by moving helper texts outside fields and allowing more lines for better display.
- Settings screen: Removed visual truncation; helper texts now display fully.
- File loading: Fixed issue with .quiz file filtering by removing the filter for correct file loading.
- Upgraded to Flutter 3.35.
- Fixed deprecation warnings related to Radio widget usage and other Flutter API changes.

## [1.0.0+2] - 2025-08-05

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
