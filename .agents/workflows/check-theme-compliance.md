---
description: Check for hardcoded colors and ensure theme extension compliance
---

This workflow helps detect and fix hardcoded hexadecimal colors or direct use of `Colors.xxx` in UI code, ensuring everything uses `ThemeExtension`.

### Steps to follow:

1. **Search for hardcoded colors**:
   Execute a search across `lib/` for hexadecimal patterns and standard color constants:
   - Regex search: `0x[a-fA-F0-9]{8}`
   - Keyword search: `Colors\.` (excluding `Colors.transparent` and `Colors.white`/`Colors.black` if used for pure logic)

2. **Identify the context**:
   For each match, determine if it's a UI property (fill, text color, border, etc.) of a widget.

3. **Check for existing tokens**:
   - Inspect `lib/core/theme/extensions/` to see if there is an existing `ThemeExtension` property that matches the purpose (e.g., `StudyThemeExtension.cardBackground`).
   - Check `lib/core/theme/app_theme.dart` to see how these extensions are initialized.

4. **Migrate to theme tokens**:
   - **If a token exists**: Replace the hardcoded color with `context.<extensionName>.<propertyName>`. Ensure the extension is imported.
   - **If no token exists**: 
     - Add a new property to the relevant `ThemeExtension` class.
     - Update the constructor and `copyWith`/`lerp` methods.
     - Register the new color value in both `lightTheme` and `darkTheme` inside `lib/core/theme/app_theme.dart`.
     - Use the new token in the widget.

// turbo
5. **Verify changes**:
   - Run `flutter analyze` to ensure no typing or import errors.
   - Run `flutter test` to ensure UI behavior remains stable.

6. **Format**:
   Run `dart format lib/` to clean up the code.
